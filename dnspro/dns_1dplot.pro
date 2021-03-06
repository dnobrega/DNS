
PRO dns_1dplot, d,k,var_plot,dim, $
                var_minmax=var_minmax, $
                showminmax=showminmax, $
                bifrost_coord=bifrost_coord,$
                bar_log=bar_log,$
                xx=xx, yy=yy, zz=zz,$
                xtitle=xtitle, ytitle=ytitle, title=title,$
                xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
                ishift=ishift,$
                position=position,$
                var_range=var_range,  $
                isotropic=isotropic, $
                linestyle=linestyle, $
                psym=psym, symsize=symsize


  nelx=n_elements(xx)
  nely=n_elements(yy)
  nelz=n_elements(zz)

  IF (dim EQ "x") THEN BEGIN
     IF (N_ELEMENTS(xmin) GT 0) THEN minix=ROUND(interpol(findgen(nelx),xx,xmin)) ELSE minix=0
     IF (N_ELEMENTS(xmax) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),xx,xmax)) ELSE maxix=nelx-1
     xx_plot=xx(minix:maxix)
  ENDIF

  IF (dim EQ "y") THEN BEGIN
     IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN BEGIN
        IF (N_ELEMENTS(ymin) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),xx,-ymin)) ELSE maxix=nelx-1
        IF (N_ELEMENTS(ymax) GT 0) THEN minix=ROUND(interpol(findgen(nelx),xx,-ymax)) ELSE minix=0
        xx_plot=xx(minix:maxix)
        xx_plot=-reverse(xx_plot)
        temp1=nelx-maxix & temp2=nelx-minix
        minix=temp1-1
        maxix=temp2-1
     ENDIF ELSE BEGIN
        IF (N_ELEMENTS(ymin) GT 0) THEN minix=ROUND(interpol(findgen(nelx),xx,ymin)) ELSE minix=0
        IF (N_ELEMENTS(ymax) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),xx,ymax)) ELSE maxix=nelx-1
        xx_plot=xx(minix:maxix)
     ENDELSE
  ENDIF

  IF (dim EQ "z") THEN BEGIN
     IF (N_ELEMENTS(bifrost_coord) EQ 0) THEN BEGIN
        IF (N_ELEMENTS(zmin) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),xx,-zmin)) ELSE maxix=nelx-1
        IF (N_ELEMENTS(zmax) GT 0) THEN minix=ROUND(interpol(findgen(nelx),xx,-zmax)) ELSE minix=0
        xx_plot=xx(minix:maxix)
        xx_plot=-reverse(xx_plot)
        temp1=nelx-maxix & temp2=nelx-minix
        minix=temp1-1
        maxix=temp2-1
     ENDIF ELSE BEGIN
        IF (N_ELEMENTS(zmin) GT 0) THEN minix=ROUND(interpol(findgen(nelx),xx,zmin)) ELSE minix=0
        IF (N_ELEMENTS(zmax) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),xx,zmax)) ELSE maxix=nelx-1
        xx_plot=xx(minix:maxix)
     ENDELSE
  ENDIF

  IF (N_ELEMENTS(ishift) GT 0) THEN var_plot=shift(var_plot,ishift)


  var_plot=var_plot(minix:maxix)

  var_max = MAX(var_plot, min=var_min, /NAN)
  IF (KEYWORD_SET(var_minmax))       THEN var_range=[var_min,var_max]
  PRINT, "------------------------------------------------------"
  PRINT, " ",ytitle+": "+strtrim(k,2)+' | '+strtrim(var_min,2)+' / '+strtrim(var_max,2)
  PRINT, "------------------------------------------------------"
  IF (N_ELEMENTS(showminmax) NE 0) THEN BEGIN
     final_title='['+strtrim(string(var_min),2)+'/'+strtrim(string(var_max),2)+'] '+title
  ENDIF ELSE final_title=title

  PLOT, xx_plot, var_plot,$
        xtitle=xtitle, ytitle=ytitle, title=final_title,$
        /xs, /ys, $
        position=position,$
        yrange=var_range, ylog=bar_log, $
        isotropic=isotropic, $
        linestyle=linestyle, $
        psym=psym, symsize=symsize

END
