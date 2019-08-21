# Welcome to D. Nóbrega-Siverio's webpage

## Bifrost

The paper explaing the code can be found in the following link:

[Gudiksen et al. (2011)](https://www.aanda.org/articles/aa/pdf/2011/07/aa16520-11.pdf)

## Getting Bifrost

Bifrost is located on github. The repository is private, meaning you
should be logged in with your github username to see it at:

[Bifrost repository](https://github.com/ITA-Solar/Bifrost)

To get started with the new repository, you'll need to have git
(pre-installed in most machines) and configure it to use your name and
email address you registered with github, by doing something like:

``` tcsh
git config --global user.name "Daniel Nobrega"  
git config --global user.email dnobrega@example.com
```

You can clone the repository through HTTPS like this:

```tcsh
git clone https://username@github.com/ITA-Solar/Bifrost.git
```

replacing "username" with your github username.

## Terminal configuration

In your home directory, create (or modify) your .login file to add the following system variables.
In case of working with tcsh:

``` csh
setenv BIFROST "/folder/Bifrost"
setenv BIFROST_IDL $BIFROST"/IDL"
```
where _folder_ is the location where you have cloned the Bifrost repository.
It is also necessary to define a system variable called OSC_CSTAGGER 
depending on your operative system. 

- If you use a Linux system:  
``` tcsh 
setenv OSC_CSTAGGER $BIFROST_IDL"/cstagger/linux"
``` 
- In case of a intelmac:  
``` tcsh 
setenv OSC_CSTAGGER $BIFROST_IDL"/cstagger/intelmac"
```

You can also add an alias so you can go the Bifrost folder easily.
In case	of working with	tcsh:

``` tcsh 
alias bifrost "cd /folder/Bifrost/"
```

## Stagger configuration

Next step is to go to your stagger folder, typing in your terminal

``` tcsh
cd $OSC_CSTAGGER
```

and then

``` tcsh 
make
```

That would create the following six files:

* cstagger.pro
* cstagger.c
* cstagger.o
* init_stagger.o
* inverse.o
* cstagger.so

which are necessary for stagger operations 

## DNSPRO

IDL routines are located on
[dnspro](https://github.com/dnobrega/)
