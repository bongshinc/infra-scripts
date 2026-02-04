#!/bin/bash

# =================================================================
# Winning Business Infrastructure - Tomcat Master Controller (v1.8)
# =================================================================

# [Environment Variables]
#CATALINA_HOME="/sw/tomcat"   # Symbolic link
CATALINA_HOME="/sw/TOMCAT/apache-tomcat-8.5.99"  # Actual location. Process displays actual path.
LOG_DIR="$CATALINA_HOME/logs"
ARCHIVE_DIR="$LOG_DIR/archived"  # Directory for isolated archiving
CATALINA_OUT="$LOG_DIR/catalina.out"

# SSL Certificate Validity Check
KEYSTORE_PATH="$CATALINA_HOME/ssl/keystore_ec.jks"
ALIAS="tomcat_ec"             # EC (Elliptic Curve) recommended over RSA for lighter weight
KEYSTORE="keystore_ec.jks"
STOREPASS="changeME!"
KEYPASS="$STOREPASS"          # Usually set the same as store password

CHECK_PORTS=(18080 18443 18005)

# [Color Definitions]
BG_SKY_SOFT="\e[38;5;0;48;5;117m"
RESET="\e[0m"
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"

# [Log Isolation and Archiving Function]
# [Unified Log Management Function]
archive_log() {
    # 1. Auto-create archive directory
    [ ! -d "$ARCHIVE_DIR" ] && mkdir -p "$ARCHIVE_DIR"

    # 2. Isolate catalina.out (date-time-minute)
    if [ -s "$CATALINA_OUT" ]; then
        TIMESTAMP=$(date +%Y%m%d-%H%M)
        mv "$CATALINA_OUT" "$ARCHIVE_DIR/catalina.out.$TIMESTAMP"
        gzip "$ARCHIVE_DIR/catalina.out.$TIMESTAMP" & # Background compression
    fi

    # 3. Bulk move access logs (ultra-fast processing with xargs)
    # -print0 and -0 options safely handle filenames with spaces
    find "$LOG_DIR" -maxdepth 1 -name "localhost_access_log.*" -type f -print0 | \
    xargs -0 -I {} mv {} "$ARCHIVE_DIR/" 2>/dev/null

    # 4. Bulk compress uncompressed files in archive and delete files older than 30 days
    find "$ARCHIVE_DIR" -type f ! -name "*.gz" -print0 | xargs -0 -r gzip &
    find "$ARCHIVE_DIR" -mtime +30 -delete 2>/dev/null
    
    echo -e "✅ [SUCCESS] All past logs have been organized into the archived directory."
}

# [Animation Function]
loading_animation() {
    local duration=$1
    local spin='-\|/'
    local end=$((SECONDS + duration))
    tput civis 2>/dev/null
    while [ $SECONDS -lt $end ]; do
        local remaining=$((end - SECONDS))
        for i in {0..3}; do
            printf "\r${spin:$i:1} ⏳ [WAIT] Waiting for system engine and port activation... (${remaining}s)"
            sleep 0.25
        done
    done
    printf "\r%-70s\r" "" 
    echo -e "✅ [COMPLETE] System engine and port activation complete!"
    tput cnorm 2>/dev/null
}

get_pid() {
    echo $(ps -ef | grep "catalina.base=$CATALINA_HOME" | grep -v grep | awk '{print $2}')
}

print_report() {
    PID=$(get_pid)
    echo -e "\n------------------------------------------------------------"
    echo "📊 [REPORT] Tomcat Infrastructure Status Report"
    echo "------------------------------------------------------------"
    
    if [ ! -z "$PID" ]; then
        echo -e "✅ Process Status: ${GREEN}RUNNING${RESET} (PID: $PID)"
    else
        echo -e "⏹️  Process Status: ${RED}STOPPED${RESET}"
    fi

    echo -e "\n🌐 Port Listen Detailed Check:"
    for PORT in "${CHECK_PORTS[@]}"; do
        IS_LISTEN=$(ss -ntlp | grep -w ":$PORT" 2>/dev/null)
        if [ ! -z "$IS_LISTEN" ]; then
            printf "   - Port %-5s: [  ${GREEN}OK${RESET}  ] (Listening)\n" "$PORT"
        else
            printf "   - Port %-5s: [ ${RED}FAILED${RESET} ] (NOT LISTENING!)\n" "$PORT"
        fi
    done

    # [Certificate Information Extraction Logic]
    if [ -f "$KEYSTORE_PATH" ]; then
        # Extract and format date from keytool result
        EXPIRY_RAW=$(keytool -list -v -keystore "$KEYSTORE_PATH" -storepass "$STOREPASS" -alias "$ALIAS" 2>/dev/null | grep "until" | sed 's/.*until: //')
        
        if [ ! -z "$EXPIRY_RAW" ]; then
            # D-Day calculation (using Linux date command)
            EXPIRY_SEC=$(date -d "$EXPIRY_RAW" +%s)
            NOW_SEC=$(date +%s)
            DIFF_DAYS=$(( (EXPIRY_SEC - NOW_SEC) / 86400 ))

            echo -e "\n🔐 SSL Certificate Security Info:"
            echo "   - Certificate Alias: $ALIAS"
            
            # Highlight in yellow when expiration is imminent (30 days threshold)
            if [ $DIFF_DAYS -lt 30 ]; then
                echo -e "   - Certificate Expiry: ${YELLOW}$EXPIRY_RAW (D-$DIFF_DAYS)${RESET}"
            else
                echo -e "   - Certificate Expiry: $EXPIRY_RAW (D-$DIFF_DAYS)"
            fi
        fi
    fi
    echo -e "------------------------------------------------------------\n"
}

start_tomcat() {
    PID=$(get_pid)
    if [ ! -z "$PID" ]; then
        echo -e "\n⚠️  [WARN] Tomcat is already running (PID: $PID)."
    else
        # 🚀 Archive logs before starting
        archive_log
        
        echo -e "\n${BG_SKY_SOFT} 🚀 [START] Starting Tomcat service... ${RESET}"
        $CATALINA_HOME/bin/startup.sh
        loading_animation 5
        print_report
    fi
}

stop_tomcat() {
    PID=$(get_pid)
    if [ ! -z "$PID" ]; then
        echo -e "\n${BG_SKY_SOFT} 🛑 [STOP] Attempting graceful shutdown (PID: $PID)... ${RESET}"
        $CATALINA_HOME/bin/shutdown.sh
        sleep 2
        print_report
    else
        echo -e "\n✅ [INFO] No process to stop.\n"
    fi
}

case "$1" in
    start)   start_tomcat ;;
    stop)    stop_tomcat ;;
    restart) echo -e "\n🔄 [RESTART] Initiating restart sequence"; stop_tomcat; start_tomcat ;;
    status)  print_report ;;
    *)       echo -e "\n💡 [USAGE] $0 {start|stop|restart|status}\n"; exit 1 ;;
esac
