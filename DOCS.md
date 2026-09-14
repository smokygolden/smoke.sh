# usame.sh - Documentacion Tecnica Completa

## Resumen General

Script de recon guiado para HTB/Pentesting. Escanea objetivos con nmap, analiza servicios contra una base de conocimiento local, genera reportes automaticos con exploits listos para usar, y ofrece menu interactivo post-escaneo.

**Ubicacion:** `tools/usame.sh` (cualquier directorio, sin rutas absolutas)
**Version actual:** v5.0
**Autor original:** smokygolden

---

## Arquitectura de Archivos

```
tools/
  usame.sh                  # Script principal (bash)
  lib/
    services.sh             # Base de conocimiento: 42+ servicios con pasos, herramientas, vulns
    cve_linux.sh            # CVEs Linux: ~80 entradas con descripcion, exploit, severidad
    cve_windows.sh          # CVEs Windows: ~50 entradas con descripcion, exploit, severidad
    postexploitation.sh     # Funciones: reverse shells, privesc, lateral movement, tools
    default_creds.sh        # Credenciales por defecto: 60+ servicios (web, DB, red, mail, VPN)
    suid_binaries.sh        # Binarios SUID explotables (GTFOBins) + escalada via sudo
    wordlists.sh            # Wordlists por escenario (10 categorias)
```

## Nota critica sobre arrays

Las librerias declaran sus arrays asociativos con **`declare -gA`** (global). Esto es
imprescindible: si se usara `declare -A` normal, al sourcear la libreria DENTRO de la
funcion `load_libraries()`, los arrays se volverian locales a esa funcion y se perderian
al retornar (bug critico corregido en v5.0 que dejo la base de conocimiento vacia).
**Usar siempre `declare -gA` en las nuevas librerias.**

---

## Dependencias del Sistema

- **nmap** (requerido): escaneo de puertos y versiones
- **python3**: actualizacion CVE desde NVD API
- **curl**: consultas a NVD API, pruebas HTTP
- **Herramientas opcionales**: hydra, smbclient, enum4linux, gobuster, nikto, wpscan, crackmapexec, impacket-*, redis-cli, mongosh, ldapsearch, xfreerdp, sqlmap, msfconsole, msfvenom

---

## Variables Globales

| Variable | Descripcion |
|----------|-------------|
| `SCRIPT_DIR` | Directorio del script (`tools/`) |
| `OUTPUT_DIR` | `$USAME_OUTPUT_DIR` si se define, si no `~/*/escaneos` (usa `~/escaneos` o `~/Escritorio/escaneos` existente) - donde se guardan reportes, XMLs, RCs |
| `CVE_DB_DIR` | `$SCRIPT_DIR/lib/` - directorio de librerias |
| `TARGET` | IP objetivo |
| `MODE` | `normal`/`fast`/`full`/`stealth` |
| `XML_FILE` | Path al XML de nmap del escaneo actual |
| `REPORT` | Path al reporte TXT generado |
| `HTML_REPORT` | Path al reporte HTML (si `--html`) |
| `DETECTED_OS` | `linux`/`windows`/`unknown` |
| `DETECTED_AD` | `1` si Active Directory detectado, `0` si no |
| `ALL_PORTS` | Lista espaciada de puertos abiertos |
| `OPEN_COUNT` | Numero total de puertos abiertos |
| `MY_IP` | IP local del atacante |
| `TS` | Timestamp del escaneo actual (`YYYYMMDD_HHMMSS`) |

---

## Uso (CLI)

