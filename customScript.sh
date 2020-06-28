#!/bin/bash
#version 1.0
function dyno(){
    
    declare -A commands
    commands=(
        [open]="Opens current folder"
        [script]="Open the 'dyno' Script file"
        [source]="Source the Current file in Shell"
        [add]="Add another source script"
        [new]="Add a New Script to folder"
        [help]="List all the commands the available"
        [reset]="Reset the script to the factory defaults"
    )
    
    #The following code helps in auto completion
    allCommands=""
    for key in ${!commands[@]}; do
        allCommands+="${key} "
    done
    
    complete -W "${allCommands}" dyno
    
    case $1 in
        
        "open")
            echo "Opening Current Folder"
            nautilus .
        ;;
        "script")
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
                    echo "source \"$fullPath\""  >> "$BASH_SOURCE"
                    source "$BASH_SOURCE"
                fi
            else
                echo "$(realpath -m $fullPath) File does not exist."
            fi
        ;;
        "new")
            read -e -p "Enter the Directory of your Project: " FILE
            fullPath=$(realpath -m $FILE | sed 's/\~\///g')
            echo $fullPath
            if test -d "$fullPath"; then
                
                read -e -p "Enter the NAME (single word) of the project: " name
                
                echo "Downloading script template"
                cd "$fullPath"
                wget https://raw.githubusercontent.com/ashindiano/customScript/master/template.sh
                if test -f "template.sh"; then
                    
                    sed -i "s|_path_|\"$fullPath\"|g" "template.sh"
                    sed -i "s/template/$name/g" "template.sh"
                    mv "template.sh"  "$name.sh"
                    
                    echo "Adding $fullPath/$name.sh to Bash sources list "
                    echo "source \"$fullPath/$name.sh\""  >> "$(dirname "${BASH_SOURCE[0]}")/.nestedScripts"
                    source "$BASH_SOURCE"
                    echo "Success: Project $name created "
                    echo "You can start using ' $name ' command"
                else
                    echo "File Download Error " >&2
                fi
                
            else
                echo "Directory does not exist."
            fi
            
        ;;
        "source")
            echo "Sourcing $BASH_SOURCE"
            
            source "$BASH_SOURCE"
        ;;
        "reset")
            echo "Are you sure you wanna reset Dyno? Yes/No"
            read answer
            if [["$answer" == "Yes"]]; then
                sed '/source/,$d'
            fi
        ;;
        "help"|"h"|"--help"|"-h")
            for key in ${!commands[@]}; do
                echo ${key} - ${commands[${key}]}
            done
        ;;
        
    esac
}

dyno #Run atleast once to list all autocomplete values
alias bye="systemctl poweroff"
alias reboo="systemctl reboot"
source "$(dirname "${BASH_SOURCE[0]}")/.nestedScripts"
cd # Go back to the default folder