# SSWIDL


## Installation
Install Solar Soft IDL (SSWIDL) following those instructions [SSWIDL_INSTALL](http://www.lmsal.com/solarsoft/sswdoc/solarsoft/ssw_install_howto.html).  
Choose the following packages: _chianti ontology aia iris hmi_

## Terminal configuration
Once installed, configurate your terminal to use SSWIDL.
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

Finally, add the following line in your .log file

``` csh
source $SSW/gen/setup/setup.ssw /quiet
```
