#!/bin/bash
# ============================================================
# default_creds.sh - Credenciales por defecto (Libreria)
#
# Que hace: base de datos de credenciales por defecto de 60+
#   servicios (web, BD, red, mail, VPN) con puerto y notas, y
#   funciones de consulta/busqueda para el reporte guiado.
#
# Exporta (se sourcea desde SMOKEME.sh):
#   Arrays    : DC_SERVICE, DC_CREDS, DC_NOTES, DC_PORT
#   Funciones : check_default_creds <svc> <port> <target>,
#               get_all_default_creds, search_default_creds.
#
# No es ejecutable por si sola; es un modulo de datos.
# ============================================================

declare -gA DC_SERVICE
declare -gA DC_CREDS
declare -gA DC_NOTES
declare -gA DC_PORT

# ============================================================
# WEB SERVERS / CMS
# ============================================================

DC_SERVICE[tomcat_manager]="Apache Tomcat Manager"
DC_CREDS[tomcat_manager]="tomcat:tomcat|admin:admin|tomcat:s3cret|admin:password|tomcat:admin|admin:123456|both:tomcat"
DC_PORT[tomcat_manager]="8080"
DC_NOTES[tomcat_manager]="Path: /manager/html"

DC_SERVICE[jenkins]="Jenkins"
DC_CREDS[jenkins]="admin:admin|admin:password|admin:123456|jenkins:jenkins|admin:@"
DC_PORT[jenkins]="8080"
DC_NOTES[jenkins]="API: /api/json | Script: /script"

DC_SERVICE[grafana]="Grafana"
DC_CREDS[grafana]="admin:admin|admin:password|admin:123456|admin:grafana"
DC_PORT[grafana]="3000"
DC_NOTES[grafana]="Default creds in older versions (< 7.0)"

DC_SERVICE[gitlab]="GitLab"
DC_CREDS[gitlab]="root:password|root:123456|admin:password"
DC_PORT[gitlab]="443/80"
DC_NOTES[gitlab]="Newer versions require setup wizard"

DC_SERVICE[gitea]="Gitea"
DC_CREDS[gitea]="root:root|admin:admin|gitea:gitea"
DC_PORT[gitea]="3000"
DC_NOTES[gitea]="" 

DC_SERVICE[phpmyadmin]="phpMyAdmin"
DC_CREDS[phpmyadmin]="root:root|root:|root:password|root:mysql|admin:admin|pma:pma"
DC_PORT[phpmyadmin]="80/443"
DC_NOTES[phpmyadmin]="Path: /phpmyadmin/, /pma/"

DC_SERVICE[weblogic]="Oracle WebLogic"
DC_CREDS[weblogic]="weblogic:Oracle@123|weblogic:password|weblogic:weblogic|system:password|system:weblogic|admin:admin"
DC_PORT[weblogic]="7001"
DC_NOTES[weblogic]="Console: /console"

DC_SERVICE[spring_actuator]="Spring Boot Actuator"
DC_CREDS[spring_actuator]="(sin auth por defecto)"
DC_PORT[spring_actuator]="8080"
DC_NOTES[spring_actuator]="Paths: /actuator, /actuator/env, /actuator/heapdump"

DC_SERVICE[solr]="Apache Solr"
DC_CREDS[solr]="(sin auth por defecto)"
DC_PORT[solr]="8983"
DC_NOTES[solr]="Path: /solr/#/"

DC_SERVICE[supervisor]="Supervisor"
DC_CREDS[supervisor]="admin:admin|supervisor:supervisor"
DC_PORT[supervisor]="9001"
DC_NOTES[supervisor]="Path: /RPC2"

DC_SERVICE[zabbix]="Zabbix"
DC_CREDS[zabbix]="Admin:zabbix|admin:zabbix|guest:guest|(empty)"
DC_PORT[zabbix]="80/443"
DC_NOTES[zabbix]="Default admin: Admin/zabbix"

DC_SERVICE[nagios]="Nagios"
DC_CREDS[nagios]="nagiosadmin:nagios|admin:admin|nagios:nagios"
DC_PORT[nagios]="80"
DC_NOTES[nagios]="Path: /nagios/"

DC_SERVICE[cacti]="Cacti"
DC_CREDS[cacti]="admin:admin|admin:cacti"
DC_PORT[cacti]="80"
DC_NOTES[cacti]="Path: /cacti/"

