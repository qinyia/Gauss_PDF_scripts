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

time = f1->time
lev = f1->lev

lon = f1->lon

CLDLIQ_1 = new((/3,dimsizes(time),dimsizes(lev)/),float)
CLOUD_1 = new((/3,dimsizes(time),dimsizes(lev)/),float)

CLDLIQ_1(0,:,:) = f1->CLDLIQ(:,:,{-20},{285}) ; 75W
CLDLIQ_1(1,:,:) = f1->CLDLIQ(:,:,{-20},{275}) ; 85W
CLDLIQ_1(2,:,:) = f1->CLDLIQ(:,:,{-20},{265}) ; 95W

CLDLIQ_1 = CLDLIQ_1*1000.

CLOUD_1(0,:,:) = f1->CLOUD(:,:,{-20},{285})
CLOUD_1(1,:,:) = f1->CLOUD(:,:,{-20},{275})
CLOUD_1(2,:,:) = f1->CLOUD(:,:,{-20},{265})

;======day mean
CLDLIQ_1_day = CLDLIQ_1(:,5:7,:)
CLDLIQ_1_day_avg = dim_avg_n_Wrap(CLDLIQ_1_day,1)

CLOUD_1_day = CLOUD_1(:,5:7,:)
CLOUD_1_day_avg = dim_avg_n_Wrap(CLOUD_1_day,1)

;night mean
CLDLIQ_1_night = CLDLIQ_1(:,1:4,:)
CLDLIQ_1_night_avg = dim_avg_n_Wrap(CLDLIQ_1_night,1)

CLOUD_1_night = CLOUD_1(:,1:4,:)
CLOUD_1_night_avg = dim_avg_n_Wrap(CLOUD_1_night,1)

;all day mean
CLDLIQ_1_avg = dim_avg_n_Wrap(CLDLIQ_1,1)
CLOUD_1_avg = dim_avg_n_Wrap(CLOUD_1,1)

;==============================
f2 = addfile(fdir2+fname2,"r")

CLDLIQ_2 = new((/3,dimsizes(time),dimsizes(lev)/),float)
CLOUD_2 = new((/3,dimsizes(time),dimsizes(lev)/),float)
sgm_tota_2 = new((/3,dimsizes(time),dimsizes(lev)/),float)
N1_2 = new((/3,dimsizes(time),dimsizes(lev)/),float)

CLDLIQ_2(0,:,:) = f2->CLDLIQ(:,:,{-20},{285}) ; 75W
CLDLIQ_2(1,:,:) = f2->CLDLIQ(:,:,{-20},{275}) ; 85W
CLDLIQ_2(2,:,:) = f2->CLDLIQ(:,:,{-20},{265}) ; 95W

CLDLIQ_2 = CLDLIQ_2*1000.

CLOUD_2(0,:,:) = f2->CLOUD(:,:,{-20},{285})
CLOUD_2(1,:,:) = f2->CLOUD(:,:,{-20},{275})
CLOUD_2(2,:,:) = f2->CLOUD(:,:,{-20},{265})

sgm_tota_2(0,:,:) = f2->sgm_tota(:,:,{-20},{285})
sgm_tota_2(1,:,:) = f2->sgm_tota(:,:,{-20},{275})
sgm_tota_2(2,:,:) = f2->sgm_tota(:,:,{-20},{265})

sgm_tota_2 = sqrt(abs(sgm_tota_2))*1e3

N1_2(0,:,:) = f2->N1(:,:,{-20},{285})
N1_2(1,:,:) = f2->N1(:,:,{-20},{275})
N1_2(2,:,:) = f2->N1(:,:,{-20},{265})

;======day mean
CLDLIQ_2_day = CLDLIQ_2(:,5:7,:)
CLDLIQ_2_day_avg = dim_avg_n_Wrap(CLDLIQ_2_day,1)

CLOUD_2_day = CLOUD_2(:,5:7,:)
CLOUD_2_day_avg = dim_avg_n_Wrap(CLOUD_2_day,1)

sgm_tota_2_day = sgm_tota_2(:,5:7,:)
sgm_tota_2_day_avg = dim_avg_n_Wrap(sgm_tota_2_day,1)

N1_2_day = N1_2(:,5:7,:)
N1_2_day_avg = dim_avg_n_Wrap(N1_2_day,1)



