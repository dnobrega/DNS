;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
; BIF_SELECT_IDLPARAM
;
; PROCEDURE:
;	searches through directory for *_[0-9][0-9][0-9].idl files and takes * as
;	root name. If several matches, prompts the user to choose one
;	of them
;
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PRO BIF_SELECT_IDLPARAM, idlparam

  IF (n_params() LT 1) THEN BEGIN
     message,'syntax: bif_select_idlparam,idlparam',/info
     RETURN
  ENDIF

;---------------------------------------------------------------------------------

  f=file_search('*.idl',count=nfiles) 

  IF (nfiles EQ 0) THEN BEGIN

     message,'No idlparam files found',/info
     f=file_search('*.idl.scr',count=nfiles)

     IF (nfiles EQ 0) THEN BEGIN
        message,'No .scr files found',/info
        idlparam=''
     ENDIF ELSE BEGIN
        nroots=1
        ic=strpos(f[0],'.idl')
        idlparam=strmid(f[0],0,ic)
     ENDELSE

  ENDIF ELSE BEGIN
     
     k="True"
     i=0
     j=4
     ic=strpos(f[i],'.idl')-j
     WHILE (k EQ "True") DO BEGIN
        IF (strmid(f[i],ic-(j-1),1) EQ '_') THEN BEGIN
           idlparam=strmid(f[i],0,ic-(j-1))
           k="False"
        ENDIF ELSE j=j-1
     ENDWHILE
        
  ENDELSE

END
