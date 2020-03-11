PRO dnsvar_e193, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Emissivity of Fe XII 193 (CGS)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_e193, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       br_iion,"fe12_193_p", d, snaps
       var=reform(d->getvar())
       var_title='!4e!3 Fe XII 193 (CGS)'
       var_range=[1d-8,5d-7]
       var_log=1
    ENDELSE
END
