PRO create_goft_tables, line, ntg=ntg, ne0=ne0, nef=nef, nst=nst, wlim=wlim
;----------------------------------------------------------------------------------------
; HELP
;----------------------------------------------------------------------------------------
;
; INPUT:
;
; line has to be a string including the element, the ionization level,
; and the wavelentgh with three decimals
;
; Examples:
; line = "fe_8_108.073"
; line = "fe_12_186.887" 
; line = "fe_12_195.119"
; line = "fe_12_1349.40"
; line = "fe_13_196.525"
; line = "fe_13_202.044"
; line = "fe_13_203.826" 
; line = "fe_14_264.788"
; line = "fe_14_274.203"
; line = "fe_15_284.160"
; line = "fe_19_108.355"
; line = "o_4_279.933"
; line = 
;
; OPTIONAL:
;
; ntg: Number of elements in Tg. 
;      By default, 101: the number of elements by default by CHIANTI
;      in all the coronal lines; however, for TR lines, they use 81.
; ne0: Lower limit for the electron number density in log10.
;      By default, 7.5.
; nef: Upper limit for the electron number density in log10.
;      By default, 12.5.
; nst: Step for the electron number density axis.
;      By default, 0.05.
;  
; OUTPUT:
; A table called "goft_table_"+line+".sav" with axis density and temeprature
;----------------------------------------------------------------------------------------
IF (NOT (KEYWORD_SET(ntg)))  THEN ntg=101
IF (NOT (KEYWORD_SET(ne0)))  THEN ne0=7.5
IF (NOT (KEYWORD_SET(nef)))  THEN nef=12.5
IF (NOT (KEYWORD_SET(nst)))  THEN nst=0.05
IF (NOT (KEYWORD_SET(wlim))) THEN wlim=0.001
;----------------------------------------------------------------------------------------
iname    = STRPOS(line,"_",/reverse_search)
ilimit   = iname+1
sngl_ion = STRMID(line,0,iname)
length   = STRLEN(line)
idot     = STRPOS(line,".",/reverse_search)
howmany  = length-1-idot
wvl0     = FLOAT(STRMID(line,ilimit,ilimit+howmany))-wlim
wvlf     = FLOAT(STRMID(line,ilimit,ilimit+howmany))+wlim
print, sngl_ion, 1d*wvl0, 1d*wvlf
nne      = (nef-ne0)/nst + 1
table    = fltarr(nne,ntg)
density  = (ne0 + (nef-ne0)*findgen(nne)/(nne-1))
filename = "goft_table_"+line+".sav"
print, "---------------------------------------"
print, "Creating "+filename
print, "---------------------------------------"
;----------------------------------------------------------------------------------------
FOR kk=0,nne-1,1 DO BEGIN
    print, strtrim(string(kk),2)+"/"+strtrim(string(fix(nne)),2)
    ch_synthetic, wvl0, wvlf, density=10^density[kk], /goft, SNGL_ION=sngl_ion, output=ion
    table[kk,*] = ion.lines[0].goft    
ENDFOR
temperature=ion.IONEQ_LOGT
;----------------------------------------------------------------------------------------
save, density, temperature, table, filename=filename
;----------------------------------------------------------------------------------------
END
