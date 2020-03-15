# ALMA

- ALMA home webpage: [ALMA](https://almascience.nrao.edu/)
- SSALMON home webpage: [SSALMON](https://www.ssalmon.uio.no/)

## Analyzing synthetic ALMA data from Bifrost simulations

- _It is necessary to clone the Bifrost code and DNS package for the following instructions._
- To get a list of the existing synthetic files (int.h5) within a folder, type:
``` IDL
f=alma_synthfiles()
```
- To get a list of the existing model files (model.h5) that generated those synthetic files within a folder, type:
``` IDL
g=alma_modelfiles()
```
- The synthetic files contain the following variables: 
``` IDL
list=['Stokes_I','Tau1','Wavelength']
```
For instance, to read _Stokes_I_, type:
``` IDL
stokes_i=alma_readsynth(f(0),Stokes_I)
```
The units of the output variables are changed in the DNS routines.
``` IDL
; Stokes_I   : Stokes Intensity in erg/cm^2
             ; We convert it in temperature:
             ; Stokes_I * lambda^2/Kb
; Tau1       : Optical depth in cm
             ; We convert it in Mm
; Wavelength : Wavelength in Angstrom
```
- The model files contain the following variables: 
``` IDL
list=['Pgas','temperature','dens','dx','dy','z']
```
The units of the output variables are as follows:
``` IDL
;Pgas         : Gas pressure in CGS
;temperature  : Temperature in K
;dens         : Total density in CGS
;dx           : X axis in Mm
;dy           : Y axis in Mm
;z            : Z azis in Mm 
```

