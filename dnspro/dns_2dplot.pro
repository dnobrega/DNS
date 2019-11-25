

PRO DNS_COLORBAR,lev2vel, $
                 varname=varname, $
                 log=log,  $
                 charthick=charthick,thick=thick,chars=chars,$
                 tit_charthick=tit_charthick, tit_chars=tit_chars,$
                 orient=orient, $
                 position=position,$
                 postitle=postitle

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
;
;                                  HELP
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

; Routine to draw a colorbar from F. Moreno-Insertis and Daniel Nobrega-Siverio
;
;     --> lev2vel is a 1D array with the levels to be shown in the colorbar, 
;         e.g., to plot a linear scale of nlev components between a and b: 
;                     lev2vel=findgen(nlev)*(b-a)/(nlev-1) + a
;     --> log: the axis is plotted logarithmically
;                     but then: lev2vel contains the logarithms, like:
;                     lev2vel=findgen(nlev)*(alog10(b)-alog10(a))/(nlev-1)
;                             + alog10(a)
;     --> orient: 'xtop', 'xbot', 'yleft', 'yright' 
;                                                   
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

 p_old=!p & x_old=!x & y_old=!y

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

 nlev=n_elements(lev2vel)
 colarr=findgen(nlev)
 nn=320/nlev & nnlong=nn*nlev & nnshort = 5
 aa = findgen(nn*nlev,nnshort)
 FOR i=0,nlev-1 DO FOR jj=0,nn-1 DO FOR kk=0,nnshort-1 DO aa(i*nn+jj,kk)=lev2vel(i) 

 IF orient EQ 'yleft' OR orient EQ 'yright' THEN aa=transpose(aa)

 CONTOUR, aa, /noerase, nlev=nlev,lev=lev2vel,/fill, c_colors=colarr,$
          xst=5,yst=5, position=position,xtit=varname

 CASE orient OF
     'xtop': BEGIN 
               titposx=(position(2)-position(0))/2+position(0) 
               titposy = position(1) - (position(3)-position(1))/2     
             END    
     'xbot': BEGIN 
               titposx=(position(2)-position(0))/2+position(0) 
               titposy = position(1) - (position(3)-position(1))/2  
             END
    'yright': BEGIN 
                titposx=(position(2)-position(0))*1.3 +position(2) 
                titposy = position(1) + (position(3)-position(1))/2 
              END
    'yleft':  BEGIN 
                titposx=(position(2)-position(0))*1.3 +position(2) 
                titposy = position(1) + (position(3)-position(1))/2 
              END
 ENDCASE

 axcol=!P.color
 titposy=postitle[1]
 titposx=postitle[0]
 xyouts,titposx,titposy,varname, $
        col=axcol,charthick=tit_charthick,chars=tit_charsize,/norm


 rang=[min(lev2vel),max(lev2vel)] & IF keyword_set(log) THEN rang=10^rang

 xlog=keyword_set(log) AND (orient EQ 'xtop'  OR orient EQ 'xbot')
 ylog=keyword_set(log) AND (orient EQ 'yleft' OR orient EQ 'yright')

 IF orient EQ 'yleft'  THEN BEGIN yax=0 & xr=[0,nnshort-1] & yr=rang & ENDIF
 IF orient EQ 'yright' THEN BEGIN yax=1 & xr=[0,nnshort-1] & yr=rang & ENDIF
 IF orient EQ 'xtop'   THEN BEGIN xax=1 & yr=[0,nnshort-1] & xr=rang & ENDIF
 IF orient EQ 'xbot'   THEN BEGIN xax=0 & yr=[0,nnshort-1] & xr=rang & ENDIF
    
 IF orient EQ 'xtop' OR orient EQ 'xbot' THEN $  
    axis,xax=xax, xr=xr, yr=yr,/xst,/yst,col=axcol,xlog=xlog,ylog=ylog, $
         charth=charthick,ticklen=-0.3,chars=chars,xthick=thick,ythick=thick

 IF orient EQ 'yleft' OR orient EQ 'yright' THEN $
    axis,yax=yax, xr=xr, yr=yr,/xst,/yst,col=axcol,xlog=xlog,ylog=ylog, $
         charth=charthick,ticklen=-0.4,chars=chars,xthick=thick,ythick=thick
    
 tickns=replicate(' ',60)

 IF orient NE 'yleft' THEN $ 
    axis,yax=0,col=axcol,ythick=thick,ytickname=tickns, $
         yticks=1,yminor=1,yticklen=0.0001

 IF orient NE 'yright' THEN $ 
    axis,yax=1,col=axcol,ythick=thick,ytickname=tickns, $
         yticks=1,yminor=1,yticklen=0.0001

 IF orient NE 'xbot' THEN $   
    axis,xax=0, col=axcol,xthick=thick,xtickname=tickns, $
         xticks=1,xminor=1,xticklen=0.0001

 IF orient NE 'xtop' THEN $  
    axis,xax=1,  col=axcol,xthick=thick,xtickname=tickns, $
         xticks=1,xminor=1,xticklen=0.0001


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

 !p=p_old & !x=x_old & !y=y_old

END

