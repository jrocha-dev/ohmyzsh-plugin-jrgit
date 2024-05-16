# ------------------------------------------------------------------------------
# Git
# ------------------------------------------------------------------------------

# [Install Git]----------------------------------------------------------------

function install_git {
  # if git is not installed, install it
  if ! command_exists git; then
    echo "Git is not installed. Installing Git..."
    sudo apt-get update -y
    sudo apt-get install -y git
  else
    echo "Git is already installed."
  fi
}

# [Basic Git configuration]-----------------------------------------------------

function core_config {

  install_git

  # get name and email set at .gitconfig and show them

  local name=$(git config --global user.name)
  local email=$(git config --global user.email)
  local change

  # if ther is name or email, show tham and ask if the user wants to change them
  echo "Git user name: $name"
  echo "Git email: $email"
  echo
  echo "Do you want to change them? (Y/N)"
  read change

  if [ "$change" = "Y" ] || [ "$change" = "y" ]; then
    echo "Enter your name for Git commits: "
    read name
    echo "Enter your email for Git commits: "
    read email
    git config --global user.name "$name"
    git config --global user.email "$email"
  fi

  # If the user name is not set, ask the user to enter it
  if [ -z "$name" ]; then
    echo "User name is not set in your git configuration."
    echo "Enter your name for Git commits: "
    read name
    git config --global user.name "$name"
  fi

  # If the email is not set, ask the user to enter it
  if [ -z "$email" ]; then
    echo "Email is not set in your git configuration."
    echo
    echo "Consider using your work email address for work-related repositories and a"
    echo "no-reply email for open-source or personal projects."
    echo
    echo "You can use one email for each repository, running the command \`git config"
    echo "user.email <email>\` within the repository directory, without the \`--global\`"
    echo "flag."
    echo "You can also use different accounts for different types of repositories, i.e.,"
    echo "Open-source, personal, and work-related and set a global e-mail for each one."
    echo
    echo "Enter your email for Git commits: "
    read email
    git config --global user.email "$email"
  fi

  echo "------------------------------------------------------------------------------"
  echo "Git user name: $name"
  echo "Git email: $email"

  # input Unix-style: checkout as-is, commit LF.
  git config --global core.autocrlf input
  # set the default branch name to main instead of master
  git config --global init.defaultBranch main

  install_diff_so_fancy

}

# [diff-so-fancy]---------------------------------------------------------------

# diff-so-fancy strives to make your diffs human readable instead of machine
# readable. This helps improve code quality and helps you spot defects faster.

function install_diff_so_fancy {
  # if nodejs is not installed, install it
  if ! command_exists node; then

    echo "Node.js is not installed. Installing Node.js through NVM..."
    sudo apt-get update -y
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    sudo nvm install --lts

  else
    echo "Node.js and npm are already installed."
  fi

  # if diff-so-fancy is not installed, install it
  if ! command_exists diff-so-fancy; then
    echo "diff-so-fancy is not installed. Installing diff-so-fancy..."
    sudo npm install -g diff-so-fancy
  else
    echo "diff-so-fancy is already installed."
  fi

  # [core] ---------------------------------------------------------------------

  #diff-so-fancy for all diff output
  git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

  # [interactive] --------------------------------------------------------------

  #diff-so-fancy for all diff output
  git config --global interactive.diffFilter "diff-so-fancy --patch"

}

# ------------------------------------------------------------------------------
# LFS (Large File Storage)
# ------------------------------------------------------------------------------

# [Install Git LFS]-------------------------------------------------------------

function install_git-lfs {

  # if git-lfs is not installed, install it
  if ! command_exists git-lfs; then
    echo "Git LFS is not installed. Installing Git LFS..."
    sudo apt-get update -y
    sudo apt-get install -y git-lfs # install Git LFS
    git lfs install                 # enable Git LFS

    # Install Git LFS from the official repository
    # curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
  else
    echo "Git LFS is already installed."
  fi

  # set the path where Git LFS files will be stored
  git config --global lfs.objectspath "~/.git-lfs"

  # set the Git LFS filters

  # clean the working directory of LFS files
  git config --global filter.lfs.clean "git-lfs clean -- %f"

  # populate the working directory with the content of LFS files
  git config --global filter.lfs.smudge "git-lfs smudge -- %f"

  # run the filter-process: clean and smudge
  git config --global filter.lfs.process "git-lfs filter-process"

  # require Git LFS to be installed and configured on every client machine that clones or works with the respository.
  # git config --global filter.lfs.required true

}

