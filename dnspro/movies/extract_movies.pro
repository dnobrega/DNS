
PRO EXTRACT_MOVIES,  savefile=savefile, $
                     folder=folder, $
                     xsize=xsize, ysize=ysize, $
                     nframes=nframes
  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                             INPUT PARAMETERS                                   
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SPAWN, 'ls *.mp4', list
nel = n_elements(list)
IF (NOT KEYWORD_SET(savefile))   THEN savefile='savefile'
IF (NOT KEYWORD_SET(xsize))      THEN xsize=800
IF (NOT KEYWORD_SET(ysize))      THEN ysize=600
IF (KEYWORD_SET(folder))         THEN CD, folder
IF (NOT KEYWORD_SET(nframes))    THEN nframes=1000

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FOR jj=0, nel-1 DO BEGIN

   print, jj, ' Extracting', list[jj]
   tt=0
   array = BYTARR(3,xsize,ysize,nframes)

   IF (NOT FILE_EXIST(list[jj]))        THEN BEGIN
      PRINT, 'File: ', list[jj], ' not found' 
      STOP
   ENDIF
   movie = OBJ_NEW('IDLffVideoRead',list[jj])

   REPEAT BEGIN
      print, tt   
      data = movie -> GETNEXT(type=type)
      array(*,0 : xsize-1, 0 : ysize-1, tt)=data
      tt=tt+1
   ENDREP UNTIL type EQ -1
   OBJ_DESTROY, movie
   array=array(*,*,*,0:tt)
   
   SAVE, array, filename=savefile+'_'+STRTRIM(STRING(JJ),2)+'.sav'

ENDFOR

END
