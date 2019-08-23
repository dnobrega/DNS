
PRO DNS_2DPLOT, d,var_plot,dim,$
                sim3d=sim3d, m=m, coord=coord,$
                var_title=var_title, var_range=var_range, var_log=var_log,  $
                xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
                fmipos=fmipos, fmititle=fmititle, axcol=axcol
  
;--------------------------------------------------------------------------------- 

  IF (n_params() LT 3) THEN BEGIN
     message,'d,var_plot,dim,'$
            +'sim3d=sim3d, m=m, coord=coord,'$
            +'var_title=var_title, var_range=var_range, var_log=var_log,'$
            +'xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,'$
            +'fmipos=fmipos, fmititle=fmititle, axcol=axcol',/info
      RETURN
  ENDIF

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;---------------------------------------------------------------------------------
;                                  MAIN
;---------------------------------------------------------------------------------


;---------------------------------------------------------------------------------  
; XZ-plane
;---------------------------------------------------------------------------------
 IF (dim EQ "xz") THEN BEGIN
    x=d->getx() & nelx=n_elements(x)
    coord='Y'
    coord_array=d->gety()    
    z=d->getz() & nelz=n_elements(z)
    maxz=MAX(z, MIN=minz)
    dz=(maxz-minz)/(nelz-1)
    newz=minz+dz*FINDGEN(nelz)
    FOR i=0,nelx-1 DO var_plot(i,*)=INTERPOL(var_plot(i,*),z,newz)
    var_plot=reverse(var_plot,2)
    IF KEYWORD_SET(xmin) THEN minix=ROUND(interpol(findgen(nelx),x,xmin)) ELSE minix=0 
    IF KEYWORD_SET(xmax) THEN maxix=ROUND(interpol(findgen(nelx),x,xmax)) ELSE maxix=nelx-1
    IF KEYWORD_SET(zmin) THEN miniz=ROUND(interpol(findgen(nelz),newz,-zmin)) ELSE miniz=0
    IF KEYWORD_SET(zmax) THEN maxiz=ROUND(interpol(findgen(nelz),newz,-zmax)) ELSE maxiz=nelz-1
    x=x(minix:maxix)
    dx=(max(x)-min(x))/(n_elements(x)-1)
    z=newz(miniz:maxiz)
    originz=min(-z)
    temp1=nelz-maxiz
    temp2=nelz-miniz
    miniz=temp1-1
    maxiz=temp2-1
    scale=[dx,dz]
    origin=[min(x),originz]
    var_plot=var_plot(minix:maxix,miniz:maxiz)
    xtitle='X (Mm)' & ytitle='Z (Mm)'
 ENDIF

;---------------------------------------------------------------------------------  
; YZ-plane
;---------------------------------------------------------------------------------
 IF (dim EQ "yz") THEN BEGIN
    y=d->gety() & nely=n_elements(y)   
    coord='X'
    coord_array=d->getx()    
    z=d->getz() & nelz=n_elements(z)
    maxz=MAX(z, MIN=minz)
    dz=(maxz-minz)/(nelz-1)
    newz=minz+dz*FINDGEN(nelz)
    FOR i=0,nely-1 DO var_plot(i,*)=INTERPOL(var_plot(i,*),z,newz)
    var_plot=reverse(var_plot,2)
    IF KEYWORD_SET(ymin) THEN miniy=ROUND(interpol(findgen(nely),y,ymin)) ELSE miniy=0 
    IF KEYWORD_SET(ymax) THEN maxiy=ROUND(interpol(findgen(nely),y,ymax)) ELSE maxiy=nely-1
    IF KEYWORD_SET(zmin) THEN miniz=ROUND(interpol(findgen(nelz),newz,-zmin)) ELSE miniz=0
    IF KEYWORD_SET(zmax) THEN maxiz=ROUND(interpol(findgen(nelz),newz,-zmax)) ELSE maxiz=nelz-1
    y=y(miniy:maxiy)
    dy=(max(y)-min(y))/(n_elements(y)-1)
    z=newz(miniz:maxiz)
    originz=min(-z)
    temp1=nelz-maxiz
    temp2=nelz-miniz
    miniz=temp1-1
    maxiz=temp2-1
    scale=[dy,dz]
    origin=[min(y),originz]
    var_plot=var_plot(miniy:maxiy,miniz:maxiz)
    xtitle='Y (Mm)' & ytitle='Z (Mm)'
 ENDIF

;---------------------------------------------------------------------------------  
; Time in minutes
;---------------------------------------------------------------------------------         
  t=d->gett()
  t=t(0)*100./60
  stt=STRING(t,format='(F10.1)')

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;---------------------------------------------------------------------------------
;                                     PLOT                               
;--------------------------------------------------------------------------------- 
   
  IF (N_ELEMENTS(sim3d) EQ 1) THEN $
     title=coord+': '+STRTRIM(STRING(coord_array(m),format='(F10.1)'),2)+' (Mm) ' $
     ELSE title=''

  plot_image, var_plot, $
              origin=origin, scale=scale, $
              title=title+'t='+STRTRIM(stt,2)+' min'  ,  $
              xtitle=xtitle, ytitle=ytitle, $
              min=var_range[0],max=var_range[1], $
              xminor=5, yminor=5, $  
              smooth=1, /isotropic,$
              bottom=0, top=255




  brange=var_range
  nlev=256
  lev2vel=min(brange)+findgen(nlev)*(max(brange)-min(brange))/(nlev-1)
  orient='yright'
  colarr=findgen(nlev) & colarr(254:255)=255
  COLORBAR_FMI, lev2vel,log=var_log,  $
                charthick=1.5,thick=2.0, chars=2.0,$
                varname=var_title, $
                orient=orient, $
                position=fmipos,$
                postitle=fmititle,$
                colarr=colarr, $
                axcol=axcol


END
