#!/bin/bash
# ============================================================
# wordlists.sh - Wordlists recomendadas por escenario
# Para HTB Recon Guiado
# ============================================================

# ============================================================
# DIRECTORIOS / PATHS
# ============================================================

WL_DIRS() {
    cat << 'EOF'
  === WORDLISTS PARA FUZZING DE DIRECTORIOS ===

  [1] COMMON (rapido, top 4000):
      /usr/share/wordlists/dirb/common.txt

  [2] BIG (mas completo):
      /usr/share/wordlists/dirb/big.txt

  [3] DIRECTORY-LIST (DNS/HTTP fuzzing):
      /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt
      /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

  [4] SECLISTS (el mejor recurso):
      /usr/share/seclists/Discovery/Web-Content/common.txt
      /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt
      /usr/share/seclists/Discovery/Web-Content/raft-small-directories.txt
      /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt
      /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt

  [5] FOCUSED (archivos especificos):
      /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt
      /usr/share/seclists/Discovery/Web-Content/parameters.txt
      /usr/share/seclists/Discovery/Web-Content/spring-boot.txt
      /usr/share/seclists/Discovery/Web-Content/api-endpoints.txt

  [WORDLIST PARA EXTENSIONES]:
      php,html,txt,bak,old,zip,conf,config,sql,xml,json,log,sh,py,rb,pl,asp,aspx,jsp

  [COMANDO RECOMENDADO]:
      gobuster dir -u http://TARGET/ -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt -x php,html,txt,bak,old,zip,conf -t 50
EOF
}

# ============================================================
# SUBDOMINIOS
# ============================================================

WL_SUBDOMAINS() {
    cat << 'EOF'
  === WORDLISTS PARA SUBDOMINIOS ===

  [1] TOP 5000 (rapido):
      /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

  [2] TOP 20000:
      /usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt

  [3] TOP 110000:
      /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt

  [4] DNS RECON:
      /usr/share/seclists/Discovery/DNS/dns-Jhaddix.txt

  [5] RAFT:
      /usr/share/seclists/Discovery/DNS/raft-large-domains.txt
      /usr/share/seclists/Discovery/DNS/raft-small-domains.txt

  [COMANDO RECOMENDADO]:
      gobuster dns -d target.htb -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -r TARGET -t 50
EOF
}

# ============================================================
# PASSWORDS
# ============================================================

WL_PASSWORDS() {
    cat << 'EOF'
  === WORDLISTS PARA PASSWORDS ===

  [1] ROCKYOU (clasico, ~14M passwords):
      /usr/share/wordlists/rockyou.txt

  [2] SECLISTS TOP PASSWORDS:
      /usr/share/seclists/Passwords/Common-Credentials/top-20-common-SSH-passwords.txt
      /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt
      /usr/share/seclists/Passwords/Common-Credentials/100k-most-common.txt

  [3] DEFAULT PASSWORDS:
      /usr/share/seclists/Passwords/Default-Credentials/default-passwords.csv
      /usr/share/seclists/Passwords/Default-Credentials/biometric-defaults.txt

  [4] LEAKED PASSWORDS:
      /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz

  [5] FPGA/BRUTE FORCE:
      /usr/share/wordlists/rockyou.txt
      /usr/share/seclists/Passwords/Leaked-Databases/caffeine.txt

  [COMANDO RECOMENDADO]:
      hydra -l user -P /usr/share/wordlists/rockyou.txt TARGET ssh -t 4
EOF
}

# ============================================================
# USUARIOS
# ============================================================

