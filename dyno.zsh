local dynoFolder="$(dirname ${(%):-%x})"
local version=$(grep -o '"version": "[^"]*' ${dynoFolder}/version.json | grep -o '[^"]*$' )
local version="v${version}" 
local sourceFolder="${dynoFolder}/commands"

local ColorOff='\033[0m'
local Black='\033[0;30m'        # Black
local Red='\033[0;31m'          # Red
local Green='\033[0;32m'        # Green
local Yellow='\033[0;33m'       # Yellow
local Blue='\033[0;34m'         # Blue
local Purple='\033[0;35m'       # Purple
local Cyan='\033[0;36m'         # Cyan
local White='\033[0;37m'        # White

function dyno() {
    
    declare -a commands
    
    commands=(
        "open::Opens current folder"
        "source::Source the Current file in Shell"
        "commands::List All commands created by DYNO"
        "repo::Opens the Github.com link of the current folder's git repo"
        "new::Add a New Script to folder"
        "remove::Removes a Project command created by dyno"
        "help::List all the commands available"
        "reset::Reset the script to the factory defaults"
        "update::Update DYNO to its latest version"
        "location::Navigate to the source location of Dyno"
        "--uninstall::Uninstall DYNO"
        "check-update::Check for updates"
    )
    
    #The following code helps in auto completion
    local allCommands=""
    for index in "${commands[@]}" ; do
        key="${index%%::*}"
        allCommands+="${key} "
    done

    complete -W "${allCommands}" dyno

    local OS="linux"
    local openCommand="open"

    getos() {
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

    subString() {
        local myresult="${1#*$2}" # removing prefix
        myresult="${myresult%$3*}" # removing suffix
        echo "$myresult"
    }
    
    sourceAll() {
        if [[ -n "$(ls -A "$sourceFolder")" ]]; then
            for file in "$sourceFolder"/*.zsh; do
                source "$file"
            done
        fi
    }

    listCustomCommands() {
        if [[ -n "$(ls -A "$sourceFolder")" ]]; then
            for file in "$sourceFolder"/*.zsh; do
                echo "${${file##*/}%.*}"
            done
        fi
    }

    remoteVersion() {
        curl -sL https://api.github.com/repos/ashindiano/dyno/releases/latest | grep -o '"tag_name": "[^"]*' | grep -o '[^"]*$' 
    }
    isUpdateAvailable() {
        local remoteVs
        remoteVs=$(remoteVersion)
        if [[ -n "$remoteVs" && $version != "$remoteVs" ]]; then
            echo ""
            echo -e "${Red}!!! Update Available !!!$ColorOff"
            echo -e "A new version of ${Yellow}Dyno${ColorOff} is available: $Yellow$remoteVs$ColorOff"
            echo -e "Your current version is: $Red$version$ColorOff"
            echo -e "To update, run: $Green dyno update $ColorOff"
            echo ""
        else
            echo -e "${Green}You are using the latest version of Dyno: $Yellow$version$ColorOff"
        fi
    }

    case $1 in
        "new")
            local name="$2"       
            local isSuccess=false
            if type "$name" > /dev/null 2>&1; then 
                echo "Command seems to exist already in the system. Please try a new command"
                return
            else     
                if [[ -z "$name" ]]; then
                    echo -n "Enter the NAME (single word) of the project: "
                    read name
                fi

                cp "${dynoFolder}/template.zsh" "${sourceFolder}/${name}.zsh"
                cp "${dynoFolder}/template.bash" "${sourceFolder}/${name}.bash"

                if [[ $OS == "mac" ]]; then
                    sed -i '' "s/template/$name/g" "${sourceFolder}/${name}.zsh"
                    sed -i '' "s/template/$name/g" "${sourceFolder}/${name}.bash"
                else
                    sed -i "s/template/$name/g" "${sourceFolder}/${name}.zsh"
                    sed -i "s/template/$name/g" "${sourceFolder}/${name}.bash"
                fi
                
                isSuccess=true
            fi

            echo -n "Is your command ${name} associated to a folder? (y/n): "
            read isFolderAssociated
            if [[ "$isFolderAssociated" == "y" ]]; then
                local folder='.'
                echo -n "Enter the Folder path of your Project (For current folder just hit enter key): "
                read prjFolder
                [ -n "$prjFolder" ] && folder=$prjFolder
                local fullPath
                fullPath=$(realpath -m "$folder" | sed 's/\~\///g')
                echo "Folder chosen for the Project: $fullPath"
                if test -d "$fullPath"; then
                    if [[ $OS == "mac" ]]; then
                        sed -i '' "s|prjFolder=\"NOPATH\"|prjFolder=\"${fullPath}\"|g" "${sourceFolder}/${name}.zsh"
                        sed -i '' "s|prjFolder=\"NOPATH\"|prjFolder=\"${fullPath}\"|g" "${sourceFolder}/${name}.bash"
                    else
                        sed -i "s|prjFolder=\"NOPATH\"|prjFolder=\"${fullPath}\"|g" "${sourceFolder}/${name}.zsh"
                        sed -i "s|prjFolder=\"NOPATH\"|prjFolder=\"${fullPath}\"|g" "${sourceFolder}/${name}.bash"
                    fi                    
                    cd "$fullPath"
                else
                    echo "Directory does not exist."
                fi
            fi

            if [[ "$isSuccess" == true ]]; then
                source "${sourceFolder}/${name}.zsh"
                echo "Success: Project $name created"
                echo "You can start using '$name' command"
            fi
        ;;
        
        "location")
            cd "$dynoFolder"
        ;;
        
        "source")
            sourceAll
        ;;
        
        "commands")
            listCustomCommands
        ;;
        
        "check-update")
            isUpdateAvailable
        ;;

        "inject-all")
            local dir="${dynoFolder}"
            local tempFile1="${dir}/.tmp1"
            local tempFile2="${dir}/.tmp2"

            echo -n "Enter the sub Command you want in all Dyno Projects: "
            read subCommand 

            echo -n "Enter help description for '$subCommand': "
            read helpDescription

            echo "Enter the File whose content you want to inject to all projects: "
            read FILE 
            local fullPath
            fullPath=$(realpath -m "$FILE" | sed 's/\~\///g')
            
            # Generating dummy file with a switch case for the sub command
            echo "\"$subCommand\")" >> "$tempFile1"
            sed 's_^_     _' "$fullPath" >> "$tempFile1"
            echo ";;" >> "$tempFile1"
            
            echo "You are about to modify all Dyno projects. Are you sure you want to continue? (y/n): "
            read answer 
            
            if [[ "$answer" == "y" ]]; then
                echo "Running iterative injections to each Project"
                local x
                x=$(locate .dynoScript)
                IFS=$'\n' read -r -d '' -a y <<< "$x"
                for file in "${y[@]}"; do
                    local functionname
                    functionname=$(subString "$sourcedFile" "source \"")
                    functionname=${functionname%%\"*}
                    functionname=$(cat "$functionname")
                    functionname=${functionname%%()\{*}
                    functionname="${functionname#*function }"
                    
                    echo "Injecting '$subCommand' command in project: $functionname"
                    awk '/"help"\|/{while(getline line<"'"$tempFile1"'"){print "        "line}}1' "$file" > "$tempFile2" && mv -f "$tempFile2" "$file"
                    
                    local reg
                    reg="/commands=/{print;print \"        \\\"$subCommand::$helpDescription\\\"\";next}1"
                    awk "$reg" "$file" > "$tempFile2" && mv -f "$tempFile2" "$file"
                done
            fi
            rm -f "$tempFile1" "$tempFile2"
        ;;
        
        "replace-all")
            echo "Running iterative injections to each Project"
            local x
            x=$(locate .dynoScript)
            IFS=$'\n' read -r -d '' -a y <<< "$x"
            for file in "${y[@]}"; do
                echo "Replacing on $file"
                ######## Replace Command ########
                # sed -i '' "s/cd[^.]*\/code/cd \"$\( dirname \"$\{BASH_SOURCE[0]\}\" \)\/code/g" "$file"
            done
            
        ;;
        
        "update")
            echo "Current version: $version"
            echo "Downloading ..."
            if test -f "${dynoFolder}/main.tar.gz"; then # delete previous copies
                rm "${dynoFolder}/main.tar.gz"
            fi

            local DOWNLOAD_URL
            DOWNLOAD_URL=$(curl -s https://api.github.com/repos/ashindiano/dyno/releases/latest \
                    | grep tarball_url \
                    | cut -d '"' -f 4)

            curl -L -o "${dynoFolder}/main.tar.gz" "$DOWNLOAD_URL" 
            
            if test -f "${dynoFolder}/main.tar.gz"; then
                echo "Extracting and Installing ..."
                tar -xf "${dynoFolder}/main.tar.gz" -C "${dynoFolder}" --strip 1
                source "${(%):-%x}"
                echo "Updated to version: $version"
            else
                echo "Download Failed !!!"
            fi
        ;;
        
        "repo")
            echo "Opening current Git Repository in github.com"
            
            local remote
            remote=$(git config --get remote.origin.url)
            if [[ $remote != *".git"* ]]; then
                echo "No Git Found"
            else
                remote=${remote//:/\/} 
                remote=${remote//git@/https:\/\/}
                $openCommand "$remote"
            fi
        ;;

        "remove")
            if [[ -z "$2" ]]; then
                echo "Not sure what to remove"
            elif [[ ! $(listCustomCommands) =~ "$2" ]]; then 
                echo "$2: Command not found"            
            elif [[ -f "${sourceFolder}/$2.zsh" || -f "${sourceFolder}/$2.bash" ]]; then
                rm "${sourceFolder}/$2.zsh"
                rm "${sourceFolder}/$2.bash"
                unset -f "$2"
                echo "Successfully removed command $2"
            fi
        ;;
        
        "--version"|"-v")
            echo "$version"
        ;;
        
        "help"|"h"|"--help"|"-h")
            for index in "${commands[@]}"; do
                key="${index%%::*}"
                value="${index##*::}"
                echo "${key} - ${value}"
            done
            echo ""
            echo "Project commands by DYNO"
            echo "========================"
            listCustomCommands
        ;;

        "--uninstall")
            echo -n "Are you sure? Do you want to uninstall dyno? (Y/n): "
            read decision
            if [[ "$decision" == "Y" ]]; then
                echo -n "Do you want to EXPORT all your commands before we uninstall dyno? (y/n): "
                read answer
                if [[ "$answer" == "y" ]]; then
                    local location="~/Desktop"
                    echo -n "Where do you want the export file? (Default Folder: ~/Desktop): "
                    read newLocation
                    [ -n "$newLocation" ] && location=$newLocation
                    local fullPath
                    fullPath=$(realpath -m "$location" | sed 's/\~\///g')
                    echo "Folder chosen for the Project: $fullPath"
                    echo "SOURCE folder chosen for the Project: $sourceFolder"
                    echo "Creating export file..."
                    tar -C "$dynoFolder" -cf "${fullPath}/dyno_backup.tar.gz" commands
                    echo "Export complete, please find the exported file at ${fullPath}/dyno_backup.tar.gz"
                fi
                rm -rf "$dynoFolder"
                case $OS in
                    mac)
                        sed -i '' '/source ~\/.dyno\/dyno.bash/d' ~/.bash_profile
                        sed -i '' '/source ~\/.dyno\/dyno.zsh/d' ~/.zprofile
                        ;;
                    *)
                        sed -i '/source ~\/.dyno\/dyno.bash/d' ~/.bash_profile
                        sed -i '/source ~\/.dyno\/dyno.zsh/d' ~/.zprofile
                        ;;
                esac
                echo "Uninstall Complete!! See you soon..."
            fi
        ;;
        
        *)  # Default case
            echo "Usage: dyno [command] [options]"
            echo "Available commands:"
            for index in "${commands[@]}"; do
                key="${index%%::*}"
                value="${index##*::}"
                echo "  ${key} - ${value}"
            done
            echo "For more information, use 'dyno help' or 'dyno --help'."
        ;;
    esac
}

dyno check-update # Run at least once to list all autocomplete values

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

dyno source
