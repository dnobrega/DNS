PRO dnsvar_divsp_hyp, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Divergence of the Poynting flux only for the diffusion term: E_hyp x B',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_divsp_hyp, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       ex=d->getvar("etax",snaps,swap=swap)*u.uu*u.ub
       ey=d->getvar("etay",snaps,swap=swap)*u.uu*u.ub
       ez=d->getvar("etaz",snaps,swap=swap)*u.uu*u.ub
       
       bx=d->getvar("bx",snaps,swap=swap)*u.ub
       by=d->getvar("by",snaps,swap=swap)*u.ub
       bz=d->getvar("bz",snaps,swap=swap)*u.ub

       vari=zdn(ey)*bz-ydn(ez)*by
       varj=xdn(ez)*bx-zdn(ex)*bz
       vark=ydn(ex)*by-xdn(ey)*bx

       var=(ddxup(vari)+ddyup(varj)+ddzup(vark))/u.ul

       var_title='div(S!dp hyp!n)'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n s!u-1!n)"
       var_range=[-1.0,1.0]*1d-1
       var_log=0
    ENDELSE
END
