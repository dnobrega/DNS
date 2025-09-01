PRO create_instr_response, instr

IF (NOT (KEYWORD_SET(ne0)))       THEN ne0=7.5
IF (NOT (KEYWORD_SET(nef)))       THEN nef=12.5
IF (NOT (KEYWORD_SET(nst)))       THEN nst=0.05


nne  = (nef-ne0)/nst + 1
IF (nne LT 2.0) THEN density = ne0 ELSE density = (ne0 + (nef-ne0)*findgen(nne)/(nne-1))

inst = STRLOWCASE(instr)
CASE 1 OF
   STRMATCH(inst, '*aia*'): BEGIN
      ch   = STREGEX(inst, '(94|131|171|193|211|304|335)', /EXTRACT)
      IF ch EQ '' THEN MESSAGE, 'Wrong AIA channel.'

      wave_resp = aia_get_response(/dn)

      CASE ch OF
         '94' : BEGIN
            ea         = wave_resp.a94.EA
            wave       = wave_resp.a94.WAVE
            platescale = wave_resp.a94.PLATESCALE[0]
         END
         '131' : BEGIN
            ea         = wave_resp.a131.EA
            wave       = wave_resp.a131.WAVE
            platescale = wave_resp.a131.PLATESCALE[0]
         END
         '171' : BEGIN
            ea         = wave_resp.a171.EA
            wave       = wave_resp.a171.WAVE
            platescale = wave_resp.a171.PLATESCALE[0]
         END
         '193' : BEGIN
            ea         = wave_resp.a193.EA
            wave       = wave_resp.a193.WAVE
            platescale = wave_resp.a193.PLATESCALE[0]
         END
         '211' : BEGIN
            ea         = wave_resp.a211.EA
            wave       = wave_resp.a211.WAVE
            platescale = wave_resp.a211.PLATESCALE[0]
         END
         '304' : BEGIN
            ea         = wave_resp.a304.EA
            wave       = wave_resp.a304.WAVE
            platescale = wave_resp.a304.PLATESCALE[0]
         END
         '335' : BEGIN
            ea         = wave_resp.a335.EA
            wave       = wave_resp.a335.WAVE
            platescale = wave_resp.a335.PLATESCALE[0]
         END
      ENDCASE
      wv0 = 0
      wvf = -1
  END

  STRMATCH(inst, '*muse*'): BEGIN
     print, "Not implemented yet"
     STOP
  END

  STRMATCH(inst, '*xrt*'): BEGIN
     filters = ['al-mesh','al-poly','c-poly','ti-poly','be-thin','be-med','al-med','al-thick','be-thick']

     idx = -1L
     FOR k=0, N_ELEMENTS(filters)-1 DO BEGIN
        IF STRPOS(inst, filters[k]) NE -1 THEN BEGIN
           idx = k
           BREAK
        ENDIF
     ENDFOR
     IF idx EQ -1 THEN MESSAGE, 'XRT: wrong filter'
     wave_resp = make_xrt_wave_resp(contam_time='2023-Mar-01 09:00:00')
     ea         = wave_resp[idx].SPRSP.SPEC_RESP[0:990]
     wave       = wave_resp[idx].effar.WAVE[0:990]
     platescale = 1.0
     wv0        = 0
     wvf        = 1980
  END

  STRMATCH(inst, '*solar-c*'): BEGIN
     print, "Not implemented yet"
     STOP
  END

  ELSE: MESSAGE, 'Instrument not recognized: ' + instr
ENDCASE

kk       = 0
dens     = density[kk]
filename = "isothermal_" + STRING(dens, FORMAT='(F0.2)') + ".sav"
restore, filename
ntg      = N_ELEMENTS(temp)
table    = FLTARR(nne, ntg)
filter   = interpol(ea, wave, lambda)
sp_conv  = 0.0*spectrum
FOR i = 0, ntg-1 DO sp_conv[*, i] = platescale*spectrum[*,i]*filter
table[kk,*] = total(sp_conv,1)

IF NNE GT 1 THEN BEGIN
   FOR kk=1,nne-1,1 DO BEGIN
      dens     = density[kk]
      filename = "isothermal_" + STRING(dens, FORMAT='(F0.2)') + ".sav"
      restore, filename
      filter   = interpol(ea, wave, lambda[wv0 : wvf])
      sp_conv  = 0.0*spectrum[wv0 : wvf,*]
      FOR i = 0, ntg-1 DO sp_conv[*, i] = platescale*spectrum[*,i]*filter
      table[kk,*] = total(sp_conv,1)
   ENDFOR
ENDIF
temperature = temp
table[where(table LT  0)] = 0.0
save, density, temperature, table, filename=instr+"_response_ne_tg.sav"


END