# ------------------------------------------------------------------------------
# VS Code
# ------------------------------------------------------------------------------

# Function to check if a command is available
function command_exists {
  command -v "$1" >/dev/null 2>&1
}

function install_code {
  # Check if we are running inside WSL
  if [ -n "$WSL_DISTRO_NAME" ]; then
    # WSL is detected
    echo "Running inside WSL (Windows Subsystem for Linux)."

    # Check if VS Code is already installed on Windows
    if command_exists code; then
      echo "VS Code is already installed on Windows."
    else
      echo "VS Code is not installed on Windows."

      # Install VS Code on Windows
      echo "Installing VS Code on Windows..."
      curl -o vs_code_installer.exe -L "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
      start /wait vs_code_installer.exe
    fi
  else
    # Not running inside WSL
    echo "Not running inside WSL."

    # Install VS Code on Ubuntu/Debian
    echo "Installing VS Code on Linux..."
    sudo apt-get install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c "echo \"deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main\" > /etc/apt/sources.list.d/vscode.list"
    rm -f packages.microsoft.gpg
    sudo apt install apt-transport-https
    sudo apt update
    sudo apt install code # or code-insiders
  fi

  # Set Visual Studio Code as default editor
  git config --global core.editor "code --wait"

}

# ------------------------------------------------------------------------------
# Install GPG and configure it for Git
# ------------------------------------------------------------------------------

# [1] Configure GPG to use Pinentry for passphrase entry------------------------

# Adding the line `pinentry-program /usr/bin/pinentry-curses` to the
# `~/.gnupg/gpg-agent.conf` file will configure GPG to use pinentry-curses for
# passphrase entry. This will prompt for passwords in the terminal.

# Adding the line `pinentry-program /usr/bin/gnome-keyring-daemon` to the
# `~/.gnupg/gpg-agent.conf` file will configure GPG to use gnome-keyring-daemon
# for passphrase entry. This will prompt for passwords using the GNOME Keyring.

# pinentry-curses is a collection of simple PIN or passphrase entry dialogs
# which utilize the Assuan protocol as described by the GnuPG project.

