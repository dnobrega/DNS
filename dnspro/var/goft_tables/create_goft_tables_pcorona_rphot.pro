PRO create_goft_tables_pcorona_rphot, caso, ntg=ntg, ne0=ne0, nef=nef, nst=nst
;----------------------------------------------------------------------------------------
; HELP
;----------------------------------------------------------------------------------------
;
; caso: Case to select.
;
; OPTIONAL:
;
; ntg: Number of elements in Tg. 
;      By default, 101: the number of elements by default by CHIANTI.
;      So far, the routine is not prepared for a different value.   
; ne0: Lower limit for the electron number density in log10.
;      By default, 7.5.
; nef: Upper limit for the electron number density in log10.
;      By default, 12.5.
; nst: Step for the electron number density axis.
;      By default, 0.05.
;  
; OUTPUT:
; A table called "table_"+line+"rphot_"+radtemp+".sav" with axis density and temeprature
;----------------------------------------------------------------------------------------
IF (NOT (KEYWORD_SET(ntg))) THEN ntg=101
IF (NOT (KEYWORD_SET(ne0))) THEN ne0=7.5
IF (NOT (KEYWORD_SET(nef))) THEN nef=12.5
IF (NOT (KEYWORD_SET(nst))) THEN nst=0.05
IF (NOT (KEYWORD_SET(nz)))  THEN nz=51
;----------------------------------------------------------------------------------------

CASE caso OF
   1: BEGIN
      sngl_ion = "fe_13"
      wvl0     = 10749.0
      wvlf     = 10750.0
      line     = "fe_13_10749.5"
      radtemp  = 6108.276 ; 6000
   END
   2: BEGIN
      sngl_ion = "fe_13"
      wvl0     = 10800.0
      wvlf     = 10802.0
      line     = "fe_13_10801.77"
      radtemp  = 6110.764 ; 6000
   END
   3: BEGIN
      sngl_ion = "fe_14"
      wvl0     = 5303.0
      wvlf     = 5305.0
      line     = "fe_14_5304.477"
      radtemp  = 6285.152 ; 6000
   END
   4: BEGIN
      sngl_ion = "fe_11"
      wvl0     = 7894.0
      wvlf     = 7895.0
      line     = "fe_11_7894.031"
      radtemp  = 6063.614 ; 6000
   END
   5: BEGIN
      sngl_ion = "si_10"
      wvl0     = 14304.0
      wvlf     = 14305.0
      line     = "si_10_14304.72"
      radtemp  = 6483.073 ; 6000
   END
   6: BEGIN
      sngl_ion = "si_9"
      wvl0     = 39292.0
      wvlf     = 39294.0
      line     = "si_09_39293.00"
      radtemp  = 5807.152 ; 6000
   END
ENDCASE
   
rphot    = 1.0 + 0.002*findgen(nz)
nne      = (nef-ne0)/nst + 1
table    = fltarr(nne,ntg,nz)
density  = (ne0 + (nef-ne0)*findgen(nne)/(nne-1))
filename = "goft_table_"+line+"_rphot_"+STRTRIM(STRING(radtemp),2)+".sav"
print, "---------------------------------------"
print, "Creating "+filename
print, "---------------------------------------"
;----------------------------------------------------------------------------------------
FOR kk=0,nne-1,1 DO BEGIN
    FOR jj=0,nz-1,1 DO BEGIN
       print, strtrim(string(jj),2)+"/"+strtrim(string(fix(nz)),2), " ", strtrim(string(kk),2)+"/"+strtrim(string(fix(nne)),2)
       ch_synthetic, wvl0, wvlf, density=10^density[kk], /goft, SNGL_ION=sngl_ion, output=ion, /photons, radtemp=radtemp, rphot=rphot[jj]
       table[kk,*,jj] = ion.lines[0].goft
    ENDFOR
ENDFOR
temperature=ion.IONEQ_LOGT
;----------------------------------------------------------------------------------------
save, density, temperature, rphot, table, filename=filename
;----------------------------------------------------------------------------------------
END
