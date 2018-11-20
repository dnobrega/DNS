
PRO EXTRACT_MOVIES,  file, savefile=savefile, $
                     folder=folder, $
                     xsize=xsize, ysize=ysize, $
                     nframes=nframes
  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                             INPUT PARAMETERS                                   
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IF (NOT FILE_EXIST(file))        THEN BEGIN
   PRINT, 'File: ', file, ' not found' 
   STOP
ENDIF
IF (NOT KEYWORD_SET(savefile))   THEN savefile='savefile.sav'
IF (NOT KEYWORD_SET(xsize))      THEN xsize=800
IF (NOT KEYWORD_SET(ysize))      THEN ysize=600
IF (KEYWORD_SET(folder))         THEN CD, folder
IF (NOT KEYWORD_SET(nframes))    THEN nframes=1000

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tt=0
array = BYTARR(3,xsize,ysize,nframes)
movie = OBJ_NEW('IDLffVideoRead',file)

REPEAT BEGIN
   print, tt   
   data = movie -> GETNEXT(type=type)
   array(*,0 : xsize-1, 0 : ysize-1, tt)=data
   tt=tt+1
ENDREP UNTIL type EQ -1
OBJ_DESTROY, movie
array=array(*,*,*,0:tt-1)

SAVE, array, filename=savefile

END