WL_USERS() {
    cat << 'EOF'
  === WORDLISTS PARA USUARIOS ===

  [1] USUARIOS COMUNES:
      /usr/share/seclists/Usernames/top-usernames-shortlist.txt
      /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt

  [2] DEFAULT USERS:
      /usr/share/seclists/Usernames/Default-Credentials/default-usernames.txt

  [3] GENERAR USUARIOS (basado en target):
      # Permutaciones del hostname:
      # target.htb -> target, admin, administrator, administrator1
      # target.htb -> svc_target, target_svc, target_admin
      # target.htb -> t, tht, tgt

  [4] HTB ESPECIFICO:
      # Muchas boxes usan usuarios como:
      # administrator, admin, administrator1, user, guest
      # svc_*, *_svc, *_adm, it_*, dev_*

  [SCRIPT DE GENERACION]:
      echo "target" | sed 's/.*/\L&/' > users.txt
      echo "target" | sed 's/.*/\u&/' >> users.txt
      echo "administrator" >> users.txt
      echo "admin" >> users.txt
      echo "svc_target" >> users.txt
      echo "target_svc" >> users.txt
EOF
}

# ============================================================
# VIRTUAL HOSTS
# ============================================================

WL_VHOSTS() {
    cat << 'EOF'
  === WORDLISTS PARA VIRTUAL HOSTS ===

  [1] SECLISTS:
      /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
      /usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt

  [2] CUSTOM (basado en target):
      # target.htb -> www, mail, ftp, smtp, admin, webmail, etc.

  [COMANDO RECOMENDADO]:
      gobuster vhost -u http://target.htb -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -t 50
EOF
}

# ============================================================
# FUZZING PARAMETROS
# ============================================================

WL_PARAMS() {
    cat << 'EOF'
  === WORDLISTS PARA FUZZING DE PARAMETROS ===

  [1] PARAMETROS COMUNES:
      /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt
      /usr/share/seclists/Discovery/Web-Content/parameters.txt

  [2] API ENDPOINTS:
      /usr/share/seclists/Discovery/Web-Content/api/endpoints.txt
      /usr/share/seclists/Discovery/Web-Content/swagger.txt

  [3] SPRING BOOT:
      /usr/share/seclists/Discovery/Web-Content/spring-boot.txt

  [4] FUZZING UNIVERSAL:
      /usr/share/seclists/Fuzzing/alphanum-case.txt
      /usr/share/seclists/Fuzzing/special-chars.txt

  [COMANDO RECOMENDADO]:
      ffuf -u http://TARGET/FUZZ -w /usr/share/seclists/Discovery/Web-Content/parameters.txt -fc 404
      wfuzz -c -z file,/usr/share/seclists/Discovery/Web-Content/parameters.txt http://TARGET/FUZZ
EOF
}

# ============================================================
# CMS ESPECIFICO
# ============================================================

WL_WORDPRESS() {
    cat << 'EOF'
  === WORDLISTS PARA WORDPRESS ===

  [PLUGIN/TEMA WORDLISTS]:
      /usr/share/seclists/Discovery/Web-Content/CMS/wordpress-plugins.txt
      /usr/share/seclists/Discovery/Web-Content/CMS/wordpress-themes.txt

  [WP-CONTENT FUZZING]:
      /usr/share/wordlists/dirb/common.txt
      # Extensiones: php, txt, log, bak

  [COMANDO RECOMENDADO]:
      wpscan --url http://TARGET/ --enumerate ap,at,u
      gobuster dir -u http://TARGET/wp-content/plugins/ -w /usr/share/seclists/Discovery/Web-Content/CMS/wordpress-plugins.txt -t 50
EOF
}

WL_JOOMLA() {
    cat << 'EOF'
  === WORDLISTS PARA JOOMLA ===

      /usr/share/seclists/Discovery/Web-Content/CMS/joomla-plugins.txt
      /usr/share/seclists/Discovery/Web-Content/CMS/joomla-themes.txt

  [COMANDO RECOMENDADO]:
      joomscan -u http://TARGET/
EOF
}

WL_DRUPAL() {
    cat << 'EOF'
  === WORDLISTS PARA DRUPAL ===

      /usr/share/seclists/Discovery/Web-Content/CMS/drupal-modules.txt
      /usr/share/seclists/Discovery/Web-Content/CMS/drupal-themes.txt

  [COMANDO RECOMENDADO]:
      droopescan scan drupal -u http://TARGET/
EOF
}

# ============================================================
# SSH KEYS
# ============================================================

