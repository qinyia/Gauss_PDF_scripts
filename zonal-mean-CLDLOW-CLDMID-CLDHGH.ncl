load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_lat_interpolate.ncl"
load "./functions_hemisphere_asymmetry.ncl"

begin
fdir1 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/F_2000_f09f09_MG1.5/atm/hist/"
fdir2 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/new-cldfrac14-1d/atm/hist/"
fdir3 = "/home/lyl/WORK3/qinyi/data/obs_data/"

fn1 = "F_2000_f09f09_MG1.5.cam.h0.ANN.nc"
fn2 = "new-cldfrac14-1d.cam.h0.ANN.nc"
fn3 = "ISCCP_ANN_climo.nc"

f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")
f3 = addfile(fdir3+fn3,"r")


;=============CLDLOW
CLDLOW_old = f1->CLDLOW
CLDLOW_new = f2->CLDLOW
CLDLOW_obs = f3->CLDLOW

CLDLOW_old = CLDLOW_old*100.
CLDLOW_new = CLDLOW_new*100.


;=============CLDMED
CLDMED_old = f1->CLDMED
CLDMED_new = f2->CLDMED
CLDMED_obs = f3->CLDMED

CLDMED_old = CLDMED_old*100.
CLDMED_new = CLDMED_new*100.

;============CLDHGH
CLDHGH_old = f1->CLDHGH
CLDHGH_new = f2->CLDHGH
CLDHGH_obs = f3->CLDHGH

CLDHGH_old = CLDHGH_old*100.
CLDHGH_new = CLDHGH_new*100.


;=============zonal mean
CLDLOW_old_zm = dim_avg_Wrap(CLDLOW_old)
CLDLOW_new_zm = dim_avg_Wrap(CLDLOW_new)
CLDLOW_obs_zm = dim_avg_Wrap(CLDLOW_obs)

CLDMED_old_zm = dim_avg_Wrap(CLDMED_old)
CLDMED_new_zm = dim_avg_Wrap(CLDMED_new)
CLDMED_obs_zm = dim_avg_Wrap(CLDMED_obs)

CLDHGH_old_zm = dim_avg_Wrap(CLDHGH_old)
CLDHGH_new_zm = dim_avg_Wrap(CLDHGH_new)
CLDHGH_obs_zm = dim_avg_Wrap(CLDHGH_obs)

;============interpolate
lat1 = f1->lat
lat2 = f2->lat
lat3 = f3->lat

CLDLOW = lat_interpolate(CLDLOW_old_zm(0,:),lat1,CLDLOW_new_zm(0,:),lat2,CLDLOW_obs_zm(0,:),lat3)
CLDMED = lat_interpolate(CLDMED_old_zm(0,:),lat1,CLDMED_new_zm(0,:),lat2,CLDMED_obs_zm(0,:),lat3)
CLDHGH = lat_interpolate(CLDHGH_old_zm(0,:),lat1,CLDHGH_new_zm(0,:),lat2,CLDHGH_obs_zm(0,:),lat3)


;=================semi-hemisphere asymmetry
CLDLOW_asy = hemis_asymmetry(CLDLOW,CLDLOW&line,CLDLOW&lat)
CLDMED_asy = hemis_asymmetry(CLDMED,CLDMED&line,CLDMED&lat)
CLDHGH_asy = hemis_asymmetry(CLDHGH,CLDHGH&line,CLDHGH&lat)




;create plot
wks = gsn_open_wks("x11","./figure/zonal-mean-CLDLOW-CLDMID-CLDHGH")
plot= new(6,graphic)

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

res@tiYAxisString      = "CLDLOW (%)" 
plot(0)  = gsn_csm_xy (wks,CLDLOW&lat,CLDLOW,res) ; create plot

res@tiYAxisString      = "CLDLOW difference (%)"
plot(1)  = gsn_csm_xy (wks,CLDLOW_asy&lat,CLDLOW_asy,res)

res@tiYAxisString      = "CLDMED (%)" 
plot(2)  = gsn_csm_xy (wks,CLDMED&lat,CLDMED,res) ; create plot

res@tiYAxisString      = "CLDMED difference (%)"
plot(3)  = gsn_csm_xy (wks,CLDMED_asy&lat,CLDMED_asy,res)

res@tiYAxisString      = "CLDHGH (%)" 
plot(4)  = gsn_csm_xy (wks,CLDHGH&lat,CLDHGH,res) ; create plot

res@tiYAxisString      = "CLDHGH difference (%)"
plot(5)  = gsn_csm_xy (wks,CLDHGH_asy&lat,CLDHGH_asy,res)

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

pres = True
;pres@gsnPanelScalePlotIndex = 2   ; 3rd plot in list, which is the biggest
pres@gsnPanelYWhiteSpacePercent = 5.0
pres@gsnPanelXWhiteSpacePercent = 5.0
pres@gsnAttachPlotsXAxis = True
gsn_panel(wks,plot,(/3,2/),pres)



end
