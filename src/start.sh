#!/data/data/com.termux/files/usr/bin/bash
mkdir -p ~/wrp/trash
cd ~/wrp/trash

termux-storage-get sample_un.pdf
while [ ! -f sample_un.pdf ]; do
  echo "Waiting for sample.pdf..."
  sleep 1
done

if [ "$1" = "fix" ]; then
    qpdf sample_un.pdf sample.pdf
else
    mv sample_un.pdf sample.pdf
fi
pdfimages -j sample.pdf s

bash ../src/duplicate_remover.sh

read -p "Enter the filename: " filename
filename="$filename".pdf

python ~/wrp/src/img2pdf.py $(ls -v *.jpg) -o "$filename"

mkdir -p /storage/emulated/0/Documents/processed/
mv "$filename" /storage/emulated/0/Documents/processed/


rm -rf *
termux-open /storage/emulated/0/Documents/processed/"$filename"

echo "Check /storage/Documents/processed/$filename"
