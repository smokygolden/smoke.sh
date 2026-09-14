#!/bin/bash
# ============================================================
# update_db.sh - Actualizador de base de datos CVE (utilidad)
#
# Que hace: actualiza las bases de datos de CVEs de SMOKEME.sh
#   (lib/cve_linux.sh y lib/cve_windows.sh) consultando la API
#   NVD 2.0 y validando el CPE con lib/nvd_parser.py. Crea
#   backups antes de modificar.
#
# Alternativa integrada: SMOKEME.sh --update-db (misma logica).
#
# Requiere: curl, python3, gzip
# ============================================================
# Uso:
#   ./update_db.sh              # actualiza ambas BD
#   ./update_db.sh --linux      # solo Linux
#   ./update_db.sh --windows    # solo Windows
#   ./update_db.sh --no-backup  # sin backups
#   sudo ./SMOKEME.sh --update-db # via SMOKEME.sh (alternativa)
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CVE_DB_DIR="$SCRIPT_DIR/lib"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/Escritorio/escaneos}"

R='\e[31m'; G='\e[32m'; Y='\e[33m'; C='\e[36m'; B='\e[1m'; W='\e[0m'

DO_LINUX=0
DO_WINDOWS=0
DO_BACKUP=1
API_URL="https://services.nvd.nist.gov/rest/json/cves/2.0"
RESULTS_PER_PAGE=200
DAYS_BACK=115

print_err()   { echo -e "${R}  [!] $1${W}"; }
print_warn()  { echo -e "${Y}  [*] $1${W}"; }
print_ok()    { echo -e "${G}  [+] $1${W}"; }
print_info()  { echo -e "${C}  [~] $1${W}"; }

usage() {
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Opciones:"
    echo "  --linux       Solo actualizar cve_linux.sh"
    echo "  --windows     Solo actualizar cve_windows.sh"
    echo "  --no-backup   No crear copia de seguridad"
    echo "  -h            Muestra esta ayuda"
    exit 0
}

check_deps() {
    for cmd in curl python3; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            print_err "Falta dependencia: $cmd"
            exit 1
        fi
    done
}

fetch_and_merge() {
    local query="$1"
    local db_prefix="$2"   # "LIN" o "WIN"
    local db_file
    [ "$db_prefix" = "LIN" ] && db_file="$CVE_DB_DIR/cve_linux.sh"
    [ "$db_prefix" = "WIN" ] && db_file="$CVE_DB_DIR/cve_windows.sh"

    [ ! -f "$db_file" ] && { print_err "BD no encontrada: $db_file"; return 1; }

    local start_date end_date
    start_date=$(date -d "$DAYS_BACK days ago" +%Y-%m-%dT00:00:00.000)
    end_date=$(date +%Y-%m-%dT23:59:59.999)

    local url="${API_URL}?keywordSearch=${query}&resultsPerPage=${RESULTS_PER_PAGE}&pubStartDate=${start_date}&pubEndDate=${end_date}"
    print_info "Query: $query"

    local json
    json=$(curl -s --max-time 30 "$url" 2>/dev/null)
    if [ -z "$json" ]; then
        print_warn "  Sin respuesta (red/NVD limite)."
        return 0
    fi

    local entries
    entries=$(echo "$json" | python3 "$SCRIPT_DIR/lib/nvd_parser.py" "$query" 2>/dev/null)

    [ -z "$entries" ] && { print_warn "  No se encontraron CVEs para '$query'."; return 0; }

    local new_count=0
    local line_exists
    while IFS='|' read -r cve_id desc severity matched_product; do
        [ -z "$cve_id" ] && continue
        if grep -q "\[$cve_id\]" "$db_file" 2>/dev/null; then
            continue
        fi
        desc=$(echo "$desc" | sed 's/["`]/\\&/g; s/\\/\\\\/g')
        {
            echo ""
            echo "CVE_${db_prefix}_DESCRIPTION[$cve_id]=\"Auto: $desc\""
            echo "CVE_${db_prefix}_AFFECTED[$cve_id]=\"$matched_product (auto-detected)\""
            echo "CVE_${db_prefix}_EXPLOIT[$cve_id]=\"Check NVD: https://nvd.nist.gov/vuln/detail/$cve_id\""
            echo "CVE_${db_prefix}_SEVERITY[$cve_id]=\"$severity\""
        } >> "$db_file"
        new_count=$((new_count + 1))
    done <<< "$entries"

    if [ "$new_count" -gt 0 ]; then
        print_ok "  +$new_count CVEs nuevos en $db_file"
    else
        print_warn "  Ya estaba al dia."
    fi
}

do_backup() {
    local backup_dir="$OUTPUT_DIR/cve_backups"
    mkdir -p "$backup_dir"
    local stamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/cve_db_${stamp}.tar.gz"
    tar -czf "$backup_file" -C "$CVE_DB_DIR" cve_linux.sh cve_windows.sh 2>/dev/null
    if [ -f "$backup_file" ]; then
        print_ok "Backup creado: $backup_file"
    else
        print_err "No se pudo crear el backup."
    fi
}

main() {
    [ $DO_LINUX -eq 0 ] && [ $DO_WINDOWS -eq 0 ] && { DO_LINUX=1; DO_WINDOWS=1; }

    if [ ! -d "$CVE_DB_DIR" ]; then
        print_err "Directorio de BD no encontrado: $CVE_DB_DIR"
        exit 1
    fi

    check_deps
    echo -e "${B}${C}  ACTUALIZANDO BASE DE DATOS CVE${W}"
    echo ""

    if [ "$DO_BACKUP" -eq 1 ]; then
        do_backup
        echo ""
    fi

    local linux_queries=(openssh vsftpd proftpd apache nginx tomcat samba redis postgresql mysql linux_kernel glibc openssl systemd runc docker jenkins wordpress drupal)
    local windows_queries=(windows exchange sharepoint outlook iis rdp smb mssql)

    if [ "$DO_LINUX" -eq 1 ]; then
        echo -e "${B}  --- Linux ---${W}"
        for q in "${linux_queries[@]}"; do
            fetch_and_merge "$q" "LIN"
            sleep 6
        done
        echo ""
    fi

    if [ "$DO_WINDOWS" -eq 1 ]; then
        echo -e "${B}  --- Windows ---${W}"
        for q in "${windows_queries[@]}"; do
            fetch_and_merge "$q" "WIN"
            sleep 6
        done
        echo ""
    fi

    echo -e "${G}  Base de datos actualizada.${W}"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --linux)    DO_LINUX=1 ;;
        --windows)  DO_WINDOWS=1 ;;
        --no-backup) DO_BACKUP=0 ;;
        -h|--help)  usage ;;
        *) print_warn "Opcion desconocida: $1"; usage ;;
    esac
    shift
done

main
