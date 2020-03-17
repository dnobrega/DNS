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
            xx=xx, yy=yy, zz=zz,$
            xshift=xshift, yshift=yshift, zshift=zshift, $
            xtitle=xtitle, ytitle=ytitle, $
            title=title, $
            bar_log=bar_log, bar_title=bar_title, $
            save_dnsvar=save_dnsvar, save_dnsfolder=save_dnsfolder

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
 IF (NOT KEYWORD_SET(save_dnsfolder)) THEN save_dnsfolder='dnsvar'
 saved_dnsvar_name=save_dnsfolder+'/'+name+'_'+strtrim(string(snaps),2)+'_'+dim+'.sav'

 IF file_test(saved_dnsvar_name) EQ 1 THEN BEGIN
    print, "Restoring variable"
    restore, saved_dnsvar_name,/verbose
 ENDIF ELSE BEGIN
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
 ENDELSE

 IF (KEYWORD_SET(save_dnsvar)) THEN BEGIN
    file_mkdir,save_dnsfolder             
    save, d, var, dnsvar_log, dnsvar_title, dnsvar_range, FILENAME=saved_dnsvar_name
 ENDIF


 IF (N_ELEMENTS(var_log) GT 0)    $
    THEN bar_log   = var_log  $
    ELSE bar_log = dnsvar_log
 IF (KEYWORD_SET(var_title))   $
    THEN bar_title = var_title $
    ELSE bar_title = dnsvar_title
 IF (NOT (KEYWORD_SET(var_range))) THEN var_range=dnsvar_range

;---------------------------------------------------------------------------------  
; SCANNING 3D VARIABLES
;---------------------------------------------------------------------------------  

 d->readpars, snaps
 d->readmesh

 x=d->getx()
 y=d->gety()
 z=d->getz()
 nelx=d->getmx()
 nely=d->getmy()
 nelz=d->getmz()

 var=reform(var,nelx,nely,nelz)
 sizevar=size(var)

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

           IF (sizevar(1) GT 1) THEN coord="X"
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
           ;-------------------------------------------------------------------
           IF (N_ELEMENTS(xshift) NE 0) THEN x=x+xshift
           IF (N_ELEMENTS(zshift) NE 0) THEN z=z+zshift
           maxz=MAX(z, MIN=minz)
           dz=(maxz-minz)/(nelz-1)
           dz1d=d->getdz1d()
           IF (abs(min(dz1d)-dz) GT 1e-5) THEN BEGIN 
              zz=minz+dz*FINDGEN(nelz)
              newsize=size(var)
              FOR j=0,newsize(2)-1 DO BEGIN
                 FOR i=0,nelx-1 DO var(i,j,*)=INTERPOL(var(i,j,*),z,zz)
              ENDFOR
           ENDIF ELSE BEGIN
              zz=z
           ENDELSE
           var=reverse(var,3)
           xtitle='X (Mm)' & ytitle='Z (Mm)'
           IF (sizevar(2) GT 1) THEN coord="Y"
           xx=x & yy=z & zz=y
           END

    "xy" : BEGIN  
           IF (sizevar(3) GT 1) THEN coord="Z"
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
 
;ENDIF ELSE sim3d=0

 t=d->gett()
 t=t(0)*100./60
 stt=STRING(t,format='(F10.1)')
 title='t='+STRTRIM(stt,2)+' min'
 IF N_ELEMENTS(coord) GT 0 THEN $
    title=coord+': '+STRTRIM(STRING(zz,format='(F10.1)'),2)+' (Mm)   '+title

;---------------------------------------------------------------------------------  
; PRINTING INFORMATION
;---------------------------------------------------------------------------------  
 var_max = MAX(var, min=var_min, /NAN)
 PRINT, "----------------------------------------------------"
 PRINT, " ",name, snaps, var_min, var_max
 PRINT, "----------------------------------------------------"

END
