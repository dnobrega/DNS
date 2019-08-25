# Bifrost

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

It is useful to create (or modify) your .login file in your home directory to add the following system variable.
In case of working with tcsh:

``` csh
setenv BIFROST "/folder/Bifrost"
```
where _folder_ is the location where you have cloned the Bifrost repository.

You can also add an alias so you can go the Bifrost folder easily.
In case	of working with	tcsh:

``` tcsh 
alias bifrost "cd /folder/Bifrost/"
```
where _folder_ is again the location where you have cloned the Bifrost repository.


## Bifrost documentation

For information about how to run Bifrost, check the documentation in [Bifrost](https://github.com/ITA-Solar/Bifrost)
