# Terminal

This page contains my terminal configuration. Currently I work with _zsh_ and therefore
all the configuration is refered to it.

## .zshrc file

### ls options
Setting shorcuts and colors in all the ls commands by default.
``` bash
alias ls="/bin/ls -FG"
alias la="ls -la"
alias ll="ls -lhrt"
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
```

### Other useful alias
Setting no-window option as default for emacs:
``` bash
alias emacs="emacs -nw"
```
Setting colors as default option for grep:
``` bash
alias grep="grep --colour"
```
Checking empty folders:
``` bash
alias empty="find . -type d -empty" #add -delete to remove the empty folders    
```
Since SSWIDL only works in _tcsh_, I do the following to avoid changing the terminal:
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

### Terminal appereance
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


