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

