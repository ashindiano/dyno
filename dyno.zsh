version=2.00
allScriptsFileName=".nestedScripts"
allScriptsFile="$(dirname "${0}")/${allScriptsFileName}"

ColorOff='\033[0m'
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

function dyno(){
    
    declare -a commands
    
    commands=(
        "open::Opens current folder"
        "script::Open the 'dyno' Script file"
        "source::Source the Current file in Shell"
        "commands::List All commands created by DYNO"
        "location::Navigate to the source location of Dyno"
        "repo::Opens the Github.com link of the current folder's git repo"
        "new::Add a New Script to folder"
        "help::List all the commands the available"
        "reset::Reset the script to the factory defaults"
        "refresh::Scans your entire omputer and updates commands of all DYNO Projects "
        "update::Updated DYNO to its latest version"
        "inject-all::Injects a piece of code under a sub command in all dyno Projects: Do only if you know what you are doing"
    )
    
    #The following code helps in auto completion
    allCommands=""
    for index in "${commands[@]}" ; do
        key="${index%%::*}"
        allCommands+="${key} "
    done
    
    complete -W "${allCommands}" dyno

    OS="linux"
    openCommand="open"

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

    subString(){
        local myresult="${1#*$2}" # removing prefix
        myresult="${myresult%$3*}" # removing suffix
        echo "$myresult"
    }
    
    allInstalledProjects(){
        x=$(locate .dynoScript)
        IFS=$'\n' y=($x)
        for file in "${y[@]}" ; do
            functionname=$(cat "${file}")
            functionname=${functionname%%()\{*}
            echo "${functionname#*function }"
        done
    }
    
    remoteVersion(){
        curl -sL https://api.github.com/repos/ashindiano/dyno/releases/latest | jq -r ".tag_name"
    }
    
    isUpdateAvailable(){
        remoteVersion=$(remoteVersion)
        if [[  ! -z "$remoteVersion"  && $version != $remoteVersion ]]; then
            echo ""
            echo -e "${Red}!!! Alert !!!$ColorOff"
            echo -e "Update found for ${Yellow}Dyno ${ColorOff}version: $Yellow$remoteVersion$ColorOff"
            echo -e "Your current version: $Red$version$ColorOff"
            echo -e "To Update:$Green dyno update  $ColorOff"
            echo ""
        fi
    }
    
    case $1 in
        "new")
            folder='.'
            echo "Enter the Folder path of your Project (For current folder just hit enter key )  : "
            read  prjFolder
            [ -n "$prjFolder" ] && folder=$prjFolder
            fullPath=$(realpath -m $folder | sed 's/\~\///g')
            echo $fullPath
            if test -d "$fullPath"; then
                
                echo "Enter the NAME (single word) of the project: "
                read name
  
                cd "$fullPath"
                cp ~/.dyno/template template
                if test -f "template"; then
                    
                    if [[ $OS == "windows" ]]; then
                        sed -i "s/template/$name/g" "template"

                    elif [[ $OS == "linux" ]]; then
                        sed -i "s/template/$name/g" "template"
                    else
                        sed -i '' "s/template/$name/g" "template"
                    fi

                    mv "template"  ".dynoScript"
                    echo "# Ignore dyno tool support file" >> .gitignore
                    echo ".dynoScript" >> .gitignore
                    
                    echo "Adding $fullPath/.dynoScript to Bash sources list "
                    echo "source \"$fullPath/.dynoScript\""  >> ${allScriptsFile}
                    source "${(%):-%x}"
                    echo "Success: Project $name created "
                    echo "You can start using ' $name ' command"
                else
                    echo "File Download Error " >&2
                fi
                
            else
                echo "Directory does not exist."
            fi
            
        ;;
        
        "location")
            cd "$( dirname ${(%):-%x} )"
        ;;
        
        "script")
            echo "Opening ${allScriptsFile}"
            code ${allScriptsFile}
        ;;
        
        "source")
            echo "Sourcing ${allScriptsFile}"
            source ${allScriptsFile}
        ;;
        "reset")  
            echo "Are you sure you wanna reset Dyno? Yes/No"
            read answer 
            if [["$answer" == "Yes"]]; then
                sed '/source/,$d'
            fi
        ;;
        
        "commands")
            i=$(cat  ${allScriptsFile})
            IFS=$'\n' j=($i)
            
            for sourcedFile in "${j[@]}" ; do
                if [[ "$sourcedFile" == *"source "* ]]; then
                    local functionname=$(subString "$sourcedFile" "source \"")
                    functionname=${functionname%%\"*}
                    functionname=$(cat $functionname)
                    functionname=${functionname%%()\{*}
                    echo "${functionname#*function }"
                fi
            done
        ;;
        
        "refresh")
            echo "Scanning computer for all local dyno Projects created"
            case $(uname | tr '[:upper:]' '[:lower:]') in
                linux*)
                    sudo updatedb
                ;;
                darwin*)
                    sudo /usr/libexec/locate.updatedb
                ;;
                *)
                    
                ;;
            esac
            echo "Search Complete refreshing Projects"
            x=$(locate .dynoScript)
            IFS=$'\n' y=($x)
            i=$(cat  ${allScriptsFile})
            IFS=$'\n' j=($i)
            for file in "${y[@]}" ; do
                local isFileExist=false
                for sourcedFile in "${j[@]}" ; do
                    if [[ "$sourcedFile" == *"source "* ]]; then
                        
                        if [[ "$file" ==  *"$(subString "$sourcedFile" "source ")"* ]]; then
                            isFileExist=true
                            break
                        fi
                    fi
                done
                if [ $isFileExist = false ]; then
                    echo "source \"$file\""  >> "${allScriptsFile}"
                fi
            done
            echo "Refresh Complete"
        ;;
        
        "inject-all")
            dir="$(dirname ${(%):-%x})"
            
            tempFile1="${dir}/.tmp1"
            tempFile2="${dir}/.tmp2"

            echo "Enter the sub Command you want in all Dyno Projects: "
            read subCommand 

            echo "Enter help description for '$subCommand' : "
            read helpDescription

            echo "Enter the File whose content you want to inject to all projects: "
            read FILE 
            fullPath=$(realpath -m $FILE | sed 's/\~\///g')
            
            #generating dummy file with a switch case for the sub command
            echo "\"$subCommand\")" >> "$tempFile1"
            sed 's_^_     _' $fullPath >> $tempFile1
            echo ";;" >> $tempFile1
            
            echo "You are about to modify all Dyno projects. Are you sure you want to continue? (y/n) : "
            read answer 
            
            if [[ "$answer" == "y" ]]; then
                # iteratively injecting to all dyno projects
                # if test -f "$fullPath"; then
                echo "Running iterative injections to each Project"
                x=$(locate .dynoScript)
                IFS=$'\n' y=($x)
                for file in "${y[@]}" ; do
                    
                    local functionname=$(subString "$sourcedFile" "source \"")
                    functionname=${functionname%%\"*}
                    functionname=$(cat $functionname)
                    functionname=${functionname%%()\{*}
                    functionname="${functionname#*function }"
                    
                    echo "Injecting '$subCommand' command in project: $functionname"
                    awk '/"help"\|/{while(getline line<"'"$tempFile1"'"){print "        "line}}1' $file > $tempFile2 && mv -f $tempFile2 $file
                    
                    reg="/commands=/{print;print \"        \\\"$subCommand::$helpDescription\\\"\";next}1"
                    awk "$reg" $file > $tempFile2 && mv -f $tempFile2 $file
                    
                done
                # fi
            fi
            rm -f $tempFile1 $tempFile2
        ;;
        
        "replace-all")
            
            echo "Running iterative injections to each Project"
            x=$(locate .dynoScript)
            IFS=$'\n' y=($x)
            for file in "${y[@]}" ; do
                echo "replacing on  $file"
                ######## Replace Command ########
                #  sed -i ''  "s/cd[^.]*\/code/cd \"$\( dirname \"$\{BASH_SOURCE[0]\}\" \)\/code/g" "$file"
            done
            
        ;;
        
        "update")
            echo "current version: $version"
            echo "Downloading ..."
            if test -f main.zip; then
                rm main.zip
            fi

            curl -L -O https://github.com/ashindiano/dyno/archive/refs/heads/main.zip            
            if test -f main.zip; then
                tar -xvf main.zip -C  ~/.dyno 
                source "${(%):-%x}"
                echo "updated to version: $version"
            else
                echo "Download Failed !!!"
            fi
        ;;
        
        "isUpdateAvailable")
            isUpdateAvailable
        ;;
        
        "repo")
            echo "Opening current Git Repository in github.com"
            
            remote=$(git config --get remote.origin.url)
            if [[ $remote != *".git"* ]]; then
                echo " No Git Found"
            else
                remote=${remote#*git@github.com:}   # remove prefix ending in "git@github.com:"
                remote=${remote%.git*}   # remove suffix starting with ".git"
                $openCommand "https://github.com/$remote"
            fi
        ;;
        
        "--version"|"-v")
            echo ${version}
        ;;
        
        "help"|"h"|"--help"|"-h")
            for index in "${commands[@]}" ; do
                key="${index%%::*}"
                value="${index##*::}"
                echo ${key} - ${value}
            done
            echo ""
            echo "Project commands by DYNO"
            echo "========================"
            allInstalledProjects
        ;;
        
    esac
}

dyno isUpdateAvailable #Run atleast once to list all autocomplete values

if [[ $OS == "windows" ]]; then
    alias bye="shutdown -s -f -t 00"
    alias reboo="shutdown -r -f -t 00"
elif [[ $OS == "mac" ]]; then
    alias bye="osascript -e 'tell app \"System Events\" to shut down'"
else
    alias bye="systemctl poweroff -i"
    alias reboo="systemctl reboot -i"
fi

alias e=exit

source "${allScriptsFile}"
cd # Go back to the default folder