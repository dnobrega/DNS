
PRO DNS_PRE_2DPLOT, var_plot,xx,yy,zz,dim,$
                    origin,scale,$
                    bar_name, snaps,$
                    bifrost_coord=bifrost_coord,$
                    ishift=ishift,jshift=jshift,$
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
       xx=xx(minix:maxix)
       originx=min(xx)
    ENDIF ELSE BEGIN
       ;X is Y
       IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN BEGIN
          IF (N_ELEMENTS(ymin) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),xx,-ymin)) ELSE maxix=nelx-1
          IF (N_ELEMENTS(ymax) GT 0) THEN minix=ROUND(interpol(findgen(nelx),xx,-ymax)) ELSE minix=0
          xx=xx(minix:maxix)
          originx=min(-xx)
          temp1=nelx-maxix & temp2=nelx-minix
          minix=temp1-1
          maxix=temp2-1
       ENDIF ELSE BEGIN
          IF (N_ELEMENTS(ymin) GT 0) THEN minix=ROUND(interpol(findgen(nelx),xx,ymin)) ELSE minix=0
          IF (N_ELEMENTS(ymax) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),xx,ymax)) ELSE maxix=nelx-1
          xx=xx(minix:maxix)
          originx=min(xx)
       ENDELSE
    ENDELSE
    dx=(max(xx)-min(xx))/(n_elements(xx)-1)
    ;------------------------------------------------------------------------------------------------
    ; Y
    ;------------------------------------------------------------------------------------------------    
    IF (strpos(dim,"z") EQ 1) THEN BEGIN
       ;Y is Z
       IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN BEGIN
          IF (N_ELEMENTS(zmin) GT 0) THEN maxiy=ROUND(interpol(findgen(nely),yy,-zmin)) ELSE maxiy=nely-1
          IF (N_ELEMENTS(zmax) GT 0) THEN miniy=ROUND(interpol(findgen(nely),yy,-zmax)) ELSE miniy=0  
          yy=yy(miniy:maxiy)
          originy=min(-yy)
          temp1=nely-maxiy & temp2=nely-miniy
          miniy=temp1-1
          maxiy=temp2-1
       ENDIF ELSE BEGIN
          IF (N_ELEMENTS(zmin) GT 0) THEN miniy=ROUND(interpol(findgen(nely),yy,zmin)) ELSE miniy=0
          IF (N_ELEMENTS(zmax) GT 0) THEN maxiy=ROUND(interpol(findgen(nely),yy,zmax)) ELSE maxiy=nely-1
          yy=yy(miniy:maxiy)
          originy=min(yy)
       ENDELSE
    ENDIF ELSE BEGIN
       ;Y is Y
       IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN BEGIN
          IF (N_ELEMENTS(ymin) GT 0) THEN maxiy=ROUND(interpol(findgen(nely),yy,-ymin)) ELSE maxiy=nely-1
          IF (N_ELEMENTS(ymax) GT 0) THEN miniy=ROUND(interpol(findgen(nely),yy,-ymax)) ELSE miniy=0
          yy=yy(miniy:maxiy)
          originy=min(-yy)
          temp1=nely-maxiy & temp2=nely-miniy
          miniy=temp1-1
          maxiy=temp2-1
       ENDIF ELSE BEGIN
          IF (N_ELEMENTS(ymin) GT 0) THEN miniy=ROUND(interpol(findgen(nely),yy,ymin)) ELSE miniy=0
          IF (N_ELEMENTS(ymax) GT 0) THEN maxiy=ROUND(interpol(findgen(nely),yy,ymax)) ELSE maxiy=nely-1
          yy=yy(miniy:maxiy)
          originy=min(yy)
       ENDELSE
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
        col=axcol,charthick=tit_charthick,chars=tit_chars,/norm,alignment=0.5


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
                var_minmax=var_minmax, $
                showminmax=showminmax, $
                bifrost_coord=bifrost_coord,$
                xx=xx, yy=yy, zz=zz,$
                xtitle=xtitle, ytitle=ytitle, ztitle=ztitle, title=title,$
                xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
                xshift=xshift, yshift=yshift, zshift=zshift, ishift=ishift, jshift=jshift,$
                position=position,$
                bar_name=bar_name, var_range=var_range, bar_log=bar_log, $
                find_min=find_min, find_max=find_max, $
                save_min=save_min, save_max=save_max, $
                min_filename=min_filename, max_filename=max_filename, $
                var_name=var_name


