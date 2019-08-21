
PRO COMBINE_MOVIES, folder=folder, $
                    ncol=ncol, nrow=nrow, $
                    moviename=moviename, fps=fps
  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                             INPUT PARAMETERS                                   
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IF (KEYWORD_SET(folder))    THEN CD, folder
SPAWN, 'ls *.sav', list
n_list = N_ELEMENTS(list)
FOR ii=0, n_list-1 DO BEGIN
   RESTORE, list[ii], /VERBOSE
   (SCOPE_VARFETCH('temp_'+STRTRIM(STRING(ii),2), /ENTER, LEVEL=1)) = array
   xsize  = (size(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(ii),2),level=1)))[2]
   ysize  = (size(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(ii),2),level=1)))[3]
   nframes= (size(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(ii),2),level=1)))[4]
ENDFOR
xsize  = (size(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(ii-1),2),level=1)))[2]
ysize  = (size(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(ii-1),2),level=1)))[3]
nframes= (size(SCOPE_VARFETCH('temp_'+STRTRIM(STRING(ii-1),2),level=1)))[4]   
IF (NOT KEYWORD_SET(nrow))       THEN nrow=1
IF (NOT KEYWORD_SET(ncol))       THEN ncol=n_list
IF (NOT KEYWORD_SET(fps))        THEN fps=1
IF (n_list NE nrow*ncol)         THEN STOP
IF (NOT KEYWORD_SET(moviename))  THEN moviename='moviename'

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

video=IDLffVideoWrite(moviename+'.mp4')
stream=video.AddVideoStream(xsize*ncol,ysize*nrow,fps,BIT_RATE=24E5)

array=BYTARR(3,xsize*ncol,ysize*nrow,nframes)

counter=0
FOR jj=0,nrow-1 DO BEGIN
   FOR ii=0,ncol-1 DO BEGIN
       array(*, ii*xsize : (ii+1)*xsize-1 , jj*ysize : (jj+1)*ysize-1, *) = $
            (SCOPE_VARFETCH('temp_'+STRTRIM(STRING(counter),2), LEVEL=1))
       counter=counter+1
   ENDFOR
ENDFOR

FOR kk=0,nframes-1 DO makingmp4=video.Put(stream,byte(array(*,*,*,kk)))

video.cleanup


END
