PRO dnsvar_fnh2_neq, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Hydrogen molecular fraction: fnh2',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_fnh2, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       nn=d->getvar('n1',snaps,swap=swap)
       FOR k=2,6 DO nn=nn+d->getvar('n'+strtrim(string(k),2),snaps)
       var=d->getvar('nh2',snaps,swap=swap)
       var=2*var/(2*var+nn)
       var_title='f!dnH2!n'
       var_range=[1d-3,1.0]
       var_log=1
    ENDELSE
END
