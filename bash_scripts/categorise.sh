#!/bin/bash

# Single-File Categorizer Script
# Usage: ./categorize_files.sh <target_directory> <output_file>

TARGET_DIR=${1:-.}          # Default: current directory
OUTPUT_FILE=${2:-./files.txt}  # Default: ./files.txt
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Initialize counters
declare -A FILE_COUNTS=(
    [bash]=0
    [yaml]=0
    [terraform]=0
    [other]=0
)

# Clear previous output file
> "$OUTPUT_FILE"

# Write header to output file
echo "# File Categorization Report" >> "$OUTPUT_FILE"
echo "# Generated: $(date)" >> "$OUTPUT_FILE"
echo "# Target Directory: $TARGET_DIR" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"

# Process files and append to single file
process_files() {
    local file="$1"
    local extension="${file##*.}"

    case "${extension,,}" in
        sh)
            ((FILE_COUNTS[bash]++))
            echo -e "\n# BASH SCRIPT: $file\n" >> "$OUTPUT_FILE"
            ;;
        yaml|yml)
            ((FILE_COUNTS[yaml]++))
            echo -e "\n# YAML FILE: $file\n" >> "$OUTPUT_FILE"
            ;;
        tf)
            ((FILE_COUNTS[terraform]++))
            echo -e "\n# TERRAFORM FILE: $file\n" >> "$OUTPUT_FILE"
            ;;
        *)
            ((FILE_COUNTS[other]++))
            return
            ;;
    esac

    # Append file contents with border
    echo "===== START CONTENT =====" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo -e "\n===== END CONTENT =====\n" >> "$OUTPUT_FILE"
}

# Main processing
echo "Starting processing at $(date)..."
while IFS= read -r -d '' file; do
    echo "Processing: $file"
    process_files "$file"
done < <(find "$TARGET_DIR" -type f \( -iname "*.sh" -o -iname "*.yaml" -o -iname "*.yml" -o -iname "*.tf" \) -print0)

# Append summary to the same file
echo "==========================================" >> "$OUTPUT_FILE"
echo "# Processing Summary" >> "$OUTPUT_FILE"
echo "# Completion time: $(date)" >> "$OUTPUT_FILE"
echo "# Bash scripts (.sh): ${FILE_COUNTS[bash]}" >> "$OUTPUT_FILE"
echo "# YAML files (.yaml/.yml): ${FILE_COUNTS[yaml]}" >> "$OUTPUT_FILE"
echo "# Terraform files (.tf): ${FILE_COUNTS[terraform]}" >> "$OUTPUT_FILE"
echo "# Other files ignored: ${FILE_COUNTS[other]}" >> "$OUTPUT_FILE"

echo "Processing complete. Results saved to: $OUTPUT_FILE"
echo "Total files processed:"
echo "- Bash scripts (.sh): ${FILE_COUNTS[bash]}"
echo "- YAML files (.yaml/.yml): ${FILE_COUNTS[yaml]}"
echo "- Terraform files (.tf): ${FILE_COUNTS[terraform]}"
echo "- Other files ignored: ${FILE_COUNTS[other]}"