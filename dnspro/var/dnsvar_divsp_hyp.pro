PRO dnsvar_divsp_hyp, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Divergence of the Poynting flux (2D case only hyp)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_divsp_hyp, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       etay=d->getvar("etay",snaps,swap=swap)*u.uu*u.ub
       bx=d->getvar("bx",snaps,swap=swap)*u.ub
       bz=d->getvar("bz",snaps,swap=swap)*u.ub
       varx=xdn(etay)*bx
       varz=zdn(etay)*bz
       var=(ddxup(varx)+ddzup(varz))/u.ul
       var_title='div(S!dp!n Ohm)'
       IF (units EQ "solar") THEN var_title=var_title+" (CGS)"
       var_range=[-1.0,1.0]*1d-1
       var_log=0
    ENDELSE
END
