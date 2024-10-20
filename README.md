# Dyno - Your Custom Shell-Command Manager

Dyno is an innovative shell command manager that empowers you to tailor your command-line experience. It allows you to create and customize commands that can be linked to specific directories, making your project development more efficient and organized. You can also create independent commands that function without any folder associations, providing you with ultimate flexibility.

##### Compatible Shells

    - zsh
    - bash
    - 
To ensure that Dyno works seamlessly, it relies on your `.bash_profile` or `.zprofile` files to include the necessary source commands. This setup allows your shell to recognize and execute the Dyno commands whenever you start a new terminal session. By adding the line `source ~/.dyno/dyno.bash` to your `.bash_profile` or `source ~/.dyno/dyno.zsh` to your `.zprofile`, you enable the shell to load Dyno's functionalities automatically, ensuring that your custom commands are always available.

##### Supported Operating Systems

    - macOS
    - Linux
    - Git Bash

![dyno](https://user-images.githubusercontent.com/7322170/179398912-f1ee5000-7e1e-4ce8-808f-d66a928fd399.gif)

## Installation

To begin using Dyno, follow these steps:

#### For macOS, Linux, and Git Bash on Windows
1. Clone the Dyno repository:
   ```bash
   git clone https://github.com/ashindiano/dyno.git
   ```

2. Navigate to the Dyno directory:
   ```bash
   cd dyno
   ```

3. Run the installation script:
   ```bash
   sh install.sh
   ```

Make sure to restart your terminal after installation for the changes to take effect.

**Manual Dependency Installation:** If the `install.sh` script failed to install all dependencies, follow these steps:

1. **For macOS users:** If Homebrew is not installed, install it first:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   Then, install the required dependencies using Homebrew:
   ```bash
   brew install curl tar jq coreutils
   ```
2. **For Linux users:** Use your distribution's package manager to install the required dependencies. For example, on Ubuntu or Debian:
   ```bash
   sudo apt update && sudo apt install curl tar jq coreutils
   ```
   On Fedora, CentOS, or RHEL:
   ```bash
   sudo dnf install curl tar jq coreutils
   ```
   On openSUSE:
   ```bash
   sudo zypper install curl tar jq coreutils
   ```



**Important:** To ensure that the changes made in your `.zprofile` or `.bash_profile` are recognized by your shell, it is essential to use a login shell. A login shell is typically initiated when you first log into your system or when you open a new terminal window.

 If you are operating in a non-login shell (which may occur in certain terminal emulators or when using terminal multiplexers), the configurations in these files may not be loaded automatically. To ensure the necessary environment settings are applied, you need to manually add the following lines to your shell's configuration file:

For zsh users, add the following line to your `.zshrc` file:
   ```bash
    echo "autoload -U compinit && compinit" >> ~/.zshrc
    echo "autoload -U bashcompinit && bashcompinit" >> ~/.zshrc
    echo "source ~/.dyno/dyno.zsh" >> ~/.zshrc
   ```

For bash users, add the following line to your `.bashrc` file:
   ```bash
   echo "source ~/.dyno/dyno.bash" >> ~/.bashrc
   ```

   When uninstalling DYNO, ensure to remove these lines from your shell configuration files.

