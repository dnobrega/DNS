;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;--------------------------------------------------------------------------------- 
;                                   DNS_VAR
;--------------------------------------------------------------------------------- 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PRO dns_var,d,name,snaps,swap,var,$
            bifrost_coord=bifrost_coord,$
            var_title=var_title, var_range=var_range, var_log=var_log,$
            units=units,$
            ixt=ixt,iyt=iyt,izt=izt, $
            ix0=ix0,iy0=iy0,iz0=iz0, $
            ixstep=ixstep, iystep=iystep, izstep=izstep,$
            ixf=ixf,iyf=iyf,izf=izf,$
            im0=im0, imf=imf, imstep=imstep,$
            dim=dim, tt=tt, $
            xx=xx, yy=yy, zz=zz,$
            xshift=xshift, yshift=yshift, zshift=zshift, $
            xtitle=xtitle, ytitle=ytitle, $
            title=title, $
            bar_log=bar_log, bar_title=bar_title, $
            save_dnsvar=save_dnsvar, save_dnsfolder=save_dnsfolder,$
            showsnap=showsnap, integration=integration


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
 saved_dnsvar_name=save_dnsfolder+'/'+name+'_'+strtrim(string(snaps),2)+'.sav'

 IF file_test(saved_dnsvar_name) EQ 1 THEN BEGIN
    print, "Restoring variable"
    restore, saved_dnsvar_name,/verbose
 ENDIF ELSE BEGIN
    file_exists=STRLEN(file_which(dnsvar_name+".pro"))
    IF (file_exists GT 0) THEN BEGIN 
       CALL_PROCEDURE, dnsvar_name, d, name, snaps, swap, var, units, $
                       var_title=dnsvar_title, $
                       var_range=dnsvar_range, $
                       var_log=dnsvar_log
    ENDIF ELSE BEGIN
       print, "Variable not found in dnsvar folder"
       print, "Trying in Bifrost folder..."
       var=d->getvar(name,snaps,swap=swap)
       var_max = MAX(var, min=var_min, /NAN)
       dnsvar_log = 0
       dnsvar_title = ''
       dnsvar_range = [var_min,var_max]
    ENDELSE
 ENDELSE

 d->readpars, snaps
 d->readmesh
 x=d->getx()
 y=d->gety()
 z=d->getz()
 nelx=d->getmx()
 nely=d->getmy()
 nelz=d->getmz()

 IF d->getboundarychk() THEN nelz=nelz+2.0*(d->getmb())

 var=float(reform(var,nelx,nely,nelz))
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
 IF (NOT (KEYWORD_SET(var_range)))  THEN var_range=dnsvar_range

