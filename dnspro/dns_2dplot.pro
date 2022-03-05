
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

PRO DNS_2DPLOT, d,snaps,var_plot,dim,$
                var_minmax=var_minmax, $
                var_extratitle=var_extratitle,$
                showminmax=showminmax, $
                bifrost_coord=bifrost_coord,$
                xx=xx, yy=yy, zz=zz,$
                xtitle=xtitle, ytitle=ytitle, ztitle=ztitle, title=title,$
                xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
                xshift=xshift, yshift=yshift, zshift=zshift, ishift=ishift, jshift=jshift,$
                position=position,$
                bar_name=bar_name, var_range=var_range, bar_log=bar_log, $
                find_min=find_min, find_max=find_max, $
                find_size=find_size, find_color=find_color, $
                show_stats=show_stats, save_stats=save_stats, $
                stats_filename=stats_filename, $
                var_name=var_name, $
                mask_fun=mask_fun, mask_save=mask_save, mask_name=mask_name,$
                mask_colors=mask_colors,$
                mask_thick=mask_thick,mask_linestyle=mask_linestyle,$
                save_2d=save_2d


COMMON BIFPLT_COMMON,  $
       bar_pos,bar_titlepos, $
       bar_orient, bar_charthick, $
       bar_thick, bar_charsize,$
       bar_titchart,$
       bar_titchars,$
       bottom, top, $
       isotropic, smooth

IF (NOT (KEYWORD_SET(find_size)))        THEN find_size=2
IF (N_ELEMENTS(find_color) EQ 0)         THEN find_color=255

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
  IF (N_ELEMENTS(var_extratitle) NE 0) THEN title=title+" "+var_extratitle
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

  IF (KEYWORD_SET(save_2d)) THEN BEGIN
     help, var_plot, position, origin, scale, final_title, xtitle, ytitle, bar_range
     folder = "var2d"
     IF (NOT FILE_TEST(folder, /DIRECTORY)) THEN file_mkdir, folder
     save, var_plot, position, origin, $
           scale, final_title, xtitle, ytitle, bar_range, $
           filename=folder+'/var2d_'+var_name+"_"+STRTRIM(snaps,2)+".sav"
  ENDIF
  
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

  IF (N_ELEMENTS(mask_fun) NE 0) THEN BEGIN
     void   = EXECUTE('wh = WHERE(' + mask_fun +', nw)')
     IF (nw GT 0) THEN BEGIN
        PRINT, STRING(STRTRIM(nw,2))+" elements found with that mask"
        ind    = array_indices(var_plot, wh)
        coords = 0.0*ind
        values = var_plot(wh)
        coords[0,*] = ind[0,*]*scale[0] + origin[0]
        coords[1,*] = ind[1,*]*scale[1] + origin[1]
        c_var = var_plot*0.0
        c_var(wh) = 1.0
        IF (strpos(dim,"z") EQ 1) THEN y_plot=reverse(-yy) ELSE y_plot=yy
        IF (N_ELEMENTS(mask_colors) EQ 0)    THEN mask_colors=0
        IF (N_ELEMENTS(mask_thick) EQ 0)     THEN mask_thick=2
        IF (N_ELEMENTS(mask_linestyle) EQ 0) THEN mask_linestyle=0
        tvlct, rgb, /get
        LOAD, 39
        CONTOUR, c_var, xx, y_plot, levels=1, /overplot,$
                 c_colors=mask_colors,$
                 c_thick=mask_thick, c_linestyle=mask_linestyle
        tvlct, rgb
     ENDIF ELSE BEGIN
        PRINT, "No elements found with that mask"
        coords = 0
        values = 0
     ENDELSE
     IF (N_ELEMENTS(mask_save) NE 0) THEN BEGIN
        folder = "masks"
        IF (N_ELEMENTS(mask_name) EQ 0) THEN mask_name = var_name
        IF (NOT FILE_TEST(folder, /DIRECTORY)) THEN file_mkdir, folder
        save, xx, yy, coords, values, mask_fun, filename=folder+'/mask_'+mask_name+"_"+STRTRIM(snaps,2)+".sav"
     ENDIF
  ENDIF

  IF ((N_ELEMENTS(show_stats) NE 0) OR (N_ELEMENTS(save_stats) NE 0)) THEN BEGIN
     ind_min = array_indices(var_plot, pos_min)
     loc_min = ind_min*scale + origin
     ind_max = array_indices(var_plot, pos_max)
     loc_max = ind_max*scale + origin
     var_mean = MEAN(var_plot)
     var_std  = STDDEV(var_plot)
     var_tot  = TOTAL(var_plot)
     PRINT, "------------------------------------------------------"
     PRINT, " STATS "
     PRINT, " Min at x = "+strtrim(loc_min[0],2)+' and y = '+strtrim(loc_min[1],2)
     PRINT, " Max at x = "+strtrim(loc_max[0],2)+' and y = '+strtrim(loc_max[1],2)
     PRINT, " Total = "+strtrim(var_tot,2)
     PRINT, " Mean value = "+strtrim(var_mean,2)
     PRINT, " Standard deviation = "+strtrim(var_std,2)
     PRINT, "------------------------------------------------------"
     IF ((N_ELEMENTS(find_max) NE 0)) THEN  oplot, loc_max[0]*[1,1], loc_max[1]*[1,1], psym=8, symsize=find_size, color=find_color
     IF ((N_ELEMENTS(find_min) NE 0)) THEN  oplot, loc_min[0]*[1,1], loc_min[1]*[1,1], psym=8, symsize=find_size, color=find_color
     IF (N_ELEMENTS(save_stats) NE 0) THEN BEGIN
        folder = "stats"
        IF (NOT FILE_TEST(folder, /DIRECTORY)) THEN file_mkdir, folder        
        file_mkdir, folder
        IF (N_ELEMENTS(stats_filename) EQ 0) THEN filename="/stats_"+var_name+"_"+STRTRIM(snaps,2)+".sav" $
        ELSE filename="/stats_"+var_name+"_"+stats_filename+"_"+STRTRIM(snaps,2)+".sav"
        print, folder+filename
        save, xx, yy, $
              loc_min, var_min, loc_max, var_max, $
              var_tot, var_mean, var_std, $
              filename=folder+filename
     ENDIF
  ENDIF
     
  DNS_COLORBAR, bar_range, nlev=nlev,$
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
