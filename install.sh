Green='\033[0;32m'
Red='\033[0;31m'
ColorOff='\033[0m'

if [ "$1" = "-uninstall" ] || [ "$1" = "-u" ]; then
    echo -e "${Red}Removing DYNO installation...${ColorOff}"
    rm -rf ~/.dyno
    echo -e "${Green}Cleaning up shell configuration files...${ColorOff}"
    case $(uname | tr '[:upper:]' '[:lower:]') in
        darwin*)
            sed -i '' '/source ~\/.dyno\/dyno.bash/d' ~/.bash_profile
            sed -i '' '/source ~\/.dyno\/dyno.zsh/d' ~/.zprofile
            echo -e "${Green}Removed DYNO entries from .bash_profile and .zprofile.${ColorOff}"
            ;;
        *)
            sed -i '/source ~\/.dyno\/dyno.bash/d' ~/.bash_profile
            sed -i '/source ~\/.dyno\/dyno.zsh/d' ~/.zprofile
            echo -e "${Green}Removed DYNO entries from .bash_profile and .zprofile.${ColorOff}"
            ;;
    esac
else
    # Check and install dependencies if not already installed
    install_dependencies() {
        local dependencies
        dependencies="curl tar jq coreutils"  # Define as a space-separated string
        local package_manager

        # Determine the package manager
        if command -v brew &> /dev/null; then
            package_manager="brew"
        elif command -v apt &> /dev/null; then
            package_manager="apt"
        elif command -v yum &> /dev/null; then
            package_manager="yum"
        elif command -v apk &> /dev/null; then
            package_manager="apk"
        else
            echo -e "${Red}No supported package manager found. Please install dependencies manually.${ColorOff}"
            return
        fi

        for dep in $dependencies; do
            if ! command -v "$dep" &> /dev/null; then
                case $package_manager in
                    brew)
                        brew install "$dep"
                        ;;
                    apt)
                        if [ $EUID -ne 0 ]; then
                            echo -e "${Red}You need to run this script as root or use sudo.${ColorOff}"
                            exit 1
                        fi
                        apt-get install -y "$dep"
                        ;;
                    yum)
                        if [ $EUID -ne 0 ]; then
                            echo -e "${Red}You need to run this script as root or use sudo.${ColorOff}"
                            exit 1
                        fi
                        yum install -y "$dep"
                        ;;
                    apk)
                        if [ $EUID -ne 0 ]; then
                            echo -e "${Red}You need to run this script as root or use sudo.${ColorOff}"
                            exit 1
                        fi
                        apk add "$dep"
                        ;;
                esac
            fi
        done
    }

    install_dependencies

    mkdir -p ~/.dyno
    cp -r * ~/.dyno/  # Added -r to copy directories recursively
    mkdir -p ~/.dyno/commands
    touch ~/.bash_profile
    touch ~/.zprofile

    case $(uname | tr '[:upper:]' '[:lower:]') in
        darwin*)
            sed -i '' '/source ~\/.dyno\/dyno.bash/d' ~/.bash_profile
            sed -i '' '/autoload -U compinit && compinit/d' ~/.zprofile
            sed -i '' '/autoload -U bashcompinit && bashcompinit/d' ~/.bash_profile
            sed -i '' '/source ~\/.dyno\/dyno.zsh/d' ~/.zprofile
            ;;
        *)
            sed -i '/source ~\/.dyno\/dyno.bash/d' ~/.bash_profile
            sed -i '/autoload -U compinit && compinit/d' ~/.zprofile
            sed -i '/autoload -U bashcompinit && bashcompinit/d' ~/.bash_profile
            sed -i '/source ~\/.dyno\/dyno.zsh/d' ~/.zprofile
            ;;
    esac

    echo "source ~/.dyno/dyno.bash" >> ~/.bash_profile
    if ! command -v compinit &> /dev/null; then
        echo "autoload -U compinit && compinit" >> ~/.zprofile
    fi
    if ! command -v bashcompinit &> /dev/null; then
        echo "autoload -U bashcompinit && bashcompinit" >> ~/.bash_profile
    fi
    echo "source ~/.dyno/dyno.zsh" >> ~/.zprofile
    
    echo -e "${Green}!!!!!!!!!!!!!!!!!!!!!! Installation Complete !!!!!!!!!!!!!!!!!!!!!!!${ColorOff}"
    echo -e "${Green}             Restart Terminal for DYNO to take effect  ${ColorOff}"
fi
