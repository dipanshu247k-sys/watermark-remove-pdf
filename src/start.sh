#!/data/data/com.termux/files/usr/bin/bash

cd ~/.watermark-remove-pdf/trash
termux-storage-get sample.pdf
pdfimages -j sample.pdf s
bash ../src/duplicate_remover.sh temp-images
read -p "Enter the filename: " filename
python ~/.watermark-remove-pdf/src/img2pdf.py $(ls -v *.jpg) -o "$filename"
mkdir -p /storage/emulated/0/Documents/processed/
mv "$filename" /storage/emulated/0/Documents/processed/
termux-open /storage/emulated/0/Documents/processed/"$filename"
rm -rf *
echo "Check /storage/Documents/processed/$file_name"