```bash
# Escaneo basico con menu interactivo
sudo ./usame.sh <target_ip>

# Modos de escaneo
sudo ./usame.sh <target> --fast       # Top 1000 puertos, 5min timeout
sudo ./usame.sh <target> --full       # Todos puertos, scripts agresivos, 30min
sudo ./usame.sh --stealth <target>    # SYN scan, T2, fragmentado, decoys
sudo ./usame.sh <target>              # Default: todos puertos, vulners, 15min

# Auto-explotacion
sudo ./usame.sh <target> --auto       # Escaneo + menu interactivo + auto-exploit

# Batch
sudo ./usame.sh --batch targets.txt   # 1 IP por linea, escanea todas

# Post-procesamiento
sudo ./usame.sh <target> --html       # Exporta HTML con estilos
sudo ./usame.sh <target> --no-scan    # Re-genera reporte desde XML existente mas reciente
sudo ./usame.sh --wordlist <target>   # Genera wordlist basada en el target
sudo ./usame.sh --diff <target>       # Compara 2 escaneos recientes del target

# Tracker
sudo ./usame.sh --list                # Lista todas las boxes escaneadas
sudo ./usame.sh --history <ip>        # Historial de una IP
sudo ./usame.sh --mark <ip> owned     # Marca box como owned/rooted

# Base de datos
sudo ./usame.sh --update-db           # Actualiza CVEs desde NVD API (validacion por CPE via lib/nvd_parser.py)
./update_db.sh                        # Alternativa independiente (misma validacion CPE)

# Comandos auxiliares (NO requieren sudo, solo cargan la base de conocimiento local)
./usame.sh --creds <target>        # Credenciales por defecto para un target (usa XML existente)
./usame.sh --creds-list            # Lista TODAS las credenciales por defecto
./usame.sh --creds-search <term>   # Busca credenciales por servicio/termino (ej: mysql, "admin\|guest")
./usame.sh --suid-list             # Lista binarios SUID explotables (GTFOBins)
./usame.sh --sudo-escalation       # Escalada via sudo (GTFOBins)
./usame.sh --wordlist [cat]        # Wordlists por escenario (lista categorias si se omite)

# Modo interactivo (sin argumentos)
sudo ./usame.sh
```

---

## Flujo Principal (`scan_and_report`)

```
1. [1/5] ESCANEO NMAP
   - Genera XML con nmap segun MODE
   - Guarda en OUTPUT_DIR/scan_<target>_<ts>.xml

2. [2/5] CARGAR BASE DE CONOCIMIENTO
   - source services.sh, cve_linux.sh, cve_windows.sh, postexploitation.sh
   - Declara arrays asociativos: SVC_*, CVE_LIN_*, CVE_WIN_*

3. [3/5] ANALIZAR RESULTADOS
   - detect_os(): infiere SO de XML
   - detect_ad(): detecta Active Directory
   - Recopila puertos abiertos en ALL_PORTS
   - Genera reporte TXT con 12 secciones

4. [4/5] EXPORTAR HTML (opcional)

5. [5/5] RESUMEN EN PANTALLA + MENU INTERACTIVO
   - Muestra puertos con exploit disponible
   - Espera input del usuario para interactuar
```

---

## Secciones del Reporte TXT

| # | Seccion | Contenido |
|---|---------|-----------|
| 1 | Resumen del Host | SO detectado, AD |
| 2 | Puertos Abiertos | Puerto, servicio, producto, version |
| 3 | CVEs de Nmap | CVEs extraidos del XML |
| 4 | CVEs Base de Conocimiento | Busqueda en cve_linux.sh / cve_windows.sh por servicio |
| 5 | Analisis Guiado | Guia paso a paso de cada servicio (de services.sh) |
| 6 | AUTO-EXPLOTACION | Comandos listos para explotar cada servicio |
| 7 | Prioridades | Que atacar primero (ALTO/MEDIO/BAJO) |
| 8 | Comandos Rapidos | Comandos listos para cada servicio |
| 9 | Reverse Shells | 23+ reverse shells (bash, python, php, java, go, powershell...) |
| 10 | Escalada de Privilegios | 10 vectores Linux, 8 vectores Windows |
| 11 | Post-Exploitacion | TTY, file transfer, persistencia, herramientas |
| 12 | Movimiento Lateral | SSH, tunnels, Kerberos, AD attacks |
| BONUS | Metasploit | Script .rc con modulos por servicio |

---

