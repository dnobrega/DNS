

PRO DNS_PRE_2DPLOT, var_plot,xx,yy,zz,dim,$
                    origin,scale,ishift=ishift,jshift=jshift,$
                    xmin=xmin,xmax=xmax,$
                    ymin=ymin,ymax=ymax,$
                    zmin=zmin,zmax=zmax


  
    nelx=n_elements(xx)
    nely=n_elements(yy)
    ;------------------------------------------------------------------------------------------------
    ; X
    ;------------------------------------------------------------------------------------------------
    IF (strpos(dim,"x") EQ 0) THEN BEGIN
       ;X is X
       IF (N_ELEMENTS(xmin) GT 0) THEN minix=ROUND(interpol(findgen(nelx),xx,xmin)) ELSE minix=0
       IF (N_ELEMENTS(xmax) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),xx,xmax)) ELSE maxix=nelx-1
    ENDIF ELSE BEGIN
       ;X is Y
       IF (N_ELEMENTS(ymin) GT 0) THEN minix=ROUND(interpol(findgen(nelx),xx,ymin)) ELSE minix=0
       IF (N_ELEMENTS(ymax) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),xx,ymax)) ELSE maxix=nelx-1
    ENDELSE
    xx=xx(minix:maxix)
    dx=(max(xx)-min(xx))/(n_elements(xx)-1)
    originx=min(xx)
    ;------------------------------------------------------------------------------------------------
    ; Y
    ;------------------------------------------------------------------------------------------------    
    IF (strpos(dim,"z") EQ 1) THEN BEGIN
       ;Y is Z
       IF (N_ELEMENTS(zmin) GT 0) THEN maxiy=ROUND(interpol(findgen(nely),yy,-zmin)) ELSE maxiy=nely-1
       IF (N_ELEMENTS(zmax) GT 0) THEN miniy=ROUND(interpol(findgen(nely),yy,-zmax)) ELSE miniy=0  
       yy=yy(miniy:maxiy)
       originy=min(-yy)
       temp1=nely-maxiy & temp2=nely-miniy
       miniy=temp1-1
       maxiy=temp2-1
    ENDIF ELSE BEGIN
       ;Y is Y
       IF (N_ELEMENTS(ymin) GT 0) THEN miniy=ROUND(interpol(findgen(nely),yy,ymin)) ELSE miniy=0
       IF (N_ELEMENTS(ymax) GT 0) THEN maxiy=ROUND(interpol(findgen(nely),yy,ymax)) ELSE maxiy=nely-1
       yy=yy(miniy:maxiy)
       originy=min(yy)
    ENDELSE
    dy=(max(yy)-min(yy))/(n_elements(yy)-1)

    ;------------------------------------------------------------------------------------------------
    ; OUTPUT
    ;------------------------------------------------------------------------------------------------    
    origin=[originx,originy]
    scale=[dx,dy]
    var_plot=var_plot(minix:maxix,miniy:maxiy)
    IF (N_ELEMENTS(ishift) GT 0) THEN var_plot=shift(var_plot,ishift,0)
    IF (N_ELEMENTS(jshift) GT 0) THEN var_plot=shift(var_plot,0,jshift)

END

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
        col=axcol,charthick=tit_charthick,chars=tit_chars,/norm


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

PRO DNS_2DPLOT, d,snaps,var_plot,dim,$
                xx=xx, yy=yy, zz=zz,$
                xtitle=xtitle, ytitle=ytitle, ztitle=ztitle, title=title,$
                xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
                xshift=xshift, yshift=yshift, zshift=zshift, ishift=ishift, jshift=jshift,$
                position=position,$
                bar_name=bar_name, var_range=var_range, bar_log=bar_log,  $
                bar_pos=bar_pos, bar_titlepos=bar_titlepos, $
                bar_orient=bar_orient, bar_charthick=bar_charthick, $
                bar_thick=bar_thick, bar_charsize=bar_charsize, $
                bar_titchars=bar_titchars, bar_titchart=bar_titchart, $
                bottom=bottom, top=top, smooth=smooth,$
                isotropic=isotropic,$
                ; Oplot Line
                oline=oline,$
                ostyle=ostyle, othick=othick, ocolor=ocolor,$
                ox=ox, oy=oy


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;---------------------------------------------------------------------------------
;                                  MAIN
;---------------------------------------------------------------------------------


 dns_pre_2dplot,var_plot,xx,yy,zz,dim,$
                origin,scale,ishift=ishift,jshift=jshift,$
                xmin=xmin,xmax=xmax,$
                ymin=ymin,ymax=ymax,$
                zmin=zmin,zmax=zmax

;---------------------------------------------------------------------------------  
; Applying log
;---------------------------------------------------------------------------------         
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

  plot_image, var_plot, $
              position=position,$
              origin=origin, scale=scale, $
              title=title,  $
              xtitle=xtitle, ytitle=ytitle, $
              min=bar_range[0],max=bar_range[1], $
              xminor=5, yminor=5, $  
              isotropic=isotropic,$
              bottom=bottom, top=top,$
              smooth=smooth
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
               dim=dim, x=xx, y=yy, z=zz
  ENDIF


END
