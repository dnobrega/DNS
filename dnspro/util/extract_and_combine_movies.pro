
PRO EXTRACT_AND_COMBINE_MOVIES, list=list, folder=folder,$
                                input_format=input_format,$
                                output_format=output_format,$
                                ncol=ncol, nrow=nrow, $
                                moviename=moviename, fps=fps, $
                                save_array=save_array
  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                             INPUT PARAMETERS                                   
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IF (KEYWORD_SET(folder))             THEN CD, folder
IF (NOT KEYWORD_SET(input_format))   THEN input_format='.mp4'
IF (NOT KEYWORD_SET(output_format))  THEN output_format='.mp4'
IF (NOT KEYWORD_SET(fps))            THEN fps=10
IF (NOT KEYWORD_SET(moviename))      THEN moviename='moviename'
IF (NOT KEYWORD_SET(list))           THEN SPAWN, 'ls -tr *'+input_format, list

n_list = n_elements(list)

IF (NOT KEYWORD_SET(nrow))           THEN nrow=1
IF (NOT KEYWORD_SET(ncol))           THEN ncol=n_list/nrow
IF (n_list NE nrow*ncol)             THEN STOP

FOR jj=0, n_list-1 DO BEGIN

   IF (NOT FILE_EXIST(list[jj]))        THEN BEGIN
      PRINT, 'File: ', list[jj], ' not found' 
   ENDIF ELSE BEGIN
      print, jj, ' Extracting ', list[jj]
      (SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj),2), /ENTER, LEVEL=1))  = READ_VIDEO(list[jj],/ALL)
      xsize_new   = (size(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj),2),level=1)))[2]
      ysize_new   = (size(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj),2),level=1)))[3]
      nframes_new = (size(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj),2),level=1)))[4]
      IF (jj EQ 0) THEN BEGIN 
         xsize_old   = xsize_new
         ysize_old   = ysize_new
         nframes_old = nframes_new
      ENDIF
      IF ((xsize_old NE xsize_new) OR (ysize_old NE ysize_new)) THEN BEGIN
         print, "Arrays do not have the same size"
         print, "X sizes:", xsize_old, xsize_new
         print, "Y sizes:", ysize_old, ysize_new
      ENDIF ELSE BEGIN
         xsize_old = xsize_new
         ysize_old = ysize_new
      ENDELSE
      IF (nframes_old NE nframes_new) THEN BEGIN
         IF (nframes_old GT nframes_new) THEN BEGIN
            FOR ii=jj, 1, -1 DO BEGIN
               temp=(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj-ii),2), /ENTER, LEVEL=1))
               (SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj-ii),2), /ENTER, LEVEL=1))=temp(*,*,*,0:nframes_new-1)
            ENDFOR
            nframes_old=nframes_new
         ENDIF ELSE BEGIN
            temp=(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj),2), /ENTER, LEVEL=1))
            (SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj),2), /ENTER, LEVEL=1))=temp(*,*,*,0:nframes_old-1)
         ENDELSE
      ENDIF
   ENDELSE
   
   IF KEYWORD_SET(save_array) THEN BEGIN
      array = (SCOPE_VARFETCH('temp_'+STRTRIM(STRING(jj),2), /ENTER, LEVEL=1))
      print, jj, " Saving "+list[jj]+'.sav'
      SAVE, array, filename=list[jj]+'.sav'
   ENDIF

ENDFOR

xsize=xsize_old
ysize=ysize_old
nframes=nframes_old

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
video=IDLffVideoWrite(moviename+output_format)
stream=video.AddVideoStream(xsize*ncol,ysize*nrow,fps,BIT_RATE=24E5)

array=BYTARR(3,xsize*ncol,ysize*nrow,nframes)

PRINT, "Combining movies..."
counter=0
FOR jj=0,nrow-1 DO BEGIN
   FOR ii=0,ncol-1 DO BEGIN
       array(*, ii*xsize : (ii+1)*xsize-1 , jj*ysize : (jj+1)*ysize-1, *) = $
            (SCOPE_VARFETCH('temp_'+STRTRIM(STRING(counter),2), LEVEL=1))
       counter=counter+1
   ENDFOR
ENDFOR

PRINT, "Creating combined movie..."
FOR kk=0,nframes-1 DO makingmp4=video.Put(stream,byte(array(*,*,*,kk)))

video.cleanup


END