## Menu Interactivo Post-Escaneo

Despues del escaneo, `interactive_port_menu()` muestra:

```
  1) 80/tcp      HTTP        Apache          2.4.49  [EXP available]
  2) 22/tcp      SSH         OpenSSH         8.2p1
  3) 445/tcp     SMB         Samba           4.13.5  [EXP available]

  a) Auto-explotar TODOS los servicios con exploit disponible
  m) Generar script Metasploit (.rc) para todos los puertos
  s) Seleccionar multiples puertos (ej: 1,3,5)
  r) Regenerar reporte completo
  w) Generar wordlist para este target
  d) Ver CVEs de un puerto especifico
  0) Salir
```

- **Seleccion numerica (1,2,3...)**: Muestra detalles completos del puerto: auto-exploit, guia, CVEs, comandos rapidos
- **a)**: `auto_exploit_all()` - Recorre todos los puertos, ejecuta exploits disponibles, genera log
- **s)**: `exploit_selected_ports()` - Explota solo puertos seleccionados
- **m)**: `generate_metasploit_rc()` - Genera script .rc completo con modulos Metasploit

---

## Funcion `get_auto_exploit(svc, prod, ver, port)`

Funcion principal de auto-explotacion. Retorna string con comandos exploit para un servicio/version dado.

### Servicios cubiertos actualmente:

| Servicio | Versiones detectadas | Accion |
|----------|---------------------|--------|
| **ftp** | vsftpd 2.3.4 | Backdoor (nc al puerto 6200) + Metasploit |
| **ftp** | proftpd 1.3.x | ModCopy exploit + backdoor check |
| **ftp** | (todos) | Fuerza brute + enumeration |
| **http/https** | Apache 2.4.49 | CVE-2021-41773 path traversal |
| **http/https** | Apache 2.4.50 | CVE-2021-42013 RCE |
| **http/https** | Apache 2.2.x | Optionsbleed check |
| **http/https** | Nginx | Path traversal via alias |
| **http/https** | Tomcat | Manager brute force + WAR deploy |
| **http/https** | IIS 6.0 | WebDAV BOF (CVE-2017-7269) |
| **http/https** | Jenkins | Script console RCE |
| **http/https** | Drupal | Drupalgeddon Metasploit |
| **http/https** | WordPress | wpscan enumeration |
| **http/https** | Spring | Spring4Shell check |
| **http/https** | Log4j | Log4Shell payload |
| **http/https** | (todos) | gobuster + nikto + robots.txt |
| **smb** | (todos) | smbclient, enum4linux, MS17-010, null session, CrackMapExec |
| **ssh** | (todos) | ssh-audit, brute force |
| **redis** | (todos) | SSH key injection, webshell, cron job |
| **mongodb** | (todos) | mongosh, mongodump, enumeration |
| **ldap** | (todos) | Anonymous bind, user enum, BloodHound |
| **mysql** | (todos) | Creds default, brute force, LOAD_FILE |
| **mssql** | (todos) | SA creds, xp_cmdshell, brute force |
| **postgresql** | (todos) | Creds default, CVE-2019-9193 |
| **rdp** | (todos) | Brute force, BlueKeep check |
| **smtp** | (todos) | User enum, VRFY/EXPN |
| **pop3** | (todos) | Brute force |
| **imap** | (todos) | Brute force |
| **telnet** | (todos) | Creds default, tcpdump interception |
| **dns** | (todos) | Zone transfer, enum |
| **snmp** | (todos) | Community string brute force |
| **vnc** | (todos) | Brute force |
| **nfs** | (todos) | showmount, mount, root squashing |
| **rpc** | (todos) | rpcclient enumeration |
| **rsync** | (todos) | Module listing, brute force |
| **docker** | (todos) | API check, container escape |
| **iis** | 6.0 | WebDAV BOF |

---

## Funcion `get_metasploit_commands(svc, port)`

Retorna comandos Metasploit RC para un servicio. Genera modulos de scanner y exploit.

