PRO DNS_OLINE, ostyle=ostyle, othick=othick, ocolor=ocolor,$
               ox=ox, oy=oy, $
               dim=dim, x=x, y=y, $
               var_range=var_range

   IF (N_ELEMENTS(ocolor) EQ 0) THEN ocolor=255
   IF (NOT KEYWORD_SET(othick)) THEN othick=3
   IF (NOT KEYWORD_SET(ostyle)) THEN ostyle=2

   xx=x
   IF (dim EQ 'xy') THEN yy=y ELSE yy=-y
   IF (strlen(dim) EQ 1) THEN o_range=var_range ELSE o_range=[min(yy),max(yy)]


   nox=N_ELEMENTS(ox)
   noy=N_ELEMENTS(oy)
   IF (nox+noy GT 0) THEN BEGIN
      IF (noy EQ 0) THEN BEGIN
         sz=size(ox,/structure)
         IF (N_ELEMENTS(ocolor) EQ 1) THEN ocolor=ocolor+fltarr(sz.n_elements/sz.n_dimensions)
         IF (N_ELEMENTS(othick) EQ 1) THEN othick=othick+fltarr(sz.n_elements/sz.n_dimensions)
         IF (N_ELEMENTS(ostyle) EQ 1) THEN ostyle=ostyle+fltarr(sz.n_elements/sz.n_dimensions)
         FOR kk=0, sz.n_elements/sz.n_dimensions-1 DO BEGIN
               oplot, ox(kk)*[1,1], o_range, color=ocolor(kk), line=ostyle(kk),thick=othick(kk)
         ENDFOR
      ENDIF
      IF (nox EQ 0) THEN BEGIN
         sz=size(oy,/structure)
         IF (N_ELEMENTS(ocolor) EQ 1) THEN ocolor=ocolor+fltarr(sz.n_elements/sz.n_dimensions)
         IF (N_ELEMENTS(othick) EQ 1) THEN othick=othick+fltarr(sz.n_elements/sz.n_dimensions)
         IF (N_ELEMENTS(ostyle) EQ 1) THEN ostyle=ostyle+fltarr(sz.n_elements/sz.n_dimensions)
         FOR kk=0, sz.n_elements/sz.n_dimensions-1 DO BEGIN
               oplot, [min(xx),max(xx)], oy(kk)*[1,1], color=ocolor(kk), line=ostyle(kk),thick=othick(kk)
         ENDFOR
      ENDIF
      IF (nox*noy GT 0) THEN BEGIN
         sz_ox=size(ox,/structure)
         sz_oy=size(oy,/structure)
         IF (sz_ox.n_elements NE sz_oy.n_elements) THEN BEGIN
            print, "ox and oy do not have the same number of elements"
            STOP
         ENDIF
         oplot, ox, oy, color=ocolor, line=ostyle,thick=othick
      ENDIF
   ENDIF ELSE BEGIN
      IF (dim EQ 'xz') THEN BEGIN 
         oplot, [min(xx),max(xx)], [0,0], color=ocolor, line=ostyle,thick=othick
      ENDIF
   ENDELSE


END
