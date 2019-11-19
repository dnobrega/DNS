PRO DNS_OLINE, ostyle=ostyle, othick=othick, ocolor=ocolor,$
               ox=ox, oy=oy, $
               dim=dim, x=x, y=y, z=z



   IF (NOT KEYWORD_SET(ocolor)) THEN ocolor=255
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
      IF (NOT KEYWORD_SET(oy)) THEN oplot, ox, [min(yy),max(yy)], color=ocolor, line=ostyle,thick=othick
      IF (NOT KEYWORD_SET(ox)) THEN oplot, [min(xx),max(xx)], oy, color=ocolor, line=ostyle,thick=othick
      IF (KEYWORD_SET(ox) AND KEYWORD_SET(oy)) THEN oplot, ox, oy, color=ocolor, line=ostyle,thick=othick
   ENDIF ELSE BEGIN
      IF (dim EQ 'xz') THEN BEGIN 
         oplot, [min(xx),max(xx)], [0,0], color=ocolor, line=ostyle,thick=othick
      ENDIF
   ENDELSE


END
