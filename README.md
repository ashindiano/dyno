# Dyno - A Shell Workspace

Dyno helps your custom shell commands. All the commands created by dyno are tightly associated to a Folder/Directory hence project development becomes much easier.

##### supported shell
    - zsh
    - bash
##### supported OS
    - mac
    - linux
    - gitbash

![dyno](https://user-images.githubusercontent.com/7322170/179398912-f1ee5000-7e1e-4ce8-808f-d66a928fd399.gif)

## Installation

Please make sure to install the following dependencies first

#### mac
```bash
brew install coreutils jq
```  

#### linux    
```bash   
sudo apt-get install coreutils jq
```

#### Then run the following to install dyno
```bash
sh install.sh
```
    
## To Uninstall

```bash
dyno --uninstall
```

## Getting Started

Please replace <b>"YOURCUSTOMCOMMAND"</b> with your actual custom command

cd to your project folder and Type

```bash 
dyno new
```
or
```bash 
dyno new YOURCUSTOMCOMMAND
``` 
replace <b>YOURCUSTOMCOMMAND</b> with the command you want to use. Example: ``` dyno new myproject```


#### To list all custom commands created by Dyno
```bash 
dyno commands
``` 

## Default Shell Shortcuts that comes with DYNO

- ```e``` -> will exit the current terminal
- ```bye``` -> will initiate system shutdown


## Support for third-party applications

- ### VsCode (Your Project can be opened easily in vscode by using the following command)

```bash
YOURCUSTOMCOMMAND code
```
<sub>
Note: Please make sure vs code is installed and accessible via shell
</sub>


- ### GIT (you can use the following commands in a git initialized project)
```bash
dyno repo
```
or

if a folder is associated your custom command
```bash
YOURCUSTOMCOMMAND repo
```

- ### NODE JS (commands under Scripts section in Package.json are available as sub commands)

Dyno automatically identifies the package manager as <b>npm</b> or <b>yarn</b> or <b>pnpm</b> based on package.json and lock files available

To list all sub commands available in the project
```bash
YOURCUSTOMCOMMAND help
```

## License
 [MIT](https://choosealicense.com/licenses/mit/)
