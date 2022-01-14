# Mac OS

This list contains useful software you should install when using a Mac for the first time
and the terminal configuration.

___
## Software

### Xcode

Xcode is an integrated development environment for macOS containing a suite of software development tools developed by Apple. You can download and install it from the Apple store. You can also check the following link:  
[Xcode](https://developer.apple.com/xcode/).

### Oh my zsh

A delightful community-driven (with 1700+ contributors) framework for managing your zsh configuration. 
Includes 200+ optional plugins (rails, git, OSX, hub, capistrano, brew, ant, php, python, etc), over 140 
themes to spice up your morning, and an auto-update tool so that makes it easy to keep up with the latest updates from the community:  
[ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)

### Emacs

Emacs is the extensible, customizable, self-documenting real-time display editor. Download the .dmg file from here:  
[Emacs](https://emacsformacosx.com/)

After installing Emacs, it is useful to define a new alias. In case of using zsh, modify your _.zshrc_ file to include
```bash
alias emacs="emacs -nw"
```
This will let you open any file in the terminal and not in a new extra annoying and time-consuming window.


### Homebrew

Homebrew is the Missing Package Manager for macOS:   
[Homebrew](https://brew.sh/)

### GCC

The GNU Compiler Collection includes front ends for C, C++, Objective-C, Fortran, Ada, Go, and D, as well as libraries for these languages (libstdc++,...). GCC was originally written as the compiler for the GNU operating system. The GNU system was developed to be 100% free software, free in the sense that it respects the user's freedom.

Install it after having homebrew by typing

```bash
brew install gcc
```

### MPICH

MPICH is a high performance and widely portable implementation of the Message Passing Interface (MPI) standard. You can install it
through homebrew following the instructions here:  
[MPICH](https://formulae.brew.sh/formula/mpich)

___
## Terminal configuration

Currently I work with _zsh_ and therefore all the configuration is refered to it.

### .zshrc file

###### A list with my useful alias
- Setting shorcuts and colors in all the ls commands by default.
``` bash
alias ls="/bin/ls -FG"
alias la="ls -la"
alias ll="ls -lhrt"
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
```
- Setting no-window option as default for emacs:
``` bash
alias emacs="emacs -nw"
```
- Setting colors as default option for grep:
``` bash
alias grep="grep --colour"
```
- Checking empty folders:
``` bash
alias empty="find . -type d -empty" #add -delete to remove the empty folders
```
- Since SSWIDL only works in _tcsh_, I do the following to avoid changing the terminal:
``` bash
alias sswidl='tcsh -c "sswidl"'
```

### Functions

This a find function, so I can, e.g., f math_mpi to look for directories having * math_mpi * files avoiding moreover all the _Permission denied_ messages in the output:
``` bash
f(){
    echo "find . -iname \"*$1*\" 2>/dev/null"
    find . -iname "*$1*" 2>/dev/null
}
```

### Appereance
I prefer having my terminal as minimalist as possible, therefore I remove the username and host information
in the terminal, to only show a ~ character.
``` bash
export PS1="~ "
```
In order to know your current folder, on MacOS, you can go to Terminal preferences, Profiles, Windows,
and enable the option "Working directory or document" and "Path". This way, the current folder is shown
in the uppermost part of the terminal.

### Autoload and zstyle
Enhancing the completion by assigning colors to the options, making them insensitive to lower-case/capital letters and enabling the TAB menu select:
``` bash
autoload -Uz compinit && compinit
zmodload -i zsh/complist
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
```


