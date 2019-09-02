
PRO EXTRACT_MOVIES, folder=folder, format=format
  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                             INPUT PARAMETERS                                   
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IF (KEYWORD_SET(folder))      THEN CD, folder
IF (NOT KEYWORD_SET(format))  THEN format='.mp4'
SPAWN, 'ls *'+format, list
nel = n_elements(list)

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FOR jj=0, nel-1 DO BEGIN

   IF (NOT FILE_EXIST(list[jj]))        THEN BEGIN
      PRINT, 'File: ', list[jj], ' not found' 
   ENDIF ELSE BEGIN
      print, jj, ' Extracting ', list[jj]
      array = READ_VIDEO(list[jj],/ALL)
      SAVE, array, filename=list[jj]+'.sav'
   ENDELSE

ENDFOR

END
