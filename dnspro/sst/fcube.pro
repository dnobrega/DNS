pro fcube,files
;+
;   fcube,files
;
;            look for *cube and return filenames in files
;
;-
if(n_params() lt 1) then begin
  message,'fcube,files',/informational
  return
endif

files=findfile("*cube",count=count)
if(count gt 0) then begin
  for i=0,count-1 do begin
    print,i,files[i],format='(i3,1x,a)'
  endfor
endif else begin
  print,'no *cube files found'
endelse

end
