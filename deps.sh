#!/bin/sh

set -eu

echo "==> Instalando dependencias para compilar dwm 6.8..."

sudo apt update

sudo apt install -y \
    build-essential \
    libx11-dev \
    libxinerama-dev \
    libxft-dev \
    libfontconfig1-dev

echo
echo "======================================"
echo " Dependencias instaladas correctamente"
echo "======================================"
