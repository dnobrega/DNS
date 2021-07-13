PRO dnsvar_e174, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Emissivity of Fe X 174',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_e174, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       br_iion,"fe10_174_p", d, snaps
       var=reform(d->getvar())
       var_title='!4e!3 Fe X 174 (CGS)'
       var_range=[1d-8,5d-7]
       var_log=1
    ENDELSE
END
