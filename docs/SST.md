# SST

## Main links

- Overview of the observation conditions at the ORM in La Palma: [Shahin's website](https://shahin.website/sst/)
- SST wiki of RoCS: [Wiki](https://wiki.uio.no/mn/astro/lapalma/)
- SST Observations Schedule: [SST Schedule](https://dubshen.astro.su.se/wiki/index.php/Observations_schedule_2019)
- SST Data acquisitions: [Data acquisitions](https://dubshen.astro.su.se/wiki/index.php/Data_acquisitions)

## Quicklook movies and images

- ITA has now a very basic web server with the purpose of providing simple access to files ment for temporary viewing - like quicklook movies. 
We can put the SST quicklook movies at `/mn/stornext/d18/lapalma/quicklook/` which will then appear under http://tsih3.uio.no/lapalma/
. For example, the 14-Jun quicklook movies from the LMSAL campaign are now under http://tsih3.uio.no/lapalma/2020/2020-06-14/
which are linked from the Oslo SST wiki: https://wiki.uio.no/mn/astro/lapalma/index.php/Quicklook_June_2020#Sunday_14-Jun-2020

- Script to combine CHROMIS quicklook movies and images:
```bash
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

- Script to combine CRISP quicklook movies and images:
```bash
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
