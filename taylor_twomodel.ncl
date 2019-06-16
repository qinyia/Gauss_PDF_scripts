;**********************************
; taylor_3.ncl
;**********************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "./taylor_diagram.ncl"
;**********************************
begin
;**********************************
; Assume the following have already been computed:
;   _ratio are the ratio:  Case_Variance/Reference_Variance
;   _cc    are the cross correlation coef of Case to Reference
;**********************************

; Cases [Model]
  case      = (/ "CAM5_Old", "CAM5_New" /) 
  nCase     = dimsizes(case )                 ; # of Cases [Cases]

; variables compared
;  var       = (/ "SLP","SWCF","LWCF","Land Rainfall","Ocean Rainfall","Land 2m T", "pacific Surface Stress", "Zonal Wind","Relative Humidity","Temperature" /) 
  var       = (/ "SLP","CLDLOW","CLDMED","CLDHGH","SWCF","LWCF","PRECT" /) 
  nVar      = dimsizes(var)                   ; # of Variables

; "Case A"                        
; ratio: variance
; cc: correlation
  CA_ratio   = (/1.103, 1.160, 1.120, 1.133, 1.240, 1.045, 1.174, 1.007, 1.135, 1.143/)
  CA_cc      = (/0.972, 0.887, 0.859, 0.784, 0.817, 0.990, 0.882, 0.972, 0.928, 0.988/)

; "Case B" 
  CB_ratio   = (/1.082, 1.070, 1.090, 1.318, 1.203, 1.042, 1.086, 1.031, 1.205, 1.127/)
  CB_cc      = (/0.944, 0.876, 0.820, 0.720, 0.759, 0.987, 0.830, 0.945, 0.900, 0.986/)

; arrays to be passed to taylor plot 
  ratio      = new ((/nCase, nVar/),typeof(CA_cc) )  
  cc         = new ((/nCase, nVar/),typeof(CA_cc) ) 

  ratio(0,:) = CA_ratio 
  ratio(1,:) = CB_ratio

  cc(0,:)    = CA_cc 
  cc(1,:)    = CB_cc

;**********************************
; create plot
;**********************************

  res   = True                           ; default taylor diagram
        
  res@Markers      = (/4, 16/)               ; make all solid fill
  res@Colors       = (/"black", "black" /)          
  res@varLabels    = var
  res@caseLabels   = case
 
  wks   = gsn_open_wks("pdf","./figure/taylor") 
  plot  = taylor_diagram(wks,ratio,cc,res)

  frame(wks)

end 
