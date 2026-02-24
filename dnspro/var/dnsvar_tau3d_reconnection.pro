PRO dnsvar_tau3d_reconnection, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'b x curl(Eparb)/B',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_tau3d_reconnection, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx   = xup(d->getvar('bx',snaps,swap=swap))
       by   = yup(d->getvar('by',snaps,swap=swap))
       bz   = zup(d->getvar('bz',snaps,swap=swap))
       modb = sqrt(bx^2.0+by^2.0+bz^2.0)
       bx   = bx/modb
       by   = by/modb
       bz   = bz/modb
       ; E (centered)
       ex   = zup(yup(d->getvar('ex',snaps,swap=swap)))
       ey   = xup(zup(d->getvar('ey',snaps,swap=swap)))
       ez   = yup(xup(d->getvar('ez',snaps,swap=swap)))
       ; E parallel centered
       eparb  = ex*bx+ey*by+ez*bz
       ; E parallel (no centered)
       ex   = xdn(eparb*bx)
       ey   = ydn(eparb*by)
       ez   = zdn(eparb*bz)
       ; rot (E||B b) centered 
       scr1 = ddydn(ez) - ddzdn(ey)
       scr1 = zup(yup(scr1))
       scr2 = ddzdn(ex) - ddxdn(ez)
       scr2 = zup(xup(scr2))
       scr3 = ddxdn(ey) - ddydn(ex)
       scr3 = xup(yup(scr3))
       ; B x rot (E||B b) centered
       ex   = by*scr3 - bz*scr2
       ey   = bz*scr1 - bx*scr3
       ez   = bx*scr2 - by*scr1
       var  = sqrt(ex*ex + ey*ey + ez*ez)/modb/u.ut
       var_title='b x curl(E!d||B!nb)/B'
       IF (units EQ "solar") THEN var_title=var_title+" (s!u-1!n)"
       var_range=[2d-3,1.d]
       var_log=1
    ENDELSE
END
