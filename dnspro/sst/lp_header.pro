pro lp_header, filename, header=header, datatype=datatype, $
               dims=dims, nx=nx, ny=ny, nt=nt ,endian=endian
;
; extracts data parameters from header
; header should contain following entries :
;   datatype=4 (float), dims=2, nx=2027, ny=2042
; see lp_write.pro
;
 IF n_params() EQ 0 THEN BEGIN
    message, /info, 'lp_header, filename, header=header, datatype=datatype $'
    print, '                      , dims=dims, nx=nx, ny=ny, nt=nt'
    retall
 ENDIF

 if ARG_PRESENT(header) then printheader=0 else printheader=1

 openr, lur, filename, /get_lun
 rec = assoc(lur, bytarr(512))   ; first 512 bytes is header info
 header = string(rec[0])
 free_lun, lur
 if printheader eq 1 then print, header
 ; extract info from header
 len = strlen(header)
 ; datatype
 searchstring = 'datatype='
 pos = strpos(header, searchstring)
 if pos eq -1 then begin
     message, /info, 'unknown datatype'
     print, '  header: '+header
     retall
 endif
 datatype = fix(strmid(header, pos+strlen(searchstring), 1))
 ; number of dimensions :
 searchstring = 'dims='
 pos = strpos(header, searchstring)
 if pos eq -1 then begin
     message, /info, 'unknown number of dimensions'
     print, '  header: '+header
     retall
 endif
 dims = fix(strmid(header, pos+strlen(searchstring), 1))
 if (dims lt 2) or (dims gt 3) then begin
     message, /info, 'number of dimensions not supported'
     print, '  dimensions: ', dims
     retall
 endif
 ; number of pixels in x-direction
 searchstring = 'nx='
 pos = strpos(header, searchstring)
 if pos eq -1 then begin
     message, /info, 'unknown number of pixels in x-direction'
     print, '  header: '+header
     retall
 endif
 pos1=strpos(header, ',', pos)
 nx = fix(strmid(header, pos+strlen(searchstring), pos1-pos))
 ; number of pixels in y-direction
 searchstring = 'ny='
 pos = strpos(header, searchstring)
 if pos eq -1 then begin
     message, /info, 'unknown number of pixels in y-direction'
     print, '  header: '+header
     retall
 endif
 pos1=strpos(header, ',', pos)
 ny = fix(strmid(header, pos+strlen(searchstring), pos1-pos))
 ; number of pixels in t-dimension
; if dims eq 3 then begin
     searchstring = 'nt='
     pos = strpos(header, searchstring)
     if pos eq -1 then begin
         message, /info, 'unknown number of pixels in t-direction'
         print, '  header: '+header
         return
     endif else begin
         pos1=strpos(header, ',', pos)
;         nt = fix(strmid(header, pos+strlen(searchstring), pos1-pos))
         nt = long(strmid(header, pos+strlen(searchstring), pos1-pos))
     endelse
; endif
     searchstring = 'endian='
     pos = strpos(header, searchstring)
     if pos eq -1 then begin
         message, /info, 'unknown endianness'
         print, '  header: '+header
         return
     endif else endian = strmid(header, pos+strlen(searchstring), 1)

end