;night mean
CLDLIQ_2_night = CLDLIQ_2(:,1:4,:)
CLDLIQ_2_night_avg = dim_avg_n_Wrap(CLDLIQ_2_night,1)

CLOUD_2_night = CLOUD_2(:,1:4,:)
CLOUD_2_night_avg = dim_avg_n_Wrap(CLOUD_2_night,1)

sgm_tota_2_night = sgm_tota_2(:,1:4,:)
sgm_tota_2_night_avg = dim_avg_n_Wrap(sgm_tota_2_night,1)

N1_2_night = N1_2(:,1:4,:)
N1_2_night_avg = dim_avg_n_Wrap(N1_2_night,1)

;all day mean
CLDLIQ_2_avg = dim_avg_n_Wrap(CLDLIQ_2,1)
CLOUD_2_avg = dim_avg_n_Wrap(CLOUD_2,1)
sgm_tota_2_avg = dim_avg_n_Wrap(sgm_tota_2,1)
N1_2_avg = dim_avg_n_Wrap(N1_2,1)



CLDLIQ_dn = new((/12,dimsizes(lev)/),float)
CLDLIQ_dn(0:2,:) = CLDLIQ_1_day_avg
CLDLIQ_dn(3:5,:) = CLDLIQ_1_night_avg
CLDLIQ_dn(6:8,:) = CLDLIQ_2_day_avg
CLDLIQ_dn(9:11,:) = CLDLIQ_2_night_avg

CLOUD_dn = new((/12,dimsizes(lev)/),float)
CLOUD_dn(0:2,:) = CLOUD_1_day_avg
CLOUD_dn(3:5,:) = CLOUD_1_night_avg
CLOUD_dn(6:8,:) = CLOUD_2_day_avg
CLOUD_dn(9:11,:) = CLOUD_2_night_avg

sgm_tota_dn = new((/12,dimsizes(lev)/),float)
sgm_tota_dn(0:2,:) = 0.0
sgm_tota_dn(3:5,:) = 0.0 
sgm_tota_dn(6:8,:) = sgm_tota_2_day_avg
sgm_tota_dn(9:11,:) = sgm_tota_2_night_avg

N1_dn = new((/12,dimsizes(lev)/),float)
N1_dn(0:2,:) = 0.0
N1_dn(3:5,:) = 0.0 
N1_dn(6:8,:) = N1_2_day_avg
N1_dn(9:11,:) = N1_2_night_avg

; no separate between day and night
CLDLIQ_all_day = new((/6,dimsizes(lev)/),float)
CLDLIQ_all_day(0:2,:) = CLDLIQ_1_avg
CLDLIQ_all_day(3:5,:) = CLDLIQ_2_avg

CLOUD_all_day = new((/6,dimsizes(lev)/),float)
CLOUD_all_day(0:2,:) = CLOUD_1_avg
CLOUD_all_day(3:5,:) = CLOUD_2_avg
;CLOUD_all_day(0:2,:) = CLOUD_1_day_avg
;CLOUD_all_day(3:5,:) = CLOUD_2_day_avg
;CLOUD_all_day(0:2,:) = CLOUD_1_night_avg
;CLOUD_all_day(3:5,:) = CLOUD_2_night_avg



sgm_tota_all_day = new((/6,dimsizes(lev)/),float)
sgm_tota_all_day(0:2,:) = 0.0
sgm_tota_all_day(3:5,:) = sgm_tota_2_avg

N1_all_day = new((/6,dimsizes(lev)/),float)
N1_all_day(0:2,:) = 0.0
N1_all_day(3:5,:) = N1_2_avg


;***********************create plot***************
;wks = gsn_open_wks("eps","../figure/fig3-profile_ql_sgm_day_night_75W_2_95W-eps")
wks = gsn_open_wks("pdf","../figure/fig3-profile_ql_sgm_day_night_75W_2_95W")

plot = new(4,graphic)

;colors = (/"black","blue","magenta","brown","burlywood","darkgreen","darkorange","purple"/)
; use colors to separate three stations
colors = (/"blue","red","black","blue","red","black","blue","red","black","blue","red","black"/)
; use marker to separate day and night
markermode = (/"Lines","Lines","Lines","Lines","Lines","Lines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines"/)
;markermode = (/"MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines"/)
markers = (/16,16,16,16,16,16/)
;markers = (/4,6,7,4,6,7,4,6,7/)
; use dash line to separate two cases
dashes = (/0,0,0,1,1,1/)
;thickes = (/1.5,3,5,1.5,3,5/)
thickes = (/3,2,1,3,2,1/)

