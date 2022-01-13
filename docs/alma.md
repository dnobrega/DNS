# ALMA

The Atacama Large Millimeter/submillimeter Array (ALMA) is a radio interferometer constructed in the Atacama Desert at 5,000 meters above sea level in the northern Republic of Chile in South America. This radio telescope is composed of 66 high-precision antennas, which operate on wavelengths of 0.32 to 3.6 mm. Its main array has fifty antennas, each with 12-meter diameters, which act together as a single telescope: an interferometer. This is complemented by a compact array of four antennas with 12-meter diameters and 12 antennas with 7-meter diameters. ALMA’s antennas can be configured in different ways, spacing them at distances from 150 meters to 16 kilometers, giving ALMA a powerful “zoom” variable, which results in images clearer than the images from the Hubble Space Telescope ([ALMA basics](https://almascience.nrao.edu/about-alma/alma-basics)).


## ALMA main links


- ALMA home webpage: [ALMA](https://almascience.nrao.edu/)
- SSALMON home webpage: [SSALMON](https://www.ssalmon.uio.no/)

## Analyzing synthetic ALMA data from Bifrost simulations: int.h5 files.

- _It is necessary to clone the Bifrost code and DNS package for the following instructions._

- To get a list of the existing synthetic files (int.h5) within a folder, type:
``` IDL
f=alma_synthfiles()
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
             ; We convert it to temperature:
             ; Stokes_I * lambda^2/Kb
; Tau1       : Optical depth in cm
             ; We convert it to Mm
; Wavelength : Wavelength in Angstrom
             ; We convert it to mm
```
This is the list of wavelengths and their correspondence with the different ALMA bands:
```
 0 : (lambda): 5000.000 for debugging purposes (should looks like a photosphere) 

Band 3 // 3.2  -> 2.77 [mm]

 1 : (lambda): 32586136.73913, (freq)     92000000000.00121, (to K) 3.845497e+14
 2 : (lambda): 31892814.68085, (freq)     94000000000.00017, (to K) 3.683600e+14
 3 : (lambda): 31228381.04167, (freq)     95999999999.99896, (to K) 3.531715e+14

 4 : (lambda): 28826197.88462, (freq)    104000000000.00137, (to K) 3.009272e+14
 5 : (lambda): 28282307.35849, (freq)    105999999999.99835, (to K) 2.896786e+14
 6 : (lambda): 27758560.92593, (freq)    107999999999.99969, (to K) 2.790491e+14

Band 6 // 1.30 -> 1.20 [mm]

 7 : (lambda): 13091373.71179, (freq)    229000000000.00690, (to K) 6.206649e+13
 8 : (lambda): 12978028.48485, (freq)    231000000000.00870, (to K) 6.099639e+13
 9 : (lambda): 12866629.09871, (freq)    233000000000.00815, (to K) 5.995374e+13

10 : (lambda): 12236426.85714, (freq)    244999999999.99716, (to K) 5.422455e+13
11 : (lambda): 12137346.47773, (freq)    246999999999.99585, (to K) 5.334998e+13
12 : (lambda): 12039857.75100, (freq)    249000000000.00040, (to K) 5.249639e+13

Band 7 // 0.88 -> 0.84 [mm]

13 : (lambda):  8853882.39811, (freq)    338599999999.99500, (to K) 2.838927e+13
14 : (lambda):  8801892.48385, (freq)    340600000000.00104, (to K) 2.805685e+13
15 : (lambda):  8750509.57385, (freq)    342600000000.00214, (to K) 2.773023e+13
16 : (lambda):  8550840.21677, (freq)    350600000000.01038, (to K) 2.647917e+13
17 : (lambda):  8502338.57062, (freq)    352600000000.01105, (to K) 2.617963e+13
18 : (lambda):  8454384.03835, (freq)    354600000000.00323, (to K) 2.588515e+13
```

## Analyzing synthetic ALMA data from Bifrost simulations: model.h5 files.

- _It is necessary to clone the Bifrost code and DNS package for the following instructions._

- To get a list of the existing model files (model.h5) that generated the ALMA synthetic files within a folder, type:
``` IDL
g=alma_modelfiles()
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
;dx           : X axis in cm. Converted to Mm.
;dy           : Y axis in Mm. Converted to Mm.
;z            : Z azis in Mm. Converted to Mm.
```

