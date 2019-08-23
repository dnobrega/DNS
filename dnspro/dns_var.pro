;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;--------------------------------------------------------------------------------- 
;                                   DNS_VAR
;--------------------------------------------------------------------------------- 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PRO dns_var,d,name,snaps,swap,var,$
            var_title=var_title, var_range=var_range, var_log=var_log,$
            ix0=ix0,iy0=iy0,iz0=iz0, $
            ixstep=ixstep, iystep=iystep, izstep=izstep,$
            ixf=ixf,iyf=iyf,izf=izf,$
            im0=im0, imf=imf, imstep=imstep,$
            sim3d=sim3d

;---------------------------------------------------------------------------------  

IF (n_params() LT 5) THEN BEGIN
    message,$
    'dns_var,d,snaps,var,name,swap,'$
              +'var_title=var_title, var_range=var_range, var_log=var_log,'$
              +'ix0=ix0,iy0=iy0,iz0=iz0,'$
              +'ixstep=ixstep, iystep=iystep, izstep=izstep,$'$
              +'ixf=ixf,iyf=iyf,izf=izf,'$
              +'im0=im0, imf=imf, imstep=imstep',/info
    RETURN
ENDIF
  
;--------------------------------------------------------------------------------- 
 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                                   MAIN       
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

;---------------------------------------------------------------------------------  
; LOADING VARIABLES
;---------------------------------------------------------------------------------  
 dnsvar_name="dnsvar_"+name
 file_exists=STRLEN(file_which(dnsvar_name+".pro"))
 IF (file_exists GT 0) THEN BEGIN 
    CALL_PROCEDURE, dnsvar_name, d, name, snaps, swap, var, $
                    var_title=dnsvar_title, var_range=dnsvar_range, var_log=dnsvar_log
 ENDIF ELSE BEGIN
    print, "Variable not found in dnsvar folder"
    print, "Trying in Bifrost folder..."
    var=d->getvar(name,snaps,swap=swap)
    var_max = MAX(var, min=var_min, /NAN)
    IF (var_min EQ var_max) THEN BEGIN
       print, "Variable not found in Bifrost folder"
       STOP
    ENDIF ELSE BEGIN
       dnsvar_log = 0
       dnsvar_title = ''
       dnsvar_range = [var_min,var_max]
    ENDELSE
 ENDELSE

 IF (NOT (KEYWORD_SET(var_log)))   THEN var_log   = dnsvar_log
 IF (NOT (KEYWORD_SET(var_title))) THEN var_title = dnsvar_title
 IF (NOT (KEYWORD_SET(var_range))) THEN var_range = dnsvar_range

;---------------------------------------------------------------------------------  
; SCANNING 3D VARIABLES
;---------------------------------------------------------------------------------  
 var=reform(var)
 sizevar=size(var)

 IF sizevar(0) EQ 3 THEN BEGIN

    sim3d=1

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

;---------------------------------------------------------------------------------  
; PRINTING INFORMATION
;---------------------------------------------------------------------------------  
 var_max = MAX(var, min=var_min, /NAN)
 PRINT, "------------------------------------------"
 PRINT, " ",name, snaps, var_min, var_max
 PRINT, "------------------------------------------"

;---------------------------------------------------------------------------------  
; DEFAULT VALUES IF NOT DEFINED PREVIOUSLY
;---------------------------------------------------------------------------------  
 IF (var_log GT 0) THEN BEGIN
    var=alog10(var)
    IF (var_range(0) EQ 0) THEN var_range(0)=1d-30
    var_range=alog10(var_range)
 ENDIF

END