PRO DNS_2DPLOT, d,var_plot,dim,$
                mm=mm, coord=coord,$
                xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
                bar_name=bar_name, var_range=var_range, bar_log=bar_log,  $
                bar_pos=bar_pos, bar_titlepos=bar_titlepos, $
                bar_orient=bar_orient, bar_charthick=bar_charthick, $
                bar_thick=bar_thick, bar_charsize=bar_charsize, $
                bar_titchars=bar_titchars, bar_titchart=bar_titchart, $
                bottom=bottom, top=top, $
                oline=oline,$
                ostyle=ostyle, othick=othick, ocolor=ocolor,$
                ox=ox, oy=oy
  

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
    IF (N_ELEMENTS(xmin) GT 0) THEN minix=ROUND(interpol(findgen(nelx),x,xmin)) ELSE minix=0 
    IF (N_ELEMENTS(xmin) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),x,xmax)) ELSE maxix=nelx-1
    IF (N_ELEMENTS(zmin) GT 0) THEN maxiz=ROUND(interpol(findgen(nelz),newz,-zmin)) ELSE maxiz=nelz-1
    IF (N_ELEMENTS(zmax) GT 0) THEN miniz=ROUND(interpol(findgen(nelz),newz,-zmax)) ELSE miniz=0
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
    IF (N_ELEMENTS(ymin) GT 0) THEN miniy=ROUND(interpol(findgen(nely),y,ymin)) ELSE miniy=0 
    IF (N_ELEMENTS(ymax) GT 0) THEN maxiy=ROUND(interpol(findgen(nely),y,ymax)) ELSE maxiy=nely-1
    IF (N_ELEMENTS(zmin) GT 0) THEN maxiz=ROUND(interpol(findgen(nelz),newz,-zmin)) ELSE maxiz=nelz-1
    IF (N_ELEMENTS(zmax) GT 0) THEN miniz=ROUND(interpol(findgen(nelz),newz,-zmax)) ELSE miniz=0
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
; XY-plane
;---------------------------------------------------------------------------------
 IF (dim EQ "xy") THEN BEGIN
    x=d->getx() & nelx=n_elements(x)   
    coord='Z'
    coord_array=-d->getz()    
    y=d->gety() & nely=n_elements(y)
    IF (N_ELEMENTS(xmin) GT 0) THEN minix=ROUND(interpol(findgen(nelx),x,xmin)) ELSE minix=0 
    IF (N_ELEMENTS(xmax) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),x,xmax)) ELSE maxix=nelx-1
    IF (N_ELEMENTS(ymin) GT 0) THEN miniy=ROUND(interpol(findgen(nely),y,ymin)) ELSE miniy=0 
    IF (N_ELEMENTS(ymax) GT 0) THEN maxiy=ROUND(interpol(findgen(nely),y,ymax)) ELSE maxiy=nely-1
    x=x(minix:maxix)
    dx=(max(x)-min(x))/(nelx-1)
    y=y(miniy:maxiy)
    dy=(max(y)-min(y))/(nely-1)
    scale=[dx,dy]
    origin=[min(x),min(y)]
    var_plot=var_plot(minix:maxix,miniy:maxiy)
    xtitle='X (Mm)' & ytitle='Y (Mm)'
 ENDIF

;---------------------------------------------------------------------------------  
; Time in minutes
;---------------------------------------------------------------------------------         
  t=d->gett()
  t=t(0)*100./60
  stt=STRING(t,format='(F10.1)')
  bar_range=var_range
  IF N_ELEMENTS(bar_log) NE 0 THEN BEGIN
     IF (bar_log EQ 1) THEN BEGIN
        var_plot=alog10(var_plot)
        IF (bar_range(0) EQ 0) THEN bar_range(0)=1d-30
        bar_range=alog10(var_range)
     ENDIF
  ENDIF

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;---------------------------------------------------------------------------------
;                                     PLOT                               
;--------------------------------------------------------------------------------- 

  IF (N_ELEMENTS(mm) EQ 1) THEN BEGIN
     title=coord+': '+STRTRIM(STRING(coord_array(mm),format='(F10.1)'),2)+' (Mm)   t='+STRTRIM(stt,2)+' min'
  ENDIF ELSE title='t='+STRTRIM(stt,2)+' min' 

  plot_image, var_plot, $
              origin=origin, scale=scale, $
              title=title,  $
              xtitle=xtitle, ytitle=ytitle, $
              min=bar_range[0],max=bar_range[1], $
              xminor=5, yminor=5, $  
              isotropic=isotropic,$
              bottom=bottom, top=top
  nlev=256
  lev2vel=bar_range[0]+findgen(nlev)*(bar_range[1]-bar_range[0])/(nlev-1)
  DNS_COLORBAR, lev2vel,$
                varname=bar_name, $
                log=bar_log,  $
                charthick=bar_charthick,$
                thick=bar_thick, $
                chars=bar_charsize,$
                orient=bar_orient, $
                position=bar_pos,$
                postitle=bar_titlepos,$
                tit_chart=bar_titchart,$ 
                tit_chars=bar_titchars



  IF (KEYWORD_SET(oline)) THEN BEGIN
     DNS_OLINE,ostyle=ostyle, othick=othick, ocolor=ocolor,$
               ox=ox, oy=oy, $
               dim=dim, x=x, y=y, z=z
  ENDIF

END
