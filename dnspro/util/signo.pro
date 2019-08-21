;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;                                 SIGN FUNCTION
;---------------------------------------------------------------------------------
FUNCTION signo, x
  compile_opt idl2
  on_error, 2
  return, 0 + (x gt 0) - (x lt 0)
END
