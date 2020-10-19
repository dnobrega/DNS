PRO DNS_OPLOT_LINE, o_x=o_x, o_y=o_y, $
                    o_linestyle=o_linestyle, o_thick=o_thick, $
                    o_load=o_load, o_color=o_color

   IF (NOT KEYWORD_SET(o_load))    THEN o_load=39
   IF (N_ELEMENTS(o_color) EQ 0)   THEN o_color=255
   IF (NOT KEYWORD_SET(o_thick))   THEN o_thick=3
   IF (NOT KEYWORD_SET(o_linestyle))   THEN o_linestyle=2

   tvlct, rgb, /get
   LOAD, o_load, /SILENT

   nox=N_ELEMENTS(o_x)
   noy=N_ELEMENTS(o_y)
   IF (nox+noy GT 0) THEN BEGIN
      IF (noy EQ 0) THEN BEGIN
         sz=size(o_x,/structure)
         IF (N_ELEMENTS(o_color) EQ 1) THEN o_color=o_color+fltarr(sz.n_elements/sz.n_dimensions)
         IF (N_ELEMENTS(o_thick) EQ 1) THEN o_thick=o_thick+fltarr(sz.n_elements/sz.n_dimensions)
         IF (N_ELEMENTS(o_linestyle) EQ 1) THEN o_linestyle=o_linestyle+fltarr(sz.n_elements/sz.n_dimensions)
         FOR kk=0, sz.n_elements/sz.n_dimensions-1 DO BEGIN
               oplot, o_x(kk)*[1,1], !Y.crange, $
                      color=o_color(kk), line=o_linestyle(kk), thick=o_thick(kk)
         ENDFOR
      ENDIF
      IF (nox EQ 0) THEN BEGIN
         sz=size(o_y,/structure)
         IF (N_ELEMENTS(o_color) EQ 1) THEN o_color=o_color+fltarr(sz.n_elements/sz.n_dimensions)
         IF (N_ELEMENTS(o_thick) EQ 1) THEN o_thick=o_thick+fltarr(sz.n_elements/sz.n_dimensions)
         IF (N_ELEMENTS(o_linestyle) EQ 1) THEN o_linestyle=o_linestyle+fltarr(sz.n_elements/sz.n_dimensions)
         FOR kk=0, sz.n_elements/sz.n_dimensions-1 DO BEGIN
               oplot, !X.crange, o_y(kk)*[1,1], $
                      color=o_color(kk), line=o_linestyle(kk), thick=o_thick(kk)
         ENDFOR
      ENDIF
      IF (nox*noy NE 0) THEN BEGIN
         sz_ox=size(o_x,/structure)
         sz_oy=size(o_y,/structure)
         IF (sz_ox.n_elements NE sz_oy.n_elements) THEN BEGIN
            print, "o_x and o_y do not have the same number of elements"
            STOP
         ENDIF
         oplot, o_x, o_y, color=o_color, line=o_linestyle, thick=o_thick
      ENDIF
   ENDIF

   tvlct, rgb

END
