#!/data/data/com.termux/files/usr/bin/bash

# Define the directory to scan (current directory if no argument provided)
# TARGET_DIR="${1:-.}"
TARGET_DIR="."

# Check if the target directory exists
# if [[ ! -d "$TARGET_DIR" ]]; then
    # echo "Error: Directory '$TARGET_DIR' not found."
    # exit 1
# fi

echo "Scanning for watermark files "

# Find all files, calculate their MD5 sum, sort them, and identify all files with duplicate hashes (including originals)
deleted_count=$(find "$TARGET_DIR" -type f -print0 | xargs -0 md5sum | \
sort | \
awk '
{
    count[$1]++
    files[$1] = files[$1] ? files[$1] "\n" $2 : $2
}
END {
    for (hash in count)
        if (count[hash] > 1)
            print files[hash]
}' | \
xargs -I {} rm -v "{}" 2>&1 | tee /dev/null | wc -l)

echo "Number of files deleted: $deleted_count"
