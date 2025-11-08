#!/data/data/com.termux/files/usr/bin/bash



# Get file location from gum
file_loc=$(gum file /storage/emulated/0/)

# Handle if user cancels gum
if [[ -z "$file_loc" ]]; then
    echo "No file selected"
    exit 1
fi

# Extract just the filename (without directory path)
file_name="${file_loc##*/}"

# Create working directory if it doesn't exist
mkdir -p ~/.cache-watermark-remover/temp-images/

cd ~/.cache-watermark-remover

# Copy file with proper quoting
cp "$file_loc" "$file_name"

echo "FILE LOCATION: $file_loc"
echo "FILE NAME: $file_name"

# Process with qpdf - generate output name properly
output_processed="processed_${file_name}"
qpdf "$file_name" "$output_processed"

# Extract images with pdfimages
pdfimages -j "processed_${file_name}" temp-images/A

# Convert images back to PDF using array for proper file handling
python ~/.watermark-remove-pdf/img2pdf.py temp-images/*.jpg -o ~/"$file_name"
mv ~/"$file_name" /storage/emulated/0/Documents/

rm -rf *


echo "Processing complete! Output saved to /storage/Documents/$file_name"
