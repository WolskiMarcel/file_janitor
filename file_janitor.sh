#!/usr/bin/env bash

display_start() {
    echo "File Janitor, 2024"
    echo "Powered by Bash"
    echo
}

display_info() {
    echo "Type $0 help to see available options"
}

display_help() {
    cat file-janitor-help.txt
}

display_list() {
    echo "Listing files in the current directory"
    echo
    ls -A1 | sort
}

is_f_d() {
    if [ -f "$1" ]; then
        echo "$1 is not a directory"
    else
        echo "$1 is not found"
    fi
}

list_args() {
    if [ -n "$2" ]; then
        if [ -d "$2" ]; then
            echo "Listing files in $2"
            ls -A1 "$2" | sort
        else
            is_f_d "$2"
        fi
    else
        display_list
    fi
}

report() {
    local path="$1"
    local tmp_files=$(find "$path" -maxdepth 1 -type f -name "*.tmp" 2>/dev/null)
    local log_files=$(find "$path" -maxdepth 1 -type f -name "*.log" 2>/dev/null)
    local py_files=$(find "$path" -maxdepth 1 -type f -name "*.py" 2>/dev/null)

    local tmp_count=$(echo "$tmp_files" | wc -l)
    local log_count=$(echo "$log_files" | wc -l)
    local py_count=$(echo "$py_files" | wc -l)

    local tmp_size=$(du -b $tmp_files 2>/dev/null | awk '{s+=$1} END {print s}')
    local log_size=$(du -b $log_files 2>/dev/null | awk '{s+=$1} END {print s}')
    local py_size=$(du -b $py_files 2>/dev/null | awk '{s+=$1} END {print s}')

    echo "$tmp_count tmp file(s), with total size of $tmp_size bytes"
    echo "$log_count log file(s), with total size of $log_size bytes"
    echo "$py_count py file(s), with total size of $py_size bytes"
}

#temporary solution
report_parent_dir() {
    local parent_dir="$1"

    local tmp_count=$(ls -A "$parent_dir"/*.tmp 2>/dev/null | wc -l)
    local tmp_size=$(du -b "$parent_dir"/*.tmp 2>/dev/null | awk '{s+=$1} END {print s}')

    local log_count=$(ls -A "$parent_dir"/*.log 2>/dev/null | wc -l)
    local log_size=$(du -b "$parent_dir"/*.log 2>/dev/null | awk '{s+=$1} END {print s}')

    local py_count=$(ls -A "$parent_dir"/*.py 2>/dev/null | wc -l)
    local py_size=$(du -b "$parent_dir"/*.py 2>/dev/null | awk '{s+=$1} END {print s}')

    echo "$parent_dir contains:"
    echo "$tmp_count tmp file(s), with total size of $tmp_size bytes"
    echo "$log_count log file(s), with total size of $log_size bytes"
    echo "$py_count py file(s), with total size of $py_size bytes"
}


display_report() {
    local target_path="$1"

    if [ -n "$target_path" ]; then
        if [ "$target_path" == ".." ]; then
            report_parent_dir "$PWD/.."
        elif [ -d "$target_path" ]; then
            echo "$target_path contains:"
            report "$target_path"
        else
            is_f_d "$target_path"
        fi
    else
        echo "The current directory contains:"
        report "$PWD"
    fi
}


display_start
if [ "$1" == "help" ]; then
    display_help
elif [ "$1" == "list" ]; then
    list_args "$@"
elif [ "$1" == "report" ]; then
    display_report "$2"
else
    display_info
fi