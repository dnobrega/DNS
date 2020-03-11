PRO  DNS_CONTOUR, d, snaps, swap, $
                  c_var, c_levels,$
                  dim=dim, x=x,y=y,z=z, $
                  ishift=ishift, jshift=jshift, $
                  ixt=ixt,iyt=iyt,izt=izt,sim3d=sim3d,$
                  c_load=c_load,$
                  c_colors=c_colors,$
                  c_thick=c_thick, $
                  c_linestyle=c_linestyle

  
   nel=N_ELEMENTS(c_levels)
   tvlct, rgb, /get
   IF (N_ELEMENTS(c_load) EQ 0)      THEN LOAD, 39 ELSE LOAD, c_load
   IF (N_ELEMENTS(c_colors) EQ 0)    THEN c_colors=255+fltarr(nel)
   IF (NOT KEYWORD_SET(c_thick))     THEN c_thick=3+fltarr(nel)
   IF (NOT KEYWORD_SET(c_linestyle)) THEN c_linestyle=fltarr(nel)


   dns_var,d,c_var,snaps,swap,var,$
           ixt=ixt,iyt=iyt,izt=izt, $
           sim3d=sim3d, dim=dim

   IF (dim EQ 'xz') THEN BEGIN
      xx=x
      yy=-z
      IF (N_ELEMENTS(ishift) GT 0) THEN var=shift(var,ishift,0)
   ENDIF

   IF (dim EQ 'yz') THEN BEGIN
      xx=y
      yy=-z
      IF (N_ELEMENTS(jshift) GT 0) THEN var=shift(var,jshift,0)
   ENDIF

   IF (dim EQ 'xy') THEN BEGIN
      xx=x
      yy=y
      IF (N_ELEMENTS(ishift) GT 0) THEN var=shift(var,ishift,0)
      IF (N_ELEMENTS(jshift) GT 0) THEN var=shift(var,0,jshift)
   ENDIF

   help, var
   help, ishift
   CONTOUR, reform(var),xx,yy,$
            levels=c_levels,c_colors=c_colors,$
            c_thick=c_thick,c_linestyle=c_linestyle,$
            /overplot


   tvlct, rgb

END
