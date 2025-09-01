PRO create_isothermal_files, ne0=ne0, nef=nef, nst=nst, wv0=wv0, wvf=wvf, wst=wst, abundance=abundance
;----------------------------------------------------------------------------------------
; HELP
;----------------------------------------------------------------------------------------
;
; ne0: Lower limit for the electron number density in log10.
;      By default, 7.5.
; nef: Upper limit for the electron number density in log10.
;      By default, 12.5.
; nst: Step for the electron number density axis.
;      By default, 0.05.
; wv0: Lower limit for the wavelength.
;      By default 1.0 A
; wvf: Upper limit for the wavelength.
;      By default, 1000 A
; wst: Step for the wavelength axis
;      By default 0.1 A
;
; abundance: abundance file from CHIANTI.
;            By default sun_coronal_2021_chianti.abund
; 
; OUTPUT:
; A file for each density called "isothermal_"+ne+".sav" 
;----------------------------------------------------------------------------------------
IF (NOT (KEYWORD_SET(ntg0)))      THEN ntg0=4.0
IF (NOT (KEYWORD_SET(ntgf)))      THEN ntgf=8.0
IF (NOT (KEYWORD_SET(ntg)))       THEN ntg=81
IF (NOT (KEYWORD_SET(ne0)))       THEN ne0=7.5
IF (NOT (KEYWORD_SET(nef)))       THEN nef=12.5
IF (NOT (KEYWORD_SET(nst)))       THEN nst=0.05
IF (NOT (KEYWORD_SET(wv0)))       THEN wv0=1.0
IF (NOT (KEYWORD_SET(wvf)))       THEN wvf=1000.0
IF (NOT (KEYWORD_SET(wst)))       THEN wst=0.1
IF (NOT (KEYWORD_SET(abundance))) THEN abundance="sun_coronal_2021_chianti.abund"
;----------------------------------------------------------------------------------------
abund_fold = GETENV('SSW')+"/packages/chianti/dbase/abundance/"
ch_version = ch_get_version()
nne        = (nef-ne0)/nst + 1
IF (nne LT 2.0) THEN density = ne0 ELSE density = (ne0 + (nef-ne0)*findgen(nne)/(nne-1))
temp       = (ntg0 + (ntgf-ntg0)*findgen(ntg)/(ntg-1))
;----------------------------------------------------------------------------------------
FOR kk=0,nne-1,1 DO BEGIN
    print, strtrim(string(kk),2)+"/"+strtrim(string(fix(nne)),2)
    isothermal, wv0, wvf, wst, 10.0^temp, $
                lambda, spectrum, list_wvl, list_ident, $
                edensity = 10.0^density[kk], /photons, /cont, ABUND_NAME=abund_fold+abundance
    dens     = density[kk]
    filename = "isothermal_" + STRING(dens, FORMAT='(F0.2)') + ".sav"
    print, filename
    save, temp, dens, lambda, spectrum, list_wvl, ch_version, abundance, $
          filename=filename
ENDFOR
;----------------------------------------------------------------------------------------
END
