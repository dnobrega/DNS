
PRO MAKE_MOVIE_FROM_IMAGES, list=list, folder=folder,$
                            step=step, $
                            input_format=input_format,$
                            output_format=output_format,$
                            moviename=moviename, fps=fps, $
                            save_array=save_array
  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                             INPUT PARAMETERS                                   
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IF (KEYWORD_SET(folder))             THEN CD, folder
IF (NOT KEYWORD_SET(input_format))   THEN input_format='.png'
IF (NOT KEYWORD_SET(output_format))  THEN output_format='.mp4'
IF (NOT KEYWORD_SET(fps))            THEN fps=24
IF (NOT KEYWORD_SET(step))           THEN step=1
IF (NOT KEYWORD_SET(moviename))      THEN moviename='movie'
IF (NOT KEYWORD_SET(list))           THEN SPAWN, 'ls *'+input_format, list

n_list = n_elements(list)

jj = 0
IF (NOT FILE_EXIST(list[jj]))        THEN BEGIN
   PRINT, 'File: ', list[jj], ' not found'
ENDIF ELSE BEGIN
   print, jj, ' Extracting ', list[jj]
   CASE input_format OF
      '.png'  : READ_PNG,  list[jj], image
      '.jpg'  : READ_JPEG, list[jj], image
      '.jpeg ': READ_JPEG, list[jj], image
      ELSE: BEGIN
            PRINT, "Only .png, .jpg or .jpeg are accepted"
            STOP
            END
   ENDCASE
   si        = size(image)
   video     = IDLffVideoWrite(moviename+output_format)
   stream    = video.AddVideoStream(si[2],si[3],fps,BIT_RATE=24E5)
   IF si[1] EQ 4 THEN BEGIN
      makingmp4 = video.Put(stream,image[0:2,*,*])
   ENDIF ELSE BEGIN
      IF si[1] EQ 3 THEN makingmp4 = video.Put(stream,image)
   ENDELSE
ENDELSE
   
FOR jj=1, n_list-1, step DO BEGIN

   IF (NOT FILE_EXIST(list[jj]))        THEN BEGIN
      PRINT, 'File: ', list[jj], ' not found' 
   ENDIF ELSE BEGIN
      print, jj, ' Extracting ', list[jj]
      image     = READ_PNG(list[jj])
      CASE input_format OF
         '.png'  : READ_PNG,  list[jj], image
         '.jpg'  : READ_JPEG, list[jj], image
         '.jpeg ': READ_JPEG, list[jj], image
         ELSE: BEGIN
               PRINT, "Only .png, .jpg or .jpeg are accepted"
               STOP
               END
      ENDCASE
      IF si[1] EQ 4 THEN BEGIN
         makingmp4 = video.Put(stream,image[0:2,*,*])
      ENDIF ELSE BEGIN
         IF si[1] EQ 3 THEN makingmp4 = video.Put(stream,image)
      ENDELSE
   ENDELSE

ENDFOR

video.cleanup

END
