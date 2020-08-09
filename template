#!/bin/bash
#version 1.0

function template(){
    declare -A commands
    commands=(
        [open]="Opens current folder"
        [script]="Open the 'template' Script file"
        [source]="Source the Current file in Shell"
        [help]="List all the commands the available"
    )
    
    #The following code helps in auto completion
    allCommands=""
    for key in ${!commands[@]}; do
        allCommands+="${key} "
    done
    
    complete -W "${allCommands}" template
    #########
    
    cd _path_
    
    case $1 in
        
        "open")
            echo "Opening Current Folder"
            nautilus .
        ;;
        "script")
            echo "Opening $BASH_SOURCE"
            code "$BASH_SOURCE"
        ;;
        "source")
            echo "Sourcing $BASH_SOURCE"
            source "$BASH_SOURCE"
        ;;
        "help"|"h"|"--help"|"-h")
            for key in ${!commands[@]}; do
                echo ${key} - ${commands[${key}]}
            done
        ;;
        
    esac
}

template