Servicios con modulos Metasploit: ftp, http, smb, ssh, mysql, mssql, postgresql, rdp, smtp, snmp.

---

## Funciones de las Librerias

### `services.sh`
- `get_service_info(svc, target, port)` - Retorna guia completa de un servicio
- Arrays: `SVC_DESCRIPTION[]`, `SVC_DIFFICULTY[]`, `SVC_TOOLS[]`, `SVC_STEPS[]`, `SVC_VULNS[]`

### `cve_linux.sh`
- `get_linux_cve_info(service)` - CVEs Linux para un servicio
- `get_linux_privesc_vectors()` - 10 vectores de escalada
- `get_linux_lateral_movement()` - Movimiento lateral Linux
- `get_linux_post_enumeration()` - Post-enumeracion
- `get_linux_cve_by_severity(severity)` - Filtrar por severidad
- `get_linux_cve_by_product(product)` - Filtrar por producto
- Arrays: `CVE_LIN_DESCRIPTION[]`, `CVE_LIN_AFFECTED[]`, `CVE_LIN_EXPLOIT[]`, `CVE_LIN_SEVERITY[]`

### `cve_windows.sh`
- `get_windows_cve_info(service)` - CVEs Windows para un servicio
- `get_windows_privesc_vectors()` - 8 vectores de escalada
- `get_windows_lateral_movement()` - Movimiento lateral Windows
- `get_windows_ad_attack()` - AD attacks (BloodHound, Certify, noPac, etc.)
- `get_windows_cve_by_severity(severity)`
- `get_windows_cve_by_product(product)`
- Arrays: `CVE_WIN_DESCRIPTION[]`, `CVE_WIN_AFFECTED[]`, `CVE_WIN_EXPLOIT[]`, `CVE_WIN_SEVERITY[]`

### `postexploitation.sh`
- `get_reverse_shells(ip, port)` - 23+ reverse shells
- `get_tty_stabilization()` - TTY upgrade
- `get_bind_shells(port)` - Bind shells
- `get_webshells(ip, port)` - Webshells (PHP, ASP, JSP, Python)
- `get_file_transfer(ip, port)` - Transferencia de archivos
- `get_persistence(ip, port)` - Persistencia Linux/Windows
- `get_useful_tools()` - Herramientas utiles para pentesting

### `default_creds.sh` (nueva en v5.0)
- `check_default_creds(svc, port, target)` - Devuelve credenciales por defecto de un servicio
- `get_all_default_creds()` - Devuelve TODAS las credenciales formateadas (usado por `--creds-list`)
- `search_default_creds(term)` - Busca por servicio/termino (usado por `--creds-search`)
- Arrays: `DC_SERVICE[]`, `DC_CREDS[]`, `DC_NOTES[]`, `DC_PORT[]`

### `suid_binaries.sh` (nueva en v5.0)
- `get_suid_exploit(bin)` - Devuelve el exploit GTFOBins para un binario
- `get_suid_exploits_by_category(cat)` - Filtra por categoria (shell/file/pager/network)
- `scan_suid_binaries()` - Escanea `find / -perm -4000` en la maquina local
- `get_all_suid_exploits()` - Lista todos los binarios explotables (usado por `--suid-list`)
- `get_sudo_escalation()` - Lista escaladas via sudo (usado por `--sudo-escalation`)
- Arrays: `SUID_EXPLOIT[]`, `SUID_CATEGORY[]`, `SUID_DESCRIPTION[]`

### `wordlists.sh` (nueva en v5.0)
- `show_wordlists(cat)` - Muestra wordlists de una categoria o de todas (usado por `--wordlist`)
- Categorias: dirs, subdomains, passwords, users, vhosts, params, wordpress, joomla, drupal, ssh, sensitive

---

## Archivos Generados

