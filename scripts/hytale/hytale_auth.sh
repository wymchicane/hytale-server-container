#!/bin/sh
# Note: Do NOT use set -eu — the background monitoring subshell must not exit on non-zero returns

# ==========================================
# HELPER FUNCTIONS
# ==========================================

init_auth_pipes() {
    AUTH_PIPE="/tmp/hytale-console.in"
    AUTH_OUTPUT_LOG="/tmp/hytale-server.log"
    rm -f "$AUTH_PIPE" "$AUTH_OUTPUT_LOG"
    mkfifo "$AUTH_PIPE"
    touch "$AUTH_OUTPUT_LOG"
    export AUTH_PIPE
    export AUTH_OUTPUT_LOG
}

generate_hardware_id() {
    HARDWARE_ID_FILE="$BASE_DIR/.hardware-id"

    if [ ! -f "$HARDWARE_ID_FILE" ]; then
        # Generate deterministic ID from container name + static salt
        CONTAINER_NAME="${HOSTNAME:-hytale-server}"
        SALT="hytale-server-container-hardware-id-v1"
        printf '%s-%s' "$CONTAINER_NAME" "$SALT" | sha256sum | cut -d' ' -f1 > "$HARDWARE_ID_FILE"
    fi

    HARDWARE_ID="$(cat "$HARDWARE_ID_FILE")"
}

check_hardware_id() {
    log_step "Hardware ID"

    if [ -f "/etc/machine-id" ] && [ -s "/etc/machine-id" ]; then
        HARDWARE_ID="$(cat /etc/machine-id)"
        printf "${GREEN}${HARDWARE_ID}${NC}\n"
        log_success

        if [ -f "$BASE_DIR/auth.enc" ]; then
            log_step "Credential Persistence"
            printf "${GREEN}enabled (auth.enc file found)${NC}\n"
            RUN_AUTO_AUTH="FALSE"
        else
            log_step "Credential Persistence"
            printf "${YELLOW}not configured${NC}\n"
        fi
    else
        generate_hardware_id
        printf "${CYAN}${HARDWARE_ID}${NC} (auto-generated)${NC}\n"
        log_success
        printf "    ${DIM}↳ Info:${NC} Stored in ${BASE_DIR}/.hardware-id\n"

        if [ -f "$BASE_DIR/auth.enc" ]; then
            log_step "Credential Persistence"
            printf "${GREEN}enabled (auth.enc file found)${NC}\n"
            RUN_AUTO_AUTH="FALSE"
        else
            log_step "Credential Persistence"
            printf "${YELLOW}not configured${NC}\n"
        fi
    fi
}

start_auth_monitor() {
    (
        sleep 5

        LOG_FILE=""
        for i in $(seq 1 30); do
            for f in /home/container/Server/logs/*_server.log; do
                if [ -f "$f" ]; then
                    LOG_FILE="$f"
                    break 2
                fi
            done
            sleep 2
        done

        if [ -n "$LOG_FILE" ] && [ -f "$LOG_FILE" ]; then
            tail -F "$LOG_FILE" 2>/dev/null | while IFS= read -r line || [ -n "$line" ]; do
                case "$line" in
                    *"Hytale Server Booted!"*)
                        sleep 2
                        echo "/auth login device" > "$AUTH_PIPE" 2>/dev/null || true
                        ;;
                esac

                case "$line" in
                    *"Multiple profiles available"*)
                        sleep 1
                        echo "/auth select $AUTH_SELECT_PROFILE" > "$AUTH_PIPE" 2>/dev/null || true
                        ;;
                esac

                case "$line" in
                    *"Authentication successful!"*|*"Server is already authenticated."*)
                        sleep 1
                        echo "/auth persistence Encrypted" > "$AUTH_PIPE" 2>/dev/null || true
                        break
                        ;;
                esac
            done
        fi
    ) &
    AUTH_PID=$!
}

# ==========================================
# MAIN EXECUTION FLOW
# ==========================================

log_section "Authentication Management"

RUN_AUTO_AUTH="TRUE"

init_auth_pipes
check_hardware_id

if [ "$RUN_AUTO_AUTH" = "TRUE" ]; then
    start_auth_monitor
fi

printf "\n"