DC_SERVICE[cockpit]="Cockpit"
DC_CREDS[cockpit]="root:<password>|admin:<password>"
DC_PORT[cockpit]="9090"
DC_NOTES[cockpit]="Uses system credentials"

DC_SERVICE[graylog]="Graylog"
DC_CREDS[graylog]="admin:admin"
DC_PORT[graylog]="9000"
DC_NOTES[graylog]=""

DC_SERVICE[kibana]="Kibana"
DC_CREDS[kibana]="(sin auth por defecto en versiones viejas)"
DC_PORT[kibana]="5601"
DC_NOTES[kibana]="Newer versions use Elastic security"

DC_SERVICE[portainer]="Portainer"
DC_CREDS[portainer]="(sin auth - setup wizard)"
DC_PORT[portainer]="9000/9443"
DC_NOTES[portainer]="First user becomes admin"

DC_SERVICE[traefik]="Traefik Dashboard"
DC_CREDS[traefik]="(sin auth por defecto)"
DC_PORT[traefik]="8080"
DC_NOTES[traefik]="Path: /dashboard/"

# ============================================================
# DATABASES
# ============================================================

DC_SERVICE[mysql]="MySQL/MariaDB"
DC_CREDS[mysql]="root:|root:root|root:password|root:toor|root:mysql|root:123456|admin:admin|mysql:mysql"
DC_PORT[mysql]="3306"
DC_NOTES[mysql]="Try empty password first"

DC_SERVICE[mssql]="Microsoft SQL Server"
DC_CREDS[mssql]="sa:|sa:sa|sa:password|sa:Password1|sa:Password123!|sa:Password1234!|sa:P@ssw0rd|sa:Admin123!"
DC_PORT[mssql]="1433"
DC_NOTES[mssql]="sa = sysadmin"

DC_SERVICE[postgresql]="PostgreSQL"
DC_CREDS[postgresql]="postgres:postgres|postgres:password|postgres:|admin:admin|postgres:123456"
DC_PORT[postgresql]="5432"
DC_NOTES[postgresql]=""

DC_SERVICE[oracle]="Oracle DB"
DC_CREDS[oracle]="system:oracle|sys:oracle|system:manager|scott:tiger|admin:admin|system:password"
DC_PORT[oracle]="1521"
DC_NOTES[oracle]="SID: ORCL, XE"

DC_SERVICE[mongodb]="MongoDB"
DC_CREDS[mongodb]="(sin auth por defecto)"
DC_PORT[mongodb]="27017"
DC_NOTES[mongodb]=""

DC_SERVICE[redis]="Redis"
DC_CREDS[redis]="(sin auth por defecto)|redis:redis"
DC_PORT[redis]="6379"
DC_NOTES[redis]="" 

DC_SERVICE[elasticsearch]="Elasticsearch"
DC_CREDS[elasticsearch]="(sin auth por defecto)|elastic:changeme|elastic:password"
DC_PORT[elasticsearch]="9200"
DC_NOTES[elasticsearch]="API: /_cat/indices, /_cat/nodes"

DC_SERVICE[couchdb]="CouchDB"
DC_CREDS[couchdb]="admin:admin|admin:password|admin:123456"
DC_PORT[couchdb]="5984"
DC_NOTES[couchdb]="Fauxton: /_utils/"

DC_SERVICE[memcached]="Memcached"
DC_CREDS[memcached]="(sin auth por defecto)"
DC_PORT[memcached]="11211"
DC_NOTES[memcached]="stats items, slabs"

DC_SERVICE[cassandra]="Cassandra"
DC_CREDS[cassandra]="cassandra:cassandra"
DC_PORT[cassandra]="9042"
DC_NOTES[cassandra]=""

DC_SERVICE[cockroachdb]="CockroachDB"
DC_CREDS[cockroachdb]="root:(empty)|admin:admin"
DC_PORT[cockroachdb]="26257"
DC_NOTES[cockroachdb]="Web UI: 8080"

DC_SERVICE[couchbase]="Couchbase"
DC_CREDS[couchbase]="Administrator:password|admin:password"
DC_PORT[couchbase]="8091"
DC_NOTES[couchbase]="Web UI: /ui/index.html"

# ============================================================
# CONTAINER / DEVOPS
# ============================================================

DC_SERVICE[docker_registry]="Docker Registry"
DC_CREDS[docker_registry]="(sin auth por defecto)"
DC_PORT[docker_registry]="5000"
DC_NOTES[docker_registry]="API: /v2/_catalog"

