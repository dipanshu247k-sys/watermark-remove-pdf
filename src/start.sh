#!/data/data/com.termux/files/usr/bin/bash
mkdir -p ~/wrp/trash
cd ~/wrp/trash

termux-storage-get sample_un.pdf
if [ $? -ne 0 ]; then
  echo "Please Choose a file"
  exit 1
fi

qpdf sample_un.pdf sample.pdf
pdfimages -j sample.pdf s

bash ../src/duplicate_remover.sh .

read -p "Enter the filename: " filename
filename="$filename".pdf

python ~/wrp/src/img2pdf.py $(ls -v *.jpg) -o "$filename"

mkdir -p /storage/emulated/0/Documents/processed/
mv "$filename" /storage/emulated/0/Documents/processed/

termux-open /storage/emulated/0/Documents/processed/"$filename"

rm -rf *

echo "Check /storage/Documents/processed/$filename"
