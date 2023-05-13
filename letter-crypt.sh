#!/bin/bash

version="1.1"
script_dir=$(dirname "$0")

usage(){
    echo "Usage:"
    echo ""
    echo "$0 -e|--encrypt <password> [<msg>]   Encrypt a message."
    echo "$0 -d|--decrypt <password> [<msg>]   Decrypt a message."
    echo "$0 -h|--help                         Display this help message."
    echo "$0 -v|--version                      Display the version number."
    echo "Options:"
    echo "-p|--paper-writable                  Format output for handwriting (default)."
    echo "-m|--machine                         No formatting of the output."
    echo "--base36                             Use base36 (a-z 0-9 lowercase) instead hexadecimal."
    echo "--                                   To separate the message in case it starts with '-'."
    echo ""
    echo "Examples:"
    echo ""
    echo "echo \"This is a message\" | $0 -e mypassword"
    echo "echo \"53616c7465645f...\" | $0 -d mypassword"
    echo "$0 -e mypassword -- -a"
    echo "$0 --help"
    echo "$0 --version"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

paper=true
operation=""
password=""
message=""
base36=false

while (( "$#" )); do
    case "$1" in
        -e|--encrypt)
            if [ -n "$operation" ]; then
                usage
            fi
            operation="encrypt"
            shift
            password=$1
            ;;
        -d|--decrypt)
            if [ -n "$operation" ]; then
                usage
            fi
            operation="decrypt"
            shift
            password=$1
            ;;
        -h|--help)
            usage
            ;;
        -v|--version)
            echo $version
            exit 0
            ;;
        -p|--paper-writable)
            paper=true
            ;;
        -m|--machine)
            paper=false
            ;;
        --base36)
            base36=true
            ;;
        --)
            shift
            message=$1
            ;;
        -*|--*=)
            echo "Error: Unsupported flag $1" >&2
            usage
            ;;
        *)
            if [ -n "$message" ]; then
                usage
            fi
            message=$1
            ;;
    esac
    shift
done

if [ -z "$operation" ] || [ -z "$password" ]; then
    usage
fi

if [ -z "$message" ]; then
    if [[ -t 0 ]]; then
        printf "Type the message and press CTRL+D to finish:\n\n"

        message=""
        while IFS= read -r line || [[ -n "$line" ]]; do
            message+=$line$'\n'
        done
    else
        read -d '' -r message
    fi
fi

if [ "$operation" = "encrypt" ]; then
    encrypted=$(echo -n "$message" | openssl enc -aes-256-cbc -salt -iter 1000000 -pbkdf2 -pass pass:$password | xxd -p | tr -d '\n')

    if $base36; then
        encrypted="$("$script_dir/base36.perl" "$encrypted")"
    fi

    if $paper; then
        printf "\nWrite down this to a paper:\n\nTo decrypt the message, please remove any numbers like 1), 2), 3), etc., at the start of each line, as well as any whitespaces and line breaks. Once you have cleaned the input, run the following command:\n\necho \"<hex>\" | xxd -r -p | openssl enc -aes-256-cbc -d -salt -iter 1000000 -pbkdf2 -pass pass:<password>\n\nReplacing <hex> with the encrypted message and <password> with the password. Or use the script letter-crypt with the option --decrypt.\n\n\n"
        echo "$encrypted" | fold -w4 | paste - - - - -d ' ' | awk '{printf("%4d) %s\n", NR, $0)}'
    else
        echo "$encrypted"
    fi
else
    clean_hex=$message

    if $base36; then
        clean_hex=$(echo "$clean_hex" | grep -E '^[0-9a-zA-Z )]*$')
    else
        clean_hex=$(echo "$clean_hex" | grep -E '^[0-9a-fA-F )]*$')
    fi

    clean_hex=$(echo "$clean_hex" | tr -d '[:blank:]')
    clean_hex=$(echo "$clean_hex" | sed 's/^[0-9]*)//g')
    clean_hex=$(echo "$clean_hex" | tr -d '\n')
    clean_hex=$(echo "$clean_hex" | tr '[:upper:]' '[:lower:]')

    if $base36; then
        clean_hex="$("$script_dir/base36.perl" "$clean_hex")"
    fi

    if $paper; then
        echo ""
    fi

    echo "$clean_hex" | xxd -r -p | openssl enc -aes-256-cbc -d -salt -iter 1000000 -pbkdf2 -pass pass:$password

    if $paper; then
        echo ""
    fi
fi
