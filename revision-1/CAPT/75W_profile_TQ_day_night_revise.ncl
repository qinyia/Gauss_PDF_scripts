load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
begin
;***************file 1********************
fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt2-vocals/run/hourmean/"
;fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt-vocals-shalcld-output2/run/hourmean/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt-vocals-revise-2/run/hourmean/"

fname1 = "day03.nc"

f1 = addfile(fdir1+fname1,"r")

T_1 = f1->T(:,:,{-20},{285})
Q_1 = f1->Q(:,:,{-20},{285})
CLDLIQ_1 = f1->CLDLIQ(:,:,{-20},{285})
lev = f1->lev


CLDLIQ_1 = CLDLIQ_1*1000.

T_1_deg = T_1-273.15

; calculate the relative humidity
es0 = 6.1078
a = 17.269
b = 35.86

Pres = conform(T_1,lev,1)
es_1 = es0*exp(a*T_1_deg/(273.15+T_1_deg-b))
e_1 =Q_1*Pres/(0.622+0.378*Q_1) 
RH_1 = e_1/es_1*100.
copy_VarCoords(T_1,RH_1)

Q_1 = Q_1*1000.

;======day mean
T_1_day = T_1(5:7,:)
Q_1_day = Q_1(5:7,:)
CLDLIQ_1_day = CLDLIQ_1(5:7,:)
RH_1_day = RH_1(5:7,:)
T_1_day_avg = dim_avg_n(T_1_day,0)
Q_1_day_avg = dim_avg_n(Q_1_day,0)
CLDLIQ_1_day_avg = dim_avg_n(CLDLIQ_1_day,0)
RH_1_day_avg = dim_avg_n(RH_1_day,0)

T_1_day_avg!0 = "lev"
T_1_day_avg&lev = lev
T_1_day_avg&lev@units = "hPa"
Q_1_day_avg!0 = "lev"
Q_1_day_avg&lev = lev
Q_1_day_avg&lev@units = "hPa"
CLDLIQ_1_day_avg!0 = "lev"
CLDLIQ_1_day_avg&lev = lev
CLDLIQ_1_day_avg&lev@units = "hPa"
RH_1_day_avg!0 = "lev"
RH_1_day_avg&lev = lev
RH_1_day_avg&lev@units = "hPa"


;night mean
T_1_night = T_1(1:4,:)
Q_1_night = Q_1(1:4,:)
CLDLIQ_1_night = CLDLIQ_1(1:4,:)
RH_1_night = RH_1(1:4,:)
T_1_night_avg = dim_avg_n(T_1_night,0)
Q_1_night_avg = dim_avg_n(Q_1_night,0)
CLDLIQ_1_night_avg = dim_avg_n(CLDLIQ_1_night,0)
RH_1_night_avg = dim_avg_n(RH_1_night,0)

T_1_night_avg!0 = "lev"
T_1_night_avg&lev = lev
T_1_night_avg&lev@units = "hPa"
Q_1_night_avg!0 = "lev"
Q_1_night_avg&lev = lev
Q_1_night_avg&lev@units = "hPa"
CLDLIQ_1_night_avg!0 = "lev"
CLDLIQ_1_night_avg&lev = lev
CLDLIQ_1_night_avg&lev@units = "hPa"
RH_1_night_avg!0 = "lev"
RH_1_night_avg&lev = lev
RH_1_night_avg&lev@units = "hPa"

;==============================
f2 = addfile(fdir2+fname1,"r")

T_2 = f2->T(:,:,{-20},{285})
Q_2 = f2->Q(:,:,{-20},{285})
CLDLIQ_2 = f2->CLDLIQ(:,:,{-20},{285})
lev = f1->lev

CLDLIQ_2 = CLDLIQ_2*1000.

T_2_deg = T_2-273.15

; calculate the relative humidity
es0 = 6.1078
a = 17.269
b = 35.86

Pres = conform(T_2,lev,1)
es_2 = es0*exp(a*T_2_deg/(273.15+T_2_deg-b))
e_2 =Q_2*Pres/(0.622+0.378*Q_2) 
RH_2 = e_2/es_2*100.
copy_VarCoords(T_2,RH_2)

Q_2 = Q_2*1000.

;======day mean
T_2_day = T_2(5:7,:)
Q_2_day = Q_2(5:7,:)
CLDLIQ_2_day = CLDLIQ_2(5:7,:)
RH_2_day = RH_2(5:7,:)
T_2_day_avg = dim_avg_n(T_2_day,0)
Q_2_day_avg = dim_avg_n(Q_2_day,0)
CLDLIQ_2_day_avg = dim_avg_n(CLDLIQ_2_day,0)
RH_2_day_avg = dim_avg_n(RH_2_day,0)

