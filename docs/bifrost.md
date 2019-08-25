# Bifrost


## Bifrost literature

The paper explaing the code can be found in [Gudiksen et al. (2011)](http://adsabs.harvard.edu/abs/2011A%26A...531A.154G)

Other important papers to understand the Bifrost modules are:

- Radiative transfer solver with coherent scattering: [Hayek et al. (2010)](http://adsabs.harvard.edu/abs/2010A%26A...517A..49H)
- Nonequilibrium ionization of Hydrogen: [Leenaarts et al. (2011)](http://adsabs.harvard.edu/abs/2011A%26A...530A.124L)
- Radiative transfer in the chromosphere: [Carlsson and Leenaarts (2012)](http://adsabs.harvard.edu/abs/2012A%26A...539A..39C)
- Generalized Ohm's Law: [Martínez-Sykora et al. (2012)](http://adsabs.harvard.edu/abs/2012ApJ...753..161M)
- Nonequilibrium ionization of _optically thin ions_: [Olluri et al. (2013)](http://adsabs.harvard.edu/abs/2013AJ....145...72O)
- Nonequilibrium ionization of Helium: [Golding et al. (2016)](http://adsabs.harvard.edu/abs/2016ApJ...817..125G)
- Lagrangian Tracing module: [Leenaarts (2018)](http://adsabs.harvard.edu/abs/2018A%26A...616A.136L)



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
