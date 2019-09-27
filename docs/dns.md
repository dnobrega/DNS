# DNS

## Getting DNS package

You can clone the repository through HTTPS like this:

```tcsh
git clone https://username@github.com/dnobrega/DNS.git
```

replacing "username" with your github username.

## Terminal configuration

It is necessary to modify your .login file in your home directory to add the following system variables.
In case of working with tcsh:

``` csh 
setenv DNS "/folder/DNS" 
setenv IDL_DNS $DNS"/dnspro"
```

where _folder_ is in this case the location where you have cloned the DNS package. 

Then you need to add ```IDL_DNS``` path to the ```IDL_PATH```. You should have something like this
in case of using tcsh and Mac:

``` csh
setenv IDL_PATH "/Applications/exelis/idl85/bin"":+"$BIFROST_IDL":+"$IDL_DNS
```

Finally, you need to define a variable called ```DNS_PROJECTS``` with the default
location where you want to save the plots and movies you are going
to create with the DNS package, e.g.,

``` csh
setenv DNS_PROJECTS "~/dns_plots"
```

Obviously, you will also need to create that folder. 
Within ```DNS_PROJECTS```, other folders will be automatically 
created with the name of the simulation when you save a image or movie.

## Using DNS routines

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
dns_plot, "r",snapt=100, dim="xy", izstep=10, xsize=1200, ysize=600, load=39, position=[0.14,0.08, 0.92, 0.74]
```

Once you are happy with your plot setup, you can save it, so you will not need to write
all the commands again. To do that, use 

``` IDL
dns_plot, "r",snapt=100, dim="xy", izstep=10, xsize=1200, ysize=600, load=39, position=[0.14,0.08, 0.92, 0.74], /save_dns_confi
```
That will create a file in your current directory called ```dns_confi.sav``` with the plot parameters you have
defined.

Concerning the variables you can plot with DNS package, check ```dnspro/var``` folder.
There you will see a list of routines containg each one a variable. For example, for
the density, you will see a file called ```dnsvar_r.pro```

``` IDL 
PRO dnsvar_r, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Density: rho (g/cm^3)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_r, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       UNITS, units
       var=d->getvar(name,snaps,swap=swap)*units.ur
       var_title='!4q!3 (g cm!u-3!n)'
       var_range=[1.d-15,1.d-11]
       var_log=1
    ENDELSE
END
```

You can create all the variables following this format. So far, the list only
includes the most fundamental variables. If you need help
with the meaning of each variable, in the IDL prompt you can type, e.g.,

```IDL
dnsvar_modb, /info
```
which will show the information about the variable of that routine, in this case,

``` csh
% DNSVAR_MODB: Module of the magnetic field: B (G)
```


