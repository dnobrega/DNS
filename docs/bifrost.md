

# Bifrost

Bifrost is a massively parallel code developed for tridimensional numerical experiments of stellar atmospheres [(Gudiksen et al. 2011)](http://adsabs.harvard.edu/abs/2011A%26A...531A.154G). In order to explicitly solve the standard partial differential equations of magnetohydrodynamics (MHD), its core uses a staggered mesh in cartesian coordinates `(x,y,z)`. The positioning of the variables in the mesh is as follows: the scalar variables, e.g., the density `ρ`, are defined in the center of the numerical cells; the components of the basic vector fields, namely, the magnetic field `B_i` and linear momentum `p_i`,  are located at the center of the cell faces;  and the cross product or curl of those vectors, like `(vxB)_i` or `J_i`, are defined on the cell edges.

The numerical scheme is a classic method of lines (MOL). It is based on a sixth order operator for the spatial derivatives. Since Bifrost uses a staggered mesh, it is not possible to avoid the use of interpolations to re-collocate the variables in space during the computations. Those interpolations are of fifth order. The time derivatives can follow a predictor-corrector scheme of third order described by [Hyman (1979)](https://ui.adsabs.harvard.edu/abs/1979acmp.proc..313H/abstract) or a third order Runge Kuttta method. In both cases, the timestep is controlled by the Courant-Friedrichs-Lewy (CFL) criterion [(Courant et al. 1928)](http://adsabs.harvard.edu/abs/1928MatAn.100...32C).

In spite of using high-order methods, the numerical codes are diffusive by their own nature due to the discretization of the equations. To ensure stability, Bifrost employs a diffusive operator that consists of two main terms: a small global diffusive term and the so called hyperdiffusion term inspired by [Nordlund & Galsgaard (1995)](http://sirrah.troja.mff.cuni.cz/~toast/archiv/nordlund-95.ps). The latter is a location-specific diffusion that acts in small regions of large gradients or jumps in the variables, like in current sheets or shocks.

The advantage of using the Bifrost code is that it includes different modules that provide relevant physics for the solar atmosphere. In the following, we list the most important ones:

- Equation of state: [Gustafsson et al. (1975)](http://adsabs.harvard.edu/abs/1975A%26A....42..407G)
- Injection of magnetic field through the bottom boundary of the convection zone: [Martínez-Sykora et al. (2008)](http://adsabs.harvard.edu/abs/2008ApJ...679..871M)
- Radiative transfer solver with coherent scattering: [Skartlien (2000)](http://adsabs.harvard.edu/abs/2000ApJ...536..465S) and [Hayek et al. (2010)](http://adsabs.harvard.edu/abs/2010A%26A...517A..49H)
- Nonequilibrium ionization of Hydrogen: [Leenaarts et al. (2011)](http://adsabs.harvard.edu/abs/2011A%26A...530A.124L)
- Radiative transfer in the chromosphere: [Carlsson and Leenaarts (2012)](http://adsabs.harvard.edu/abs/2012A%26A...539A..39C)
- Generalized Ohm's Law: [Martínez-Sykora et al. (2012)](http://adsabs.harvard.edu/abs/2012ApJ...753..161M)
- Nonequilibrium ionization of _optically thin ions_: [Olluri et al. (2013)](http://adsabs.harvard.edu/abs/2013AJ....145...72O)
- Nonequilibrium ionization of Helium: [Golding et al. (2016)](http://adsabs.harvard.edu/abs/2016ApJ...817..125G)
- Lagrangian Tracing module: [Leenaarts (2018)](http://adsabs.harvard.edu/abs/2018A%26A...616A.136L)
- New ambipolar diffusion module: [Nóbrega-Siverio et al. (2020)](https://ui.adsabs.harvard.edu/abs/2020A%26A...638A..79N/abstract)



## Getting Bifrost

Bifrost is located on github. The repository is private, meaning you
should be logged in with your github username to see it at:

[Bifrost repository](https://github.com/ITA-Solar/Bifrost)

To get started with the new repository, you'll need to have git
(pre-installed in most machines) and configure it to use your name and
email address you registered with github, by doing something like:

``` bash
git config --global user.name "Your name"  
git config --global user.email username@example.com
```

You can clone the repository through HTTPS like this:

```bash
git clone https://username@github.com/ITA-Solar/Bifrost.git
```

replacing "username" with your github username.

## Terminal configuration

It can be useful to create (or modify) your _.login_ (in csh/tcsh) or _.zlogin_ (in zsh) file in your home directory to add a Bifrost system variable.

In case of working with zsh:  
```bash
export BIFROST="/folder/Bifrost"
```
In case of tcsh:  
```bash
setenv BIFROST "/folder/Bifrost"
```
where _folder_ is the location where you have cloned the Bifrost repository. 