T_2_day_avg!0 = "lev"
T_2_day_avg&lev = lev
T_2_day_avg&lev@units = "hPa"
Q_2_day_avg!0 = "lev"
Q_2_day_avg&lev = lev
Q_2_day_avg&lev@units = "hPa"
CLDLIQ_2_day_avg!0 = "lev"
CLDLIQ_2_day_avg&lev = lev
CLDLIQ_2_day_avg&lev@units = "hPa"
RH_2_day_avg!0 = "lev"
RH_2_day_avg&lev = lev
RH_2_day_avg&lev@units = "hPa"


;night mean
T_2_night = T_2(1:4,:)
Q_2_night = Q_2(1:4,:)
CLDLIQ_2_night = CLDLIQ_2(1:4,:)
RH_2_night = RH_2(1:4,:)
T_2_night_avg = dim_avg_n(T_2_night,0)
Q_2_night_avg = dim_avg_n(Q_2_night,0)
CLDLIQ_2_night_avg = dim_avg_n(CLDLIQ_2_night,0)
RH_2_night_avg = dim_avg_n(RH_2_night,0)

T_2_night_avg!0 = "lev"
T_2_night_avg&lev = lev
T_2_night_avg&lev@units = "hPa"
Q_2_night_avg!0 = "lev"
Q_2_night_avg&lev = lev
Q_2_night_avg&lev@units = "hPa"
CLDLIQ_2_night_avg!0 = "lev"
CLDLIQ_2_night_avg&lev = lev
CLDLIQ_2_night_avg&lev@units = "hPa"
RH_2_night_avg!0 = "lev"
RH_2_night_avg&lev = lev
RH_2_night_avg&lev@units = "hPa"

;**********************file3****************************
fdir3 = "/home/lyl/WORK3/qinyi/scripts/vocals-fortran/vocals_unify/"
fname31 = "75W_day.txt"
fname32 = "75W_nig.txt"

data31 = asciiread(fdir3+fname31,(/30,6/),"float")
data32 = asciiread(fdir3+fname32,(/30,6/),"float")

;day 
p31 = data31(:,0)
t31 = data31(:,1)
td31 = data31(:,2)
rh31 = data31(:,3)
u31 = data31(:,4)
v31 = data31(:,5)

;night
p32 = data32(:,0)
t32 = data32(:,1)
td32 = data32(:,2)
rh32 = data32(:,3)
u32 = data32(:,4)
v32 = data32(:,5)

;printVarSummary(t2)


 ; calculate the specific humidity
  es0 = 6.1078
  a = 17.269
  b = 35.86
  
  e31 = es0*exp(a*td31/(273.15+td31-b))
  qv31 = 0.622*e31/(p31-0.378*e31)

  e32 = es0*exp(a*td32/(273.15+td32-b))
  qv32 = 0.622*e32/(p32-0.378*e32)

  T_3_day_avg = t31(::-1)
  T_3_night_avg = t32(::-1)
  Q_3_day_avg = qv31(::-1)
  Q_3_night_avg = qv32(::-1)
  RH_3_day_avg = rh31(::-1)
  RH_3_night_avg = rh32(::-1)

  copy_VarCoords(T_1_day_avg,T_3_day_avg)
  copy_VarCoords(T_1_day_avg,T_3_night_avg)
  copy_VarCoords(Q_1_day_avg,Q_3_day_avg)
  copy_VarCoords(Q_1_day_avg,Q_3_night_avg)
  copy_VarCoords(RH_1_day_avg,RH_3_day_avg)
  copy_VarCoords(RH_1_day_avg,RH_3_night_avg)

  Q_3_day_avg = Q_3_day_avg*1000.
  Q_3_night_avg = Q_3_night_avg*1000.
  T_3_day_avg = T_3_day_avg+273.15
  T_3_night_avg = T_3_night_avg+273.15



T_dn = new((/6,dimsizes(lev)/),float)
T_dn(0,:) = T_1_day_avg
T_dn(1,:) = T_1_night_avg
T_dn(2,:) = T_2_day_avg
T_dn(3,:) = T_2_night_avg
T_dn(4,:) = T_3_day_avg
T_dn(5,:) = T_3_night_avg


Q_dn = new((/6,dimsizes(lev)/),float)
Q_dn(0,:) = Q_1_day_avg
Q_dn(1,:) = Q_1_night_avg
Q_dn(2,:) = Q_2_day_avg
Q_dn(3,:) = Q_2_night_avg
Q_dn(4,:) = Q_3_day_avg
Q_dn(5,:) = Q_3_night_avg



CLDLIQ_dn = new((/4,dimsizes(lev)/),float)
CLDLIQ_dn(0,:) = CLDLIQ_1_day_avg
CLDLIQ_dn(1,:) = CLDLIQ_1_night_avg
CLDLIQ_dn(2,:) = CLDLIQ_2_day_avg
CLDLIQ_dn(3,:) = CLDLIQ_2_night_avg


