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

FUNCTION BIF_STRING3,i
  result=0
  CASE 1 OF
     (i LT 0)  : print,'i has an illegal value'
     (i LE 9)  : result='00'+strtrim(string(i),2)
     (i LE 99) : result='0'+strtrim(string(i),2)
     ELSE     : result=strtrim(string(i),2)
  ENDCASE

RETURN,result
END


PRO BIF_SELECT_IDLPARAM, idlparam, snaps

  IF (n_params() LT 2) THEN BEGIN
     message,'syntax: bif_select_idlparam,idlparam,snaps',/info
     RETURN
  ENDIF

;---------------------------------------------------------------------------------

  f=file_search('*.idl' , count=idlfiles) 

  IF (idlfiles EQ 0) THEN BEGIN

     message,'No .idl files found',/info
     f=file_search('*.idl.scr',count=idlfiles)

     IF (idlfiles EQ 0) THEN BEGIN
        message,'No idl.scr files found',/info
        idlparam=''
     ENDIF ELSE BEGIN
        nroots=1
        ic=strpos(f[0],'.idl')
        idlparam=strmid(f[0],0,ic)
        g = file_search('*.snap.scr', count=snapfiles) 
        IF (snapfiles EQ 0) THEN BEGIN
           message,'No snap.scr files found',/info
        ENDIF ELSE BEGIN
           snaps = idlparam+'.snap.scr'
        ENDELSE
     ENDELSE

  ENDIF ELSE BEGIN

     g=file_search('*.snap', count=snapfiles) 

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
        
     val=min([idlfiles,snapfiles])
     snaps=indgen(val)
     k0=strlen(idlparam)+1
     j=0

     FOR ii=0,val-1 DO BEGIN
        temp = strmid(g[ii],k0,strlen(g[ii])-k0)
        IF ISA(temp, /NUMBER) THEN BEGIN
           snap_nr=fix(strmid(g[ii],k0,strlen(g[ii])-k0))
           dum=file_search(idlparam+'_'+bif_string3(snap_nr)+'.snap',count=count)
           print, snap_nr, count
           IF (count EQ 0) THEN dum=file_search(idlparam+bif_string3(snap_nr)+'.snap',count=count)
           IF (count EQ 1) THEN BEGIN
              snaps[j]=snap_nr
              print, snaps[j]
              j=j+1
           ENDIF
        ENDIF
     ENDFOR
     snaps=snaps[0:j-1]
  ENDELSE

END
