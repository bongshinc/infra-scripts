#!/bin/bash
PGDATA="/sw/pg_data"
PGUSER="appuser"
SOCKETDIR="/tmp/pgsql"

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

show_listen_status() {
    local PID=$1
    echo -e "${BLUE}=== PostgreSQL Listen Status (PID: ${PURPLE}$PID${BLUE})${NC} ===${NC}"
    
    # TCP Listen Status - 9 spaces indentation
    echo "TCP Listens:"
    TCP_COUNT=$(ss -tlnp 2>/dev/null | grep "pid=$PID" | wc -l)
    if [ $TCP_COUNT -eq 0 ]; then
        echo "         No TCP sockets listening"
    else
        ss -tlnp 2>/dev/null | grep "pid=$PID" | sed 's/^/    /'
    fi
    
    # Unix Sockets - 9 spaces indentation
    echo "Unix Sockets:"
    UNIX_COUNT=$(ss -lnp 2>/dev/null | grep "pid=$PID" | wc -l)
    if [ $UNIX_COUNT -eq 0 ]; then
        echo "         No Unix sockets"
    else
        ss -lnp 2>/dev/null | grep "pid=$PID" | sed 's/^/    /'
    fi
    
    # Configuration Summary - 9 spaces indentation
    if [ -f "$PGDATA/postgresql.conf" ]; then
        echo "Config Summary:"
        grep -E "(port|listen_addresses|unix_socket_directories)" "$PGDATA/postgresql.conf" | grep -v "^#" | head -3 | sed 's/^/    /'
    fi
}

case "$1" in
    start)
        echo -e "${BLUE}Starting PostgreSQL ($PGUSER instance)...${NC}"
        sudo -u $PGUSER /usr/bin/pg_ctl -D $PGDATA -l /sw/pg_data/log/postgresql-$(date +%a).log start
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ PostgreSQL started successfully${NC}"
            sleep 2
            PG_PID=$(sudo -u $PGUSER /usr/bin/pg_ctl -D $PGDATA status -q 2>/dev/null | grep "PID:" | awk '{print $2}')
            [ -n "$PG_PID" ] && show_listen_status $PG_PID
        else
            echo -e "${RED}✗ Failed to start PostgreSQL${NC}"
            echo -e "${YELLOW}Check logs:${NC}"
            tail -5 /sw/pg_data/log/postgresql-$(date +%a).log
        fi
        ;;
    stop)
        echo -e "${BLUE}Stopping PostgreSQL (appuser instance)...${NC}"
        sudo -u $PGUSER /usr/bin/pg_ctl -D $PGDATA stop
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ PostgreSQL stopped successfully${NC}"
        else
            echo -e "${RED}✗ Failed to stop PostgreSQL${NC}"
        fi
        ;;
    restart)
        echo -e "${BLUE}Restarting PostgreSQL...${NC}"
        $0 stop
        sleep 3
        $0 start
        ;;
    status)
        # Note: Original script checks for Korean text "서버가 실행 중임"
        # This version uses a more universal approach
        PG_STATUS=$(sudo -u $PGUSER /usr/bin/pg_ctl -D $PGDATA status 2>/dev/null)
        if echo "$PG_STATUS" | grep -qE "(server is running|서버가 실행 중임)"; then
            # More accurate PID extraction
            PID=$(ps aux | grep "[p]ostgres.*$PGDATA" | grep -v grep | awk '{print $2}' | head -1)
            if [ -z "$PID" ]; then
                PID=$(echo "$PG_STATUS" | grep -o 'PID: [0-9]*' | grep -o '[0-9]*')
            fi
            echo "$PG_STATUS"
            echo
            if [ -n "$PID" ]; then
                show_listen_status $PID
            else
                echo "Could not determine PID"
            fi
        else
            echo -e "${RED}PostgreSQL is not running${NC}"
            exit 1
        fi
        ;;
    logs)
        echo -e "${BLUE}=== Recent Logs ===${NC}"
        tail -20 /sw/pg_data/log/postgresql-$(date +%a).log
        ;;
    config)
        echo -e "${BLUE}=== postgresql.conf (network settings) ===${NC}"
        grep -E "(port|listen_addresses|unix_socket_directories)" "$PGDATA/postgresql.conf" | grep -v "^#" | while read line; do
            echo -e "${YELLOW}  $line${NC}"
        done
        ;;
    *)
        echo -e "${RED}Usage:${NC} $0 ${GREEN}{start|stop|restart|status|logs|config}${NC}"
        echo -e "  ${CYAN}status:${NC} shows PID + detailed colored listen status"
        exit 1
        ;;
esac