RH_dn = new((/6,dimsizes(lev)/),double)
RH_dn(0,:) = RH_1_day_avg
RH_dn(1,:) = RH_1_night_avg
RH_dn(2,:) = RH_2_day_avg
RH_dn(3,:) = RH_2_night_avg
RH_dn(4,:) = RH_3_day_avg
RH_dn(5,:) = RH_3_night_avg


;************************create plot***************
date=systemfunc("date")
print(date)
wks = gsn_open_wks("pdf","../figure/75W-profile-TQ-day-night"+date)
plot = new(3,graphic)

;colors = (/"black","blue","magenta","brown","burlywood","darkgreen","darkorange","purple"/)
colors = (/"red","red","blue","blue","black","black","darkorange","purple"/)

res = True
;res@tiMainString = "Temperature (75W,20S)" 	;add title
res@trYReverse = True 				;reverse Y-axis
res@gsnFrame = False 				;don't advance frame yet
res@gsnDraw = False
res@trYMinF =700
res@trYMaxF = lev(29)
res@trXMinF = 275.
res@trXMaxF = 295.
res@xyMarkLineModes = "Lines"
;res@xyMarkers = markers
res@tiXAxisString = "T (K)"
res@tiYAxisString = "pressure (hPa)"
res@xyLineColors = colors 
res@xyLineThicknessF = 2.0
;res@xyDashPatterns = (/0,16,0,16,0,16,0,16/)
;res@xyDashPatterns = (/0,1,0,1,0,1,0,1/)
res@xyDashPatterns = (/0,14,0,14,0,14,0,14/)

res@tiMainFont = "helvetica"
res@tiXAxisFont = "helvetica"
res@tiYAxisFont = "helvetica"
res@tmXBLabelFont = "helvetica"
res@tmYLLabelFont = "helvetica"

res@gsnRightString = "[20S,75W]"

res@tmXTOn				= False
res@tmYROn				= False
res@tmXBMinorOn			= False
res@tmYLMinorOn			= False

;fh							= 0.03
;res@gsnStringFontHeightF	= fh
;res@tmXBLabelFontHeightF	= fh
;res@tmYLLabelFontHeightF	= fh
;res@tiXAxisFontHeightF		= fh
;res@tiYAxisFontHeightF		= fh

ft								= 0.035
res@gsnStringFontHeightF		= ft+0.005
res@tmXTOn						= False
res@tmYROn						= False
res@tmXBLabelFontHeightF		= ft
res@tmYLLabelFontHeightF		= ft 
res@tmXBMinorOn					= False
res@tmYLMinorOn					= False

res@tiXAxisFontHeightF			= ft+0.005
res@tiYAxisFontHeightF			= ft+0.005




;res@gsnLeftString = "[20S,75W]"


res@gsnLeftString = "(a)"
plot(0) = gsn_csm_xy(wks,T_dn,T_dn&lev,res)

;========================
;Attach a legend
lgres = True
lgres@lgLineColors = colors
lgres@lgLineThicknessF = res@xyLineThicknessF
lgres@lgDashIndexes = res@xyDashPatterns
lgres@lgItemTypes = res@xyMarkLineModes
lgres@lgLabelFontHeightF = .18
lgres@vpWidthF = 0.30
lgres@vpHeightF = 0.32
;lgres@lgPerimThicknessF = 1.0
lgres@lgPerimOn = False


;labels = (/"22:30","01:30","04:30","07:30","10:30","13:30","16:30","19:30"/)
;labels = (/"RH-day","RH-night","PDF-day","PDF-night","Obs-day","Obs-night"/)
labels = (/"Park_RH-day","Park_RH-night","Gauss_PDF-day","Gauss_PDF-night","Obs-day","Obs-night"/)


legend = gsn_create_legend(wks,6,labels,lgres)

;========================

;res@tiMainString = "Specific Humidity (75W,20S)" 	;add title
res@tiXAxisString = "q~B~v~N~ (g kg~S~-1~N~)"
res@trXMinF = 0.
res@trXMaxF = 12.
res@gsnLeftString = "(b)"

plot(1) = gsn_csm_xy(wks,Q_dn,Q_dn&lev,res)

amres = True
amres@amJust = "TopRight"
amres@amParallelPosF = 0.5
amres@amOrthogonalPosF = -0.5 
annoid = gsn_add_annotation(plot(1),legend,amres)



;res@tiMainString = "Relative Humidity (75W,20S)" 	;add title
res@tiXAxisString = "RH (%)"
res@trXMinF = 0
res@trXMaxF = 100
res@gsnLeftString = "(c)"

plot(2) = gsn_csm_xy(wks,RH_dn,RH_dn&lev,res)

;draw(plot)
;frame(wks)
;gsn_panel(wks,plot,(/3,1/),False)

resP		= True
resP@gsnPanelYWhiteSpacePercent  = 5.0
resP@gsnPanelXWhiteSpacePercent  = 5.0

gsn_panel(wks,plot,(/1,3/),resP)

end
