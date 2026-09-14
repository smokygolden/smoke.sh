#!/usr/bin/env python3
"""nvd_parser.py - Parsea respuestas de la API NVD 2.0 con validacion CPE.

Uso: echo "<json>" | python3 nvd_parser.py <query>

Solo imprime entradas CVE cuyo CPE coincida con el producto buscado.
Formato salida: CVE_ID|descripcion|severidad|producto_real
"""
import json
import re
import sys

CPE_MAP = {
    'openssh': ['openbsd:openssh'],
    'vsftpd': ['vsftpd_project:vsftpd', 'vsftpd:vsftpd'],
    'proftpd': ['proftpd:proftpd'],
    'apache': ['apache:http_server', 'apache:tomcat', 'apache:struts', 'apache:commons_text'],
    'nginx': ['nginx:nginx'],
    'tomcat': ['apache:tomcat'],
    'samba': ['samba:samba'],
    'redis': ['redis:redis', 'redis:redis_enterprise'],
    'postgresql': ['postgresql:postgresql'],
    'mysql': ['oracle:mysql', 'mysql:mysql'],
    'linux_kernel': ['linux:linux_kernel'],
    'glibc': ['gnu:glibc'],
    'openssl': ['openssl:openssl'],
    'systemd': ['systemd:systemd'],
    'runc': ['runc:runc'],
    'docker': ['docker:docker', 'docker:docker_desktop'],
    'jenkins': ['jenkins:jenkins'],
    'wordpress': ['wordpress:wordpress'],
    'drupal': ['drupal:drupal'],
    'windows': ['microsoft:windows_'],
    'exchange': ['microsoft:exchange_server'],
    'sharepoint': ['microsoft:sharepoint_server'],
    'outlook': ['microsoft:outlook'],
    'iis': ['microsoft:iis'],
    'rdp': ['microsoft:windows_'],
    'smb': ['microsoft:windows_', 'samba:samba'],
    'mssql': ['microsoft:sql_server'],
}


def cpe_to_product(cpe):
    """Extrae vendor:product de una cadena CPE 2.3.

    cpe:2.3:a:microsoft:exchange_server:2019:*:*:*:*:*:*:*
    -> microsoft:exchange_server
    """
    parts = cpe.split(':')
    if len(parts) >= 5 and parts[:2] == ['cpe', '2.3']:
        vendor = parts[3]
        product = parts[4].replace('_', ' ')
        return f"{vendor}:{product}"
    return ''


def extract_cpes(cve):
    """Extrae todas las cadenas CPE de un objeto CVE."""
    cpes = []
    for config in cve.get('configurations', []):
        for node in config.get('nodes', []):
            for match in node.get('cpeMatch', []):
                cpe = match.get('criteria', '')
                if cpe:
                    cpes.append(cpe)
    return cpes


def get_description(cve):
    for d in cve.get('descriptions', []):
        if d.get('lang') == 'en':
            return d.get('value', '')
    return ''


def get_severity(cve):
    for key in ('cvssMetricV41', 'cvssMetricV40', 'cvssMetricV31', 'cvssMetricV30'):
        if key in cve.get('metrics', {}):
            for m in cve['metrics'][key]:
                return m.get('cvssData', {}).get('baseSeverity', 'UNKNOWN')
    return 'UNKNOWN'


def main():
    query = sys.argv[1] if len(sys.argv) > 1 else ''
    valid_cpes = CPE_MAP.get(query, [])

    try:
        data = json.load(sys.stdin)
    except Exception:
        return

    for v in data.get('vulnerabilities', []):
        cve = v.get('cve', {})
        cve_id = cve.get('id', '')
        if not cve_id:
            continue

        cpes = extract_cpes(cve)
        matched_product = query
        accepted = False
        matched_product = query

        if valid_cpes:
            # Query con mapa CPE: SOLO se acepta si un CPE del CVE coincide.
            # Si NVD no devuelve CPEs o ninguno coincide, se rechaza: evita
            # falsos positivos (p.ej. routers cuyo firmware menciona
            # 'vsftpd.conf' en la descripcion pero no es un CVE de vsftpd).
            for cpe in cpes:
                for pattern in valid_cpes:
                    if pattern in cpe:
                        accepted = True
                        prod = cpe_to_product(cpe)
                        if prod:
                            matched_product = prod
                        break
                if accepted:
                    break
        else:
            # Sin mapa CPE configurado: aceptar los resultados del keywordSearch
            desc_full = get_description(cve)
            if re.search(rf'\b{re.escape(query)}\b', desc_full, re.IGNORECASE):
                accepted = True

        if not accepted:
            continue

        desc = get_description(cve).replace('\n', ' ')[:80]
        severity = get_severity(cve)
        print(f'{cve_id}|{desc}|{severity}|{matched_product}')


if __name__ == '__main__':
    main()