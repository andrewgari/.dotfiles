#!/bin/bash

echo "=== Updating System ==="
sudo dnf update -y

echo "=== Cleaning Up ==="
sudo dnf autoremove -y
sudo dnf clean all

echo "=== System Updated! ==="

