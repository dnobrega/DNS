;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;--------------------------------------------------------------------------------- 
;                                   DNS_VAR
;--------------------------------------------------------------------------------- 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PRO dns_var,d,snaps,var,name,swap,$
            dim=dim, donde=donde, title1d=title1d,ytitle1d=ytitle1d,$
            title2d=title,btitle=btitle,$
            log=log,yrange=yrange,$
            myrange=myrange,mylog=mylog,$
            varunits=varunits, $
            shiftx=shiftx,$
            ix0=ix0,iy0=iy0,iz0=iz0, $
            ixstep=ixstep, iystep=iystep, izstep=izstep,$
            ixf=ixf,iyf=iyf,izf=izf,$
            im0=im0, imf=imf, imstep=imstep


  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;---------------------------------------------------------------------------------
;                                   HELP                                      
;---------------------------------------------------------------------------------

  IF (n_params() LT 5) THEN BEGIN
      message,$
      'dns_var,d,snaps,var,name,swap,'+$
            'd1=d1,donde=donde, title1d=title1d,ytitle1d=ytitle1d,'+$
            'title2d=title,btitle=btitle,'+$
            'log=log,yrange=yrange,'+$
            'myrange=myrange,mylog=mylog,'+$
            'varunits=varunits,'+$
            'shiftx',/info
      RETURN
  ENDIF

  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;---------------------------------------------------------------------------------
;                                  VARIABLES                                    
;--------------------------------------------------------------------------------- 


;---------------------------------------------------------------------------------


;Logaritmo en eje y
 var_log=0
 var_title=''
 title=''

 dnsvar_name="dnsvar_"+name
 file_exists=STRLEN(file_which(dnsvar_name+".pro"))
 IF (file_exists GT 0) THEN BEGIN 
    CALL_PROCEDURE, dnsvar_name, d, name, snaps, swap, $
                    var, var_title, var_range, var_log
    varunits=var_title
    log=var_log
    yrange=var_range
 ENDIF ELSE BEGIN
    print, "Variable not found in dnsvar folder"
    print, "Trying in Bifrost folder..."
    var=d->getvar(name,snaps,swap=swap)
    var_max = MAX(var, min=var_min)
    IF (var_min EQ 0) AND (var_max EQ 0) THEN BEGIN
       print, "Variable not found in Bifrost folder"
       STOP
    ENDIF ELSE var_range=[min(var),max(var)]
 ENDELSE

 sizevar=size(var)
 print, sizevar
 IF sizevar(0) EQ 3 THEN BEGIN

IF (N_ELEMENTS(ix0)+ N_ELEMENTS(ixf) GE 1) THEN BEGIN
   IF (N_ELEMENTS(ix0) EQ 0) THEN im0=0 ELSE im0=ix0
   IF (N_ELEMENTS(ixf) EQ 0) THEN imf=sizevar(1)-1 ELSE imf=ixf
   IF (NOT KEYWORD_SET(ixstep)) THEN imstep=1 ELSE imstep=ixstep
   var=var(im0 : imf,*,*)
ENDIF

IF (N_ELEMENTS(iy0)+ N_ELEMENTS(iyf) GE 1) THEN BEGIN
   IF (N_ELEMENTS(iy0) EQ 0) THEN im0=0 ELSE im0=iy0
   IF (N_ELEMENTS(iyf) EQ 0) THEN imf=sizevar(2)-1 ELSE imf=iyf
   IF (NOT KEYWORD_SET(iystep)) THEN imstep=1 ELSE imstep=iystep
   var=var(*,im0 : imf,*)
ENDIF

IF (N_ELEMENTS(iz0)+ N_ELEMENTS(izf) GE 1) THEN BEGIN
   IF (N_ELEMENTS(iz0) EQ 0) THEN im0=0 ELSE im0=iz0
   IF (N_ELEMENTS(izf) EQ 0) THEN imf=sizevar(3)-1 ELSE imf=izf
   IF (NOT KEYWORD_SET(izstep)) THEN imstep=1 ELSE imstep=izstep
   var=var(im0 : imf,*,*)
ENDIF

ENDIF

PRINT, "------------------------------------------"
PRINT, " ",name, snaps, MIN(var,/NAN), MAX(var,/NAN)
PRINT, "------------------------------------------"





;Hacemos shift
;IF (KEYWORD_SET(shiftx)) THEN BEGIN
;   var=shift(var,shiftx,0)         ;Desplaza las columnas
;ENDIF

;Creamos el resto de titulos
;IF (KEYWORD_SET(dim)) THEN BEGIN
; IF (dim EQ 'z') THEN BEGIN
;     IF (N_ELEMENTS(donde) EQ 0 ) THEN BEGIN
;         title1d='< '+title+' > vs Z'
;      ENDIF ELSE BEGIN
;         x=d->getx()
;         title1d=title+' in X='+STRTRIM(STRING(x(donde), FORMAT='(F6.1)'),2)
;      ENDELSE
; ENDIF
; IF (dim EQ 'x') THEN BEGIN
;     IF (N_ELEMENTS(donde) EQ 0 ) THEN BEGIN
;        title1d='< '+title+' > vs X' 
;     ENDIF ELSE BEGIN
;         z=d->getz()
;         title1d=title+' in Z='+STRTRIM(STRING(-z(donde), FORMAT='(F6.1)'),2)
;     ENDELSE
; ENDIF
; ENDIF

 ytitle1d=varunits
 btitle=varunits
 title2d=title

;Escala y logaritmo
IF (KEYWORD_SET(myrange)) THEN yrange=myrange
IF N_ELEMENTS(mylog) NE 0 THEN log=mylog
IF log EQ 1 THEN BEGIN
   var=ALOG10(var)
   IF yrange(0) EQ 0 THEN yrange(0)=1.
   yrange=ALOG10(yrange)
ENDIF

END
