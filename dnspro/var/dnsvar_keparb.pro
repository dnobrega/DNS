PRO dnsvar_keparb, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'K = B x Rot (E parallel to B b): keparb',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_eparb, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx   = d->getvar('bx',snaps,swap=swap)
       by   = d->getvar('by',snaps,swap=swap)
       bz   = d->getvar('bz',snaps,swap=swap)
       modb = sqrt(xup(bx)^2+yup(by)^2+zup(bz)^2)
       bxob = bx/xdn(modb)
       byob = by/ydn(modb)
       bzob = bz/zdn(modb)
       ux   = d->getvar('ex',snaps,swap=swap)
       uy   = d->getvar('ey',snaps,swap=swap)
       uz   = d->getvar('ez',snaps,swap=swap)
       var  = ((zup(uz*bz)+xup(ux*bx)+yup(uy*by))/modb) 
       ux   = var*bxob 
       uy   = var*byob
       uz   = var*bzob
       ; rot (E||B b) centered 
       bxob = ddydn(uz) - ddzdn(uy)
       bxob = zup(yup(bxob))
       byob = ddzdn(ux) - ddxdn(uz)
       byob = zup(xup(byob))
       bzob = ddxdn(uy) - ddydn(ux)
       bzob = xup(yup(bzob))
       ; B x rot (E||B b) centered
       ux   = yup(by)*bzob - zup(bz)*byob
       uy   = zup(bz)*bxob - xup(bx)*bzob
       uz   = xup(bx)*byob - yup(by)*bxob
       var  = sqrt(ux*ux + uy*uy + uz*uz)*u.ub*u.ub/u.ul
       var_title='B x rot(E!d||B!n b)'
       IF (units EQ "solar") THEN var_title=var_title+" (G!u2!n cm!u-1!n)"
       var_range=[1d-6,1.d6]
       var_log=1
    ENDELSE
END
