PRO dnsvar_nuac, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Explain here',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_nuac, d, name, snaps, swap, var, units ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar("cs",snaps,swap=swap)*u.ul/u.ut ; CGS
       var=1/(4*!PI*var) ; finish this
       var_title='Title'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (km s!u-1!n)" ; Fix this
          var=var/1e5                         ; Check this
       ENDIF
       var_range=[1.d-1,1.d1] ; cambiar
       var_log=1 ; cambiar
    ENDELSE
END
