load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
begin
;***************file 1********************
fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt2-vocals/run/hourmean/"
;fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt-vocals-shalcld-output2/run/hourmean/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt-vocals-revise-2/run/hourmean/"

fname1 = "day03.nc"
fname2 = "day03.nc"

f1 = addfile(fdir1+fname1,"r")

CLDLIQ_1 = f1->CLDLIQ(:,:,{-20},{265})
CLOUD_1 = f1->CLOUD(:,:,{-20},{265})

lev = f1->lev


CLDLIQ_1 = CLDLIQ_1*1000.

;======day mean
CLDLIQ_1_day = CLDLIQ_1(5:7,:)
CLDLIQ_1_day_avg = dim_avg_n(CLDLIQ_1_day,0)

CLDLIQ_1_day_avg!0 = "lev"
CLDLIQ_1_day_avg&lev = lev
CLDLIQ_1_day_avg&lev@units = "hPa"

CLOUD_1_day = CLOUD_1(5:7,:)
CLOUD_1_day_avg = dim_avg_n(CLOUD_1_day,0)

CLOUD_1_day_avg!0 = "lev"
CLOUD_1_day_avg&lev = lev
CLOUD_1_day_avg&lev@units = "hPa"




;night mean
CLDLIQ_1_night = CLDLIQ_1(1:4,:)
CLDLIQ_1_night_avg = dim_avg_n(CLDLIQ_1_night,0)
CLDLIQ_1_night_avg!0 = "lev"
CLDLIQ_1_night_avg&lev = lev
CLDLIQ_1_night_avg&lev@units = "hPa"

CLOUD_1_night = CLOUD_1(1:4,:)
CLOUD_1_night_avg = dim_avg_n(CLOUD_1_night,0)
CLOUD_1_night_avg!0 = "lev"
CLOUD_1_night_avg&lev = lev
CLOUD_1_night_avg&lev@units = "hPa"



;==============================
f2 = addfile(fdir2+fname2,"r")

CLDLIQ_2 = f2->CLDLIQ(:,:,{-20},{265})
CLOUD_2 = f2->CLOUD(:,:,{-20},{265})
sgm_tota_2 = f2->sgm_tota(:,:,{-20},{265})
N1 = f2->N1(:,:,{-20},{265})


lev = f1->lev

CLDLIQ_2 = CLDLIQ_2*1000.
sgm_tota_2 = sqrt(abs(sgm_tota_2))*1e3

;======day mean
CLDLIQ_2_day = CLDLIQ_2(5:7,:)
CLDLIQ_2_day_avg = dim_avg_n(CLDLIQ_2_day,0)
CLDLIQ_2_day_avg!0 = "lev"
CLDLIQ_2_day_avg&lev = lev
CLDLIQ_2_day_avg&lev@units = "hPa"

CLOUD_2_day = CLOUD_2(5:7,:)
CLOUD_2_day_avg = dim_avg_n(CLOUD_2_day,0)
CLOUD_2_day_avg!0 = "lev"
CLOUD_2_day_avg&lev = lev
CLOUD_2_day_avg&lev@units = "hPa"

sgm_tota_2_day = sgm_tota_2(5:7,:)
sgm_tota_2_day_avg = dim_avg_n(sgm_tota_2_day,0)
sgm_tota_2_day_avg!0 = "lev"
sgm_tota_2_day_avg&lev = lev
sgm_tota_2_day_avg&lev@units = "hPa"

N1_day = N1(5:7,:)
N1_day_avg = dim_avg_n(N1_day,0)
N1_day_avg!0 = "lev"
N1_day_avg&lev = lev
N1_day_avg&lev@units = "hPa"



;night mean
CLDLIQ_2_night = CLDLIQ_2(1:4,:)
CLDLIQ_2_night_avg = dim_avg_n(CLDLIQ_2_night,0)
CLDLIQ_2_night_avg!0 = "lev"
CLDLIQ_2_night_avg&lev = lev
CLDLIQ_2_night_avg&lev@units = "hPa"

CLOUD_2_night = CLOUD_2(1:4,:)
CLOUD_2_night_avg = dim_avg_n(CLOUD_2_night,0)
CLOUD_2_night_avg!0 = "lev"
CLOUD_2_night_avg&lev = lev
CLOUD_2_night_avg&lev@units = "hPa"

sgm_tota_2_night = sgm_tota_2(1:4,:)
sgm_tota_2_night_avg = dim_avg_n(sgm_tota_2_night,0)
sgm_tota_2_night_avg!0 = "lev"
sgm_tota_2_night_avg&lev = lev
sgm_tota_2_night_avg&lev@units = "hPa"

