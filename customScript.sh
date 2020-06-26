#!/bin/bash
#version 1.0
declare -A commands
commands=(
    [open]="Opens current folder"
    [script]="Open the 'dyno' Script file"
    [source]="Source the Current file in Shell"
    [add]="Add another source script"
    [help]="List all the commands the available"
    [reset]="Reset the script to the factory defaults"
)

#The following code helps in auto completion
allCommands=""
for key in ${!commands[@]}; do
    allCommands+="${key} "
done

complete -W "${allCommands}" dyno
#########

function dyno(){
    case $1 in
        
        "open")
            cd ~
            echo "Opening Current Folder"
            nautilus .
        ;;
        "script")
            cd ~
            echo "Opening $BASH_SOURCE"
            code "$BASH_SOURCE"
        ;;
        "add")
            read -e -p "Enter the path of the new script to source: " FILE
            fullPath=$(realpath -m $FILE | sed 's/\~\///g')
            if test -f "$fullPath"; then
                if  [[ "$fullPath" -ef "$BASH_SOURCE" ]]; then
                    echo "You cannot add Me Again"
                else
                    echo "source $fullPath"  >> "$BASH_SOURCE"
                    source "$BASH_SOURCE"
                fi
            else
                echo "$(realpath -m $fullPath) File does not exist."
            fi
        ;;
        "source")
            cd ~
            echo "Sourcing $BASH_SOURCE"
            
            source "$BASH_SOURCE"
        ;;
        "reset")
            echo "Are you sure you wanna reset Dyno? Yes/No"
            read answer
            # if $answer = "Yes"
            
            # fi
        ;;
        "help"|"h"|"--help"|"-h")
            for key in ${!commands[@]}; do
                echo ${key} - ${commands[${key}]}
            done
        ;;
        
    esac
}

alias bye="systemctl poweroff"
