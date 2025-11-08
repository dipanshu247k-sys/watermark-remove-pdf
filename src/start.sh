#!/bin/bash

cd /storage/emulated/0/
file_loc="(gum file)"
mkdir cache-watermark-remover
mkdir temp-images
cd cache-watermark-remover
pdfimages -j "$file_loc" temp-images/A

python ~/.watermark-remove-pdf/img2pdf.py  $(ls -v temp-images/*.jpg) -o ${variable##*/}
