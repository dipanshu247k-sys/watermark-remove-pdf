#!/usr/bin/env python3
"""
JPG Deduplication Tool
Groups identical JPG files by size first, then by content (hash),
and allows safe deletion of duplicates.
"""

import os
import hashlib
import json
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Tuple
import shutil
from datetime import datetime

def get_file_size(file_path: str) -> int:
    """Get file size in bytes."""
    return os.path.getsize(file_path)

def calculate_file_hash(file_path: str, algorithm: str = 'md5') -> str:
    """
    Calculate hash of file content for exact comparison.
    Uses MD5 for speed, but can be changed to SHA256 for more security.
    """
    hash_obj = hashlib.new(algorithm)
    try:
        with open(file_path, 'rb') as f:
            # Read file in chunks to handle large files efficiently
            for chunk in iter(lambda: f.read(8192), b''):
                hash_obj.update(chunk)
        return hash_obj.hexdigest()
    except (IOError, OSError) as e:
        print(f"Error reading file {file_path}: {e}")
        return None

def find_jpg_files(folder_path: str) -> List[str]:
    """Find all JPG files in the given folder (non-recursive)."""
    jpg_files = []
    try:
        for file in os.listdir(folder_path):
            file_path = os.path.join(folder_path, file)
            if os.path.isfile(file_path):
                if file.lower().endswith(('.jpg', '.jpeg')):
                    jpg_files.append(file_path)
    except PermissionError:
        print(f"Permission denied accessing {folder_path}")
    return jpg_files

def group_by_size(files: List[str]) -> Dict[int, List[str]]:
    """Group files by their size in bytes."""
    size_groups = defaultdict(list)
    for file_path in files:
        try:
            size = get_file_size(file_path)
            size_groups[size].append(file_path)
        except (IOError, OSError) as e:
            print(f"Error getting size of {file_path}: {e}")
    return size_groups

def group_by_hash(files: List[str], algorithm: str = 'md5') -> Dict[str, List[str]]:
    """Group files by their content hash."""
    hash_groups = defaultdict(list)
    for file_path in files:
        file_hash = calculate_file_hash(file_path, algorithm)
        if file_hash:
            hash_groups[file_hash].append(file_path)
    return hash_groups

def find_duplicates(folder_path: str, algorithm: str = 'md5') -> Dict[str, List[str]]:
    """
    Find duplicate JPG files in folder.
    Returns dict where each key is file hash and value is list of duplicate file paths.
    """
    print(f"Scanning folder: {folder_path}")

    # Step 1: Find all JPG files
    jpg_files = find_jpg_files(folder_path)
    if not jpg_files:
        print("No JPG files found in the folder.")
        return {}

    print(f"Found {len(jpg_files)} JPG files")

    # Step 2: Group by size (fast filter)
    print("\nStep 1: Grouping by file size...")
    size_groups = group_by_size(jpg_files)

    # Filter groups with more than one file (potential duplicates)
    potential_duplicates = [files for files in size_groups.values() if len(files) > 1]

    if not potential_duplicates:
        print("No potential duplicates found (all files have unique sizes).")
        return {}

    total_potential = sum(len(g) for g in potential_duplicates)
    print(f"Found {len(potential_duplicates)} size groups with {total_potential} potential duplicate files")

    # Step 3: Compare by hash within each size group
    print(f"\nStep 2: Comparing files by content ({algorithm} hash)...")
    duplicates = {}

    for size_group in potential_duplicates:
        hash_groups = group_by_hash(size_group, algorithm)
        # Add groups with more than one file to duplicates
        for file_hash, files in hash_groups.items():
            if len(files) > 1:
                duplicates[file_hash] = files

    if not duplicates:
        print("No exact duplicates found.")
        return {}

    print(f"Found {len(duplicates)} duplicate groups")
    return duplicates

