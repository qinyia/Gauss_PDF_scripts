load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
begin
;***************file 1********************

; assume constant sub-saturation "deltaq=qw-qstl"

;deltaq = fspan(-10,10,1001)
deltaq = fspan(-5,5,1001)


; gradually changed sub-grid standard deviation: from 0 to 1.0
;sgm = fspan(0,1.0,6)
sgm = (/0.1,0.2,0.4,0.6,0.8/)

reff = new((/5,1001/),"float")

deltaq_1 = conform(reff,deltaq,1)
sgm_1 = conform(reff,sgm,0)

Q1 = deltaq_1/2.0/mask(sgm_1,sgm_1.eq.0,False)

cld = 0.5*(1+erf(Q1/sqrt(2.0)))


cld = where(cld.gt.1e-4,cld,0.)

conden0 = (Q1*cld + exp(-0.5*Q1^2)/sqrt(2*3.1415))
conden = 2*sgm_1*(Q1*cld + exp(-0.5*Q1^2)/sqrt(2*3.1415))
conden1 = 2*sgm_1*(Q1*cld)
conden2 = 2*sgm_1*(exp(-0.5*Q1^2)/sqrt(2*3.1415))


incld = conden/mask(cld,cld.eq.0,False)
incld1 = conden1/mask(cld,cld.eq.0,False)
incld2 = conden2/mask(cld,cld.eq.0,False)


index = ind_resolve(maxind(ndtooned(incld2)),dimsizes(incld2))
;print(index(0,:))
print(conden2(index(0,0),index(0,1)))
print(cld(index(0,0),index(0,1)))
print(conden2(index(0,0),index(0,1)+10))
print(cld(index(0,0),index(0,1)+10))

;************************create plot***************
wks = gsn_open_wks("pdf","figure/deltaq-sgm-cld-conden")


res = True

res@gsnFrame = False
res@gsnDraw = False

res@vpWidthF = 0.64
res@vpHeightF = 0.4

res@xyLineThicknessF = 3.0

;res@xyMarkLineMode = "MarkLines"

res@xyLabelMode            = "Custom"
res@xyExplicitLabels = sgm


res@trYMaxF = 1.

res@xyLineLabelFontHeightF =0.013

;; add a legend
; res@pmLegendDisplayMode    = "Always"              ; turn on legend
; 
; res@pmLegendSide           = "Top"                 ; Change location of 
; res@pmLegendParallelPosF   = .90                   ; move units right
; res@pmLegendOrthogonalPosF = -0.8                  ; more neg = down
; 
; res@pmLegendWidthF         = 0.12                  ; Change width and
; res@pmLegendHeightF        = 0.25                  ; height of legend.
; res@lgLabelFontHeightF     = .02                   ; change font height
; res@lgPerimOn              = False                 ; no box around
;; labels for the legend

;res@xyExplicitLegendLabels = sgm

;res@cnLineLabelDensityF = -3.0
;res@cnLineLabelDensityF = 0.25


res1 = res
res2 = res
res1@trXMinF = -5.
res1@trXMaxF = 5.
res1@trYMinF = 0.
res1@trYMaxF = 1.
res1@tiYAxisString = "R"
res1@xyLineColor = "red"
res1@xyDashPattern = 0
res1@tiYAxisFontColor = res1@xyLineColor
res1@tiXAxisString = "~F33~D~F~q (g kg~S~-1~N~)"
res1@xyLineLabelConstantSpacingF = 0.

res1@xyLineDashSegLenF = 0.3

res2@trXMinF = -5.
res2@trXMaxF = 5.
res2@trYMinF = 0.
res2@trYMaxF = 2.
;~B~ : subscript
;~N~ : normal
;~S~ : superscript
;~F33~s: sigma
res2@tiYAxisString = "q~B~l~N~/(2~F33~s)"
res2@xyLineColor = "blue"
res2@tiYAxisFontColor = res2@xyLineColor
res2@xyDashPattern = 0
res2@tiXAxisString = "~F33~D~F~q (g kg~S~-1~N~)"

res2@xyLineDashSegLenF = 0.5

;plot1 = gsn_csm_xy2(wks,x1,y11,y12,res1,res2)
plot1 = gsn_csm_xy(wks,deltaq,cld,res1)
plot2 = gsn_csm_xy(wks,deltaq,conden0,res2)

;gsn_panel(wks,(/plot1,plot2/),(/2,1/),False)
gsn_panel(wks,(/plot1,plot2/),(/1,2/),False)

end
