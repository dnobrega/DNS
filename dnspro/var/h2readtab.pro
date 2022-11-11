PRO h2readtab,outtg,outpf

  ; -----------------------------------------------------------------------------------
  ; Routine to read the h2_molecule.txt file
  ; This file contains the partition function of the H2 molecule
  ; The data are obtained from Barklem and Collet, A&A 588, 2016 
  ; https://www.aanda.org/articles/aa/pdf/2016/04/aa26961-15.pdf  
  ; -----------------------------------------------------------------------------------  

  folder    = GETENV('DNS')+"/dnspro/var/"
  h2inputfile=folder+'h2_molecule_bc.txt'

  openr,lur,h2inputfile,/get_lun
  text=''
  WHILE(NOT eof(lur)) DO BEGIN
     readf,lur,text
     txt=strsplit(text,/extract)
     IF n_elements(txt) ge 2 THEN BEGIN
        IF txt[0] NE ';' THEN BEGIN
           IF n_elements(outpf) EQ 0 THEN outpf=txt[1] ELSE outpf=[outpf,txt[1]]
           IF n_elements(outtg) EQ 0 THEN outtg=txt[0] ELSE outtg=[outtg,txt[0]]
        ENDIF
     ENDIF
  ENDWHILE
  free_lun,lur
  outtg=outtg*1d 
  outpf=outpf*1d

END
