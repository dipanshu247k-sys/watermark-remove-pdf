#!/data/data/com.termux/files/usr/bin/bash
cd ~/wrp
pkg install -y python libjpeg-turbo termux-api poppler mupdf
pip install Pillow
rm -rf /data/data/com.termux/files/usr/etc/motd
termux-setup-storage
chmod +x src/pdfrm
cp src/pdfrm /data/data/com.termux/files/usr/bin/pdfrm