;---------------------------------------------------------------------------------  
; SCANNING 3D VARIABLES
;---------------------------------------------------------------------------------  

 IF STRPOS(name,"alma") EQ -1 THEN BEGIN
    IF (NOT (KEYWORD_SET(dim))) THEN BEGIN
       dim='xz'
       IF (nelx EQ 1) THEN BEGIN
          IF (nely EQ 1) THEN dim='z' ELSE dim="yz"
          IF (nelz EQ 1) THEN dim='y'
       ENDIF ELSE BEGIN 
          IF (nely EQ 1) THEN BEGIN
             IF (nelz EQ 1) THEN dim='x' ELSE dim="xz"
          ENDIF ELSE dim="xy"
       ENDELSE
    ENDIF
    units_coord="  "
 ENDIF ELSE BEGIN
    dim="xy"
    alma_synthfiles, f
    ssnaps=strtrim(string(snaps),2)
    wh=where(strpos(f, ssnaps+"_int") GT -1)
    wv=alma_readsynth(f(wh), "Wavelength")
    FOR i=0,n_elements(wv)-1 DO print, strtrim(string(i),2),"  lambda: ",strtrim(string(wv(i),format='(F10.4)'),2)+" mm"
    z=-wv
    coord="!4k!3"
    units_coord="(mm)"
 ENDELSE
 sizevar=size(var)

 CASE dim OF

    "yz" : BEGIN 
           IF N_ELEMENTS(ixt) GT 0 THEN BEGIN
              imf=ixt & im0=ixt & imstep=1
           ENDIF ELSE BEGIN
              IF (N_ELEMENTS(ix0) EQ 0) THEN im0=0 ELSE im0=ix0
              IF (N_ELEMENTS(ixf) EQ 0) THEN imf=sizevar(1)-1 ELSE imf=ixf
              IF (NOT KEYWORD_SET(ixstep)) THEN imstep=1 ELSE imstep=ixstep
              IF (im0 EQ imf) THEN imstep=1
           ENDELSE
           IF (N_ELEMENTS(yshift) NE 0) THEN y=y+xshift
           IF (N_ELEMENTS(zshift) NE 0) THEN z=z+zshift
           IF (N_ELEMENTS(integration) NE 0) THEN BEGIN
              dx=d->getdx()
              var=var*dx*1e8
              var(imf,*,*)=total(var[im0 : imf, *, *],1) - 0.5*(var[im0,*,*]+var[imf,*,*]) 
              im0=imf
           ENDIF
           maxz=MAX(z, MIN=minz)
           dz=(maxz-minz)/(nelz-1)
           dz1d=d->getdz1d()
           IF (abs(min(dz1d)-dz) GT 1e-5) THEN BEGIN
              zz    = minz+dz*FINDGEN(nelz)
              index = (indgen(nelx))[im0:imf:imstep]
              indey = indgen(nely)
              indez = interpol(indgen(nelz),z,zz )
              var[im0:imf:imstep,*,*] = INTERPOLATE(var, index, indey, indez, /grid)
           ENDIF ELSE BEGIN
              zz=z
           ENDELSE
           IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN BEGIN
              var=reverse(var,3)
              var=reverse(var,2)
           ENDIF
           xtitle="Y" & ytitle="Z"
           IF ((sizevar(1) GT 1) AND (NOT (KEYWORD_SET(coord)))) THEN BEGIN
              coord="X"
           ENDIF
           xx=y & yy=zz & zz=x
           END

    "xz" : BEGIN  
           IF N_ELEMENTS(iyt) GT 0 THEN BEGIN
              imf=iyt & im0=iyt & imstep=1
           ENDIF ELSE BEGIN
              IF (N_ELEMENTS(iy0) EQ 0) THEN im0=0 ELSE im0=iy0
              IF (N_ELEMENTS(iyf) EQ 0) THEN imf=sizevar(2)-1 ELSE imf=iyf
              IF (NOT KEYWORD_SET(iystep)) THEN imstep=1 ELSE imstep=iystep
              IF (im0 EQ imf) THEN imstep=1
           ENDELSE
           IF (N_ELEMENTS(xshift) NE 0) THEN x=x+xshift
           IF (N_ELEMENTS(zshift) NE 0) THEN z=z+zshift
           IF (N_ELEMENTS(integration) NE 0) THEN BEGIN
              dy=d->getdy()
              var=var*dy*1e8
              var(*,imf,*)=total(var[*, im0 : imf, *],2) - 0.5*(var[*,im0,*]+var[*,imf,*])
              im0=imf
           ENDIF
           maxz=MAX(z, MIN=minz)
           dz=(maxz-minz)/(nelz-1)
           dz1d=d->getdz1d()
           IF (abs(min(dz1d)-dz) GT 1e-5) THEN BEGIN
              zz    = minz+dz*FINDGEN(nelz)
              index = indgen(nelx)
              indey = (indgen(nely))[im0:imf:imstep]
              indez = interpol(indgen(nelz),z,zz )
              var[*,im0:imf:imstep,*] = INTERPOLATE(var, index, indey, indez, /grid)
           ENDIF ELSE BEGIN
              zz=z
           ENDELSE
           IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN var=reverse(var,3)
           xtitle="X" & ytitle="Z"
           IF ((sizevar(2) GT 1) AND (NOT (KEYWORD_SET(coord)))) THEN BEGIN
              coord="Y"
           ENDIF
           xx=x & yy=zz
           IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN zz=-y ELSE zz=y
           END

    "xy" : BEGIN  
           IF N_ELEMENTS(izt) GT 0 THEN BEGIN
              imf=izt & im0=izt & imstep=1
           ENDIF ELSE BEGIN
              IF (N_ELEMENTS(iz0) EQ 0) THEN im0=0 ELSE im0=iz0
              IF (N_ELEMENTS(izf) EQ 0) THEN imf=sizevar(3)-1 ELSE imf=izf
              IF (NOT KEYWORD_SET(izstep)) THEN imstep=1 ELSE imstep=izstep
              IF (N_ELEMENTS(integration) NE 0) THEN BEGIN
                 dz1d=d->getdz1d()
                 FOR k=0,nelz-1 DO var(*,*,k)=var(*,*,k)*dz1d(k)*1e8
                 var(*,*,imf)=total(var[*, *, im0 : imf],3) - 0.5*(var[*,*,im0]+var[*,*,imf])
                 im0=imf
              ENDIF
              IF (im0 EQ imf) THEN imstep=1
           ENDELSE
           IF (N_ELEMENTS(xshift) NE 0) THEN x=x+xshift
           IF (N_ELEMENTS(yshift) NE 0) THEN y=y+yshift
           IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN var=reverse(var,2)
           xtitle="X" & ytitle="Y"
           IF ((sizevar(3) GT 1) AND (NOT (KEYWORD_SET(coord)))) THEN BEGIN
              coord="Z"
           ENDIF
           xx=x & yy=y
           IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN zz=-z ELSE zz=z
           END

    "x" : BEGIN
          IF N_ELEMENTS(izt) GT 0 THEN BEGIN
             ix0=izt & ixf=izt & ixstep=1
             IF N_ELEMENTS(iyt) GT 0 THEN BEGIN
                iy0=iyt & iyf=iyt & iystep=1
             ENDIF ELSE BEGIN
                IF (N_ELEMENTS(iy0) EQ 0) THEN iy0=0
                IF (N_ELEMENTS(iyf) EQ 0) THEN iyf=sizevar(2)-1
                IF (NOT KEYWORD_SET(iystep)) THEN iystep=1
             ENDELSE
          ENDIF ELSE BEGIN
             IF (N_ELEMENTS(iz0) EQ 0) THEN ix0=0 ELSE ix0=iz0
             IF (N_ELEMENTS(izf) EQ 0) THEN ixf=sizevar(3)-1 ELSE ixf=izf
             IF (NOT KEYWORD_SET(izstep)) THEN ixstep=1 ELSE ixstep=izstep
             IF N_ELEMENTS(iyt) GT 0 THEN BEGIN
                iy0=iyt & iyf=iyt & iystep=1
             ENDIF ELSE BEGIN
                IF (N_ELEMENTS(iy0) EQ 0) THEN iy0=0
                IF (N_ELEMENTS(iyf) EQ 0) THEN iyf=sizevar(2)-1
                IF (NOT KEYWORD_SET(iystep)) THEN iystep=1
             ENDELSE
          ENDELSE
          IF (N_ELEMENTS(xshift) NE 0) THEN x=x+xshift
          IF ((sizevar(3) GT 1) AND (NOT (KEYWORD_SET(coord)))) THEN BEGIN
             coord="Z"
             IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN yy=-z ELSE yy=z
             IF (sizevar(2) GT 1) THEN BEGIN
                coord=["Z","Y"]
                IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN zz=-y ELSE zz=y
             ENDIF
          ENDIF ELSE BEGIN
             IF (sizevar(2) GT 1) THEN BEGIN
                coord="Y"
                IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN yy=-y ELSE yy=y
             ENDIF
          ENDELSE
          xtitle="X"
          ytitle=bar_title
          xx=x
          END

    "y" : BEGIN
          IF N_ELEMENTS(ixt) GT 0 THEN BEGIN
             ix0=ixt & ixf=ixt & ixstep=1
             IF N_ELEMENTS(izt) GT 0 THEN BEGIN
                iy0=izt & iyf=izt & iystep=1
             ENDIF ELSE BEGIN
                IF (N_ELEMENTS(iz0) EQ 0) THEN iy0=0 ELSE iy0=iz0
                IF (N_ELEMENTS(izf) EQ 0) THEN iyf=sizevar(3)-1 ELSE iyf=izf
                IF (NOT KEYWORD_SET(izstep)) THEN iystep=1 ELSE iystep=izstep
             ENDELSE
          ENDIF ELSE BEGIN
             IF (N_ELEMENTS(ix0) EQ 0) THEN ix0=0
             IF (N_ELEMENTS(ixf) EQ 0) THEN ixf=sizevar(1)-1
             IF (NOT KEYWORD_SET(ixstep)) THEN ixstep=1
             IF N_ELEMENTS(izt) GT 0 THEN BEGIN
                iy0=izt & iyf=izt & iystep=1
             ENDIF ELSE BEGIN
                IF (N_ELEMENTS(iz0) EQ 0) THEN iy0=0 ELSE iy0=iz0
                IF (N_ELEMENTS(izf) EQ 0) THEN iyf=sizevar(3)-1 ELSE iyf=izf
                IF (NOT KEYWORD_SET(izstep)) THEN iystep=1 ELSE iystep=izstep
             ENDELSE
          ENDELSE
          IF (N_ELEMENTS(yshift) NE 0) THEN y=y+yshift
          IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN var=reverse(var,2)
          IF ((sizevar(1) GT 1) AND (NOT (KEYWORD_SET(coord)))) THEN BEGIN
             coord="X"
             yy=x
             IF (sizevar(3) GT 1) THEN BEGIN
                coord=["X","Z"]
                IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN zz=-z ELSE zz=z
             ENDIF
          ENDIF ELSE BEGIN
             IF (sizevar(3) GT 1) THEN BEGIN
                coord="Z"
                IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN yy=-z ELSE yy=z
             ENDIF
          ENDELSE
          xtitle="Y"
          ytitle=bar_title
          xx=y
          END


    "z" : BEGIN  
          IF N_ELEMENTS(ixt) GT 0 THEN BEGIN
             ix0=ixt & ixf=ixt & ixstep=1
             IF N_ELEMENTS(iyt) GT 0 THEN BEGIN 
                iy0=iyt & iyf=iyt & iystep=1
             ENDIF ELSE BEGIN
                IF (N_ELEMENTS(iy0) EQ 0) THEN iy0=0
                IF (N_ELEMENTS(iyf) EQ 0) THEN iyf=sizevar(2)-1
                IF (NOT KEYWORD_SET(iystep)) THEN iystep=1
             ENDELSE
          ENDIF ELSE BEGIN
             IF (N_ELEMENTS(ix0) EQ 0) THEN ix0=0
             IF (N_ELEMENTS(ixf) EQ 0) THEN ixf=sizevar(1)-1
             IF (NOT KEYWORD_SET(ixstep)) THEN ixstep=1
             IF N_ELEMENTS(iyt) GT 0 THEN BEGIN
                iy0=iyt & iyf=iyt & iystep=1 
             ENDIF ELSE BEGIN
                IF (N_ELEMENTS(iy0) EQ 0) THEN iy0=0
                IF (N_ELEMENTS(iyf) EQ 0) THEN iyf=sizevar(2)-1
                IF (NOT KEYWORD_SET(iystep)) THEN iystep=1
             ENDELSE                
          ENDELSE
          IF (N_ELEMENTS(zshift) NE 0) THEN z=z+zshift
          maxz=MAX(z, MIN=minz)
          dz=(maxz-minz)/(nelz-1)
          dz1d=d->getdz1d()
          IF (abs(min(dz1d)-dz) GT 1e-5) THEN BEGIN
             zz=minz+dz*FINDGEN(nelz)
             FOR j=iy0,iyf,iystep DO BEGIN
                FOR i=ix0,ixf,ixstep DO var(i,j,*)=INTERPOL(var(i,j,*),z,zz)
             ENDFOR
          ENDIF ELSE BEGIN
             zz=z
          ENDELSE
          IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN var=reverse(var,3)
          IF ((sizevar(1) GT 1) AND (NOT (KEYWORD_SET(coord)))) THEN BEGIN
             coord="X"
             yy=x
             IF (sizevar(2) GT 1) THEN BEGIN
                coord=["X","Y"]
                IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN xx=-y ELSE xx=y
             ENDIF
          ENDIF ELSE BEGIN
             IF (sizevar(2) GT 1) THEN BEGIN
                coord="Y"
                IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN xx=-y ELSE xx=y
             ENDIF
          ENDELSE
          xtitle="Z"
          ytitle=bar_title
          xx=zz
          END


    ELSE : BEGIN
           print, "Wrong dim"
           STOP
           END
 ENDCASE