N1_night = N1(1:4,:)
N1_night_avg = dim_avg_n(N1_night,0)
N1_night_avg!0 = "lev"
N1_night_avg&lev = lev
N1_night_avg&lev@units = "hPa"




CLDLIQ_dn = new((/4,dimsizes(lev)/),float)
CLDLIQ_dn(0,:) = CLDLIQ_1_day_avg
CLDLIQ_dn(1,:) = CLDLIQ_1_night_avg
CLDLIQ_dn(2,:) = CLDLIQ_2_day_avg
CLDLIQ_dn(3,:) = CLDLIQ_2_night_avg

CLOUD_dn = new((/4,dimsizes(lev)/),float)
CLOUD_dn(0,:) = CLOUD_1_day_avg
CLOUD_dn(1,:) = CLOUD_1_night_avg
CLOUD_dn(2,:) = CLOUD_2_day_avg
CLOUD_dn(3,:) = CLOUD_2_night_avg

sgm_tota_dn = new((/4,dimsizes(lev)/),float)
sgm_tota_dn(0,:) = 0.0
sgm_tota_dn(1,:) = 0.0 
sgm_tota_dn(2,:) = sgm_tota_2_day_avg
sgm_tota_dn(3,:) = sgm_tota_2_night_avg

N1_dn = new((/4,dimsizes(lev)/),float)
N1_dn(0,:) = 0.0
N1_dn(1,:) = 0.0 
N1_dn(2,:) = N1_day_avg
N1_dn(3,:) = N1_night_avg





;************************create plot***************
wks = gsn_open_wks("x11","figure/85W-profile-ql-sgm-day-night")
plot = new(4,graphic)

;colors = (/"black","blue","magenta","brown","burlywood","darkgreen","darkorange","purple"/)
colors = (/"blue","blue","red","red","black","black","darkorange","purple"/)

res = True
;res@tiMainString = "Temperature (85W,20S)" 	;add title
res@trYReverse = True 				;reverse Y-axis
res@gsnFrame = False 				;don't advance frame yet
res@gsnDraw = False
res@trYMinF =700
res@trYMaxF = lev(29)
res@xyMarkLineModes = "Lines"
;res@xyMarkers = markers
res@tiXAxisString = "temperature [K]"
res@tiYAxisString = "pressure [hPa]"
res@xyLineColors = colors 
res@xyLineThicknessF = 2.0
;res@xyDashPatterns = (/0,2,0,2,0,2,0,0/)
res@xyDashPatterns = (/0,16,0,16,0,16,0,16/)


res@tiXAxisString = "ql [g/kg]"
res@trXMinF = 0
res@trXMaxF = 0.25
res@gsnLeftString = "(e)"
plot(0) = gsn_csm_xy(wks,CLDLIQ_dn,CLDLIQ_dn&lev,res)



;========================
;Attach a legend
lgres = True
lgres@lgLineColors = colors
lgres@lgLineThicknesses = res@xyLineThicknessF
lgres@lgDashIndexes = res@xyDashPatterns
lgres@lgItemTypes = res@xyMarkLineModes
lgres@lgLabelFontHeightF = .08 
lgres@vpWidthF = 0.18 
lgres@vpHeightF = 0.22
;lgres@lgPerimThicknessF = 1.0
lgres@lgPerimOn = False


labels = (/"Old-day","Old-night","New-day","New-night"/)

legend = gsn_create_legend(wks,4,labels,lgres)

amres = True
amres@amJust = "TopRight"
amres@amParallelPosF = 0.5
amres@amOrthogonalPosF = -0.5 
annoid = gsn_add_annotation(plot(0),legend,amres)

;========================
res@tiXAxisString = "cloud fraction"
res@trXMinF = 0
res@trXMaxF = 1.0
res@gsnLeftString = "(f)"
plot(1) = gsn_csm_xy(wks,CLOUD_dn,CLOUD_dn&lev,res)

;========================
res@tiXAxisString = "sub-grid stdv.(10~S~-3~N~)"
res@trXMinF = 0
res@trXMaxF = 0.5
res@gsnLeftString = "(g)"

plot(2) = gsn_csm_xy(wks,sgm_tota_dn,sgm_tota_dn&lev,res)

res@tiXAxisString = "freq. of deltaq_sat"
res@trXMinF = 0
res@trXMaxF = 1.0
res@gsnLeftString = "(h)"
plot(3) = gsn_csm_xy(wks,N1_dn,N1_dn&lev,res)



gsn_panel(wks,plot,(/2,2/),False)

end