DC_SERVICE[docker_api]="Docker API"
DC_CREDS[docker_api]="(sin auth por defecto)"
DC_PORT[docker_api]="2375/2376"
DC_NOTES[docker_api]="" 

DC_SERVICE[kubernetes]="Kubernetes API"
DC_CREDS[kubernetes]="(sin auth por defecto en algunos setups)"
DC_PORT[kubernetes]="6443"
DC_NOTES[kubernetes]="" 

DC_SERVICE[etcd]="etcd"
DC_CREDS[etcd]="(sin auth por defecto)"
DC_PORT[etcd]="2379"
DC_NOTES[etcd]="Keys: /, /registry"

DC_SERVICE[consul]="HashiCorp Consul"
DC_CREDS[consul]="(sin auth por defecto)"
DC_PORT[consul]="8500"
DC_NOTES[consul]="API: /v1/catalog/services"

DC_SERVICE[vault]="HashiCorp Vault"
DC_CREDS[vault]="(token-based auth)"
DC_PORT[vault]="8200"
DC_NOTES[vault]="UI: /ui/"

DC_SERVICE[rabbitmq]="RabbitMQ"
DC_CREDS[rabbitmq]="guest:guest|admin:admin|admin:password|rabbitmq:rabbitmq"
DC_PORT[rabbitmq]="5672/15672"
DC_NOTES[rabbitmq]="Management UI: 15672"

DC_SERVICE[mosquitto]="Mosquitto MQTT"
DC_CREDS[mosquitto]="(sin auth por defecto en versiones viejas)"
DC_PORT[mosquitto]="1883"
DC_NOTES[mosquitto]="v1.x: sin auth por defecto"

DC_SERVICE[nats]="NATS"
DC_CREDS[nats]="(sin auth por defecto)"
DC_PORT[nats]="4222/8222"
DC_NOTES[nats]="Monitoring: 8222/varz"

DC_SERVICE[kafka]="Apache Kafka"
DC_CREDS[kafka]="(sin auth por defecto)"
DC_PORT[kafka]="9092"
DC_NOTES[kafka]=""

# ============================================================
# MONITORING / LOGGING
# ============================================================

DC_SERVICE[prometheus]="Prometheus"
DC_CREDS[prometheus]="(sin auth por defecto)"
DC_PORT[prometheus]="9090"
DC_NOTES[prometheus]="API: /api/v1/targets"

DC_SERVICE[alertmanager]="Alertmanager"
DC_CREDS[alertmanager]="(sin auth por defecto)"
DC_PORT[alertmanager]="9093"
DC_NOTES[alertmanager]="" 

DC_SERVICE[node_exporter]="Node Exporter"
DC_CREDS[node_exporter]="(sin auth por defecto)"
DC_PORT[node_exporter]="9100"
DC_NOTES[node_exporter]="Metrics: /metrics"

DC_SERVICE[minio]="MinIO"
DC_CREDS[minio]="minioadmin:minioadmin|admin:password"
DC_PORT[minio]="9000/9001"
DC_NOTES[minio]="Console: 9001"

DC_SERVICE[sonarqube]="SonarQube"
DC_CREDS[sonarqube]="admin:admin|admin:password"
DC_PORT[sonarqube]="9000"
DC_NOTES[sonarqube]=""

# ============================================================
# NETWORK / PROTOCOLS
# ============================================================

DC_SERVICE[snmp]="SNMP"
DC_CREDS[snmp]="public:|private:|community:|manager:"
DC_PORT[snmp]="161"
DC_NOTES[snmp]="Community strings, no auth"

DC_SERVICE[ldap]="LDAP"
DC_CREDS[ldap]="(anonymous bind) (cn=admin,dc=domain,dc=com):password"
DC_PORT[ldap]="389/636"
DC_NOTES[ldap]=""

DC_SERVICE[smb]="SMB/CIFS"
DC_CREDS[smb]="(null session) Administrator:|admin:|guest:"
DC_PORT[smb]="445/139"
DC_NOTES[smb]="Null session test"

DC_SERVICE[ftp]="FTP"
DC_CREDS[ftp]="anonymous:anonymous|anonymous:|ftp:ftp|ftp:|admin:admin|admin:password"
DC_PORT[ftp]="21"
DC_NOTES[ftp]="Try anonymous first"

