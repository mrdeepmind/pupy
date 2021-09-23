#!/bin/bash

# Check to make sure script is not initially run as root
if [ "$EUID" == 0 ]
  then echo "Please do not run as root. Script will prompt for sudo password."
  exit
fi

# Get username for regular user.
username=$(whoami)

# Start root section
sudo su root <<'EOF'

# Pacman update and installs
pacman -Syu
pacman -S python-pip curl libffi swig tcpdump python-virtualenv openssl wine mingw-w64 python2 python3

# Install Docker
pacman -S docker docker-compose
systemctl enable docker.service
systemctl enable docker.socket
systemctl enable containerd.service
systemctl start docker.service
systemctl start docker.socket
systemctl start containerd.service

# Add user to docker group
groupadd docker
usermod -aG docker $USER

# End of root section
EOF

PYTHON=python

$PYTHON --help >/dev/null
if [ ! $? -eq 0 ]; then
  PYTHON=python3
fi

# Create workspace at ~/pupyws
${PYTHON} create-workspace.py -E docker -P $HOME/pupy-workspace

print("If building process does not start, go into your pupy-arch folder and execute ./create-workspace.py by sudo.")