| Archivo | Descripcion |
|---------|-------------|
| `RECON_<ip>_<ts>.txt` | Reporte completo de recon |
| `RECON_<ip>_<ts>.html` | Reporte en HTML con estilos |
| `scan_<ip>_<ts>.xml` | XML de nmap |
| `msf_<ip>_<ts>.rc` | Script Metasploit Resource |
| `handler_<ip>_<ts>.rc` | Handler RC para Meterpreter |
| `auto_exploit_<ip>_<ts>.log` | Log de auto-explotacion |
| `wordlist_<ip>_<ts>.txt` | Wordlist custom |
| `.tracker` | Base de datos de boxes escaneadas |

---

## Lo que FALTA / Oportunidades de Mejora

### Funcionalidades no implementadas:
1. **No ejecuta exploits directamente** - Solo genera comandos/RC, no ejecuta metasploit ni nmap scripts automaticamente
2. **No tiene bypass de antivirus** - No genera payloads evasivos
3. **No tiene parsing de nmap scripts output** - No extrae resultados de scripts como `http-title`, `smb-os-discovery`, etc.
4. **No detecta version exacta para todos los CVEs** - Solo compara strings simples con `grep -q`
5. **No tiene nucleo CVE matching por version** - Podria comparar rangos de versiones mas precisamente
6. **No tiene exportacion a JSON** - Solo TXT y HTML
7. **No tiene comparacion de hashes NTLM** - Podria extraer hashes del XML y offer cracking
8. **No tiene integracion con CrackMapExec directa** - Solo sugiere comandos
9. **No tiene configuracion de interfaces/red** - No detecta VPN/TUN automaticamente
10. **No tiene rate limiting inteligente** - nmap timeout es fijo por modo
11. **No tiene resume/retry** - Si nmap falla, empieza de cero
12. **No tiene notificaciones** - Podria usar notify-send o telegram
13. **No tiene modo automatico completo** - `--auto` solo genera, no ejecuta

### Bugs/Issues conocidos (CORREGIDOS en v4.1):
1. ~~`ALL_PORTS` se define despues de `scan_and_report` pero se usa en `interactive_port_menu` que se llama dentro de `scan_and_report` - funciona porque se define antes de la llamada a la funcion~~ (funciona correctamente en bash - variables locales accesibles por funciones hijas)
2. ~~`CVE_LIST` se usa al final del reporte pero se define en la seccion 3~~ (mismo scope, funciona correctamente)
3. ~~`EXPLOIT_LOG` se usa en `auto_exploit_all` pero se define como local ahi~~ (corregido: `generate_metasploit_rc` ahora verifica si la variable existe antes de usarla)
4. ~~Las funciones de las librerias usan `${R}` y `${W}` que son variables del script principal~~ (funcionan porque se sourcean en el mismo shell)
5. **CORREGIDO**: `SVC_DIFFICULTy[smtp]` y `SVC_DIFFICULTy[nginx]` tenian typo (y minuscula) - la variable fantasma nunca se leia
6. **CORREGIDO**: `CVE-2021-34527` estaba duplicada en `cve_windows.sh` - la segunda entrada sobre escribia la primera
7. **CORREGIDO**: `--mark` no validaba el argumento status (solo aceptaba "owned" o "rooted")

### Mejoras sugeridas:
- Agregar `--execute` que ejecute comandos Metasploit via `msfconsole -q -x`
- Agregar parsing de servicios de nmap XML mas robusto (usar `xmllint` o python)
- Agregar exportacion a JSON para integracion con otras herramientas
- Agregar headless mode sin interactivo para automatizacion
- Agregar scan differential automatico (guardar baseline, comparar despues)
- Agregar integracion con Shodan/Censys para enrichment
- Agregar generacion de Payloads via msfvenom directa
- Agregar soporte para IPv6
- Agregar timeout configurable por servicio
- Agregar log verbose para debugging

---

## Notas para IA que Mejore el Script

