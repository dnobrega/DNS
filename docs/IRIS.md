# IRIS

- IRIS home webpage: [IRIS](https://iris.lmsal.com/)
- IRIS Science Highlights: [IRIS Higlights](http://iris.lmsal.com/science_highlights/)
- IRIS Event Search: [IRIS Search](https://iris.lmsal.com/search/)
- IRIS Event Search + Other Telescopes/Observations: [HEK Search](http://www.lmsal.com/heksearch/)

## Analyzing IRIS data
- Data Analysis Tutorials by Tiago Pereira: [Data Analysis Tutorials](https://folk.uio.no/tiago/iris9/exercises/index.html)
- IRIS2: [IRIS2](https://iris.lmsal.com/iris2/)


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
