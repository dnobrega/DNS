;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;--------------------------------------------------------------------------------- 
;                                   DNS_VAR
;--------------------------------------------------------------------------------- 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PRO dns_var,d,name,snaps,swap,var,$
            var_title=var_title, var_range=var_range, var_log=var_log,$
            ixt=ixt,iyt=iyt,izt=izt, $
            ix0=ix0,iy0=iy0,iz0=iz0, $
            ixstep=ixstep, iystep=iystep, izstep=izstep,$
            ixf=ixf,iyf=iyf,izf=izf,$
            im0=im0, imf=imf, imstep=imstep,$
            sim3d=sim3d, mm=mm, dim=dim, $
            bar_range=bar_range, bar_log=bar_log, bar_title=bar_title

;---------------------------------------------------------------------------------  

IF (n_params() LT 5) THEN BEGIN
    message,$
    'dns_var,d,name,snaps,swap,var,'$
              +'var_title=var_title, var_range=var_range, var_log=var_log,'$
              +'ixt=ixt,iyt=iyt,izt=izt,'$
              +'ix0=ix0,iy0=iy0,iz0=iz0,'$
              +'ixstep=ixstep, iystep=iystep, izstep=izstep,$'$
              +'ixf=ixf,iyf=iyf,izf=izf,'$
              +'im0=im0, imf=imf, imstep=imstep'$
              +'sim3d=sim3d, mm=mm, dim=dim,' $
              +'bar_range=bar_range, bar_log=bar_log, bar_title=bar_title',$
               /info
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
                    var_title=dnsvar_title, $
                    var_range=dnsvar_range, $
                    var_log=dnsvar_log
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

 IF (N_ELEMENTS(var_log) GT 0)    $
    THEN bar_log   = var_log  $
    ELSE bar_log = dnsvar_log
 IF (KEYWORD_SET(var_title))   $
    THEN bar_title = var_title $
    ELSE bar_title = dnsvar_title
 IF (KEYWORD_SET(var_range))   $
    THEN bar_range = var_range $
    ELSE bar_range=dnsvar_range

;---------------------------------------------------------------------------------  
; SCANNING 3D VARIABLES
;---------------------------------------------------------------------------------  
 var=reform(var)
 sizevar=size(var)

 IF sizevar(0) EQ 3 THEN BEGIN

    sim3d=1

    CASE dim OF

    "yz" : BEGIN  
           IF N_ELEMENTS(ixt) GT 0 THEN BEGIN
              var=var(ixt,*,*)
              mm=ixt & imf=0 & im0=0 & imstep=1
           ENDIF ELSE BEGIN
              IF (N_ELEMENTS(ix0) EQ 0) THEN im0=0 ELSE im0=ix0
              IF (N_ELEMENTS(ixf) EQ 0) THEN imf=sizevar(1)-1 ELSE imf=ixf
              IF (NOT KEYWORD_SET(ixstep)) THEN imstep=1 ELSE imstep=ixstep
              var=var(im0 : imf,*,*)
              IF (im0 EQ imf) THEN BEGIN
                 mm=im0 & imf=0 & im0=0 & imstep=1
              ENDIF ELSE BEGIN
                 mm=im0 & imf=imf-im0 & im0=0
              ENDELSE
           ENDELSE
           END

    "xz" : BEGIN  
           IF N_ELEMENTS(iyt) GT 0 THEN BEGIN
              var=var(*,iyt,*)
              mm=iyt & imf=0 & im0=0 & imstep=1
           ENDIF ELSE BEGIN
              IF (N_ELEMENTS(iy0) EQ 0) THEN im0=0 ELSE im0=iy0
              IF (N_ELEMENTS(iyf) EQ 0) THEN imf=sizevar(2)-1 ELSE imf=iyf
              IF (NOT KEYWORD_SET(iystep)) THEN imstep=1 ELSE imstep=iystep
              var=var(*,im0 : imf,*)
              IF (im0 EQ imf) THEN BEGIN
                 mm=im0  & imf=0 & im0=0 & imstep=1
              ENDIF ELSE BEGIN
                 mm=im0 & imf=imf-im0 & im0=0
              ENDELSE
           ENDELSE
           END

    "xy" : BEGIN  
           IF N_ELEMENTS(izt) GT 0 THEN BEGIN
              var=var(*,*,izt)
              mm=izt & imf=0 & im0=0 & imstep=1
           ENDIF ELSE BEGIN
              IF (N_ELEMENTS(iz0) EQ 0) THEN im0=0 ELSE im0=iz0
              IF (N_ELEMENTS(izf) EQ 0) THEN imf=sizevar(3)-1 ELSE imf=izf
              IF (NOT KEYWORD_SET(izstep)) THEN imstep=1 ELSE imstep=izstep
              var=var(*,*,im0 : imf)
              IF (im0 EQ imf) THEN BEGIN
                 mm=im0 & imf=0 & im0=0 & imstep=1
              ENDIF ELSE BEGIN
                 mm=im0 & imf=imf-im0 & im0=0
              ENDELSE
           ENDELSE
           END

    ELSE : BEGIN
           print, "Wrong plane"
           STOP
           END
 ENDCASE
 ENDIF ELSE sim3d=0

;---------------------------------------------------------------------------------  
; PRINTING INFORMATION
;---------------------------------------------------------------------------------  
 var_max = MAX(var, min=var_min, /NAN)
 PRINT, "------------------------------------------"
 PRINT, " ",name, snaps, var_min, var_max
 PRINT, "------------------------------------------"

;---------------------------------------------------------------------------------  
; VAR IN LOG SCALE
;---------------------------------------------------------------------------------  
 IF (bar_log GT 0) THEN BEGIN
    var=alog10(var)
    IF (bar_range(0) EQ 0) THEN bar_range(0)=1d-30
    bar_range=alog10(bar_range)
 ENDIF

END
