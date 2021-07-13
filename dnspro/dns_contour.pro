PRO  DNS_CONTOUR, d, snaps, m, swap, $
                  c_var, c_levels,$
                  units=units,$
                  dim=dim, xx=xx,yy=yy,$
                  xmin=xmin,xmax=xmax,$
                  ymin=ymin, ymax=ymax,$
                  zmin=zmin, zmax=zmax,$
                  ishift=ishift, jshift=jshift, $
                  ixt=ixt,iyt=iyt,izt=izt,$
                  c_load=c_load,$
                  c_colors=c_colors,$
                  c_thick=c_thick, $
                  c_linestyle=c_linestyle, $
                  c_labels=c_labels, $
                  c_charsize=c_charsize, $
                  c_charthick=c_charthick, $
                  c_save=c_save,c_filename=c_filename

  
   nel=N_ELEMENTS(c_levels)
   tvlct, rgb, /get
   IF (N_ELEMENTS(c_load) EQ 0)      THEN LOAD, 39 ELSE LOAD, c_load
   IF (N_ELEMENTS(c_colors) EQ 0)    THEN c_colors=255+fltarr(nel)
   IF (NOT KEYWORD_SET(c_thick))     THEN c_thick=3+fltarr(nel)
   IF (NOT KEYWORD_SET(c_linestyle)) THEN c_linestyle=fltarr(nel)

   dns_var,d,c_var,snaps,swap,var,$
           units=units,$
           ixt=ixt,iyt=iyt,izt=izt, $
           xx=xx,yy=yy,zz=zz,$
           dim=dim


   IF (dim EQ "yz") THEN var = reform(var(m,*,*))
   IF (dim EQ "xz") THEN var = reform(var(*,m,*))
   IF (dim EQ "xy") THEN var = reform(var(*,*,m))

   DNS_PRE_2DPLOT, var,xx,yy,zz,dim,$
                   origin,scale,ishift=ishift,jshift=jshift,$
                   xmin=xmin,xmax=xmax,$
                   ymin=ymin,ymax=ymax,$
                   zmin=zmin,zmax=zmax


   IF (strpos(dim,"z") EQ 1) THEN yy=reverse(-yy)

   IF (N_ELEMENTS(c_save) GT 0) THEN BEGIN
      CONTOUR, reform(var),xx,yy,$
               levels=c_levels,c_colors=c_colors,$
               c_thick=c_thick,c_linestyle=c_linestyle, $
               c_labels=c_labels,c_charsize=c_charsize,$
               c_charthick=c_charthick, /overplot, $
               PATH_XY=xy, /PATH_DATA_COORDS
      folder = "contours"
      IF (NOT FILE_TEST(folder, /DIRECTORY)) THEN file_mkdir, folder
      IF (N_ELEMENTS(c_filename) EQ 0) THEN filename="/c_"+c_var+"_"+STRTRIM(snaps,2)+".sav" $
      ELSE filename="/c_"+c_filename+"_"+STRTRIM(snaps,2)+".sav"
      print, folder+filename
      save, xy, filename=folder+filename
   ENDIF ELSE BEGIN
      CONTOUR, reform(var),xx,yy,$
               levels=c_levels,c_colors=c_colors,$
               c_thick=c_thick,c_linestyle=c_linestyle, $
               c_labels=c_labels,c_charsize=c_charsize,$
               c_charthick=c_charthick, /overplot
   ENDELSE


   tvlct, rgb

END
