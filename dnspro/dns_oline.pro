PRO DNS_OLINE, ostyle=ostyle, othick=othick, ocolor=ocolor,$
               ox=ox, oy=oy, $
               dim=dim, x=x, y=y, z=z



   IF (N_ELEMENTS(ocolor) EQ 0) THEN ocolor=255
   IF (NOT KEYWORD_SET(othick)) THEN othick=3
   IF (NOT KEYWORD_SET(ostyle)) THEN ostyle=2

   IF (dim EQ 'xz') THEN BEGIN
      xx=x
      yy=-z
   ENDIF

   IF (dim EQ 'yz') THEN BEGIN
      xx=y
      yy=-z
   ENDIF

   IF (dim EQ 'xy') THEN BEGIN
      xx=x
      yy=y
   ENDIF

   IF (KEYWORD_SET(ox)) OR (KEYWORD_SET(oy)) THEN BEGIN
      IF (NOT KEYWORD_SET(oy)) THEN BEGIN
         sz=size(ox,/structure)
         IF (N_ELEMENTS(ocolor) EQ 1) THEN ocolor=ocolor+fltarr(sz.n_elements/sz.n_dimensions)
         IF (N_ELEMENTS(othick) EQ 1) THEN othick=othick+fltarr(sz.n_elements/sz.n_dimensions)
         IF (N_ELEMENTS(ostyle) EQ 1) THEN ostyle=ostyle+fltarr(sz.n_elements/sz.n_dimensions)
         FOR kk=0, sz.n_elements/sz.n_dimensions-1 DO BEGIN
            oplot, ox(*,kk), [min(yy),max(yy)], color=ocolor(kk), line=ostyle(kk),thick=othick(kk)
         ENDFOR
      ENDIF
      IF (NOT KEYWORD_SET(ox)) THEN BEGIN
         sz=size(oy,/structure)
         IF (N_ELEMENTS(ocolor) EQ 1) THEN ocolor=ocolor+fltarr(sz.n_elements/sz.n_dimensions)
         IF (N_ELEMENTS(othick) EQ 1) THEN othick=othick+fltarr(sz.n_elements/sz.n_dimensions)
         IF (N_ELEMENTS(ostyle) EQ 1) THEN ostyle=ostyle+fltarr(sz.n_elements/sz.n_dimensions)
         FOR kk=0, sz.n_elements/sz.n_dimensions-1 DO BEGIN
            oplot, [min(xx),max(xx)], oy(*,kk), color=ocolor(kk), line=ostyle(kk),thick=othick(kk)
         ENDFOR
      ENDIF
      IF (KEYWORD_SET(ox) AND KEYWORD_SET(oy)) THEN BEGIN
         sz_ox=size(ox,/structure)
         sz_oy=size(oy,/structure)
         IF (sz_ox.n_elements NE sz_oy.n_elements) THEN BEGIN
            print, "ox and oy do not have the same number of elements"
            STOP
         ENDIF
         IF (N_ELEMENTS(ocolor) EQ 1) THEN ocolor=ocolor+fltarr(sz_ox.n_elements/sz_ox.n_dimensions)
         IF (N_ELEMENTS(othick) EQ 1) THEN othick=othick+fltarr(sz_ox.n_elements/sz_ox.n_dimensions)
         IF (N_ELEMENTS(ostyle) EQ 1) THEN ostyle=ostyle+fltarr(sz_ox.n_elements/sz_ox.n_dimensions)
         FOR kk=0, sz_ox.n_elements/sz_ox.n_dimensions-1 DO BEGIN
            oplot, ox(*,kk), oy(*,kk), color=ocolor(kk), line=ostyle(kk),thick=othick(kk)
         ENDFOR
      ENDIF
   ENDIF ELSE BEGIN
      IF (dim EQ 'xz') THEN BEGIN 
         oplot, [min(xx),max(xx)], [0,0], color=ocolor, line=ostyle,thick=othick
      ENDIF
   ENDELSE


END
