#!/bin/bash

pkg update && upgrade
LDFLAGS="-L/system/lib/" CFLAGS="-I/data/data/com.termux/files/usr/include/" pip install Pillow
pkg install termux-api python poppler gum
termux-setup-storage


if [[ "$TERMUX_VERSION" == googleplay* ]]; then
    echo "Termux is from Google Play Store version"
    echo "You need F-droid edition of Termux"
    echo 's|https://f-droid.org/en/packages/com.termux/|replacement|'
    exit 0
fi

cd ~
mkdir .watermark-remove-pdf
cd .watermark-remove-pdf
git clone --depth 1 https://github.com/dipanshu247k-sys/watermark-remove-pdf


echo "alias='python ~/.watermark-remove-pdf'/img2pdf.py" >> ~/.bashrc
echo "helpmeremove='python ~/.watermark-remove-pdf'/src/start.sh" >> ~/.bashrc
