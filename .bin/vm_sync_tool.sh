#!/usr/bin/env bash

# === VM SYNC CLI TOOL ===
# Date created: 2025-07-17
# Description: Sync Parallels .pvm files between two macOS hosts via Tailscale + rsync.
# Author: ChatGPT & Jerid Francom

# --- CONFIGURATION ---
LOCAL_VM_PATH="$HOME/Parallels"
VM_NAME="Ubuntu.pvm"
REMOTE_USER="jeridf"
REMOTE_HOST_MACMINI="minicore.gerbil-matrix.ts.net"
REMOTE_HOST_MACBOOK="airborne.gerbil-matrix.ts.net"
REMOTE_VM_PATH="/Users/jeridf/Parallels"
LOGFILE="$HOME/rsync_vm_sync.log"

# --- FUNCTIONS ---

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
    echo "🔄 Syncing $VM_NAME to $REMOTE_HOST..."
    rsync -avh --progress --delete \
        "$LOCAL_VM_PATH/$VM_NAME/" \
        "$REMOTE_USER@$REMOTE_HOST:$REMOTE_VM_PATH/$VM_NAME/" | tee -a "$LOGFILE"
    echo "✅ Sync complete to $REMOTE_HOST"
}

function sync_from_remote() {
    REMOTE_HOST=$1
    echo "⬅️  Syncing $VM_NAME from $REMOTE_HOST to local machine..."
    rsync -avh --progress --delete \
        "$REMOTE_USER@$REMOTE_HOST:$REMOTE_VM_PATH/$VM_NAME/" \
        "$LOCAL_VM_PATH/$VM_NAME/" | tee -a "$LOGFILE"
    echo "✅ Sync from $REMOTE_HOST complete"
}

function show_menu() {
    clear
    echo "🖥  VM Sync CLI Tool"
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
            check_vm_shutdown
            sync_to_remote $REMOTE_HOST_MACMINI
            ;;
        2)
            check_vm_shutdown
            sync_from_remote $REMOTE_HOST_MACMINI
            ;;
        3)
            check_vm_shutdown
            sync_to_remote $REMOTE_HOST_MACBOOK
            ;;
        4)
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
