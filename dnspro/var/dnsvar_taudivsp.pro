PRO dnsvar_taudivsp, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Characteristic time of the divergence of the Poynting flux',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_taudivsp, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       ex=d->getvar("ex",snaps,swap=swap)*u.uu*u.ub
       ey=d->getvar("ey",snaps,swap=swap)*u.uu*u.ub
       ez=d->getvar("ez",snaps,swap=swap)*u.uu*u.ub
       
       bx=d->getvar("bx",snaps,swap=swap)*u.ub
       by=d->getvar("by",snaps,swap=swap)*u.ub
       bz=d->getvar("bz",snaps,swap=swap)*u.ub

       vari=zdn(ey)*bz-ydn(ez)*by
       varj=xdn(ez)*bx-zdn(ex)*bz
       vark=ydn(ex)*by-xdn(ey)*bx

       var=(ddxup(vari)+ddyup(varj)+ddzup(vark))/u.ul

       e=d->getvar("e",snaps,swap=swap)*u.ue
       var=e/ABS(var + 1d-30)
       
       var_title='!4s!3!ddiv(Sp)!n'
       IF (units EQ "solar") THEN var_title=var_title+" (s)"
       var_range=[1d-1,1.d3]
       var_log=1
    ENDELSE
END
