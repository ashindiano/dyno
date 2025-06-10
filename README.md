# Dyno - Your Custom Shell-Command Manager 🚀

**Tired of jumping between terminal tabs and manually running repetitive commands?** Dyno lets you create powerful custom shell commands — tied to your folders or system-wide — so you can run, jump, and automate like a boss. Whether you're juggling projects or building one-off utilities, Dyno adapts to your flow.

<img src="https://user-images.githubusercontent.com/7322170/179398912-f1ee5000-7e1e-4ce8-808f-d66a928fd399.gif" width="80%" >
---

## ✨ Key Features

* 🔖 Create your own **project-specific** or **system-level** commands
* 📂 Automatically jump to project folders
* 🧩 Add **subcommands** with real script logic
* 📁 Export/import command definitions
* 🛠️ Edit existing commands anytime
* ⌨️ Bash/zsh **autocompletion** support
* ⚡ Lightweight, scriptable, and includes fun **global aliases**

---

## 💻 Compatible Shells

* `zsh`
* `bash`

To ensure Dyno works properly across shell sessions, add the appropriate source line to your shell configuration:

* For **login shells**, use `.zprofile` (zsh) or `.bash_profile` (bash)
* For **non-login shells**, use `.zshrc` or `.bashrc`

---

## 📦 Installation

### 🔧 Quick Start (macOS, Linux, Git Bash)

```bash
git clone https://github.com/ashindiano/dyno.git
cd dyno
sh install.sh
```

Then restart your terminal. If the install script misses any dependencies, follow manual steps below.

### ⚙️ Manual Dependencies (Use if install.sh fails to set them up)

#### macOS (with Homebrew)

```bash
brew install curl tar jq coreutils
```

#### Ubuntu/Debian

```bash
sudo apt update && sudo apt install curl tar jq coreutils
```

#### Fedora/CentOS/RHEL

```bash
sudo dnf install curl tar jq coreutils
```

#### openSUSE

```bash
sudo zypper install curl tar jq coreutils
```

### 🧠 Shell Configuration (Only if automatic setup doesn't work)

If the `install.sh` script didn’t set up your shell configuration correctly, add the following lines manually **to either ********************************************************`~/.zshrc`******************************************************** or  `~/.bashrc`**, depending on your shell:

```bash
autoload -U compinit && compinit
autoload -U bashcompinit && bashcompinit
# Use one of the following depending on your shell:
source ~/.dyno/dyno.zsh  # for zsh users
source ~/.dyno/dyno.bash # for bash users
```

---

## 📖 How to Use

### 🔹 Step 1: Create Your Command

```bash
dyno new jarvis
```

You'll be asked:

```
Is your command jarvis associated to a folder? (y/n): n
```

✅ Now you can use the `jarvis` command directly!

### 🔹 Step 2: Explore Built-in Subcommands

```bash
jarvis
```

Use `Tab` autocomplete to explore:

```
help    rename    script    source
```

### 🔹 Step 3: Add Your Own Subcommand

Dyno subcommands are customizable. Just follow these 3 steps:

1. **Edit the script:** Open the script file for the custom command using:

```bash
jarvis script
```

2. **Describe your new command** (in the script file, look for the section with this format):

```bash
# "<command_name>::<description_of_command>"
search::Search the web using a search engine
```

3. **Add logic under the script section:**

```bash
# Add your custom scripts here

"search")
    echo -n -e "${Yellow}Enter your search query: ${ColorOff}"
    read query
    if [[ -n "$query" ]]; then
        local searchUrl="https://www.google.com/search?q=${query// /+}"
        $openCommand "$searchUrl"
        echo -e "${Green}Searching for: $query${ColorOff}"
    else
        echo -e "${Red}No search query entered.${ColorOff}"
    fi
;;
```

4. **Reload it:**

```bash
jarvis source
```

Or just restart your shell.

✅ Try it out:

```bash
jarvis search
```

You'll see something like:

```bash
❯ jarvis search
Enter your search query: robert downey jr movies
Searching for: robert downey jr movies
```

This will open your browser and perform a Google search using the query you entered.

*(Now that's some shell discipline.)*

---

## 🔸 Default Subcommands

Each custom command (like `jarvis`, created in the example above) comes with built-in subcommands.

There are two types of subcommands:

* **Generic subcommands** like `help`, `rename`,  `script` and `s`ource are always available.
* **Folder-aware subcommands** like `open`, `code`, and `repo` only take effect if the command is linked to a folder — Dyno will `cd` into the folder first before running them. These are always available, and if the command is linked to a folder, Dyno will automatically switch to it first.

Here's what it looks like in action:

```bash
❯ jarvis help
Available subcommands:
  help       Show help message
  rename     Rename the command
  script     Open the script associated with the command
  source     Reload the script into your shell session
  open       Opens the current folder
  code       Opens the folder in VS Code editor
  repo       Opens the respective Git origin repo in the browser
```

These can be triggered like:

```bash
jarvis repo
jarvis open
```

Use `Tab` to explore available subcommands interactively in your shell.

---

## 🧰 Default Dyno Commands

These are the built-in commands available in every Dyno installation by default.

When you run:

```bash
dyno help
```

You’ll see something like:

```bash
$ dyno help
Available Dyno commands:
  new             Add a new command
  remove          Remove a command created by Dyno
  commands        List all commands created by Dyno
  location        Navigate to the source location of Dyno
  repo            Open the GitHub repo of the current folder-s Git origin
  open            Open the current folder
  source          Source the current file in the shell
  update          Update Dyno to its latest version
  check-update    Check if a new version is available
  help            List all available Dyno commands
  --uninstall     Uninstall Dyno
```

Each command can be run like this:

```bash
dyno update
```

You can use `Tab` to autocomplete them in your shell.

## 📦 Version Update

Use `dyno check-update` to check if there are any new updates.

When you run `dyno update`, it checks your version, downloads the latest release, and installs it automatically. Here's how it looks in your shell:

```bash
❯ dyno update
Current version: v2.6.12
Downloading ...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100  9730    0  9730    0     0   5982      0 --:--:--  0:00:01 --:--:-- 27879
Extracting and Installing ...
Updated to version: v2.6.13
```

## ✨ Shell Features: Global Aliases

In addition to command management, Dyno enhances your shell with built-in global aliases for convenience:

* `bye` – Shutdown the system *(typed directly in shell)*
* `e` – Exit the current terminal session *(typed directly in shell)*

---

## 🔁 Uninstall (via Dyno command)

To uninstall Dyno using the built-in command, simply run:

```bash
dyno --uninstall
```

This will clean up all registered Dyno commands and remove shell config entries.

If you're removing Dyno manually, be sure to clean up any related lines from your `.bashrc`, `.zshrc`, or `.profile` files, and also delete the `.dyno` directory from your home folder:

```bash
rm -rf ~/.dyno
```
