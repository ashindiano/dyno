if [ "$1" = "-uninstall" ] || [ "$1" = "-u" ]; then
    rm -rf ~/.dyno
    case $(uname | tr '[:upper:]' '[:lower:]') in
        linux*)
             sed -i '/source ~\/.dyno\/dyno/d' ~/.bash_profile
            ;;
        darwin*)
            sed -i '' '/source ~\/.dyno\/dyno/d' ~/.bash_profile
            ;;
        *)

            ;;
    esac
    
else
    mkdir -p ~/.dyno
    cp dyno ~/.dyno
    cp template ~/.dyno
    touch ~/.dyno/.nestedScripts
    echo "autoload -U compinit && compinit" >> ~/.bash_profile
    echo "autoload -U bashcompinit && bashcompinit" >> ~/.bash_profile
    echo "source ~/.dyno/dyno" >> ~/.bash_profile
    
    echo "autoload -U compinit && compinit" >> ~/.zprofile
    echo "autoload -U bashcompinit && bashcompinit" >> ~/.zprofile
    echo "source ~/.dyno/dyno" >> ~/.zprofile
    
    echo "!!!!!!!!!!!!!!!!!!!!!! Installation Complete !!!!!!!!!!!!!!!!!!!!!!!"
    echo "             Restart Terminal for DYNO take effect  "
fi
