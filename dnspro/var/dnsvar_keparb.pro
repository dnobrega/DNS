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
       bxob = xup(bx)
       byob = yup(by)
       bzob = zup(bz)
       modb = sqrt(bxob^2+byob^2+bzob^2)
       ux   = zup(yup(d->getvar('ex',snaps,swap=swap)))
       uy   = xup(zup(d->getvar('ey',snaps,swap=swap)))
       uz   = yup(xup(d->getvar('ez',snaps,swap=swap)))
       var  = (uz*bzob+ux*bxob+uy*byob)/modb
       bxob = bx/xdn(modb)
       byob = by/ydn(modb)
       bzob = bz/zdn(modb)
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
       var  = sqrt(ux*ux + uy*uy + uz*uz)
       var_title='B x rot(E!d||B!n b)'
       IF (units EQ "solar") THEN BEGIN
          var = u.ub*var*(u.ul/u.ut*u.ub/3e10)/u.ul   ;  light speed in cm/s      
          var_title=var_title+" (G!u2!n cm!u-1!n)"
       ENDIF
       var_range=[1d-6,1.d6]
       var_log=1
    ENDELSE
END
