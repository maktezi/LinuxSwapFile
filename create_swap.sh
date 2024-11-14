#!/bin/bash

# Set desired swapfile size (e.g., 8G for 8 GB)
SWAP_SIZE="8G"

# Check if a swapfile exists and disable it if so
echo "Checking for existing swapfile..."
if grep -q '/swapfile' /etc/fstab; then
    echo "Existing swapfile found. Disabling and removing it..."
    sudo swapoff /swapfile
    sudo rm -f /swapfile
    sudo sed -i '/\/swapfile/d' /etc/fstab
else
    echo "No existing swapfile found. Proceeding with new swapfile creation..."
fi

# Create a new swapfile with specified size
echo "Creating a new swapfile of size $SWAP_SIZE..."
sudo fallocate -l $SWAP_SIZE /swapfile || { echo "fallocate failed, trying dd instead..."; sudo dd if=/dev/zero of=/swapfile bs=1M count=$(( ${SWAP_SIZE%G} * 1024 )); }
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Add swapfile entry to /etc/fstab to make it persistent
echo "Adding new swapfile to /etc/fstab..."
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Adjust swappiness settings
echo "Setting swappiness to 10..."
sudo sysctl vm.swappiness=10
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Display current swap status and settings
echo "New swapfile setup complete. Current swap status:"
sudo swapon --show
free -h
cat /proc/sys/vm/swappiness
