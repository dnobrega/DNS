# SST

The Swedish 1-m Solar Telescope (SST) is a refracting solar telescope at Roque de los Muchachos Observatory, La Palma in the Canary Islands.
The SST is capable of providing high-quality time series of spectrally resolved photospheric and chromospheric diagnostics that under excellent seeing conditions reach the diffraction limit of 0.1" over the full arcmin^2 FOV. Furthermore, the versatile CRISP instrument can provide spectro-polarimetric data that enable measurement of the magnetic field topology. In addition, the tunable filter system CHROMIS, installed in 2016, can simultaneously provide narrowband filtergrams at several wavelengths in the core of the Ca II K line (Extracted from [Rouppe et al. (2020)](https://ui.adsabs.harvard.edu/abs/2020A%26A...641A.146R/abstract)).

## SST main links

- Overview of the observation conditions at the ORM in La Palma: [Shahin's website](https://shahin.website/sst/)
- SST wiki of RoCS: [Wiki](https://wiki.uio.no/mn/astro/lapalma/)
- SST Observations Schedule: [SST Schedule](https://dubshen.astro.su.se/wiki/index.php/Observations_schedule_2021)
- SST Data acquisitions: [Data acquisitions](https://dubshen.astro.su.se/wiki/index.php/Data_acquisitions)

## SST literature

- The SST telescope design and its main optical elements: [Scharmer et al. 2003a](https://ui.adsabs.harvard.edu/abs/2003SPIE.4853..341S/abstract).
- The SST adaptive optics system: [Scharmer et al. 2003a](https://ui.adsabs.harvard.edu/abs/2003SPIE.4853..370S/abstract).
- The CHROMospheric Imaging Spectrometer (CHROMIS): [CHROMIS webpage](https://dubshen.astro.su.se/wiki/index.php/CHROMIS) 
- The CRISP imaging spectropolarimeter: [Scharmer et al. 2008](https://ui.adsabs.harvard.edu/abs/2008ApJ...689L..69S/abstract)
- Upgrades of optical components and instrumentation, as well as a thorough evaluation of optical performance: [Scharmer et al. 2019](https://ui.adsabs.harvard.edu/abs/2019A%26A...626A..55S/abstract).


## Quicklook movies and images

ITA has now a very basic web server with the purpose of providing simple access to files ment for temporary viewing - like quicklook movies. 
We can put the SST quicklook movies at `/mn/stornext/d18/lapalma/quicklook/` which will then appear under http://tsih3.uio.no/lapalma/
- _For example, the 14-Jun quicklook movies from the LMSAL campaign are now under_    
 http://tsih3.uio.no/lapalma/2020/2020-06-14/
_which are linked from the Oslo SST wiki:_ 
 [https://wiki.uio.no/mn/astro/lapalma/index.php/Quicklook_June_2020#Sunday_14-Jun-2020](https://wiki.uio.no/mn/astro/lapalma/index.php/Quicklook_June_2020#Sunday_14-Jun-2020)

#### Script to combine CHROMIS quicklook movies and images:
```bash
#!/bin/bash
quickfile1=4861_+0
quickfile2=-1371
image_format=.jpg
movie_format=.mov

for ii in $( ls -d */); do
    jj="${ii///}"
    cd $jj
    temp=*$quickfile1*$image_format
    header=$( echo $temp | sed -e 's/\(quick_..........\).*/\1/')"_"
    image=$header"${jj//:}"$image_format 
    movie=$header"${jj//:}"$movie_format
    echo $image 
    echo $movie         
    ysize=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 *$quickfile1*$image_format)
    echo $ysize
    ffmpeg -i *$quickfile1*$image_format -i \
              *$quickfile2*$image_format    \
              -q:v 1 -filter_complex vstack=inputs=2 $image -hide_banner    
    ffmpeg -i *$quickfile1*$movie_format -i \
              *$quickfile2*$movie_format    \
              -filter_complex vstack=inputs=2 \
               $movie -hide_banner    
    cd ..       
done
```

#### Script to combine CRISP quicklook movies and images:
```bash
#!/bin/bash
quickfile1=6563_+0
quickfile2=8542_+0
quickfile3=-1680
image_format=.jpg
movie_format=.mov

for ii in $( ls -d */); do
    jj="${ii///}"
    cd $jj
    temp=*$quickfile1*$image_format
    header=$( echo $temp | sed -e 's/\(quick_..........\).*/\1/')"_"
    image=$header"${jj//:}"$image_format 
    movie=$header"${jj//:}"$movie_format
    ffmpeg -i *$quickfile1*$image_format -i \
              *$quickfile2*$image_format -i \
              *$quickfile3*$image_format      \
              -q:v 1 -filter_complex hstack=inputs=3 $image -hide_banner    
    ffmpeg -i *$quickfile1*$movie_format -i \
              *$quickfile2*$movie_format -i \
              *$quickfile3*$movie_format      \
              -filter_complex hstack=inputs=3 $movie -hide_banner    
    cd ..       
done
```

#### Script to see in the terminal a list of dates with quicklook movies available:
```bash
#!/bin/bash                                                                                                                    
for year in $(curl -s http://tsih3.uio.no/lapalma/ |
                  grep '\[DIR\]' |
                  sed 's/.*href="//' |
                  sed 's/".*//'
             ); do
    echo "---------------------------"
    echo $year
    echo "---------------------------"
    for date in $(curl -s http://tsih3.uio.no/lapalma/$year |
                      grep '\[DIR\]' |
                      sed 's/.*href="//' |
                      sed 's/".*//'); do
        echo $date
    done
done
```
#### Script to download quicklook movies by date:
```bash
#!/bin/bash                                                                                                                                                   
web="http://tsih3.uio.no/lapalma/"
input=$1
if [ ${#input} -eq 0 ]
then
    folder=$web
    read -p "Do you want to download all the available movies from "$folder" [y/n]: " yn
    case $yn in
        [Yy]* ) wget -c -r -l 3 --cut-dirs=1 -nH --no-parent --reject="index.html*" $folder;;
        [Nn]* ) break;;
    esac
fi
if [ ${#input} -eq 4 ]
then
    folder=$web$input"/"
    wget -c -r -l 2 --cut-dirs=1 -nH --no-parent --reject="index.html*" $folder
fi
if [ ${#input} -eq 7 ]
then
    temp=(${input//-/ })
    year=${temp[0]}
    folder=$web$year"/"
    echo $folder
    echo  ${input}*
    for date in $(curl -s $folder |
                      grep '\[DIR\]' |
                      sed 's/.*href="//' |
                      sed 's/".*//'); do
        if [[ "$date" == "$input"* ]]; then
            echo $date
            wget -c -r -l 2 --cut-dirs=1 -nH --no-parent --reject="index.html*" $folder"/"$date
        fi
    done
fi
if [ ${#input} -eq 10 ]
then
    temp=(${input//-/ })
    year=${temp[0]}
    folder=$web$year"/"$input"/"
    wget -c -r -l 1 --cut-dirs=1 -nH --no-parent --reject="index.html*" $folder
fi
```

## Extracting IRIS SAA times for the SST log

This scripts extracts the IRIS SAA times and copy them in your clipboard on MacOs systems.
```bash
curl -s $1 | grep SAAI | awk '{print $2}' | sed -e 's/\(:..\).*/\1/' > saai.txt
curl -s $1 | grep SAAO | awk '{print $2}' | sed 's/\(:..\).*/\1 IRIS in SAA <br\>/'  > saao.txt
paste -d "~" saai.txt saao.txt | sed 's/~/ - /' | pbcopy -selection c
rm saai.txt
rm saao.txt
```
The input of the script for a given day can be found within TIM in the following webpage:
[IRIS_SAA](https://iris.lmsal.com/health-safety/timeline/)

For Linux, if you have X installed you may define an equivalent to pbcopy from MacOS in this way :
```bash
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
```
or with xclip:
```bash
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
```
