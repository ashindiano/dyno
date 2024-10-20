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
    # Check and install dependencies that are not already installed
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
                echo -e "${Green}Installing $dep...${ColorOff}"
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
            else
                echo -e "${Green}$dep is already installed. Skipping installation.${ColorOff}"
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
            sed -i '' '/autoload -U bashcompinit && bashcompinit/d' ~/.zprofile
            sed -i '' '/source ~\/.dyno\/dyno.zsh/d' ~/.zprofile
            ;;
        *)
            sed -i '/source ~\/.dyno\/dyno.bash/d' ~/.bash_profile
            sed -i '/autoload -U compinit && compinit/d' ~/.zprofile
            sed -i '/autoload -U bashcompinit && bashcompinit/d' ~/.zprofile
            sed -i '/source ~\/.dyno\/dyno.zsh/d' ~/.zprofile
            ;;
    esac

    echo "source ~/.dyno/dyno.bash" >> ~/.bash_profile
    echo "autoload -U compinit && compinit" >> ~/.zprofile
    echo "autoload -U bashcompinit && bashcompinit" >> ~/.zprofile
    echo "source ~/.dyno/dyno.zsh" >> ~/.zprofile
    
    # Check if dyno is successfully installed
    if command -v dyno &> /dev/null; then
        echo -e "${Green}!!!!!!!!!!!!!!!!!!!!!! Installation Complete !!!!!!!!!!!!!!!!!!!!!!!${ColorOff}"
        echo -e "${Green}             Restart Terminal for DYNO to take effect  ${ColorOff}"
    else
        echo -e "${Red}Installation complete but DYNO command not found.${ColorOff} This could be because your shell is not a login shell. To fix this, ensure you are using a login shell or manually add the following lines to your shell's configuration file:"
        echo -e "${Yellow}For zsh users, add the following lines to your .zshrc file:${ColorOff}"
        echo "autoload -U compinit && compinit"
        echo "autoload -U bashcompinit && bashcompinit"
        echo "source ~/.dyno/dyno.zsh"
        echo -e "${Yellow}For bash users, add the following line to your .bashrc file:${ColorOff}"
        echo "source ~/.dyno/dyno.bash"
    fi
fi
