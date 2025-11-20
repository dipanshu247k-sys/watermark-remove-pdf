#!/data/data/com.termux/files/usr/bin/bash
#pkg update -y && pkg upgrade -y
pkg install -y python libjpeg-turbo termux-api poppler
LDFLAGS="-L/system/lib/" CFLAGS="-I/data/data/com.termux/files/usr/include/" pip install Pillow || pip install Pillow
clang ~/.watermark-remove-pdf/src/pdfrm.c -o /data/data/com.termux/files/usr/bin/pdfrm
rm -rf /data/data/com.termux/files/usr/etc/motd
until termux-setup-storage; do
    echo "Command failed, retrying..."
done
exit