function gpg_setup {

  sudo apt-get update
  sudo apt-get install -y gnupg2 gnupg-agent pinentry-curses scdaemon
  sudo apt-get install -y whiptail # user interface tool
  echo "All necessary dependencies are installed."

  local gpg_config_dir="$HOME/.gnupg"
  local gpg_agent_file="$gpg_config_dir/gpg-agent.conf"

  mkdir -p "$gpg_config_dir" # -p flag creates the directory if it doesn't exist
  touch "$gpg_agent_file" # create the file if it doesn't exist

  # Configure gpg-agent to handle SSH keys
  if ! grep -q "enable-ssh-support" ~/.gnupg/gpg-agent.conf; then
    echo "enable-ssh-support" >>~/.gnupg/gpg-agent.conf
  fi
  # configure gpg-agent to use the standard socket
  if ! grep -q "use-standard-socket" ~/.gnupg/gpg-agent.conf; then
    echo "use-standard-socket" >>~/.gnupg/gpg-agent.conf
  fi
  # configure gpg-agent to write the environment variables to a file
  if ! grep -q "write-env-file" ~/.gnupg/gpg-agent.conf; then
    echo "write-env-file ~/.gpg-agent-info" >>~/.gnupg/gpg-agent.conf
  fi
  # configure pinentry-curses, a program that allows GPG to prompt for passwords in the terminal.
  if ! grep -q "pinentry-program" ~/.gnupg/gpg-agent.conf; then
    # echo "pinentry-program /usr/bin/pinentry-curses" >>~/.gnupg/gpg-agent.conf
    echo "pinentry-program /usr/bin/gnome-keyring-daemon" >>~/.gnupg/gpg-agent.conf
  fi

  # Restart gpg-agent to apply changes
  gpg-connect-agent reloadagent /bye

  # GPG_TTY environment variable: tell GPG which terminal to use for passphrase entry.

  local line_to_add="export GPG_TTY=\$(tty)"

  if ! grep -qF "$line_to_add" ~/.bashrc; then
    echo "$line_to_add" >>~/.bashrc
  fi
  if [ -f ~/.zshrc ]; then
    if ! grep -qF "$line_to_add" ~/.zshrc; then
      echo "$line_to_add" >>~/.zshrc
    fi
  fi

  # Set SSH to use gpg-agent for authentication
  export GPG_TTY=$(tty)
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  # if gpgconf --list-dirs agent-ssh-socket is not et at .bashrc or .zshrc, add it
  if ! grep -q "export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)" ~/.bashrc; then
    echo "export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)" >> ~/.bashrc
  fi
  if ! grep -q "export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)" ~/.zshrc; then
    echo "export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)" >> ~/.zshrc
  fi

  echo "GPG agent configured to handle SSH keys."
  
  # Check if gpg-agent is working for SSH
  ssh-add -L

  # Source the updated shell configuration files to apply changes
  if [ -n "$BASH_VERSION" ]; then
    source ~/.bashrc
  elif [ -n "$ZSH_VERSION" ]; then
    source ~/.zshrc
  fi

  # Set the GPG program to Use
  git config --global gpg.program "gpg"
  # General configuration for signing commits and tags
  git config --global commit.gpgsign true
  git config --global tag.gpgsign true


  # Adding a test GPG key and check if it's stored

  echo "Checking for existing GPG keys..."
  gpg --list-keys
  echo "If keys appear above, GPG is configured correctly."
  echo "Adding and removing a test GPG key..."
  if gpg --list-keys "Test User" | grep -q "Test User"; then
    echo "Test GPG key already added. Removing it..."
    gpg --delete-keys "Test User"
  else
    echo "Adding a test GPG key..."
    gpg --quick-generate-key "Test User <test@example.com>" default default never
    gpg --list-keys "Test User"
    if gpg --list-keys "Test User" | grep -q "Test User"; then
      echo "Test GPG key successfully added and listed. Removing it..."
      # Remove the test GPG key
      gpg --delete-keys "Test User"
    else
      echo "Failed to add or list test GPG key."
    fi
  fi

  # Configuring git to use GPG for signing commits and tags

  if ! gpg --list-secret-keys; then
    echo "No existing GPG keys found. Generating a new GPG key..."
    generate_gpg_key
  else
    echo "Existing GPG key found. Listing GPG keys..."
    gpg --list-secret-keys
    # Ask for user to select one to config with Git
    echo "Select the GPG key to use for Git commits (16 characters):"
    read key_id
    git config --global user.signingkey "$key_id"
  fi

  # If the .gitconfig is already configured with a GPG key, display the key info 
  if git config --get user.signingkey; then
    echo "Git is already configured with a GPG key."
    echo "Configuring for GitHub, Bitbucket, and GitLab..."
    display_gpg_key_info
  fi

}

function generate_gpg_key {

  # Get user name and email from Git config
  local name=$(git config --global user.name)
  local email=$(git config --global user.email)

  # Check if name and email are set
  if [ -z "$name" ] || [ -z "$email" ]; then
    echo "Git user name or email not configured."
    core_config
  fi

  # Generate Key if doesn t exist a key with the comment "Git Commit Key"
  if ! gpg --list-secret-keys | grep -q "Git Commit Key"; then
    echo "No existing GPG key found for Git commits. Generating a new key..."
    gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 4096
Key-Usage: sign
Subkey-Type: RSA
Subkey-Length: 4096
Subkey-Usage: encrypt
Name-Real: $name
Name-Email: $email
Expire-Date: 1y
Name-Comment: Git Commit Key
%commit
%echo GPG key generation completed.
EOF
  else
    echo "Existing GPG Commit key found."
  fi

  local keys=$(gpg --list-secret-keys --with-colons | grep -B3 "Git Commit Key" | grep -E "^sec" | awk -F':' '{print $5}' | head -n 1)
  echo "GPG key ID: $keys"
  Using this key for signing commits and tags.
  git config --global user.signingkey "$keys"

}

# [Display GPG key info]--------------------------------------------------------

function display_gpg_key_info {

  local key_id=$(gpg --list-secret-keys --with-colons | grep -B3 "Git Commit Key" | grep -E "^sec" | awk -F':' '{print $5}' | head -n 1)

  if [ -z "$key_id" ]; then
    echo "No GPG key for Git Commit found."
    return
  fi

  echo "Git Commit Key ID: $key_id"
  echo "Exporting the public key..."

  gpg --armor --export "$key_id" # export the public key

  echo "Add the public key to your account(s) settings:"
  echo "GitHub: Go to Settings > SSH and GPG keys > New GPG key."
  echo "Bitbucket: Will implement Signed commit at Q4 2024. Atlasian have no shame."
  echo "GitLab: Go to Preferences > GPG Keys > Add new GPG key."

}

