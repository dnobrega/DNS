# IRIS

The Interface Region Imaging Spectrograph (IRIS), is a NASA solar observation satellite. Launched on 28 June (2013), the mission was funded through the Small Explorer program to investigate the physical conditions of the solar limb, particularly the chromosphere of the Sun. The spacecraft consists of a satellite bus and spectrometer built by the Lockheed Martin Solar and Astrophysics Laboratory (LMSAL), and a telescope provided by the Smithsonian Astrophysical Observatory. IRIS is operated by LMSAL and NASA's Ames Research Center.

## IRIS main links

- IRIS home webpage: [IRIS](https://iris.lmsal.com/)
- IRIS Science Highlights: [IRIS Higlights](http://iris.lmsal.com/science_highlights/)
- IRIS Event Search: [IRIS Search](https://iris.lmsal.com/search/)
- IRIS Event Search + Other Telescopes/Observations: [HEK Search](http://www.lmsal.com/heksearch/)

## Analyzing IRIS data
- Data Analysis Tutorials by Tiago Pereira: [Data Analysis Tutorials](https://folk.uio.no/tiago/iris9/exercises/index.html)
- IRIS2: [IRIS2](https://iris.lmsal.com/iris2/)
- A quick-start guide to work with IRIS Level2 data in Python: [IRIS_LMSALPY](https://iris.lmsal.com/itn45/)


## Creating LVL3 data

These are the steps to create LVL3 data to analyze, for instance, IRIS+SDO/AIA data.

- Download IRIS raster data + SDO data in the same folder.
- Open a SSWIDL session in that folder
- Write 
``` IDL
iris_xfiles
```
and choose the folder with the data, choose one of the .fits and then create LVL3. 

- After that, we make a list with the name of the IRIS and SDO files:
``` IDL
f=iris_files()
```

- Finally,

``` IDL
crispex, f(im), f(sp), sji=f(AIA),/win
```
