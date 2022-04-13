if [[ "$1" = "-uninstall" ]] || [[ "$1" = "-u" ]]; then
    rm -rf ~/.dyno
    case $(uname | tr '[:upper:]' '[:lower:]') in
        darwin*)
            sed -i '' '/source ~\/.dyno\/dyno.bash/d' ~/.bash_profile
            sed -i '' '/source ~\/.dyno\/dyno.zsh/d' ~/.zprofile
            ;;
        *)
            sed -i '/source ~\/.dyno\/dyno.bash/d' ~/.bash_profile
            sed -i '/source ~\/.dyno\/dyno.zsh/d' ~/.zprofile
            ;;

    esac
    
else
    mkdir -p ~/.dyno
    cp * ~/.dyno/
    mkdir -p ~/.dyno/commands
    touch ~/.bash_profile
    touch ~/.zprofile

    case $(uname | tr '[:upper:]' '[:lower:]') in # rm sourcing dyno files if they already exist to avoid duplicates
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
    
    echo "!!!!!!!!!!!!!!!!!!!!!! Installation Complete !!!!!!!!!!!!!!!!!!!!!!!"
    echo "             Restart Terminal for DYNO take effect  "
fi
