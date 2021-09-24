PRO dnsvar_modsp_hyp, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Poynting flux only for the diffusion term: E_hyp x B',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_modsp_hyp, d, name, snaps, swap, var, units, ' $
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

       vari=xup(vari)
       varj=yup(varj)
       varz=zup(varz)

       var=sqrt(vari*vari + varj*varj + varz*varz)
       
       var_title='S!dp hyp!n'
       IF (units EQ "solar") THEN var_title=var_title+" (G!u2!n cm s!u-1!n)"
       var_range=[1d-5,1.d5]
       var_log=1
    ENDELSE
END
