# SSWIDL

SolarSoft is a set of integrated software libraries, data bases, and system utilities which provide a common programming and data analysis environment for Solar Physics. It is primarily an IDL based system, although some instrument teams integrate executables written in other languages. 


## Installation
SSWIDL can be only used in csh/tcsh terminals, but we can configurate our terminal to launch without having to switch (see below). 
To install it, follow these instructions: [SSWIDL_INSTALL](http://www.lmsal.com/solarsoft/sswdoc/solarsoft/ssw_install_howto.html).  
Choose, e.g., the following packages to install: _chianti ontology aia iris hmi_


## Terminal configuration
Once installed, configurate your csh/tcsh terminal to use SSWIDL.
In your home directory, in the .login file you need to define 
the system variable ```SSW``` as the location of your
SSW installation, e.g.: 

``` csh
setenv SSW "/Users/yourname/ssw"
```

Then you need to define the ```SSW_INSTR``` with the list of instruments you have included in the installation.

``` csh
setenv SSW_INSTR "chianti ontology aia iris hmi"
```

Finally, add the following line in your .login file:

``` csh
source $SSW/gen/setup/setup.ssw /quiet
```

Once you have everything ready, in case you use zsh, you can define the following alias in your .zlogin (or .zshrc) file:
``` csh
alias sswidl='tcsh -c "sswidl"'
```
This way you will be able to launch it without switching manually to tsch.
