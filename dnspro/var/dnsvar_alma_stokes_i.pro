PRO dnsvar_alma_stokes_i, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'ALMA synthetic Stokes I (K)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_alma_stokes_i, d, name, snaps, swap, var, units,' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       f=alma_synthfiles()
       ssnaps=strtrim(string(snaps),2)
       wh=where(strpos(f, ssnaps+"_int") GT -1)
       IF wh EQ -1 THEN BEGIN
          PRINT, "Synthetic file for snapshot",ssnaps," not found."
          PRINT, "The available synthetic files are", f
          STOP
       ENDIF ELSE BEGIN
          var=transpose(alma_readsynth(f(wh), "Stokes_I"),[1,2,0])
          var_title='Stokes I (K)'
          var_range=[1d3,1d5]
          var_log=1
       ENDELSE
    ENDELSE
END
