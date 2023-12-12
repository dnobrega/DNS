PRO create_goft_tables, line, ntg=ntg, ne0=ne0, nef=nef, nst=nst
;-----------------------------------------------------------------------
; HELP
;-----------------------------------------------------------------------
;
; INPUT:
;
; line has to be a string including the element, the ionization level,
; and the wavelentgh with three decimals
;
; Examples:
; line = "fe_13_196.525"
; line = "fe_13_202.044"
; line = "fe_14_264.788"
; line = "fe_14_274.203"
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
; A table called "table_"+line+".sav" with axis density and temeprature
;-----------------------------------------------------------------------
IF (NOT (KEYWORD_SET(ntg))) THEN ntg=101
IF (NOT (KEYWORD_SET(ne0))) THEN ne0=7.5
IF (NOT (KEYWORD_SET(nef))) THEN nef=12.5
IF (NOT (KEYWORD_SET(nst))) THEN nst=0.05
;-----------------------------------------------------------------------
sngl_ion = STRMID(line,0,5) 
wvl0     = FLOAT(STRMID(line,6,7))-0.001
wvlf     = FLOAT(STRMID(line,6,7))+0.001
nne      = (nef-ne0)/nst + 1
table    = fltarr(nne,ntg)
density  = 10^(ne0 + (nef-ne0)*findgen(nne)/(nne-1))
;-----------------------------------------------------------------------
FOR kk=0,nne-1,1 DO BEGIN
    print, density[kk]
    ch_synthetic, wvl0, wvlf, density=density[kk], $
                 /goft, SNGL_ION=sngl_ion, output=ion
    table[kk,*] = ion.lines[0].goft    
ENDFOR
temperature=ion.IONEQ_LOGT
;-----------------------------------------------------------------------
save, density, temperature, table, filename="table_"+line+".sav"
;-----------------------------------------------------------------------
END
