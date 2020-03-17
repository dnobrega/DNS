PRO  DNS_CONTOUR, d, snaps, swap, $
                  c_var, c_levels,$
                  dim=dim, xx=xx,yy=yy,$
                  ishift=ishift, jshift=jshift, $
                  ixt=ixt,iyt=iyt,izt=izt,$
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
           dim=dim,$
           xx=xx,yy=yy

   IF (strpos(dim,"z") EQ 1) THEN yy=reverse(-yy)

   CONTOUR, reform(var),xx,yy,$
            levels=c_levels,c_colors=c_colors,$
            c_thick=c_thick,c_linestyle=c_linestyle,$
            /overplot
   tvlct, rgb

END