COMMON BIFPLT_COMMON,  $
       bar_pos,bar_titlepos, $
       bar_orient, bar_charthick, $
       bar_thick, bar_charsize,$
       bar_titchart,$
       bar_titchars,$
       bottom, top, $
       isotropic, smooth

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;---------------------------------------------------------------------------------
;                                  MAIN
;---------------------------------------------------------------------------------


 dns_pre_2dplot,var_plot,xx,yy,zz,dim,$
                origin,scale,$
                bar_name, snaps,$
                ishift=ishift,jshift=jshift,$
                bifrost_coord=bifrost_coord,$
                xmin=xmin,xmax=xmax,$
                ymin=ymin,ymax=ymax,$
                zmin=zmin,zmax=zmax

;---------------------------------------------------------------------------------  
; Print min/max
;---------------------------------------------------------------------------------         
  var_max = MAX(var_plot, pos_max, min=var_min, SUBSCRIPT_MIN=pos_min, /NAN)
  IF (KEYWORD_SET(var_minmax))       THEN var_range=[var_min,var_max]
  PRINT, "------------------------------------------------------"
  PRINT, " ",bar_name+": "+strtrim(snaps,2)+' | '+strtrim(var_min,2)+' / '+strtrim(var_max,2)
  PRINT, "------------------------------------------------------"
  IF (N_ELEMENTS(showminmax) NE 0) THEN BEGIN
     final_title='['+strtrim(string(var_min),2)+'/'+strtrim(string(var_max),2)+'] '+title
  ENDIF ELSE final_title=title



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
              title=final_title,  $
              xtitle=xtitle, ytitle=ytitle, $
              min=bar_range[0],max=bar_range[1], $
              xminor=5, yminor=5, $  
              isotropic=isotropic,$
              bottom=bottom, top=top,$
              smooth=smooth

  AA = FINDGEN(17) * (!PI*2/16.)
  USERSYM, COS(AA), SIN(AA)

  IF ((N_ELEMENTS(find_max) NE 0) OR (N_ELEMENTS(save_max) NE 0)) THEN BEGIN
     ind_max = array_indices(var_plot, pos_max)
     loc_max = ind_max*scale + origin
     oplot, loc_max[0]*[1,1], loc_max[1]*[1,1], psym=8, symsize=1.0, color=0
     IF (N_ELEMENTS(save_max) NE 0) THEN BEGIN
        folder = "loc_max"
        file_mkdir, folder
        IF (N_ELEMENTS(max_filename) EQ 0) THEN filename="/max_"+var_name+"_"+STRTRIM(snaps,2)+".sav" $
        ELSE filename="/max_"+var_name+"_"+max_filename+"_"+STRTRIM(snaps,2)+".sav"
        print, folder+filename
        save, scale, origin, loc_max, filename=filename
     ENDIF
  ENDIF

  IF ((N_ELEMENTS(find_min) NE 0) OR (N_ELEMENTS(save_min) NE 0)) THEN BEGIN
     ind_min = array_indices(var_plot, pos_min)
     loc_min = ind_min*scale + origin
     oplot, loc_min[0]*[1,1], loc_min[1]*[1,1], psym=8, symsize=1.0,color=255
     IF (N_ELEMENTS(save_min) NE 0) THEN BEGIN
        folder = "loc_min"
        file_mkdir, folder
        IF (N_ELEMENTS(min_filename) EQ 0) THEN filename="/min_"+var_name+"_"+STRTRIM(snaps,2)+".sav" $
        ELSE filename="/min_"+var_name+"_"+min_filename+"_"+STRTRIM(snaps,2)+".sav"
        print, folder+filename
        save, scale, origin, loc_min, filename=folder+filename
     ENDIF
  ENDIF
  
  IF (bar_titlepos(0) LT 0) THEN BEGIN
     ignore = 0
     ignore = ignore + 2*bar_name.Contains('!u')
     ignore = ignore + 2*bar_name.Contains('!n')
     ignore = ignore + 2*bar_name.Contains('!d')
     ignore = ignore + 2*bar_name.Contains('!4')
     ignore = ignore + 2*bar_name.Contains('!3')
     title_len=STRLEN(bar_name)-ignore
     bar_titlepos(0)=(bar_pos[2]+bar_pos[0])/2.0 - (title_len - 1)*0.01
  ENDIF
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


END
