
PRO EXTRACT_AND_COMBINE_IMAGES, folder=folder,$
                                input_format=input_format,$
                                output_format=output_format,$
                                ncol=ncol, nrow=nrow, $
                                imagename=imagename, $
                                save_array=save_array
  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                             INPUT PARAMETERS                                   
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IF (KEYWORD_SET(folder))             THEN CD, folder
IF (NOT KEYWORD_SET(input_format))   THEN input_format='.jpeg'
IF (NOT KEYWORD_SET(output_format))  THEN output_format=input_format
IF (NOT KEYWORD_SET(imagename))      THEN imagename='imagename'

SPAWN, 'ls *'+input_format, list
n_list = n_elements(list)

IF (NOT KEYWORD_SET(nrow))           THEN nrow=1
IF (NOT KEYWORD_SET(ncol))           THEN ncol=n_list/nrow
IF (n_list NE nrow*ncol)             THEN STOP

FOR jj=0, n_list-1 DO BEGIN

   IF (NOT FILE_EXIST(list[jj]))        THEN BEGIN
      PRINT, 'File: ', list[jj], ' not found' 
   ENDIF ELSE BEGIN
      print, jj, ' Extracting ', list[jj]
      READ_JPEG, list[jj], (SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj),2), /ENTER, LEVEL=1)), TRUE=1
      xsize_new   = (size(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj),2),level=1)))[2]
      ysize_new   = (size(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj),2),level=1)))[3]
      IF (jj EQ 0) THEN BEGIN 
         xsize_old   = xsize_new
         ysize_old   = ysize_new
      ENDIF
      IF ((xsize_old NE xsize_new) OR (ysize_old NE ysize_new)) THEN BEGIN
         print, "Arrays do not have the same size"
         print, "X sizes:", xsize_old, xsize_new
         print, "Y sizes:", ysize_old, ysize_new
      ENDIF ELSE BEGIN
         xsize_old = xsize_new
         ysize_old = ysize_new
      ENDELSE
   ENDELSE
   
   IF KEYWORD_SET(save_array) THEN BEGIN
      array = (SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj),2), /ENTER, LEVEL=1))
      print, jj, " Saving "+list[jj]+'.sav'
      SAVE, array, filename=list[jj]+'.sav'
   ENDIF

ENDFOR

xsize=xsize_old
ysize=ysize_old

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
array=BYTARR(3,xsize*ncol,ysize*nrow)

PRINT, "Combining images..."
counter=0
FOR jj=0,nrow-1 DO BEGIN
   FOR ii=0,ncol-1 DO BEGIN
       array(*, ii*xsize : (ii+1)*xsize-1 , jj*ysize : (jj+1)*ysize-1) = $
            (SCOPE_VARFETCH('temp_'+STRTRIM(STRING(counter),2), LEVEL=1))
       counter=counter+1
   ENDFOR
ENDFOR

answer=''
PRINT, "Image size is ", STRTRIM(xsize*ncol,2)+'x'+STRTRIM(ysize*nrow,2), "... do you want to resize it? (y/n) [by default n]"
READ, answer

IF (answer EQ 'y') THEN BEGIN
   PRINT, "Introduce xsize"
   READ, nxsize
   nysize=ysize*nrow/(xsize*ncol/nxsize)
   array=CONGRID(array, 3, nxsize, nysize)
   help, array
ENDIF

PRINT, "Creating combined image..."
CASE output_format OF

 '.jpeg':  WRITE_JPEG, imagename+output_format, array, QUALITY=100, /TRUE
 '.jpg' :  WRITE_JPEG, imagename+output_format, array, QUALITY=100, /TRUE
 '.png' :  WRITE_PNG, imagename+output_format, array
  ELSE : PRINT, "Output format not recognized"

ENDCASE

END
