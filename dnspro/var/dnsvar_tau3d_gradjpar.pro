PRO dnsvar_tau3d_gradjpar, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, '|b times eta (gradjpar x b)|/B',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_tau3d_gradj, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       ; Unit vector
       bx   = d->getvar('bx',snaps,swap=swap)
       by   = d->getvar('by',snaps,swap=swap)
       bz   = d->getvar('bz',snaps,swap=swap)
       bxob = xup(bx)                         
       byob = yup(by)
       bzob = zup(bz)
       modb = sqrt(bxob^2+byob^2+bzob^2) ;modb centered
       bxob = bx/modb                    ;unit vector x
       byob = by/modb                    ;unit vector y 
       bzob = bz/modb                    ;unit vector z
       ; J par (centered)
       jx   = zup(yup(d->getvar('jx',snaps,swap=swap)))
       jy   = xup(zup(d->getvar('jy',snaps,swap=swap)))
       jz   = yup(xup(d->getvar('jz',snaps,swap=swap)))
       j2   = jx*jx + jy*jy + jz*jz
       jpar = (jz*bzob+jx*bxob+jy*byob)
       jparx = xup(ddxdn(jpar))
       jpary = yup(ddydn(jpar))
       jparz = zup(ddzdn(jpar))
       ; gradeta (centered)
       qj   = d->getvar('qjoule',snaps,swap=swap)
       eta  = qj/j2
       
       ; eta (nabla J x b) (centered)
       ux   = eta*(jpary*bzob - jparz*byob)
       uy   = eta*(jparz*bxob - jparx*bzob)
       uz   = eta*(jparx*byob - jpary*bxob)

       ; b x () (centered)
       ux   = (uy*bzob - uz*byob)
       uy   = (uz*bxob - ux*bzob)
       uz   = (ux*byob - uy*bxob)
       var  = sqrt(ux*ux + uy*uy + uz*uz)/modb/u.ut
       var_title='|b x eta(gradJ!dpar!n x b)|/B'
       IF (units EQ "solar") THEN var_title=var_title+" (s!u-1!n)"
       var_range=[2d-3,1d]
       var_log=1
    ENDELSE
END
