#!/bin/sh
set -eu

# Load dependencies
. "$SCRIPTS_PATH/utils.sh"

log_section "Hytale core initialization"
log_step "Evaluating installation status"

# Searches for the zip file
ZIP_FILE=""
for f in "$BASE_DIR"/*.zip; do
    if [ -e "$f" ]; then
        ZIP_FILE="$f"
        break # Found the first zip, stop looking
    fi
done

# Decision Logic
if [ -n "$ZIP_FILE" ]; then
    log_success "Update package detected" "Running update script..."
    exec sh "$SCRIPTS_PATH/hytale/hytale_update.sh"

elif [ ! -f "$SERVER_JAR_PATH" ]; then
    log_success "No installation found" "Running fresh download..."
    exec sh "$SCRIPTS_PATH/hytale/hytale_download.sh"

else
    # Server is already installed and no update zip exists
    log_success "Server up-to-date" "Skipping extraction. Place *.zip in $BASE_DIR to trigger an update."
fi