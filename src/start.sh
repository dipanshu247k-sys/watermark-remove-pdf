#!/data/data/com.termux/files/usr/bin/bash
mkdir -p ~/wrp/trash
cd ~/wrp/trash

read -p "Enter the filename: " filename
filename="$filename".pdf

termux-storage-get sample_un.pdf
while [ ! -f sample_un.pdf ]; do
  sleep 1
done
echo "Detected File"

if [ "$1" = "fix" ]; then
    qpdf sample_un.pdf sample.pdf
    echo "Fixing the file"
else
    mv sample_un.pdf sample.pdf
fi
pdfimages -j sample.pdf s
echo "Extracted all images"

if [ "$1" != "fix" ]; then
    rm *.ppm
fi
echo "Checking for duplicates"
bash ../src/duplicate_remover.sh


echo "Making PDF file from images"
python ~/wrp/src/img2pdf.py $(ls -v *.jpg) -o "$filename"

mkdir -p /storage/emulated/0/Documents/processed/
mv "$filename" /storage/emulated/0/Documents/processed/


rm -rf *
termux-open /storage/emulated/0/Documents/processed/"$filename"

echo "Check /storage/Documents/processed/$filename"
