local ColorOff='\033[0m'
local Black='\033[0;30m'        # Black
local Red='\033[0;31m'          # Red
local Green='\033[0;32m'        # Green
local Yellow='\033[0;33m'       # Yellow
local Blue='\033[0;34m'         # Blue
local Purple='\033[0;35m'       # Purple
local Cyan='\033[0;36m'         # Cyan
local White='\033[0;37m'        # White

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
                echo -e "${Green}yarn run  $1${ColorOff}"
                yarn run "$1"
            else
                echo -e "${Green}npm run  $1${ColorOff}"
                npm run "$1"
            fi
        fi
    fi

    case $1 in
        
        "open")
            echo -e "${Green}Opening Current Folder${ColorOff}"
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
            echo -e "${Green}Opening ${(%):-%x}${ColorOff}"
            code "${(%):-%x}"
        ;;
        
        "code")
            code .
        ;;
        
        "source")
            echo -e "${Green}Sourcing ${(%):-%x}${ColorOff}"
            source "${(%):-%x}"
        ;;
        
        "repo")
            echo -e "${Green}Opening current Git Repository in github.com${ColorOff}"
            
            local remote
            remote=$(git config --get remote.origin.url)
            if [[ $remote != *".git"* ]]; then
                echo -e "${Red} No Git Found${ColorOff}"
            else
                remote=${remote//:/\/} 
                remote=${remote//git@/https:\/\/}
                $openCommand "$remote"
            fi
        ;;
        
        "rename")
            echo -n -e "${Yellow}You are about to rename the command $FUNCNAME ? (y/n) : ${ColorOff}" 
            read answer
            if [[ "$answer" == "y" ]]; then
                echo -n -e "${Yellow}Please enter the new command: ${ColorOff}"
                read newCommandName
                if ! [[ -x "$(command -v $newCommandName)" ]]; then
                    sed -i -e "s/$FUNCNAME()/$newCommandName()/g" "${(%):-%x}" # replacing the function name
                    sed -i -e '$s'"/$FUNCNAME/$newCommandName/g" "${(%):-%x}" # replacing the command in last line
                    source "${(%):-%x}"
                    echo -e "${Green}Rename successful!!! $newCommandName  is effective now${ColorOff}"        
                else
                    echo -e "${Red}Cannot use $newCommandName because this command already exists${ColorOff}"
                fi
            fi
        ;;
        
        "help"|"h"|"--help"|"-h")
            for index in "${genericCommands[@]}" ; do
                local key="${index%%::*}"
                local value="${index##*::}"
                echo -e "${Cyan}${key}${ColorOff} - ${value}"
            done
            if [[ $prjFolder != "NOPATH" ]]; then
                for index in "${folderCommands[@]}" ; do
                    local key="${index%%::*}"
                    local value="${index##*::}"
                    echo -e "${Cyan}${key}${ColorOff} - ${value}"
                done
                while read -r line
                do
                    local key="${line%%::*}"
                    local value="${line##*::}"
                    echo -e "${Cyan}${key}${ColorOff} - ${value}"
                done <<< "$packageJsonCommands"
            fi
        ;;
        
    esac
    
}

template indexCommands