DC_SERVICE[ssh]="SSH"
DC_CREDS[ssh]="root:root|root:toor|admin:admin|user:user|test:test|guest:guest"
DC_PORT[ssh]="22"
DC_NOTES[ssh]=""

DC_SERVICE[telnet]="Telnet"
DC_CREDS[telnet]="admin:admin|root:root|admin:password|cisco:cisco"
DC_PORT[telnet]="23"
DC_NOTES[telnet]=""

DC_SERVICE[rdp]="RDP"
DC_CREDS[rdp]="administrator:|admin:admin|user:user|guest:guest"
DC_PORT[rdp]="3389"
DC_NOTES[rdp]=""

# ============================================================
# MAIL
# ============================================================

DC_SERVICE[dovecot]="Dovecot"
DC_CREDS[dovecot]="postmaster:postmaster"
DC_PORT[dovecot]="993/995"
DC_NOTES[dovecot]=""

DC_SERVICE[postfix]="Postfix"
DC_CREDS[postfix]="(sin auth por defecto)"
DC_PORT[postfix]="25/587"
DC_NOTES[postfix]=""

# ============================================================
# VPN / PROXY
# ============================================================

DC_SERVICE[openvpn]="OpenVPN"
DC_CREDS[openvpn]="(cert-based auth)"
DC_PORT[openvpn]="1194"
DC_NOTES[openvpn]=""

DC_SERVICE[wireguard]="WireGuard"
DC_CREDS[wireguard]="(key-based auth)"
DC_PORT[wireguard]="51820"
DC_NOTES[wireguard]=""

# ============================================================
# OTROS
# ============================================================

DC_SERVICE[vsftpd]="vsftpd"
DC_CREDS[vsftpd]="anonymous:anonymous|ftp:ftp"
DC_PORT[vsftpd]="21"
DC_NOTES[vsftpd]="2.3.4 = backdoor on port 6200"

DC_SERVICE[proftpd]="ProFTPD"
DC_CREDS[proftpd]="anonymous:anonymous|ftp:ftp"
DC_PORT[proftpd]="21"
DC_NOTES[proftpd]=""

DC_SERVICE[openldap]="OpenLDAP"
DC_CREDS[openldap]="(anonymous bind)"
DC_PORT[openldap]="389"
DC_NOTES[openldap]="cn=admin,dc=example,dc=org"

DC_SERVICE[samba]="Samba"
DC_CREDS[samba]="(null session)|root:root|nobody:nobody"
DC_PORT[samba]="445/139"
DC_NOTES[samba]=""

DC_SERVICE[isc_dhcp]="ISC DHCP"
DC_CREDS[isc_dhcp]="(sin auth)"
DC_PORT[isc_dhcp]="67/68"
DC_NOTES[isc_dhcp]=""

# ============================================================
# FUNCIONES
# ============================================================

