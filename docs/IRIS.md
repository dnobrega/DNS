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

- Download IRIS raster data + SDO data.
- Open a SSWIDL session
-  
``` IDL
iris_xfiles, choose folder, choose one file and create it. 
```
where ...

- We create a list with the name of the IRIS files:
``` IDL
f=iris_files()
```

- We open a CRISPEX session:

``` IDL
crispex, f(im), f(sp), sji=f(AIA? STS?),/win
```