WL_SSHKEYS() {
    cat << 'EOF'
  === BUSQUEDA DE SSH KEYS ===

      find / -name "id_rsa" 2>/dev/null
      find / -name "id_rsa.pub" 2>/dev/null
      find / -name "*.pem" 2>/dev/null
      find / -name "authorized_keys" 2>/dev/null
      find / -name "known_hosts" 2>/dev/null
      find / -name "config" -path "*/.ssh/*" 2>/dev/null

  [SI ENCONTRAS CLAVE PRIVADA]:
      chmod 600 id_rsa
      ssh -i id_rsa user@TARGET
EOF
}

# ============================================================
# ARCHIVOS SENSIBLES
# ============================================================

WL_SENSITIVE_FILES() {
    cat << 'EOF'
  === ARCHIVOS SENSIBLES PARA BUSCAR ===

  [CONFIGURACION]:
      find / -name "*.conf" -o -name "*.cfg" -o -name "*.ini" 2>/dev/null
      find / -name "*.config" -o -name "config.*" 2>/dev/null
      find / -name ".env" -o -name "*.env" 2>/dev/null
      find / -name "wp-config.php" -o -name "config.php" -o -name "settings.py" 2>/dev/null

  [BACKUPS]:
      find / -name "*.bak" -o -name "*.old" -o -name "*.swp" 2>/dev/null
      find / -name "*.sql" -o -name "*.sql.gz" -o -name "*.dump" 2>/dev/null
      find / -name "*.zip" -o -name "*.tar.gz" -o -name "*.7z" 2>/dev/null

  [CREDENCIALES]:
      find / -name "password*" -o -name "passwd*" -o -name "shadow" 2>/dev/null
      find / -name "*.kdbx" -o -name "*.key" -o -name "*.pem" 2>/dev/null
      find / -name ".bash_history" -o -name ".mysql_history" 2>/dev/null
      grep -r "password" /etc/ 2>/dev/null | head -20
      grep -r "password" /var/www/ 2>/dev/null | head -20

  [LOGS]:
      find /var/log -name "*.log" 2>/dev/null
      cat /var/log/auth.log 2>/dev/null
      cat /var/log/syslog 2>/dev/null

  [WEBSHELLS/WEBSERVER]:
      find /var/www -name "*.php" -o -name "*.asp" -o -name "*.aspx" 2>/dev/null
      find /opt -name "*.conf" -o -name "*.yml" -o -name "*.yaml" 2>/dev/null
EOF
}

# ============================================================
# FUNCION PRINCIPAL
# ============================================================

show_wordlists() {
    local category="${1:-all}"
    
    case "$category" in
        dirs|dir|directory|directories) WL_DIRS ;;
        subdomains|sub|dns) WL_SUBDOMAINS ;;
        passwords|pass|pwd) WL_PASSWORDS ;;
        users|user|usuarios) WL_USERS ;;
        vhosts|vhost|virtual) WL_VHOSTS ;;
        params|param|parameters) WL_PARAMS ;;
        wordpress|wp) WL_WORDPRESS ;;
        joomla) WL_JOOMLA ;;
        drupal) WL_DRUPAL ;;
        ssh) WL_SSHKEYS ;;
        sensitive|files|sensibles) WL_SENSITIVE_FILES ;;
        all|*)
            echo -e "${B}${C}=== WORDLISTS POR ESCENARIO ===${W}\n"
            echo "  Categorias disponibles:"
            echo ""
            echo "  [1] dirs       - Directorios y paths"
            echo "  [2] subdomains - Subdominios"
            echo "  [3] passwords  - Contrasenas"
            echo "  [4] users      - Usuarios"
            echo "  [5] vhosts     - Virtual hosts"
            echo "  [6] params     - Parametros"
            echo "  [7] wordpress  - WordPress"
            echo "  [8] joomla     - Joomla"
            echo "  [9] drupal     - Drupal"
            echo "  [10] ssh       - SSH keys"
            echo "  [11] sensitive - Archivos sensibles"
            echo ""
            echo "  Uso: ${0} --wordlist <categoria>"
            echo ""
            ;;
    esac
}
