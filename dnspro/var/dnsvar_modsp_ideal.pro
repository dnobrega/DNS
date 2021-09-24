PRO dnsvar_modsp_ideal, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Module of the Poynting flux with no diffusion: |ExB|',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_modsp_ideal, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       ux=d->getvar("ux",snaps,swap=swap)*u.uu
       uy=d->getvar("uy",snaps,swap=swap)*u.uu
       uz=d->getvar("uz",snaps,swap=swap)*u.uu
       
       bx=d->getvar("bx",snaps,swap=swap)*u.ub
       by=d->getvar("by",snaps,swap=swap)*u.ub
       bz=d->getvar("bz",snaps,swap=swap)*u.ub

       vari=yup(uy)*zup(bz)-zup(uz)*yup(by)
       varj=zup(uz)*xup(bx)-xup(ux)*zup(bz)
       vark=xup(ux)*yup(by)-yup(uy)*xup(bx)
       
       var=sqrt(vari*vari+varj*varj+vark*vark)

       var_title='S!dp!n'
       IF (units EQ "solar") THEN var_title=var_title+" (G!u2!n cm s!u-1!n)"
       var_range=[1.d6,1.d12]
       var_log=1
    ENDELSE
END
