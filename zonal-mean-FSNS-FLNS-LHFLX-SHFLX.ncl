load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_lat_interpolate.ncl"
load "./functions_hemisphere_asymmetry.ncl"

begin
fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/F_2000_f09f09_MG1.5/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-revise/atm/hist/"
fdir3 = "/home/lyl/WORK3/qinyi/data/obs_data/"

fn1 = "F_2000_f09f09_MG1.5.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d-MG15-revise.cam.h0.ANN.nc"
fn3 = "JRA25_ANN_climo.nc"

f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")
f3 = addfile(fdir3+fn3,"r")

;=============net surface flux
FSNS_old = f1->FSNS
FLNS_old = f1->FLNS
LHFLX_old = f1->LHFLX
SHFLX_old = f1->SHFLX

FSNS_new = f2->FSNS
FLNS_new = f2->FLNS
LHFLX_new = f2->LHFLX
SHFLX_new = f2->SHFLX

FSNS_obs = f3->FSNS
FLNS_obs = f3->FLNS
LHFLX_obs = f3->LHFLX
SHFLX_obs = f3->SHFLX

FSNS_obs = -1.0*FSNS_obs

;=============zonal mean
FSNS_old_zm = dim_avg_Wrap(FSNS_old)
FSNS_new_zm = dim_avg_Wrap(FSNS_new)
FSNS_obs_zm = dim_avg_Wrap(FSNS_obs)

FLNS_old_zm = dim_avg_Wrap(FLNS_old)
FLNS_new_zm = dim_avg_Wrap(FLNS_new)
FLNS_obs_zm = dim_avg_Wrap(FLNS_obs)

LHFLX_old_zm = dim_avg_Wrap(LHFLX_old)
LHFLX_new_zm = dim_avg_Wrap(LHFLX_new)
LHFLX_obs_zm = dim_avg_Wrap(LHFLX_obs)

SHFLX_old_zm = dim_avg_Wrap(SHFLX_old)
SHFLX_new_zm = dim_avg_Wrap(SHFLX_new)
SHFLX_obs_zm = dim_avg_Wrap(SHFLX_obs)


;============interpolate
lat1 = f1->lat
lat2 = f2->lat
lat3 = f3->lat

FSNS = lat_interpolate(FSNS_old_zm(0,:),lat1,FSNS_new_zm(0,:),lat2,FSNS_obs_zm(0,:),lat3)
FLNS = lat_interpolate(FLNS_old_zm(0,:),lat1,FLNS_new_zm(0,:),lat2,FLNS_obs_zm(0,:),lat3)
LHFLX = lat_interpolate(LHFLX_old_zm(0,:),lat1,LHFLX_new_zm(0,:),lat2,LHFLX_obs_zm(0,:),lat3)
SHFLX = lat_interpolate(SHFLX_old_zm(0,:),lat1,SHFLX_new_zm(0,:),lat2,SHFLX_obs_zm(0,:),lat3)

;=================semi-hemisphere asymmetry
FSNS_asy = hemis_asymmetry(FSNS,FSNS&line,FSNS&lat)
FLNS_asy = hemis_asymmetry(FLNS,FLNS&line,FLNS&lat)
LHFLX_asy = hemis_asymmetry(LHFLX,LHFLX&line,LHFLX&lat)
SHFLX_asy = hemis_asymmetry(SHFLX,SHFLX&line,SHFLX&lat)


;create plot
wks = gsn_open_wks("x11","./figure/zonal-mean-FSNS-FLNS-LHFLX-SHFLX")
plot= new(8,graphic)

res = True
res@gsnFrame = False
res@gsnDraw = False

;res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
;res@cnMaxLevelValF       = 200        ; min level
;res@cnMinLevelValF       = 10
;res@cnLevelSpacingF      = 10

res@xyMarkLineMode = "Lines"               ; Markers *and* lines
;res@xyMarkers      = (/6,11,16/)               ; 3 different markers
;res@xyMarkerColors = (/"blue","red","black"/) ; 3 different colors
res@xyLineColors = (/"blue","red","black"/) ; 3 different colors
res@xyLineThicknesses = (/2.0,2.0,2.0/)
res@xyDashPatterns = (/16,15,0/)


res@trXMaxF = 90.0

res@tiYAxisString      = "FSNS (W/m~S~2~N~)" 
plot(0)  = gsn_csm_xy (wks,FSNS&lat,FSNS,res) ; create plot

res@tiYAxisString      = "FSNS difference (W/m~S~2~N~)"
plot(1)  = gsn_csm_xy (wks,FSNS_asy&lat,FSNS_asy,res)

res@tiYAxisString      = "FLNS (W/m~S~2~N~)" 
plot(2)  = gsn_csm_xy (wks,FLNS&lat,FLNS,res) ; create plot

res@tiYAxisString      = "FLNS difference (W/m~S~2~N~)"
plot(3)  = gsn_csm_xy (wks,FLNS_asy&lat,FLNS_asy,res)

res@tiYAxisString      = "LHFLX (W/m~S~2~N~)" 
plot(4)  = gsn_csm_xy (wks,LHFLX&lat,LHFLX,res) ; create plot

res@tiYAxisString      = "LHFLX difference (W/m~S~2~N~)"
plot(5)  = gsn_csm_xy (wks,LHFLX_asy&lat,LHFLX_asy,res)

res@tiYAxisString      = "SHFLX (W/m~S~2~N~)" 
plot(6)  = gsn_csm_xy (wks,SHFLX&lat,SHFLX,res) ; create plot

res@tiYAxisString      = "SHFLX difference (W/m~S~2~N~)"
plot(7)  = gsn_csm_xy (wks,SHFLX_asy&lat,SHFLX_asy,res)

colors = (/"blue","red","black"/)
;========================
;Attach a legend
lgres = True
lgres@lgLineColors = colors
lgres@lgItemType = "Lines"
lgres@lgLabelFontHeightF = .08
lgres@vpWidthF = 0.2
lgres@vpHeightF = 0.17
lgres@lgPerimThicknessF = 2.0
lgres@lgMonoDashIndex = True
lgres@lgDashIndex = 0

labels = (/"CAM_old","CAM_new","Obs"/)

legend = gsn_create_legend(wks,3,labels,lgres)

;Use gsn_add_annotation to attach this legend to our existing plot.
;This way, if we resize the plot,the legend will stay with the plot
;and be resized automatically.

amres = True
amres@amJust = "BottomLeft"
amres@amParallelPosF = -0.5
amres@amOrthogonalPosF = 0.5
annoid = gsn_add_annotation(plot(1),legend,amres)



gsn_panel(wks,plot,(/4,2/),False)


end
