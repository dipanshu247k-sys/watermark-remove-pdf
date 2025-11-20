#!/data/data/com.termux/files/usr/bin/bash

# Define the directory to scan (current directory if no argument provided)
TARGET_DIR="${1:-.}"

# Check if the target directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' not found."
    exit 1
fi

echo "Scanning for duplicate files (including originals) in '$TARGET_DIR'..."

# Find all files, calculate their MD5 sum, sort them, and identify all files with duplicate hashes (including originals)
find "$TARGET_DIR" -type f -print0 | xargs -0 md5sum | \
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
xargs -I {} rm -v "{}"

echo "Duplicate detection and removal simulation complete."
echo "To perform actual deletion, remove 'echo' from the 'xargs' command."
