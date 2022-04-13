function template(){
    declare -a commands
    commands=(
        "open::Opens current folder"
        "script::Open the 'template' Script file"
        "code::Open the folder in VS Code editor"
        "source::Source the Current file in Shell"
        "help::List all the commands the available"
        "rename::Renames the current command"
    )
    
    #The following code helps in auto completion
    allCommands=""
    for index in "${commands[@]}" ; do
        key="${index%%::*}"
        allCommands+="${key} "
    done
    
    cd "$( dirname "${BASH_SOURCE[0]}" )"

    getos(){
        case "$(uname -s)" in
        Darwin)
            openCommand="open"
            OS="mac"
            ;;

        Linux)
            openCommand="open"
            OS="linux"
            ;;

        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            openCommand="start"
            OS="windows"
            ;;
        esac
    }
    
    getos
    
    case $1 in
        
        "open")
            echo "Opening Current Folder"
            if [ $OS == "linux" ]; then 
                nautilus .
            elif [ $OS == "mac" ]; then
                open .
            elif [ $OS == "windows" ]; then
                start .
            fi
        ;;

        "indexCommands")
            complete -W "${allCommands}" template
        ;;

        "script")
            echo "Opening $BASH_SOURCE"
            code "$BASH_SOURCE"
        ;;
        
        "code")
            code .
         ;;
         
        "source")
            echo "Sourcing $BASH_SOURCE"
            source "$BASH_SOURCE"
        ;;
        
        "repo")
            echo "Opening current Git Repository in github.com" 

            remote=$(git config --get remote.origin.url)
            if [[ $remote != *".git"* ]]; then
                echo " No Git Found"
            else
                remote=${remote#*git@github.com:}   # remove prefix ending in "git@github.com:"
                remote=${remote%.git*}   # remove suffix starting with ".git"
                $open "https://github.com/$remote"
            fi
        ;;
        
        "rename")
            read -e -p "You are about to rename the command $FUNCNAME ? (y/n) : " answer
            if [[ "$answer" == "y" ]]; then
                echo "Please enter the new command: "
                read newCommandName
                if ! [ -x "$(command -v $newCommandName)" ]; then
                    sed -i -e "s/$FUNCNAME()/$newCommandName()/g" "${BASH_SOURCE[0]}" # replacing the function name
                    sed -i -e '$s'"/$FUNCNAME/$newCommandName/g" "${BASH_SOURCE[0]}" # replacing the command in last line
                    source "${BASH_SOURCE[0]}"
                    echo "Rename successful!!! $newCommandName  is effective now"        
                else
                    echo "Cannot use $newCommandName because this command already exists"
                fi
            fi
        ;;
        
        "help"|"h"|"--help"|"-h")
            for index in "${commands[@]}" ; do
                key="${index%%::*}"
                value="${index##*::}"
                echo ${key} - ${value}
            done
        ;;
        
    esac
}

template indexCommands
