#!/bin/sh
# Note: Do NOT use set -eu here — the background monitoring subshell must not exit on non-zero returns
# (e.g., grep no-match returns 1, file-not-yet-available returns 2)

# Preload auth commands into the server console after the server signals readiness
# Skip auto-auth if credentials are already persisted AND hardware ID matches
log_section "Authentication Management"

# Initialize variable default
RUN_AUTO_AUTH="TRUE"

AUTH_PIPE="/tmp/hytale-console.in"
AUTH_OUTPUT_LOG="/tmp/hytale-server.log"
rm -f "$AUTH_PIPE" "$AUTH_OUTPUT_LOG"
mkfifo "$AUTH_PIPE"
touch "$AUTH_OUTPUT_LOG"

# Export for use in parent script
export AUTH_PIPE
export AUTH_OUTPUT_LOG

# Verify if a user-defined hardware environment ID exists; required for authentication persistence.
log_step "Checking Hardware ID"
if [ ! -f "/etc/machine-id" ]; then
    log_warning "Hardware ID not found" "Mount /etc/machine-id:/etc/machine-id:ro to enable encrypted credential persistence"
    printf "    ${DIM}↳ Info:${NC} Auto-auth will run on every startup without it\n"
elif [ ! -s "/etc/machine-id" ]; then
    log_warning "Hardware ID file is empty" "Ensure /etc/machine-id contains a valid machine identifier"
elif [ -f "$BASE_DIR/auth.enc" ]; then
    log_success
    log_step "Credential Persistence"
    printf "${GREEN}enabled (auth.enc file found)${NC}\n"
    RUN_AUTO_AUTH="FALSE"
else
    log_success
    log_step "Credential Persistence"
    printf "${YELLOW}not configured${NC}\n"
fi

# If auto-authentication is enabled, automatically execute the login command.
if [ "$RUN_AUTO_AUTH" = "TRUE" ]; then
    # Monitor logs and send auth command when ready
    (
        # Wait for the server to start creating the log file
        sleep 5
        
        # Poll for the log directory and most recent *_server.log file
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
            # Use tail -F (capital F) to follow by name and handle log rotation/creation
            # Run tail in a way that ensures line buffering across all platforms
            tail -F "$LOG_FILE" 2>/dev/null | while IFS= read -r line || [ -n "$line" ]; do
                
                # 1. Look for the boot confirmation to send the login command
                case "$line" in
                    *"Hytale Server Booted!"*)
                        sleep 2
                        echo "/auth login device" > "$AUTH_PIPE" 2>/dev/null || true
                        printf "[%s] ✔ Sent auth command to server\n" "$(date '+%H:%M:%S')" >> /tmp/hytale_auth.log 2>/dev/null || true
                        ;;
                esac

                # 2. Handle profile selection if prompted
                case "$line" in
                    *"Multiple profiles available"*)
                        sleep 1
                        echo "/auth select $AUTH_SELECT_PROFILE" > "$AUTH_PIPE" 2>/dev/null || true
                        printf "[%s] ✔ Selected profile %s\n" "$(date '+%H:%M:%S')" "$AUTH_SELECT_PROFILE" >> /tmp/hytale_auth.log 2>/dev/null || true
                        ;;
                esac

                # 3. Check for successful auth, set persistence, and exit the loop
                case "$line" in
                    *"Authentication successful!"*|*"Server is already authenticated."*)
                        sleep 1
                        echo "/auth persistence Encrypted" > "$AUTH_PIPE" 2>/dev/null || true
                        printf "[%s] ✔ Sent persistence command to server\n" "$(date '+%H:%M:%S')" >> /tmp/hytale_auth.log 2>/dev/null || true
                        break # Stops the tail process since auth is complete
                        ;;
                esac
                
            done
        fi
    ) &
    AUTH_PID=$!
fi

printf "\n"
