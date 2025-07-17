#!/usr/bin/env bash

# === VM SYNC CLI TOOL ===
# Date created: 2025-07-17
# Description: Sync Parallels .pvm files between two macOS hosts via Tailscale + rsync.
# Author: ChatGPT & Jerid Francom

# --- CONFIGURATION ---
LOCAL_VM_PATH="$HOME/Parallels"
VM_NAME="${1:-macOS.macvm}"  # Use first argument or default to macOS.macvm

# Show usage if --help is requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  echo "Usage: $0 [VM_NAME]"
  echo "  VM_NAME: Name of the .pvm file to sync (default: macOS.macvm)"
  echo "  Example: $0 nixOS.pvm"
  exit 0
fi

# Remote host configurations
REMOTE_HOST_MACMINI="jeridf@mac-minicore.gerbil-matrix.ts.net"
REMOTE_HOST_MACBOOK="francojc@macbook-airborne.gerbil-matrix.ts.net"
REMOTE_VM_PATH="~/Parallels"
LOGFILE="$HOME/rsync_vm_sync.log"

# --- FUNCTIONS ---

function check_directories() {
    if [[ ! -d "$LOCAL_VM_PATH" ]]; then
        echo "📁 Creating local Parallels directory: $LOCAL_VM_PATH"
        mkdir -p "$LOCAL_VM_PATH"
    fi
}

function check_remote_directories() {
    REMOTE_HOST=$1
    HOST_DISPLAY=$(echo "$REMOTE_HOST" | cut -d'@' -f2)
    echo "🔍 Checking remote Parallels directory on $HOST_DISPLAY..."
    ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no "$REMOTE_HOST" "mkdir -p \$HOME/Parallels"
    echo "✅ Remote directory verified on $HOST_DISPLAY"
}

function check_vm_shutdown() {
    echo "⚠️  Ensure that the VM is fully shut down before syncing."
    read -r -p "Have you shut down the VM? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo "❌ Aborting sync. Please shut down the VM first."
        exit 1
    fi
}

function sync_to_remote() {
    REMOTE_HOST=$1
    HOST_DISPLAY=$(echo "$REMOTE_HOST" | cut -d'@' -f2)
    REMOTE_USER=$(echo "$REMOTE_HOST" | cut -d'@' -f1)
    echo "🔄 Syncing $VM_NAME to $HOST_DISPLAY (user: $REMOTE_USER)..."
    rsync -avh --progress --delete -e "ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no" \
        "$LOCAL_VM_PATH/$VM_NAME/" \
        "$REMOTE_HOST:$REMOTE_VM_PATH/$VM_NAME/" | tee -a "$LOGFILE"
    echo "✅ Sync complete to $HOST_DISPLAY"
}

function sync_from_remote() {
    REMOTE_HOST=$1
    HOST_DISPLAY=$(echo "$REMOTE_HOST" | cut -d'@' -f2)
    REMOTE_USER=$(echo "$REMOTE_HOST" | cut -d'@' -f1)
    echo "⬅️  Syncing $VM_NAME from $HOST_DISPLAY (user: $REMOTE_USER) to local machine..."
    rsync -avh --progress --delete -e "ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no" \
        "$REMOTE_HOST:$REMOTE_VM_PATH/$VM_NAME/" \
        "$LOCAL_VM_PATH/$VM_NAME/" | tee -a "$LOGFILE"
    echo "✅ Sync from $HOST_DISPLAY complete"
}

function show_menu() {
    clear
    echo "🖥  VM Sync CLI Tool"
    echo "======================="
    echo "VM: $VM_NAME"
    echo "======================="
    echo "1. Push VM → Mac mini"
    echo "2. Pull VM ← Mac mini"
    echo "3. Push VM → MacBook"
    echo "4. Pull VM ← MacBook"
    echo "5. Exit"
    echo "======================="
    read -p "Choose an option [1-5]: " choice

    case $choice in
        1)
            check_directories
            check_remote_directories $REMOTE_HOST_MACMINI
            check_vm_shutdown
            sync_to_remote $REMOTE_HOST_MACMINI
            ;;
        2)
            check_directories
            check_remote_directories $REMOTE_HOST_MACMINI
            check_vm_shutdown
            sync_from_remote $REMOTE_HOST_MACMINI
            ;;
        3)
            check_directories
            check_remote_directories $REMOTE_HOST_MACBOOK
            check_vm_shutdown
            sync_to_remote $REMOTE_HOST_MACBOOK
            ;;
        4)
            check_directories
            check_remote_directories $REMOTE_HOST_MACBOOK
            check_vm_shutdown
            sync_from_remote $REMOTE_HOST_MACBOOK
            ;;
        5)
            echo "👋 Exiting."
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Try again."
            ;;
    esac
}

# --- MAIN LOOP ---
while true; do
    show_menu
    read -r -p "Press Enter to continue..." _
done
