function template(){
    local prjFolder="NOPATH"
    local -a commands
    local -a genericCommands=(
        "script::Open the 'template' Script file"
        "source::Source the Current file in Shell"
        "help::List all the commands the available"
        "rename::Renames the current command"
    )

    local -a folderCommands=(
        "open::Opens current folder"
        "code::Opens the folder in VS Code editor"
        "repo::Opens the respective git origin repo in the browser"
    )
    
    #The following code helps in auto completion
    local allCommands=""
    for index in "${genericCommands[@]}" ; do
        local key="${index%%::*}"
        allCommands+="${key} "
    done
    if [[ $prjFolder != "NOPATH" ]]; then
        for index in "${folderCommands[@]}" ; do
            local key="${index%%::*}"
            allCommands+="${key} "
        done
    fi
    local openCommand
    local OS
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

    if [[ $prjFolder != "NOPATH" ]]; then
        if [[ $# -eq 0 ]] || [[ "$1" != "indexCommands" ]]; then
            cd "$prjFolder"
        fi
   

        local packageJsonCommands=""
        if test -f "${prjFolder}/package.json"; then
            packageJsonCommands=$(jq '.scripts' "$prjFolder/package.json"  | sed 's/{/ /g' |  sed 's/}/ /g' | sed 's/\":/::/g' | sed 's/\"//g' | sed 's/ //g' | sed 's/,//g' )
            
            while read -r line
            do
                local key="${line%%::*}"
                allCommands+="${key} "          
            done <<< "$packageJsonCommands"
        fi
    

        if [[ ! $# -eq 0 && "$packageJsonCommands" == *"$1::"* ]]; then
            if test -f "${prjFolder}/yarn.lock"; then
                echo "yarn run  $1"
                yarn run "$1"
            else
                echo "npm run  $1"
                npm run "$1"
            fi
        fi
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
            
            local remote
            remote=$(git config --get remote.origin.url)
            if [[ $remote != *".git"* ]]; then
                echo " No Git Found"
            else
                remote=${remote//:/\/} 
                remote=${remote//git@/https:\/\/}
                $openCommand "$remote"
            fi
        ;;
        
        "rename")
            echo -n "You are about to rename the command $FUNCNAME ? (y/n) : " 
            read answer
            if [[ "$answer" == "y" ]]; then
                echo -n "Please enter the new command: "
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
            for index in "${genericCommands[@]}" ; do
                local key="${index%%::*}"
                local value="${index##*::}"
                echo ${key} - ${value}
            done
            if [[ $prjFolder != "NOPATH" ]]; then
                for index in "${folderCommands[@]}" ; do
                    local key="${index%%::*}"
                    local value="${index##*::}"
                    echo ${key} - ${value}
                done
                while read -r line
                do
                    local key="${line%%::*}"
                    local value="${line##*::}"
                    echo ${key} - ${value}
                done <<< "$packageJsonCommands"
            fi
        ;;
        
    esac
    
}

template indexCommands
