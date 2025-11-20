#!/data/data/com.termux/files/usr/bin/bash
mkdir -p ~/wrp/trash
cd ~/wrp/trash

termux-storage-get sample.pdf
if [ $? -ne 0 ]; then
  echo "Please Choose a file"
  exit 1
fi

pdfimages -j sample.pdf s
if [ $? -ne 0 ]; then
  echo "Error: pdfimages command failed."
  mupdf sample.pdf sample_fixed.pdf
  pdfimages -j sample_fixed.pdf s
fi

bash ../src/duplicate_remover.sh .

read -p "Enter the filename: " filename
filename="$filename".pdf

python ~/wrp/src/img2pdf.py $(ls -v *.jpg) -o "$filename"

mkdir -p /storage/emulated/0/Documents/processed/
mv "$filename" /storage/emulated/0/Documents/processed/

termux-open /storage/emulated/0/Documents/processed/"$filename"

rm -rf *

echo "Check /storage/Documents/processed/$filename"