# ------------------------------------------------------------------------------
# SSH Configuration
# ------------------------------------------------------------------------------

function ssh_config {

  # Define associative arrays
  declare -A gh bb gl

  # GitHub configuration
  gh=(
    [file]="$HOME/.ssh/id_ed25519_gh"
    [host]="github.com"
    [service_name]="GitHub"
    [settings_url]="https://github.com/settings/keys"
    [test_ssh_command]="ssh -T git@github.com"
    [success_message]="successfully authenticated"
  )

  # Bitbucket configuration
  bb=(
    [file]="$HOME/.ssh/id_ed25519_bb"
    [host]="bitbucket.org"
    [service_name]="BitBucket"
    [settings_url]="https://bitbucket.org/account/settings/ssh-keys/"
    [test_ssh_command]="ssh -T git@bitbucket.org"
    [success_message]="authenticated via"
  )

  # GitLab configuration
  gl=(
    [file]="$HOME/.ssh/id_ed25519_gl"
    [host]="gitlab.com"
    [service_name]="GitLab"
    [settings_url]="https://gitlab.com/-/profile/keys"
    [test_ssh_command]="ssh -T git@gitlab.com"
    [success_message]="Welcome to GitLab"
  )

  # Array of keys for the associative arrays
  local services=("gh" "bb" "gl")

  # Get user name and email from global git config
  local name=$(git config --global user.name)
  local email=$(git config --global user.email)

  # Ensure the SSH config file exists. It iwll be used to store the SSH keys
  # path and the host to use the key with.
  local config_file="$HOME/.ssh/config"
  if [ ! -f "$config_file" ]; then
    touch "$config_file"
  fi
  chmod 600 "$config_file"

  # Start the ssh-agent in the background
  if ! pgrep ssh-agent >/dev/null; then
    echo "No ssh-agent found. Starting a new one."
    eval "$(ssh-agent -s)"
  fi

  for service in "${services[@]}"; do

    local file="${service}[file]"; file="${(P)file}"
    local host="${service}[host]"; host="${(P)host}"
    local service_name="${service}[service_name]"; service_name="${(P)service_name}"
    local settings_url="${service}[settings_url]"; settings_url="${(P)settings_url}"
    local test_ssh_command="${service}[test_ssh_command]"; test_ssh_command="${(P)test_ssh_command}"
    local success_message="${service}[success_message]"; success_message="${(P)success_message}"

    echo "------------------------------------------------------------------------------"
    echo "Configuring SSH for ${service_name}"  # `(P)` is for zsh, in bash should be `!`
    echo "------------------------------------------------------------------------------"

    # Check if an SSH key for the service exists -------------------------------

    if [ -f "${file}" ]; then
      echo "SSH key for ${service_name} already exists."
    else
      # Generate a new SSH key for the remote repository
      ssh-keygen -t ed25519 -f "${file}" -C "$email"
      echo "Generated SSH key for ${service_name}."
    fi

    # Ensure proper permissions for the private key file: only the owner can
    # read or write it
    chmod 600 "${file}"

    # verify if private key file is already added to the ssh-agent -------------

    if ssh-add -l | grep -q "$(ssh-keygen -l -f ${file}.pub)"; then
      echo "SSH key is already added to the ssh-agent."
    else
      echo "Adding the private key to the ssh-agent. You should enter your password."
      ssh-add "${file}"
    fi

    # Update the SSH configuration file with the SSH key and the host ----------

    if ! grep -Fq "Host ${host}" "$config_file" && ! grep -Fq "  IdentityFile ${file}" "$config_file"; then
      echo "Host ${host}" >>"$config_file"
      echo "  IdentityFile ${file}\n  IdentitiesOnly yes\n" >>"$config_file"
      echo "SSH configuration for ${host} has been updated."
    fi

    # Configure the keys -------------------------------------------------------

    while true; do
      # Inform the user about the next steps
      echo "Go to ${settings_url}"
      echo "Add this SSH key to your ${service_name} account:"
      cat "${file}.pub"
      echo "After adding the key, press enter to continue..."
      read

      local output=$(eval $test_ssh_command 2>&1); echo $output
      
      if [[ $output == *"${success_message}"* ]]; then
        echo "Successfully authenticated with ${service_name}!"
        break
      else
        echo "Authentication failed. Ensure the SSH key is added to your ${service_name} account."
        echo "Press enter to try again or Ctrl+C to exit."
        read
      fi
    done

    echo "Git is now configured to use SSH for ${service_name}."

  done

  # core.sshCommand is used to override the default SSH command used by Git.
  # The -F /dev/null option is used to disable the use of the SSH configuration
  # file. This is necessary because the SSH configuration file is used to
  # specify the SSH key to use for each host, and we want to use the SSH agent
  # to manage the keys.
  git config --global core.sshCommand "ssh -F /dev/null"

  #use_gnome_keyring

}

