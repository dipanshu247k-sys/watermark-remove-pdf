#!/data/data/com.termux/files/usr/bin/bash
pkg install git
cd ~
mkdir .watermark-remove-pdf
cd .watermark-remove-pdf
git clone --depth 1 https://github.com/dipanshu247k-sys/watermark-remove-pdf .
chmod +x realinstall.sh
bash realinstall.sh
