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

    if [[ $# -eq 0 ]] && [[ "$1" != "indexCommands" ]]; then
        cd path
    fi
    
    case $1 in
        
        "open")
            echo "Opening Current Folder"
            if [[ $OS == "linux" ]]; then 
                nautilus .
            elif [[ $OS == "mac" ]]; then
                open .
            elif [[ $OS == "windows" ]]; then
                start .
            fi
        ;;

        "indexCommands")
            complete -W "${allCommands}" template
        ;;

        "script")
            echo "Opening ${(%):-%x}"
            code "${(%):-%x}"
        ;;
        
        "code")
            code .
         ;;
         
        "source")
            echo "Sourcing ${(%):-%x}"
            source "${(%):-%x}"
        ;;
        
        "repo")
            echo "Opening current Git Repository in github.com"
            
            remote=$(git config --get remote.origin.url)
            if [[ $remote != *".git"* ]]; then
                echo " No Git Found"
            else
                remote=${remote//:/\/} 
                remote=${remote//git@/https:\/\/}
                $openCommand $remote
            fi
        ;;
        
        "rename")
            echo "You are about to rename the command $FUNCNAME ? (y/n) : " 
            read answer
            if [[ "$answer" == "y" ]]; then
                echo "Please enter the new command: "
                read newCommandName
                if ! [[ -x "$(command -v $newCommandName)" ]]; then
                    sed -i -e "s/$FUNCNAME()/$newCommandName()/g" "${(%):-%x}" # replacing the function name
                    sed -i -e '$s'"/$FUNCNAME/$newCommandName/g" "${(%):-%x}" # replacing the command in last line
                    source "${(%):-%x}"
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