;---------------------------------------------------------------------------------  
; Coordinates (By default in Mm)
;---------------------------------------------------------------------------------  
 IF (units EQ "solar") THEN BEGIN
    xtitle=xtitle+" (Mm)"
    units_coord=' Mm  '
    IF (STRLEN(dim) EQ 2) THEN ytitle=ytitle+" (Mm)"
 ENDIF

;---------------------------------------------------------------------------------  
; Time (By default in minutes)
;---------------------------------------------------------------------------------  
 CALL_PROCEDURE, "units_"+units, u
 t=d->gett()*u.ut
 IF (units EQ "solar") THEN t_units=1./60. ELSE t_units=1.0
 tt=t(0)*t_units
 stt=STRING(tt,format='(F10.2)')
 title='t='+STRTRIM(stt,2)
 IF (units EQ "solar") THEN title=title+' min'
 IF N_ELEMENTS(coord) EQ 1 THEN BEGIN
    IF (STRLEN(dim) EQ 2) THEN $
       title=coord+'='+STRTRIM(STRING(zz,format='(F10.2)'),2)+$
             units_coord+title
    IF (STRLEN(dim) EQ 1) THEN $
       title=coord+'='+STRTRIM(STRING(yy,format='(F10.2)'),2)+$
             units_coord+title
 ENDIF ELSE BEGIN
    IF N_ELEMENTS(coord) EQ 2 THEN BEGIN
       title={title1:coord[0]+'='+STRTRIM(STRING(yy,format='(F10.2)'),2)+units_coord, $
              title2:coord[1]+'='+STRTRIM(STRING(zz,format='(F10.2)'),2)+units_coord+ $
              title}
    ENDIF
 ENDELSE
 IF (N_ELEMENTS(showsnap) NE 0) THEN BEGIN
    title=title+'  snap='+strtrim(string(snaps),2)
 ENDIF

 IF KEYWORD_SET(integration) THEN BEGIN
    bar_title = "Int of "+bar_title
    IF bar_title.contains("cm") THEN BEGIN
       IF bar_title.contains("cm ")    THEN bar_title = bar_title.Replace('cm ', 'cm!u2!n')
       IF bar_title.contains("cm!u-1!n") THEN bar_title = bar_title.Replace('cm!u-1!n ', '')
       IF bar_title.contains("cm!u-2!n") THEN bar_title = bar_title.Replace('cm!u-2!n', 'cm!u-1!n')
       IF bar_title.contains("cm!u-3!n") THEN bar_title = bar_title.Replace('cm!u-3!n', 'cm!u-2!n')
    ENDIF ELSE BEGIN
       bar_title = bar_title.Replace(')', ' cm)')
    ENDELSE
 ENDIF
 
END