1. **Las librerias se sourcean dinamicamente** - Cualquier nueva funcion debe ir en el `.sh` correspondiente
2. **Los arrays asociativos requieren bash 4+** - Verificar compatibilidad
3. **`get_auto_exploit` es la funcion clave** - Expandir cubriendo mas servicios/versiones
4. **`interactive_port_menu` es el UX principal** - Es donde el usuario interactua post-escaneo
5. **El reporte TXT es la salida principal** - HTML es secundario
6. **Metasploit RC se genera por servicio** - `get_metasploit_commands()` retorna comandos por servicio
7. **`detect_os()` y `detect_ad()` infieren del XML** - No ejecutan fingerprinting activo
8. **El script NO ejecuta exploits** - Solo genera comandos y reportes
9. **Todas las rutas son relativas a OUTPUT_DIR** (`$USAME_OUTPUT_DIR` o `~/escaneos`)
10. **El script necesita root para nmap** - Muchas funciones requieren sudo

---

## Roadmap v4.2+

Ver `.opencode/plans/TODO.md` para el plan completo de mejoras.

### Proximas mejoras (resumen):
1. **Bugs criticos:** fix echo/printf, --mark argc, eval removal, REAL_USER safety
2. **Helpers DRY:** get_port_info, to_lower, print_section, show_cves_for_os, get_quick_commands, write_msf_module
3. **Refactor:** split scan_and_report (425 lineas) en funciones fase
4. **Error handling:** bounds check args, XML guards, nmap exit codes
5. **Robustez:** Python inline -> scripts, grep portability, cat -> grep directo
6. **Features:** --execute, --json, --resume, --verbose, --dry-run
7. **UX:** progress indicators, confirmation prompts

---

## Changelog

### v5.0 (actual)
- [+] Nueva libreria `default_creds.sh`: credenciales por defecto para 60+ servicios (web, bases de datos, contenedores, monitorizacion, red, correo, VPN)
- [+] Nueva libreria `suid_binaries.sh`: binarios SUID explotables (GTFOBins) por categoria + escalada via sudo
- [+] Nueva libreria `wordlists.sh`: wordlists por escenario (10 categorias)
- [+] Servicios nuevos en `services.sh`: Elasticsearch, Docker Registry, RabbitMQ, CouchDB, MinIO, Grafana, GitLab, etcd, Consul, Vault, Mosquitto
- [+] CVEs 2024-2025 en `cve_linux.sh`: CVE-2024-23897, CVE-2024-27198, CVE-2023-44487, CVE-2023-46747, CVE-2023-20198, CVE-2023-38545, CVE-2024-6387, CVE-2024-3094 (XZ), CVE-2024-21626 (runc), CVE-2024-2879 (GeoServer), etc.
- [+] CVEs 2024-2025 en `cve_windows.sh`: CVE-2024-30088, CVE-2024-26169, CVE-2024-21410, CVE-2024-21413, etc.
- [+] Comandos auxiliares sin sudo: `--creds`, `--creds-list`, `--creds-search`, `--suid-list`, `--sudo-escalation`, `--wordlist [cat]`
- [+] Seccion 8.5 "CREDENCIALES POR DEFECTO" en el reporte
- [*] **BUG CRITICO**: las librerias usaban `declare -A`; al sourcearse dentro de `load_libraries()` los arrays se perdian (base de conocimiento vacia). Corregido con `declare -gA` en todas las librerias
- [*] `--wordlist` ahora acepta categoria opcional (antes consumia el target por error)

### v4.2
- Fix: echo -e con %s en tracker_list (printf unificado)
- Fix: --mark sin validacion de argc
- Fix: eval para stealth nmap (nmap directo)
- Fix: eval echo ~REAL_USER (getent passwd)
- Agregado: to_lower(), get_port_info(), print_section/subsection/err/warn/ok/info()
- Agregado: show_cves_for_os(), get_quick_commands(), write_msf_module()
- TODO.md con plan completo para fases 3-7

### v4.1
- Fix: SVC_DIFFICULTY typo en smtp/nginx
- Fix: CVE-2021-34527 duplicada
- Fix: generate_metasploit_rc usaba $EXPLOIT_LOG no definido
- Fix: --mark sin validacion de status
