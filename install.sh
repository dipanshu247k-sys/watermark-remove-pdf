#!/data/data/com.termux/files/usr/bin/bash
pkg install -y python libjpeg-turbo termux-api poppler
pip install Pillow
rm -rf /data/data/com.termux/files/usr/etc/motd
termux-setup-storage
done

