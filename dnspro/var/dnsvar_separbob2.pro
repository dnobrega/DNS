PRO dnsvar_separbob2, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 's = B . Rot (E parallel to B b)/B2: separbob2',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_separbob2, d, name, snaps, swap, var, units, ' $
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
       ux   = xdn(var)*bxob 
       uy   = ydn(var)*byob
       uz   = zdn(var)*bzob
       ; rot (E||B b) centered 
       bxob = ddydn(uz) - ddzdn(uy)
       bxob = zup(yup(bxob))
       byob = ddzdn(ux) - ddxdn(uz)
       byob = zup(xup(byob))
       bzob = ddxdn(uy) - ddydn(ux)
       bzob = xup(yup(bzob))
       ; B x rot (E||B b) centered
       ux   = bxob*xup(bx)
       uy   = byob*yup(by)
       uz   = bzob*zup(bz)
       var  = abs((ux + uy + uz)/modb/modb)
       var_title="B.rot(E!d||B!n b)/B!u2!n"
       IF (units EQ "solar") THEN BEGIN
          var = var/1e3
          var_title=var_title+" (km!u-1!n)"
       ENDIF
       var_range=[1d-6,1.d6]
       var_log=1
    ENDELSE
END
