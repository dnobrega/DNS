# Mac OS

This list contains useful software you should install when usinig a Mac for the first time.


## Xcode

Xcode is an integrated development environment for macOS containing a suite of software development tools developed by Apple. You can download and install it from the Apple store. You can also check the following link:  
[Xcode](https://developer.apple.com/xcode/).

## Oh my zsh

A delightful community-driven (with 1700+ contributors) framework for managing your zsh configuration. 
Includes 200+ optional plugins (rails, git, OSX, hub, capistrano, brew, ant, php, python, etc), over 140 
themes to spice up your morning, and an auto-update tool so that makes it easy to keep up with the latest updates from the community:  
[ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)

## Emacs

Emacs is the extensible, customizable, self-documenting real-time display editor. Download the .dmg file from here:  
[Emacs](https://emacsformacosx.com/)

After installing Emacs, it is useful to define a new alias. In case of using zsh, modify your _.zshrc_ file to include
```bash
alias emacs="emacs -nw"
```
This will let you open any file in the terminal and not in a new extra annoying and time-consuming window.


## Homebrew

Homebrew is the Missing Package Manager for macOS:   
[Homebrew](https://brew.sh/)

## GCC

The GNU Compiler Collection includes front ends for C, C++, Objective-C, Fortran, Ada, Go, and D, as well as libraries for these languages (libstdc++,...). GCC was originally written as the compiler for the GNU operating system. The GNU system was developed to be 100% free software, free in the sense that it respects the user's freedom.

Install it after having homebrew by typing

```bash
brew install gcc
```

## MPICH

MPICH is a high performance and widely portable implementation of the Message Passing Interface (MPI) standard. You can install it
through homebrew following the instructions here:  
[MPICH](https://formulae.brew.sh/formula/mpich)
