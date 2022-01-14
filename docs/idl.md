# IDL 

IDL, short for Interactive Data Language, is a programming language used for data analysis. It is popular in particular areas of science, such as astronomy, atmospheric physics and medical imaging
___
## Installation

Ask in your institute to install it and to get a license since IDL is a paid programming language. 
Once you have it, in your home directory, check your .zlogin file to see if you have defined the
following variables: ```IDL_DIR``` and  ```IDL_PATH```.
In case of using Mac and tcsh, you should have something like this:

``` zsh
export IDL_PATH="/Applications/exelis/idl85/bin"
export IDL_DIR="/Applications/exelis/idl85/"
```

including the ```IDL_PATH``` in your ```PATH```:

``` zsh
export PATH=$PATH":"$IDL_PATH
```

___
## SSWIDL

SolarSoft is a set of integrated software libraries, data bases, and system utilities which provide a common programming and data analysi\
s environment for Solar Physics. It is primarily an IDL based system, although some instrument teams integrate executables written in oth\
er languages.

### Installation

SSWIDL can be only used in csh/tcsh terminals, but we can configurate our terminal to launch without having to switch (see below).
To install it, follow these instructions: [SSWIDL_INSTALL](http://www.lmsal.com/solarsoft/sswdoc/solarsoft/ssw_install_howto.html).
Choose, e.g., the following packages to install: _chianti ontology aia iris hmi_

### Terminal configuration
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

___
## DNSPRO

DNSPRO is a package of IDL routines developed by Daniel Nóbrega Siverio to visualize Bifrost simulations.
So far, it depends on IDL routines of Bifrost, so you need to clone Bifrost. In addition to Bifrost visualization
routines, now it includes basic routines for SST observations developed by Luc Rouppe van der Voort. 


### Installation

You can clone the repository through HTTPS like this:

```tcsh
git clone https://username@github.com/dnobrega/DNS.git
```

replacing "username" with your github username.

To use the package, it is necessary to modify your .login file in your home directory to add the following system variables.
In case of working with zsh:

``` zsh
export DNS="/folder/DNS"
```

where _folder_ is in this case the location where you have cloned the DNS package.

Then you need to add ```DNS``` path to the ```IDL_PATH```. You should have something like this
in case of using tcsh and Mac:

``` zsh
export IDL_PATH="/Applications/exelis/idl85/bin"":+"$BIFROST_IDL":+"$DNS
```

Finally, you need to define a variable called ```DNS_PROJECTS``` with the default
location where you want to save the plots and movies you are going
to create with the DNS package, e.g.,

``` zsh
export DNS_PROJECTS="~/dns_plots"
```

and create that folder. Within ```DNS_PROJECTS```, new folders will be automatically
created with the name of the simulation when you save images or movies related
to that simulation.

### Usage examples for Bifrost runs

Within a folder with a Bifrost experiment, run ```SSWIDL```.
The first plot we are going to create is a density plot:

``` IDL
dns_plot, "r",snapt=0
```
where you have to modify ```snapt``` variable with the number of snapshot you want to plot.
In case of a 3D run, by default it will show the "XZ" plane along the whole Y-direction.
You can modify which slices you want to show, e.g.,

``` IDL
dns_plot, "r",snapt=0, iy0=10, iyf=100, iystep=2
```
will show from index 10 to index 100 in Y-direction each two indexes.
In case you want a specific slice in Y-direction,
use ```iyt```, e..g,

``` IDL
dns_plot, "r",snapt=0, iyt=300, /png
```
In this case we have also added the png flag to save the image as a .png file
in ```DNS_PROJECTS``` folder.

You can also plot animations moving in time as follows:

``` IDL
dns_plot, "r",snap0=0, snapf=500, step=10, iyt=300
```

That will show the XZ plane of the simulation in the index 300 of the Y-direction from
snapshot 0 to snapshot 500 each 10 snapshots.

You can save the previous animation, writing

``` IDL
dns_plot, "r",snap0=0, snapf=500, step=10, iyt=300, /movie, /setplot
```

That will create a movie in your ```DNS_PROJECTS``` folder. The ```setplot``` flag is
to create the movie using the Z buffer device.

In 3D experiments you can plot different planes, for example,

``` IDL
dns_plot, "r",snapt=100, dim="yz", ixstep=10
```
which will show the YZ plane each 10 indexes in X-direction. You can do the same for XY,

``` IDL
dns_plot, "r",snapt=100, dim="xy", izstep=10
```

You can customize your window size, thickness, colors, position of the plot... For instance,

``` IDL
dns_plot, "r",snapt=100, dim="xy", xsize=1200, ysize=600, position=[0.14,0.08, 0.92, 0.74]
```

Once you are happy with your plot setup, you can save it, so you will not need to write
all the commands again. To do that, use

``` IDL
dns_plot, "r",snapt=100, dim="xy", xsize=1200, ysize=600, position=[0.14,0.08, 0.92, 0.74], /save_dns_confi
```
That will create a file in your current directory called ```dns_confi.sav``` with the plot parameters you have
defined.

### Usage examples for SST obs

Within a folder with reduced SST observations, run ```SSWIDL```.

Then create a string list with the names of the cube files within that folder. To that end, type
``` IDL
fcube, f
```

That will give you an array ```f``` of files that can be fcubes (floating-point cubes) or icubes (integer cubes).

The following step is, e.g., to read the first cube of the list by writting
``` IDL
cube=lp_read(f(0),header=header)
```

You can also run a CRISPEX session by doing the following. Let's assume your list contains the following files:
``` IDL
 0 nb_6563_08:05:00_aligned_3950_2017-05-25T08:07:37.icube
 1 nb_6563_08:05:00_aligned_3950_2017-05-25T08:07:37_sp.icube
 2 hmimag_2017-05-25T08:07:37_aligned_3950_2017-05-25T08:07:37.fcube
```
so,
``` IDL
crispex, f[0], f[1], refcube=f[2]
```
will start a CRISPEX session using the Halpha data together with an HMI magnetogram as reference. Please remind that the first
file has to be an image file and the second file has to be a sp (spectral) file. They are actually the same array, but
ordered differently.