res = True
;res@tiMainString = "Temperature (85W,20S)" 	;add title
res@trYReverse = True 				;reverse Y-axis
res@gsnFrame = False 				;don't advance frame yet
res@gsnDraw = False
res@trYMinF =700
res@trYMaxF = lev(29)
res@xyMarkLineModes = markermode
;res@xyMarkers = markers
;res@xyMarkerSizeF	= 0.03
;res@xyMarkerColors  = colors
res@tiXAxisString = "temperature (K)"
res@tiYAxisString = "pressure (hPa)"
res@xyLineColors = colors 
;res@xyLineColor	= "black"
;res@xyMonoLineColor = True
res@xyLineThicknesses= thickes
res@xyDashPatterns = dashes


res@tiXAxisString = "q~B~l~N~ (g kg~S~-1~N~)"
res@trXMinF = 0
res@trXMaxF = 0.25
res@gsnLeftString = "(a)"

;res@gsnLeftStringFontHeightF = 0.03

ft								= 0.025
res@gsnStringFontHeightF		= ft+0.005
res@tmXTOn						= False
res@tmYROn						= False
res@tmXBLabelFontHeightF		= ft
res@tmYLLabelFontHeightF		= ft 
res@tmXBMinorOn					= False
res@tmYLMinorOn					= False

res@tiXAxisFontHeightF			= ft+0.005
res@tiYAxisFontHeightF			= ft+0.005


plot(0) = gsn_csm_xy(wks,CLDLIQ_all_day,CLDLIQ_all_day&lev,res)
;plot(0) = gsn_csm_xy(wks,CLDLIQ_dn,CLDLIQ_dn&lev,res)


;========================
;Attach a legend
lgres = True
lgres@lgMonoItemType = False
lgres@lgMonoDashIndex	= False
lgres@lgLineColors = colors
lgres@lgMonoLineThickness = False
lgres@lgLineThicknesses = (/3,2,1/) ;res@xyLineThicknesses
lgres@lgDashIndexes = res@xyDashPatterns
lgres@lgItemTypes = res@xyMarkLineModes
lgres@lgLabelFontHeightF = .10
lgres@vpWidthF = 0.27
lgres@vpHeightF = 0.22
;lgres@lgPerimThicknessF = 1.0
lgres@lgPerimOn = False

labels_RH = (/"Park_RH-75W","Park_RH-85W","Park_RH-95W"/)
labels_PDF = (/"Gauss_PDF-75W","Gauss_PDF-85W","Gauss_PDF-95W"/)

legend_RH = gsn_create_legend(wks,3,labels_RH,lgres)

lgres@lgDashIndexes = (/1,1,1,1,1,1/)
;lgres@lgLineThicknesses = (/1.5,1.5,1.5/)*2 ;res@xyLineThicknesses
legend_PDF = gsn_create_legend(wks,3,labels_PDF,lgres)

amres_RH = True
amres_RH@amJust = "TopLeft"
amres_RH@amParallelPosF = -0.5
amres_RH@amOrthogonalPosF = -0.5 
annoid_RH = gsn_add_annotation(plot(0),legend_RH,amres_RH)



amres_PDF = True
amres_PDF@amJust = "TopRight"
amres_PDF@amParallelPosF = 0.5
amres_PDF@amOrthogonalPosF = -0.5 
annoid_PDF = gsn_add_annotation(plot(0),legend_PDF,amres_PDF)



;========================
res@tiXAxisString = "cloud fraction"
res@trXMinF = 0
res@trXMaxF = 1.0
res@gsnLeftString = "(b)"
plot(1) = gsn_csm_xy(wks,CLOUD_all_day,CLOUD_all_day&lev,res)

;========================
res@tiXAxisString = "~F33~s~N~ (10~S~-3~N~)"
res@trXMinF = 0
res@trXMaxF = 0.5
res@gsnLeftString = "(c)"

plot(2) = gsn_csm_xy(wks,sgm_tota_all_day,sgm_tota_all_day&lev,res)

res@tiXAxisString = "freq. of deltaq_sat"
res@trXMinF = 0
res@trXMaxF = 1.0
res@gsnLeftString = "(d)"
plot(3) = gsn_csm_xy(wks,N1_all_day,N1_all_day&lev,res)



gsn_panel(wks,plot,(/2,2/),False)

end