def print_duplicate_report(duplicates: Dict[str, List[str]]) -> None:
    """Print a formatted report of duplicate files."""
    if not duplicates:
        print("No duplicates to report.")
        return

    print("\n" + "="*70)
    print("DUPLICATE FILES REPORT")
    print("="*70)

    total_duplicates = sum(len(files) for files in duplicates.values())
    total_wasted_space = 0

    for idx, (file_hash, files) in enumerate(duplicates.items(), 1):
        size = os.path.getsize(files[0])
        wasted = size * (len(files) - 1)
        total_wasted_space += wasted

        print(f"\nDuplicate Group {idx} ({len(files)} files)")
        print(f"  Hash: {file_hash}")
        print(f"  File size: {size:,} bytes ({size/1024/1024:.2f} MB)")
        print(f"  Wasted space: {wasted:,} bytes ({wasted/1024/1024:.2f} MB)")
        print(f"  Files:")
        for file_path in files:
            print(f"    - {file_path}")

    print("\n" + "="*70)
    print(f"Total duplicate groups: {len(duplicates)}")
    print(f"Total duplicate files: {total_duplicates}")
    print(f"Total wasted space: {total_wasted_space:,} bytes ({total_wasted_space/1024/1024:.2f} MB)")
    print("="*70)

def save_report_to_file(duplicates: Dict[str, List[str]], report_file: str = "duplicates_report.json") -> None:
    """Save duplicate report to JSON file."""
    report_data = {}
    for file_hash, files in duplicates.items():
        report_data[file_hash] = {
            "count": len(files),
            "size": os.path.getsize(files[0]),
            "files": files
        }

    try:
        with open(report_file, 'w') as f:
            json.dump(report_data, f, indent=2)
        print(f"\nReport saved to: {report_file}")
    except IOError as e:
        print(f"Error saving report: {e}")

def delete_duplicates_interactive(duplicates: Dict[str, List[str]]) -> None:
    """
    Interactively delete duplicate files.
    Keeps the first file in each group and offers to delete others.
    """
    if not duplicates:
        print("No duplicates to delete.")
        return

    total_freed = 0

    for idx, (file_hash, files) in enumerate(duplicates.items(), 1):
        print(f"\nDuplicate Group {idx}/{len(duplicates)}")
        print("Files:")
        for i, file_path in enumerate(files, 1):
            size = os.path.getsize(file_path)
            print(f"  {i}. {file_path} ({size:,} bytes)")

        print(f"\nKeeping: {files[0]}")
        print("Delete remaining files? (y/n): ", end="")

        if input().strip().lower() == 'y':
            for file_path in files[1:]:
                try:
                    os.remove(file_path)
                    size = os.path.getsize(files[0])
                    total_freed += size
                    print(f"  ✓ Deleted: {file_path}")
                except OSError as e:
                    print(f"  ✗ Error deleting {file_path}: {e}")
        else:
            print("  Skipped.")

    if total_freed > 0:
        print(f"\nTotal space freed: {total_freed:,} bytes ({total_freed/1024/1024:.2f} MB)")

def main():
    """Main function."""
    import sys

    # Get folder path from command line or prompt user
    if len(sys.argv) > 1:
        folder_path = sys.argv[1]
    else:
        folder_path = input("Enter the path to the folder with JPG files: ").strip()

    # Validate folder
    if not os.path.isdir(folder_path):
        print(f"Error: {folder_path} is not a valid directory.")
        return

    # Find duplicates
    duplicates = find_duplicates(folder_path)

    if not duplicates:
        print("\nNo duplicate files found.")
        return

    # Print report
    print_duplicate_report(duplicates)

    # Save report
    print("\nSave detailed report? (y/n): ", end="")
    if input().strip().lower() == 'y':
        report_file = f"duplicates_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        save_report_to_file(duplicates, report_file)

    # Delete duplicates
    print("\nDelete duplicate files? (y/n): ", end="")
    if input().strip().lower() == 'y':
        print("\nStarting deletion process (you'll be asked for each group)...")
        delete_duplicates_interactive(duplicates)
        print("\nDeletion process completed.")
    else:
        print("No files were deleted.")

if __name__ == "__main__":
    main()