# Emite el bloque de credenciales + comandos de prueba para una clave.
_emit_creds_block() {
    local key="$1" service="$2" port="$3" target="$4"
    local svc_lower=$(echo "$service" | tr '[:upper:]' '[:lower:]')
    local creds="${DC_CREDS[$key]}"
    local notes="${DC_NOTES[$key]}"
    local dc_port="${DC_PORT[$key]}"

    results="${results}\n  ${C}[*] ${DC_SERVICE[$key]} detectado${W}\n"
    results="${results}  ${Y}Credenciales por defecto:${W}\n"

    IFS='|' read -ra CRED_ARRAY <<< "$creds"
    for cred in "${CRED_ARRAY[@]}"; do
        IFS=':' read -ra CPART <<< "$cred"
        local user="${CPART[0]}"
        local pass="${CPART[1]}"
        results="${results}    ${G}+${W} $user : $pass\n"
    done

    [ -n "$notes" ] && results="${results}  ${DIM}  Nota: $notes${W}\n"
    [ -n "$dc_port" ] && results="${results}  ${DIM}  Puerto default: $dc_port${W}\n"

    results="${results}  ${C}  Comandos de prueba:${W}\n"
    case "$svc_lower" in
        *mysql*)
            results="${results}    mysql -h $target -P ${dc_port} -u root -p\n"
            results="${results}    mysql -h $target -P ${dc_port} -u root -p ''\n"
            ;;
        *mssql*)
            results="${results}    impacket-mssqlclient sa:@$target -windows-auth\n"
            results="${results}    impacket-mssqlclient sa:password@$target\n"
            ;;
        *postgres*)
            results="${results}    psql -h $target -U postgres\n"
            results="${results}    psql -h $target -U postgres -W\n"
            ;;
        *redis*)
            results="${results}    redis-cli -h $target -p ${dc_port}\n"
            results="${results}    redis-cli -h $target -p ${dc_port} INFO\n"
            ;;
        *mongo*)
            results="${results}    mongosh $target:${dc_port}\n"
            ;;
        *elastic*)
            results="${results}    curl http://$target:${dc_port}/\n"
            results="${results}    curl http://$target:${dc_port}/_cat/indices\n"
            ;;
        *smb*|*microsoft*|*netbios*)
            results="${results}    smbclient -L //$target/ -N\n"
            results="${results}    crackmapexec smb $target -u '' -p ''\n"
            ;;
        *ssh*)
            results="${results}    sshpass -p 'password' ssh user@$target\n"
            results="${results}    hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://$target -t 4\n"
            ;;
        *ftp*)
            results="${results}    ftp anonymous@$target\n"
            results="${results}    curl ftp://anonymous:anonymous@$target/\n"
            ;;
        *snmp*)
            results="${results}    snmpwalk -v2c -c public $target\n"
            results="${results}    snmp-check -c public $target\n"
            ;;
        *ldap*)
            results="${results}    ldapsearch -x -H ldap://$target -b '' -s base namingContexts\n"
            ;;
        *tomcat*)
            results="${results}    hydra -l tomcat -P /usr/share/wordlists/rockyou.txt http-get://$target:${dc_port}/manager/html -t 4\n"
            ;;
        *jenkins*)
            results="${results}    hydra -l admin -P /usr/share/wordlists/rockyou.txt http-get://$target:${dc_port}/script -t 4\n"
            ;;
        *)
            results="${results}    curl -u 'admin:admin' http://$target:${dc_port}/\n"
            ;;
    esac
}

check_default_creds() {
    local service="$1"
    local port="$2"
    local target="$3"
    local results=""

    local svc_lower=$(echo "$service" | tr '[:upper:]' '[:lower:]')

    # Buscar en la base de datos: primero por nombre de servicio/producto,
    # y como fallback por el puerto del servicio (p.ej. http en 8080 = Tomcat).
    for key in "${!DC_SERVICE[@]}"; do
        local key_lower=$(echo "$key" | tr '[:upper:]' '[:lower:]')
        local desc_lower=$(echo "${DC_SERVICE[$key]}" | tr '[:upper:]' '[:lower:]')
        local dc_port="${DC_PORT[$key]}"
        local dc_port_match
        dc_port_match=$(echo "$dc_port" | grep -qE "(^|[/ ])${port}([/ ]|$)"; echo $?)
        if echo "$svc_lower" | grep -qi "$key_lower\|$desc_lower"; then
            _emit_creds_block "$key" "$service" "$port" "$target"
            break
        elif [ "$dc_port_match" -eq 0 ]; then
            _emit_creds_block "$key" "$service" "$port" "$target"
            break
        fi
    done

    if [ -z "$results" ]; then
        echo "  No se encontraron credenciales por defecto para: $service"
    else
        echo -e "$results"
    fi
}

get_all_default_creds() {
    local count=0
    for key in $(echo "${!DC_SERVICE[@]}" | tr ' ' '\n' | sort); do
        echo -e "  ${B}${C}${DC_SERVICE[$key]}${W} (${DC_PORT[$key]})"
        echo -e "    ${Y}Creds: ${DC_CREDS[$key]}${W}"
        [ -n "${DC_NOTES[$key]}" ] && echo -e "    ${DIM}${DC_NOTES[$key]}${W}"
        echo ""
        count=$((count + 1))
    done
    echo -e "  ${G}Total: $count servicios en la base de datos${W}"
}

search_default_creds() {
    local query="$1"
    local found=0
    for key in "${!DC_SERVICE[@]}"; do
        if echo "${DC_SERVICE[$key]}" | grep -qi "$query"; then
            echo -e "  ${B}${C}${DC_SERVICE[$key]}${W} (Puerto: ${DC_PORT[$key]})"
            echo -e "    ${Y}Creds: ${DC_CREDS[$key]}${W}"
            [ -n "${DC_NOTES[$key]}" ] && echo -e "    ${DIM}${DC_NOTES[$key]}${W}"
            echo ""
            found=$((found + 1))
        fi
    done
    [ "$found" -eq 0 ] && echo "  No se encontraron resultados para: $query"
}