# ------------------------------------------------------------------------------
# Git credential helpers
# ------------------------------------------------------------------------------

function use_gnome_keyring {
  sudo apt-get update
  sudo apt-get install -y gnome-keyring libsecret-tools libsecret-1-0 libsecret-1-dev

  # if credential helper is not built, build it
  if ! command_exists git-credential-libsecret; then
    echo "Building the Git credential helper for GNOME Keyring..."
    sudo make --directory=/usr/share/doc/git/contrib/credential/libsecret
  else
    echo "Git credential helper for GNOME Keyring is already built."
  fi
  
  # Set the credential helper to use the GNOME Keyring

  # If Debian or Ubuntu:
  if [ -f /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret ]; then
    git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
  # If Arch Linux:
  elif [ -f /usr/lib/git-core/git-credential-libsecret ]; then
    git config --global credential.helper /usr/lib/git-core/git-credential-libsecret
  else
    echo "Git credential helper for GNOME Keyring not found."
  fi

  # Script to start gnome-keyring-daemon with necessary components on shell startup

  echo "Starting GNOME Keyring daemon with necessary components..."

  # for BASH
  
  # for gnome-keyring. What this code does is to set the SSH_AUTH_SOCK environment
  # variable to the path of the socket file that gnome-keyring uses to communicate
  # with the ssh-agent. This way, when you run ssh-add, it will add the key to
  # gnome-keyring's ssh-agent, and you will be able to use the key without having
  # to enter the passphrase again.

  local ssh_auth_sock=$(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)
  echo "Auth sock:"$ssh_auth_sock

  if ! grep -qxF $ssh_auth_sock ~/.bashrc; then
    echo $ssh_auth_sock >>~/.bashrc
    echo "GNOME Keyring daemon will start automatically in future shell sessions at BASH."
  else
    echo "GNOME Keyring daemon startup script already present in .bashrc."
  fi

  if ! grep -qxF $ssh_auth_sock ~/.zshrc; then
    echo $ssh_auth_sock >>~/.zshrc
    echo "GNOME Keyring daemon will start automatically in future shell sessions at ZSH."
  else
    echo "GNOME Keyring daemon startup script already present in .zshrc."
  fi

  # Restart the shell or source the .bashrc file to initialize the GNOME Keyring daemon
  if [ -n "$BASH_VERSION" ]; then
    source ~/.bashrc
  elif [ -n "$ZSH_VERSION" ]; then
    source ~/.zshrc
  fi

  # if gnome keyring is emprty, add a test entry
  if secret-tool lookup test test | grep -q "test"; then
    echo "Test entry already exists in the GNOME Keyring."
    echo "GNOME Keyring is working."
  else
    echo "Adding a test entry to the GNOME Keyring..."
    secret-tool store --label="Test Entry" test test
    if secret-tool lookup test test | grep -q "test"; then
      echo "GNOME Keyring is working."
    else
      echo "GNOME Keyring is not working."
    fi
  fi

}

# ------------------------------------------------------------------------------
# aliases
# ------------------------------------------------------------------------------

alias jr_git_config="core_config"  # install git and core config
alias jr_git_lfs="install_git-lfs" # install git-lfs
alias jr_install_code="install_code"   # install VS Code
alias jr_keyring="use_gnome_keyring"   # use GNOME Keyring

alias jr_gpg_setup="gpg_setup"              # setup GPG for GitHub, Bitbucket, and GitLab
alias jr_gpg_display="display_gpg_key_info" # display GPG key info
alias jr_gpg_key_gen="generate_gpg_key"     # generate GPG key
alias jr_ssh_config="ssh_config"            # configure SSH for GitHub, Bitbucket, and GitLab
