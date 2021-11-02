function lp_read, filename, header=header
;
; read La Palma data stored as IDL assoc file
;
; First 512 bytes are assumed to contain header info containing:
;    datatype=2 (integer), dims=2, nx=2027, ny=2042
;
; see lp_write for writing right header style
;
 IF n_params() EQ 0 THEN BEGIN
    message, /info, 'image = lp_read(filename [, header=header])'
    retall
 ENDIF

 if ARG_PRESENT(header) then printheader=0 else printheader=1
 ; print header if header is not asked for as keyword
 
 lp_header, filename, header=header, datatype=datatype, $
            dims=dims, nx=nx, ny=ny, nt=nt

 openr, lur, filename, /get_lun
 if printheader then message, /info, header

 ; read actual data
 if dims eq 2 then begin   ; 2D case
     case datatype of
         1: begin 
             rec = assoc(lur, bytarr(nx,ny), 512)
             image = rec[0]
         end
         2: begin
             rec = assoc(lur, intarr(nx,ny), 512)
             image = rec[0]
         end
         3: begin
             rec = assoc(lur, lonarr(nx,ny), 512)
             image = rec[0]
         end
         4: begin
             rec = assoc(lur, fltarr(nx,ny), 512)
             image = rec[0]
         end
         else: begin
             message, /info, 'datatype not supported '
             print, ' datatype = ', datatype
             free_lun, lur
             return, 0
         end
     end
     free_lun, lur
     return, image
 endif else begin  ; 3D case
      case datatype of
         1: begin 
             rec = assoc(lur, bytarr(nx,ny,nt), 512)
             cube = rec[0]
         end
         2: begin
             rec = assoc(lur, intarr(nx,ny,nt), 512)
             cube = rec[0]
         end
         3: begin
             rec = assoc(lur, lonarr(nx,ny,nt), 512)
             cube = rec[0]
         end
         4: begin
             rec = assoc(lur, fltarr(nx,ny,nt), 512)
             cube = rec[0]
         end
         else: begin
             message, /info, 'datatype not supported '
             print, ' datatype = ', datatype
             free_lun, lur
             return, 0
         end
     end
     free_lun, lur
     return, cube
 endelse

end
