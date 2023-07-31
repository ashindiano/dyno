#!/bin/bash
dynoFolder="$(dirname ${BASH_SOURCE})"
version=$(grep -o '"version": "[^"]*' ${dynoFolder}/version.json | grep -o '[^"]*$')
version="v${version}"
sourceFolder="${dynoFolder}/commands"

ColorOff='\033[0m'
Black='\033[0;30m'  # Black
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Blue='\033[0;34m'   # Blue
Purple='\033[0;35m' # Purple
Cyan='\033[0;36m'   # Cyan
White='\033[0;37m'  # White

function dyno() {

    declare -a commands

    commands=(
        "open::Opens current folder"
        "source::Source the Current file in Shell"
        "commands::List All commands created by DYNO"
        "repo::Opens the Github.com link of the current folder's git repo"
        "new::Add a New Script to folder"
        "remove::Removes a Project command created by dyno"
        "help::List all the commands the available"
        "reset::Reset the script to the factory defaults"
        "location::Navigate to the source location of Dyno"
        "update::Updated DYNO to its latest version"
        "--uninstall::Uninstall DYNO"
    )

    #The following code helps in auto completion
    allCommands=""
    for index in "${commands[@]}"; do
        key="${index%%::*}"
        allCommands+="${key} "
    done

    complete -W "${allCommands}" dyno

    OS="linux"
    openCommand="open"

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

        CYGWIN* | MINGW32* | MSYS* | MINGW*)
            openCommand="start"
            OS="windows"
            ;;
        esac
    }

    getos

    subString() {
        local myresult="${1#*$2}"  # removing prefix
        myresult="${myresult%$3*}" # removing suffix
        echo "$myresult"
    }

    sourceAll() {
        if [[ ! -z "$(ls -A $sourceFolder)" ]]; then
            for file in "$sourceFolder"/*.bash; do
                source "$file"
            done
        fi
    }

    listCustomCommands() {
        if [[ ! -z "$(ls -A $sourceFolder)" ]]; then
            for file in "$sourceFolder"/*.bash; do
                tmp=${file##*/}
                echo "${tmp%%.*}"
            done
        fi
    }

    remoteVersion() {
        curl -sL https://api.github.com/repos/ashindiano/dyno/releases/latest | grep -o '"tag_name": "[^"]*' | grep -o '[^"]*$'
    }

    isUpdateAvailable() {
        remoteVersion=$(remoteVersion)
        if [[ ! -z "$remoteVersion" && $version != $remoteVersion ]]; then
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
        name=$2
        isSuccess=false
        if [[ $(type $name 2>/dev/null) ]]; then

            echo "Command seems to exist already in the system. Please try a new command"

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

        read -e -p "Is your command ${name} associated to a folder ? (y/n) : " isFolderAssociated

        if [[ "$isFolderAssociated" == "y" ]]; then
            folder='.'
            read -e -p "Enter the Folder path of your Project (For current folder just hit enter key )  : " prjFolder
            [ -n "$prjFolder" ] && folder=$prjFolder
            fullPath=$(realpath -m $folder | sed 's/\~\///g')
            echo $fullPath
            if test -d "$fullPath"; then
                if [[ $OS == "mac" ]]; then
                    sed -i '' "s|path|${fullPath}|g" "${sourceFolder}/${name}.zsh"
                    sed -i '' "s|path|${fullPath}|g" "${sourceFolder}/${name}.bash"
                else
                    sed -i "s|path|${fullPath}|g" "${sourceFolder}/${name}.zsh"
                    sed -i "s|path|${fullPath}|g" "${sourceFolder}/${name}.bash"
                fi
                cd "$fullpath"
            else
                echo "Directory does not exist."
            fi
        fi

        if [[ "$isSuccess" = true ]]; then
            source "${sourceFolder}/${name}.bash"
            echo "Success: Project $name created "
            echo "You can start using ' $name ' command"
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

    "isUpdateAvailable")
        isUpdateAvailable
        ;;

    "remove")
        if [[ -z "$2" ]]; then
            echo "Not sure what to remove"
        elif [[ ! $(listCustomCommands) =~ "$2" ]]; then
            echo "$2 : Command not found"
        else

            if [[ -f "${sourceFolder}/$2.zsh" || -f "${sourceFolder}/$2.bash" ]]; then
                rm "${sourceFolder}/$2.zsh"
                rm "${sourceFolder}/$2.bash"
                echo "Successfully removed command $2"
                source "${BASH_SOURCE}"
            fi
        fi

        ;;

    "inject-all")
        dir="$dynoFolder"

        tempFile1="${dir}/.tmp1"
        tempFile2="${dir}/.tmp2"

        read -e -p "Enter the sub Command you want in all Dyno Projects: " subCommand
        read -e -p "Enter help description for '$subCommand' : " helpDescription

        read -e -p "Enter the File whose content you want to inject to all projects: " FILE
        fullPath=$(realpath -m $FILE | sed 's/\~\///g')

        #generating dummy file with a switch case for the sub command
        echo "\"$subCommand\")" >>"$tempFile1"
        sed 's_^_     _' $fullPath >>$tempFile1
        echo ";;" >>$tempFile1

        read -e -p "You are about to modify all Dyno projects. Are you sure you want to continue? (y/n) : " answer

        if [[ "$answer" == "y" ]]; then
            # iteratively injecting to all dyno projects
            # if test -f "$fullPath"; then
            echo "Running iterative injections to each Project"
            x=$(locate .dynoScript)
            IFS=$'\n' y=($x)
            for file in "${y[@]}"; do

                local functionname=$(subString "$sourcedFile" "source \"")
                functionname=${functionname%%\"*}
                functionname=$(cat $functionname)
                functionname=${functionname%%()\{*}
                functionname="${functionname#*function }"

                echo "Injecting '$subCommand' command in project: $functionname"
                awk '/"help"\|/{while(getline line<"'"$tempFile1"'"){print "        "line}}1' $file >$tempFile2 && mv -f $tempFile2 $file

                reg="/commands=/{print;print \"        \\\"$subCommand::$helpDescription\\\"\";next}1"
                awk "$reg" $file >$tempFile2 && mv -f $tempFile2 $file

            done
            # fi
        fi
        rm -f $tempFile1 $tempFile2
        ;;

    "replace-all")

        echo "Running iterative injections to each Project"
        x=$(locate .dynoScript)
        IFS=$'\n' y=($x)
        for file in "${y[@]}"; do
            echo "replacing on  $file"
            ######## Replace Command ########
            #  sed -i ''  "s/cd[^.]*\/code/cd \"$\( dirname \"$\{BASH_SOURCE\}\" \)\/code/g" "$file"
        done

        ;;

    "update")
        echo "current version: $version"
        echo "Downloading ..."
        if test -f "${dynoFolder}/main.tar.gz"; then # delete previous copies
            rm "${dynoFolder}/main.tar.gz"
        fi

        DOWNLOAD_URL=$(curl -s https://api.github.com/repos/ashindiano/dyno/releases/latest |
            grep tarball_url |
            cut -d '"' -f 4)

        curl -L -o "${dynoFolder}/main.tar.gz" "$DOWNLOAD_URL"

        if test -f "${dynoFolder}/main.tar.gz"; then
            echo "Extracting and Installing ..."
            tar -xf "${dynoFolder}/main.tar.gz" -C "${dynoFolder}" --strip 1
            source "${BASH_SOURCE}"
            echo "updated to version: $version"
        else
            echo "Download Failed !!!"
        fi
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

    "--version" | "-v")
        echo ${version}
        ;;

    "help" | "h" | "--help" | "-h")
        for index in "${commands[@]}"; do
            key="${index%%::*}"
            value="${index##*::}"
            echo ${key} - ${value}
        done
        echo ""
        echo "Project commands by DYNO"
        echo "========================"
        listCustomCommands
        ;;

    "--uninstall")
        echo -n "Are you sure ? Do you want to uninstall dyno ? (Y/n) : "
        read decision
        if [[ "$decision" == "Y" ]]; then
            echo -n "Do you want to EXPORT all your commands before we uninstall dyno ? (y/n) : "
            read answer
            if [[ "$answer" == "y" ]]; then
                location="~/Desktop"
                echo -n "Where do you want the export file ? (Default Folder: ~/Desktop) :"
                read newLocation
                [ -n "$newLocation" ] && location=$newLocation
                fullPath=$(realpath -m $location | sed 's/\~\///g')
                echo "folder chosen for the Project : $fullPath "
                echo "SOURCE folder chosen for the Project : $sourceFolder "
                echo "Creating export file..."
                tar -C $dynoFolder -cf "${fullPath}/dyno_backup.tar.gz" commands
                echo "Export complete, please find the exported file at ${fullPath}/dyno_backup.tar.gz"
            fi
            rm -rf $dynoFolder
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

dyno source
