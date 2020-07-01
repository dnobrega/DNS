PRO dns_1dplot, d,k,var_plot,dim, $
                bar_log=bar_log,$
                xx=xx, yy=yy, zz=zz,$
                xtitle=xtitle, ytitle=ytitle, title=title,$
                xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
                ishift=ishift,$
                position=position,$
                xcharsize=xcharsize, ycharsize=ycharsize,$
                var_range=var_range,  $
                isotropic=isotropic,$
                oline=oline,$
                ostyle=ostyle, othick=othick, ocolor=ocolor,$
                ox=ox, oy=oy


  nelx=n_elements(xx)
  nely=n_elements(yy)
  nelz=n_elements(zz)

  IF (dim EQ "x") THEN BEGIN
     IF (N_ELEMENTS(xmin) GT 0) THEN minix=ROUND(interpol(findgen(nelx),xx,xmin)) ELSE minix=0
     IF (N_ELEMENTS(xmax) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),xx,xmax)) ELSE maxix=nelx-1
     xx_plot=xx(minix:maxix)
  ENDIF

  IF (dim EQ "y") THEN BEGIN
     IF (N_ELEMENTS(ymin) GT 0) THEN minix=ROUND(interpol(findgen(nelx),xx,ymin)) ELSE minix=0
     IF (N_ELEMENTS(ymax) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),xx,ymax)) ELSE maxix=nelx-1
     xx_plot=xx(minix:maxix)
  ENDIF

  IF (dim EQ "z") THEN BEGIN
     IF (N_ELEMENTS(zmin) GT 0) THEN maxix=ROUND(interpol(findgen(nelx),xx,-zmin)) ELSE maxix=nelx-1
     IF (N_ELEMENTS(zmax) GT 0) THEN minix=ROUND(interpol(findgen(nelx),xx,-zmax)) ELSE minix=0
     xx_plot=xx(minix:maxix)
     xx_plot=-reverse(xx_plot)
     temp1=nelx-maxix & temp2=nelx-minix
     minix=temp1-1
     maxix=temp2-1
  ENDIF

  IF (N_ELEMENTS(ishift) GT 0) THEN var_plot=shift(var_plot,ishift)

  var_plot=var_plot(minix:maxix)

  PLOT, xx_plot, var_plot,$
        xtitle=xtitle, ytitle=ytitle, title=title,$
        /xs, /ys, $
        position=position,$
        xcharsize=xcharsize, ycharsize=ycharsize,$
        yrange=var_range, ylog=bar_log, $
        isotropic=isotropic


END
