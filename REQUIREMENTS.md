# Requisitos

## Obligatorios

| Herramienta | Version | Nota |
|-------------|---------|------|
| **bash** | **≥ 4** | Asociativas (`declare -gA`), `${var,,}`, `[[ ]]` |
| **nmap** | — | El núcleo del script; necesitas `sudo` para SYN scan/OS detection |
| coreutils | — | `sort`, `ls`, `cp`, `mv`, `date`, `comm`, `wc`, `getent`, `hostname` |
| **grep** | — | Perl regex (`-P`) requerido internamente |

---

## Opcionales (funcionalidades extra)

| Herramienta | Activa | Requiere |
|-------------|--------|----------|
| **python3** | `--html`, `--update-db` | Conversión a HTML; parser NVD API |
| **curl** | `--update-db`, `--web` | Consultas a NVD API |
| **firefox** | `--web` | Abrir puertos web + configurar `/etc/hosts` |
| **lolcat** | Banner | Colores arcoíris; sin esto funciona con ANSI rainbow |
| **sudo** | Escaneos completos | `nmap -sS`, `-O` y NSE scripts lo requieren |

---

## Comandos generados (recomendados instalar en tu máquina)

El script **no ejecuta** estas herramientas; las **recomienda** en el reporte
para que tú las uses manualmente contra el target.

### Web
```
gobuster nikto whatweb wpscan
```

### Red / SMB / RPC
```
smbclient enum4linux smbmap crackmapexec rpcclient
```

### Brute force
```
hydra medusa
```

### LDAP / AD
```
ldapsearch windapsearch bloodhound-python
```

### Bases de datos
```
redis-cli mongosh psql mysql
```

### Windows
```
impacket-* evil-winrm xfreerdp rubeus mimikatz
```

### Metasploit (para los `.rc` generados)
```
msfconsole msfvenom
```

---

## Wordlists (por defecto)

| Ruta | Paquete |
|------|---------|
| `/usr/share/wordlists/rockyou.txt` | `wordlists` (Kali default) |
| `/usr/share/wordlists/dirb/common.txt` | `dirb` |
| `/usr/share/seclists/Discovery/SNMP/snmp.txt` | `seclists` |

---

## Instalación rápida (Kali/Debian)

```bash
sudo apt update
sudo apt install nmap python3 curl hydra gobuster nikto smbclient enum4linux \
  smbmap crackmapexec whatweb redis-tools mongodb-clients ldap-utils \
  xfreerdp2 freerdp2-x11 powershell-empire bloodhound impacket-scripts \
  wordlists seclists

# Firefox y Metasploit suelen venir preinstalados en Kali.
# Para lolcat (colores del banner, opcional):
sudo apt install lolcat || pip3 install lolcat
```
