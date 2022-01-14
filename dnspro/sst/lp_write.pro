pro lp_write, image, filename, extraheader=extraheader
;
; writes La Palma data as IDL assoc file
; first 512 bytes are used to store header info
; minimum required header info for lp_read is written here, additional
; header info can be added in <extraheader>
;
 IF n_params() EQ 0 THEN BEGIN
    message, /info, 'lp_write, image, filename [, extraheader=extraheader]'
 ENDIF

 if KEYWORD_SET(extraheader) eq 0 then extraheader=''
 
 sZ = size(image)
 dims = sZ[0]
 if dims lt 2 then begin
     message, /info, ' only 2D or 3D files are supported'
 endif
 nx = sZ[1]
 ny = sZ[2]
 if dims eq 3 then nt = sZ[3]
 datatype = sZ[dims+1]

 bheader = make_lp_header(image)
 message, /info, bheader
 header = extraheader +' : ' + bheader

 openw, luw, filename, /get_lun
 rec = assoc(luw, bytarr(512))
 rec[0] = byte(header)
 case datatype of
     1: begin
         if dims eq 2 then rec = assoc(luw, bytarr(nx,ny), 512) $
           else rec = assoc(luw, bytarr(nx,ny,nt), 512)
         rec[0] = image
     end
     2: begin
         if dims eq 2 then rec = assoc(luw, intarr(nx,ny), 512) $
           else rec = assoc(luw, intarr(nx,ny,nt), 512)
         rec[0] = image
     end
     3: begin
         if dims eq 2 then rec = assoc(luw, lonarr(nx,ny), 512) $
           else rec = assoc(luw, lonarr(nx,ny,nt), 512)
         rec[0] = image
     end
     4: begin
         if dims eq 2 then rec = assoc(luw, fltarr(nx,ny), 512) $
           else rec = assoc(luw, fltarr(nx,ny,nt), 512)
         rec[0] = image
     end
     else : begin
         message, ' datatype not supported'
         print, ' datatype = ', datatype
         free_lun, luw
     end
 endcase
 free_lun, luw


end
