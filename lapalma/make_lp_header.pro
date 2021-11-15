function make_lp_header, array, nt=nt, t_start=t_start, delta_t=delta_t
;
; set up a standard header for saving La Palma data
;
; 21 Jan 2004: add info on endianess of system (little endian in Oslo)
; 
 if n_params() eq 0 then begin
     message, /info, 'header = make_lp_header(image, nt=nt, t_start=t_start, delta_t=delta_t)'
     return, 0
 endif

 sZ = size(array)
 dims = sZ[0]
 if dims lt 2 then begin
     message, /info, ' only 2D or 3D files are supported'
     return, ''
 endif
 datatype = sZ[dims+1]
 if keyword_set(nt) ne 0 then dims=3
 nx = sZ[1]
 ny = sZ[2]
 if dims eq 3 then begin
     if keyword_set(nt) eq 0 then nt = sZ[3]
 endif
 case datatype of
     1: typestring = '(byte)'
     2: typestring = '(integer)'
     3: typestring = '(long)'
     4: typestring = '(float)'
     else: typestring = '(-)'
 endcase
 header = ' datatype='+strtrim(datatype,2)+' '+typestring
 header = header + ', dims='+strtrim(dims,2)
 header = header + ', nx='+strtrim(nx,2)
 header = header + ', ny='+strtrim(ny,2)
 if dims eq 3 then header = header + ', nt='+strtrim(nt,2)
 ; add endianess
 ; if (byte(1L, 0, 1) eq 1)  ;  not in IDL53! -> complain about array
 if ((byte(1L, 0, 1))[0] eq 1) then endianstr = 'endian=l'  $  ; little endian
   else endianstr = 'endian=b'  ; big endian
 header = header + ', '+endianstr
 if keyword_set(t_start) eq 1 then header=header+', t_start='+t_start
 if keyword_set(delta_t) eq 1 then begin
     header=header+', delta_t='
     if size(delta_t,/type) ne 7 then header=header+strtrim(delta_t,2) else $
       header=header+'delta_t='+delta_t
 endif 

 return, header

end
