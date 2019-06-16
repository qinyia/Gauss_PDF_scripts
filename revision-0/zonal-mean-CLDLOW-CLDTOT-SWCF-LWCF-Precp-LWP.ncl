load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_lat_interpolate.ncl"
load "./functions_hemisphere_asymmetry.ncl"

begin
fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/FC5_f09f09_MG15/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-revise-2-COSP/atm/hist/"
fdir3 = "/home/lyl/WORK3/qinyi/data/obs_data/"

;new-cldfrac16-1d-MG15-revise-shal

fn1 = "FC5_f09f09_MG15.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d-MG15-revise-2-COSP.cam.h0.ANN.nc"
fn3 = "CLOUDSAT_ANN_climo.nc"
fn4 = "GPCP_ANN_climo.nc"
fn5 = "CERES-EBAF_ANN_climo.nc"
;fn6 = "NVAP_ANN_climo.nc"
fn6 = "SSMI_ANN_climo.nc"



f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")
f3 = addfile(fdir3+fn3,"r")
f4 = addfile(fdir3+fn4,"r")
f5 = addfile(fdir3+fn5,"r")
f6 = addfile(fdir3+fn6,"r")


LANDFRAC = f1->LANDFRAC(0,:,:)

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

;============CLDTOT
CLDTOT_old = f1->CLDTOT
CLDTOT_new = f2->CLDTOT
CLDTOT_obs = f3->CLDTOT

CLDTOT_old = CLDTOT_old*100.
CLDTOT_new = CLDTOT_new*100.


;=============Precip
precl_old = f1->PRECL
precc_old = f1->PRECC
prect_old = precl_old+precc_old
prect_old = prect_old*8.64e7
copy_VarCoords(precl_old,prect_old)

precl_new = f2->PRECL
precc_new = f2->PRECC
prect_new = precl_new+precc_new
prect_new = prect_new*8.64e7
copy_VarCoords(precl_new,prect_new)

prect_obs = f4->PRECT

;=============SWCF
SWCF_old = f1->SWCF
SWCF_new = f2->SWCF
SWCF_obs = f5->SWCF

;=============LWCF
LWCF_old = f1->LWCF
LWCF_new = f2->LWCF
LWCF_obs = f5->LWCF

;=============LWP
LWP_old = f1->TGCLDLWP
LWP_new = f2->TGCLDLWP
LWP_obs = f6->TGCLDLWP_OCEAN

LWP_old = LWP_old*1000.
LWP_new = LWP_new*1000.

;mask land fraction
LWP_old_ocean = mask(LWP_old,LANDFRAC,0)
LWP_new_ocean = mask(LWP_new,LANDFRAC,0)
LWP_obs_ocean = LWP_obs
copy_VarCoords(LWP_old,LWP_old_ocean)
copy_VarCoords(LWP_new,LWP_new_ocean)


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

CLDTOT_old_zm = dim_avg_Wrap(CLDTOT_old)
CLDTOT_new_zm = dim_avg_Wrap(CLDTOT_new)
CLDTOT_obs_zm = dim_avg_Wrap(CLDTOT_obs)

prect_old_zm = dim_avg_Wrap(prect_old)
prect_new_zm = dim_avg_Wrap(prect_new)
prect_obs_zm = dim_avg_Wrap(prect_obs)

LWCF_old_zm = dim_avg_Wrap(LWCF_old)
LWCF_new_zm = dim_avg_Wrap(LWCF_new)
LWCF_obs_zm = dim_avg_Wrap(LWCF_obs)

SWCF_old_zm = dim_avg_Wrap(SWCF_old)
SWCF_new_zm = dim_avg_Wrap(SWCF_new)
SWCF_obs_zm = dim_avg_Wrap(SWCF_obs)

LWP_old_zm = dim_avg_Wrap(LWP_old_ocean)
LWP_new_zm = dim_avg_Wrap(LWP_new_ocean)
LWP_obs_zm = dim_avg_Wrap(LWP_obs_ocean)



;============interpolate
lat1 = f1->lat
lat2 = f2->lat
lat3 = f3->lat
lat4 = f4->lat
lat5 = f5->lat
lat6 = f6->lat

;;;;for ISCCP obs data
;CLDLOW = lat_interpolate(CLDLOW_old_zm(0,:),lat1,CLDLOW_new_zm(0,:),lat2,CLDLOW_obs_zm(0,:),lat3)
;CLDMED = lat_interpolate(CLDMED_old_zm(0,:),lat1,CLDMED_new_zm(0,:),lat2,CLDMED_obs_zm(0,:),lat3)
;CLDHGH = lat_interpolate(CLDHGH_old_zm(0,:),lat1,CLDHGH_new_zm(0,:),lat2,CLDHGH_obs_zm(0,:),lat3)

