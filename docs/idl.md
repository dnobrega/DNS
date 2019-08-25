# IDL in Bifrost

## First steps

In your home directory, check your .login file to see if you have defined the
following variables: ```IDL_DIR``` and  ```IDL_PATH```.
In case of using Mac and tcsh, you should have something like this:

``` csh
setenv IDL_PATH "/Applications/exelis/idl85/bin"
setenv IDL_DIR "/Applications/exelis/idl85/"
```

including the ```IDL_PATH``` in your ```PATH```:

``` csh
setenv PATH $PATH":"$IDL_PATH
```

In addition to that, you need to have installed Solar Soft IDL (SSWIDL). 
Check the documentation in [SSWIDL](https://dnobrega.github.io/DNS/sswidl/)

## Terminal configuration to use the IDL routines of Bifrost

Modify your .login file to add the following system variables.
In case of working with tcsh:

``` csh
setenv BIFROST_IDL $BIFROST"/IDL"
```
where ```BIFROST``` is a system variable for your Bifrost repository (see Bifrost section).
Then, modifiy your ```IDL_PATH``` to the the Bifrost IDL folder:

``` csh
setenv IDL_PATH "/Applications/exelis/idl85/bin"":+"$BIFROST_IDL
```

It is also necessary to define a system variable called ```OSC_CSTAGGER```, which
depends on your operative system. 

- If you use a Linux system:  
``` tcsh 
setenv OSC_CSTAGGER $BIFROST_IDL"/cstagger/linux"
``` 
- In case of a intelmac:  
``` tcsh 
setenv OSC_CSTAGGER $BIFROST_IDL"/cstagger/intelmac"
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

which are necessary for stagger operations.

## IDL startup

After all this steps, create a IDL startup file.
This file is going to be executed automatically each time IDL 
is started. For example, you can create it in your
IDLWorkspace and then add a similar line in your .login file
(in case of using tcsh) with the location:

``` csh
setenv IDL_STARTUP "/Users/yourname/IDLWorkspace85/startup.pro"
```
Edit the startup.pro file to add the following line

``` idl
.r $OSC_CSTAGGER/cstagger
```
whici will compile the Stagger routines each time you execute
IDL. With all the information above, you should be able
to use the IDL routines of Bifrost without any problem.

I also have the following useful lines in startup.pro

``` IDL
br_select_idlparam, idlparam
d=obj_new('br_data', idlparam)
br_getsnapind, idlparam, snaps
PRINT, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
PRINT, ' Project : ', idlparam, '  ', strtrim(string(min(snaps)),2), '-',strtrim(string(max(snaps)),2)
PRINT, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
PRINT, '
```

so everytime I run IDL within a folder containing a numerical experiment carried out with
Bifrost, I get the object to load Bifrost variables (```d```), the name of the simulation 
(```idlparam```) and all the snapshots I have in that folder (```snaps```). Then I print 
on the screen some of that information.


