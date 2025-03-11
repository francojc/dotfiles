#!/usr/bin/env bash

# Setup script for Google Directory to Emailbook integration
# This script will install required dependencies and set up a cron job

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up Google Directory to Emailbook integration...${NC}"

# Check if the required packages are installed, but do not attempt to install them. Only provide a message and exit
echo -e "\n${YELLOW}Checking for required Python packages...${NC}"
if ! python3 -c "import googleapiclient, google.auth, google_auth_oauthlib" 2>/dev/null; then
    echo -e "${RED}Error: Required Python packages not found. Please enter the nix development shell first with:${NC}"
    echo -e "${RED}nix develop .bin -c bash${NC}"
    echo -e "${RED}Then re-run this setup script from within the nix shell.${NC}"
    exit 1
fi

# Create config directory
mkdir -p ~/.config
mkdir -p ~/.local/share/emailbook

# Check for the fetcher script
SCRIPT_PATH="$HOME/.bin/personal-contacts-fetcher.py"
if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "\n${YELLOW}The contacts fetcher script was not found at $SCRIPT_PATH${NC}"
    echo -e "${RED}Please ensure personal-contacts-fetcher.py exists in your .bin directory${NC}"
    exit 1
fi

# Set up cron job
echo -e "\n${YELLOW}How often would you like to update contacts?${NC}"
echo "1) Daily"
echo "2) Weekly"
echo "3) Monthly"
echo "4) No cron job (manual updates only)"
read -p "Enter your choice (1-4): " CRON_CHOICE

CRON_CMD="$SCRIPT_PATH --output ~/.emailbook.txt > ~/.emailbook.log 2>&1"

case $CRON_CHOICE in
    1)
        CRON_SCHEDULE="0 5 * * *"  # 5 AM daily
        CRON_DESC="daily at 5 AM"
        ;;
    2)
        CRON_SCHEDULE="0 5 * * 0"  # 5 AM on Sundays
        CRON_DESC="weekly on Sundays at 5 AM"
        ;;
    3)
        CRON_SCHEDULE="0 5 1 * *"  # 5 AM on the 1st of each month
        CRON_DESC="monthly on the 1st at 5 AM"
        ;;
    4)
        CRON_SCHEDULE=""
        echo -e "${GREEN}No cron job will be set up. You can run the script manually when needed.${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice. No cron job will be set up.${NC}"
        CRON_SCHEDULE=""
        ;;
esac

if [ -n "$CRON_SCHEDULE" ]; then
    # Check if crontab exists
    crontab -l > /tmp/current_crontab 2>/dev/null || echo "" > /tmp/current_crontab

    # Check if the cron job already exists
    if grep -q "$SCRIPT_PATH" /tmp/current_crontab; then
        # Update existing cron job
        sed -i "\|$SCRIPT_PATH|c\\$CRON_SCHEDULE $CRON_CMD" /tmp/current_crontab
    else
        # Add new cron job
        echo "$CRON_SCHEDULE $CRON_CMD" >> /tmp/current_crontab
    fi

    # Install new crontab
    crontab /tmp/current_crontab
    rm /tmp/current_crontab

    echo -e "${GREEN}Cron job set up to run $CRON_DESC${NC}"
fi

# Instructions for OAuth credentials
echo -e "\n${YELLOW}==== NEXT STEPS ====${NC}"
echo -e "1. Go to the Google Cloud Console (https://console.cloud.google.com/)"
echo -e "2. Create a new project for personal contacts sync"
echo -e "3. Enable the People API: ${GREEN}https://console.cloud.google.com/apis/library/people.googleapis.com${NC}"
echo -e "4. Configure OAuth consent screen: ${GREEN}https://console.cloud.google.com/apis/credentials/consent${NC}"
echo -e "5. Create OAuth credentials (Desktop application type)"
echo -e "6. Download the JSON credentials file"
echo -e "7. Save the file as: ${GREEN}~/.config/aerc/google-aerc-credentials.json${NC}"
echo -e "8. Run the script once to authenticate: ${GREEN}$SCRIPT_PATH${NC}"
echo -e "\n${GREEN}Contacts will be saved to: ~/.emailbook.txt${NC}"

echo -e "\n${GREEN}Setup complete!${NC}"