; for cloudsat data
CLDLOW = lat_interpolate(CLDLOW_old_zm(0,:),lat1,CLDLOW_new_zm(0,:),lat2,CLDLOW_obs_zm(:),lat3)
CLDMED = lat_interpolate(CLDMED_old_zm(0,:),lat1,CLDMED_new_zm(0,:),lat2,CLDMED_obs_zm(:),lat3)
CLDHGH = lat_interpolate(CLDHGH_old_zm(0,:),lat1,CLDHGH_new_zm(0,:),lat2,CLDHGH_obs_zm(:),lat3)
CLDTOT = lat_interpolate(CLDTOT_old_zm(0,:),lat1,CLDTOT_new_zm(0,:),lat2,CLDTOT_obs_zm(:),lat3)



prect = lat_interpolate(prect_old_zm(0,:),lat1,prect_new_zm(0,:),lat2,prect_obs_zm(0,:),lat4)
LWCF = lat_interpolate(LWCF_old_zm(0,:),lat1,LWCF_new_zm(0,:),lat2,LWCF_obs_zm(0,:),lat5)
SWCF = lat_interpolate(SWCF_old_zm(0,:),lat1,SWCF_new_zm(0,:),lat2,SWCF_obs_zm(0,:),lat5)
LWP = lat_interpolate(LWP_old_zm(0,:),lat1,LWP_new_zm(0,:),lat2,LWP_obs_zm(0,:),lat6)

;create plot
wks = gsn_open_wks("x11","./figure/zonal-mean-CLDLOW-CLDTOT-SWCF-LWCF-Precp-LWP")
plot1= new(6,graphic)

res = True
res@gsnFrame = False
res@gsnDraw = False

res@vpWidthF = 0.7
res@vpHeightF = 0.4

;res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
;res@cnMaxLevelValF       = 200        ; min level
;res@cnMinLevelValF       = 10
;res@cnLevelSpacingF      = 10

res@xyMarkLineMode = "Lines"               ; Markers *and* lines
;res@xyMarkers      = (/6,11,16/)               ; 3 different markers
;res@xyMarkerColors = (/"blue","red","black"/) ; 3 different colors
res@xyLineColors = (/"blue","red","black"/) ; 3 different colors
res@xyLineThicknesses = (/3.0,3.0,3.0/)
;res@xyDashPatterns = (/16,15,0/)

res@xyDashPatterns = (/0,0,0/)

res@trXMaxF = 90.0

res@tiYAxisString      = "CLDLOW (%)" 
plot1(0)  = gsn_csm_xy (wks,CLDLOW&lat,CLDLOW,res) ; create plot

res@tiYAxisString      = "CLDTOT (%)" 
plot1(1)  = gsn_csm_xy (wks,CLDTOT&lat,CLDTOT,res) ; create plot

res@tiYAxisString      = "PRECT (mm/day)" 
plot1(2)  = gsn_csm_xy (wks,prect&lat,prect,res) ; create plot

res@tiYAxisString      = "LWP (g/m2)"
plot1(3)  = gsn_csm_xy (wks,LWP&lat,LWP,res)

res@tiYAxisString      = "SWCF (W/m~S~2~N~)"
plot1(4)  = gsn_csm_xy (wks,SWCF&lat,SWCF,res)

res@tiYAxisString      = "LWCF (W/m~S~2~N~)"
plot1(5)  = gsn_csm_xy (wks,LWCF&lat,LWCF,res)


colors = (/"blue","red","black"/)
;========================
;Attach a legend
lgres = True
lgres@lgLineColors = colors
lgres@lgItemType = "Lines"
;lgres@lgLabelFontHeightF = .08
lgres@vpWidthF = 0.2
lgres@vpHeightF = 0.10
;lgres@lgPerimThicknessF = 3.0
lgres@lgPerimOn = False
lgres@lgMonoDashIndex = True
lgres@lgDashIndex = 0

labels = (/"RH","PDF","OBS"/)

legend = gsn_create_legend(wks,3,labels,lgres)

;Use gsn_add_annotation to attach this legend to our existing plot.
;This way, if we resize the plot,the legend will stay with the plot
;and be resized automatically.

amres = True
amres@amJust = "TopLeft"
amres@amParallelPosF = -0.1
amres@amOrthogonalPosF = -0.4
annoid = gsn_add_annotation(plot1(0),legend,amres)

press = True
press@gsnPanelScalePlotIndex = 2   ; 3rd plot in list, which is the biggest
press@gsnPanelYWhiteSpacePercent = 5.0
press@gsnPanelXWhiteSpacePercent = 5.0
;pres@gsnAttachPlotsXAxis = True

press@amJust = "TopRight"
press@gsnPanelFigureStrings = (/"(a)","(d)","(b)","(e)","(c)","(f)"/)

gsn_panel(wks,plot1,(/3,2/),press)


end
