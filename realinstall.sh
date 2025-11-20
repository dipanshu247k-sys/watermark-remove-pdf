#!/data/data/com.termux/files/usr/bin/bash
#pkg update -y && pkg upgrade -y
pkg install -y python-pip python ndk-sysroot clang make libjpeg-turbo
LDFLAGS="-L/system/lib/" CFLAGS="-I/data/data/com.termux/files/usr/include/" pip install Pillow
pip install Pillow


if [[ "$TERMUX_VERSION" == googleplay* ]]; then
    echo "Termux is from Google Play Store version"
    echo "You need F-droid edition of Termux"
    exit 0
fi


pkg install -y termux-api poppler gum qpdf
echo "alias img2pdf='python ~/.watermark-remove-pdf/src/img2pdf.py'" >> ~/.bashrc
echo "alias helpmeremove='bash ~/.watermark-remove-pdf/src/start.sh'" >> ~/.bashrc
mkdir ~/.cache-watermark-remover
mkdir ~/.cache-watermark-remover/temp-images
rm -rf /data/data/com.termux/files/usr/etc/motd
termux-setup-storage
exit
