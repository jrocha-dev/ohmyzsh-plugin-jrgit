# Oh-My-Zsh Plugin for Enhanced Git Functionality

This oh-my-zsh plugin provides a suite of functions to streamline the Git user experience. It includes
features for installing and configuring Git, handling large files with Git LFS, improving diff outputs, and
managing credentials and keys securely.

## Features

- **Git Installation and Basic Configuration**: Automatically install Git if it's not already present and
  configure user details.
- **Enhanced Diff Output**: Integrate `diff-so-fancy` for more readable and informative git diffs.
- **Large File Storage (LFS)**: Setup and configure Git LFS to handle large files efficiently in your
  repositories.
- **Visual Studio Code Integration**: Setup VS Code as the default editor for commits and configure it to work
  seamlessly with Git.
- **GPG Configuration**: Setup and manage GPG for signing commits and tags, ensuring security and
  verifiability of your contributions.
- **SSH Configuration**: Generate and manage SSH keys for GitHub, Bitbucket, and GitLab, including automated
  SSH-agent handling.
- **Credential Management**: Use GNOME Keyring as a credential helper to securely store and access your Git
  credentials.

## Installation

1. **Clone the Plugin Repository**: Clone this repository into your custom oh-my-zsh plugins directory:

```bash
git clone https://github.com/jrocha-dev/ohmyzsh-plugin-jrgit.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/jrgit/
```

2. **Activate the Plugin**: Add jrgit to the list of plugins in your .zshrc file:

```bash
plugins=(... jrgit)
```

3. **Reload Your Shell**: Reload your zsh configuration to apply the changes:

```bash
source ~/.zshrc
```

## Usage

After installation, you can use the following aliases and functions to manage your Git environment:

- `jr_git_config`: Install Git if necessary and set up basic user configuration.
- `jr_git_lfs`: Install and configure Git Large File Storage.
- `jr_install_code`: Install Visual Studio Code and configure it as the default Git editor.
- `jr_keyring`: Set up GNOME Keyring as the Git credential helper.
- `jr_gpg_setup`: Configure GPG for use with Git, including SSH key management.
- `jr_gpg_display`: Display GPG key information and provide instructions for adding it to GitHub, Bitbucket,
  or GitLab.
- `jr_gpg_key_gen`: Generate a new GPG key for signing commits and tags.
- `jr_ssh_config`: Configure SSH for use with GitHub, Bitbucket, and GitLab.

## Contributing

Contributions to this plugin are welcome! Please fork the repository, make your changes, and submit a pull
request.

## Support

If you encounter any issues while using this plugin, please open an issue in the repository on GitHub.

Thank you for using this oh-my-zsh plugin to enhance your Git experience!
