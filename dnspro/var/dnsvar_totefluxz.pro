PRO dnsvar_totefluxz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Kinetic+entalphy energy flux in z-direction: F_E',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_totefluxz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       uz=d->getvar("uz",snaps,swap=swap)

       r=d->getvar("r",snaps,swap=swap)
       u2=d->getvar("u2",snaps,swap=swap)
       var1=0.5*zdn(r*u2)

       e=d->getvar("e",snaps,swap=swap)
       var2 = zdn(e)
       pg=d->getvar("p",snaps,swap=swap)
       var3 = zdn(pg) 
       var=-(var1+var2+var3)*uz*u.ue*u.uu
       var_title='F!dEz!n' ; in the z face 
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (erg cm!u-2!n s!u-1!n)"
       ENDIF
       var_range=[-5.0,5.0]
       var_log=0
    ENDELSE
END
