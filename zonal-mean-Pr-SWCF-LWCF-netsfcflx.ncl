load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_lat_interpolate.ncl"
load "./functions_hemisphere_asymmetry.ncl"

begin

fdir1 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/F_2000_f09f09_MG1.5/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15/atm/hist/"
fdir3 = "/home/lyl/WORK3/qinyi/data/obs_data/"

fn1 = "F_2000_f09f09_MG1.5.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d-MG15.cam.h0.ANN.nc"
fn3 = "GPCP_ANN_climo.nc"
fn4 = "CERES-EBAF_ANN_climo.nc"
fn5 = "JRA25_ANN_climo.nc"

f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")
f3 = addfile(fdir3+fn3,"r")
f4 = addfile(fdir3+fn4,"r")
f5 = addfile(fdir3+fn5,"r")

lon1 = f1->lon
lat1 = f1->lat

lon3 = f3->lon
lat3 = f3->lat

;===========Precipitation
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

prect_obs = f3->PRECT

;=============SWCF
SWCF_old = f1->SWCF
SWCF_new = f2->SWCF
SWCF_obs = f4->SWCF

;=============LWCF
LWCF_old = f1->LWCF
LWCF_new = f2->LWCF
LWCF_obs = f4->LWCF

;=============net surface flux
FSNS_old = f1->FSNS
FLNS_old = f1->FLNS
LHFLX_old = f1->LHFLX
SHFLX_old = f1->SHFLX
net_sfc_flux_old = FSNS_old-FLNS_old-LHFLX_old-SHFLX_old

FSNS_new = f2->FSNS
FLNS_new = f2->FLNS
LHFLX_new = f2->LHFLX
SHFLX_new = f2->SHFLX
net_sfc_flux_new = FSNS_new-FLNS_new-LHFLX_new-SHFLX_new

FSNS_obs = f5->FSNS
FLNS_obs = f5->FLNS
LHFLX_obs = f5->LHFLX
SHFLX_obs = f5->SHFLX
net_sfc_flux_obs = (-1.0)*FSNS_obs-FLNS_obs-LHFLX_obs-SHFLX_obs

copy_VarCoords(net_sfc_flux_old,FSNS_old)
copy_VarCoords(net_sfc_flux_new,FSNS_new)
copy_VarCoords(net_sfc_flux_obs,FSNS_obs)

;=============zonal mean
prect_old_zm = dim_avg_Wrap(prect_old)
prect_new_zm = dim_avg_Wrap(prect_new)
prect_obs_zm = dim_avg_Wrap(prect_obs)

LWCF_old_zm = dim_avg_Wrap(LWCF_old)
LWCF_new_zm = dim_avg_Wrap(LWCF_new)
LWCF_obs_zm = dim_avg_Wrap(LWCF_obs)

SWCF_old_zm = dim_avg_Wrap(SWCF_old)
SWCF_new_zm = dim_avg_Wrap(SWCF_new)
SWCF_obs_zm = dim_avg_Wrap(SWCF_obs)

net_sfc_flux_old_zm = dim_avg_Wrap(net_sfc_flux_old)
net_sfc_flux_new_zm = dim_avg_Wrap(net_sfc_flux_new)
net_sfc_flux_obs_zm = dim_avg_Wrap(net_sfc_flux_obs)


;============interpolate
lat1 = f1->lat
lat2 = f2->lat
lat3 = f3->lat
lat4 = f4->lat
lat5 = f5->lat

prect = lat_interpolate(prect_old_zm(0,:),lat1,prect_new_zm(0,:),lat2,prect_obs_zm(0,:),lat3)
LWCF = lat_interpolate(LWCF_old_zm(0,:),lat1,LWCF_new_zm(0,:),lat2,LWCF_obs_zm(0,:),lat4)
SWCF = lat_interpolate(SWCF_old_zm(0,:),lat1,SWCF_new_zm(0,:),lat2,SWCF_obs_zm(0,:),lat4)
net_sfc_flux = lat_interpolate(net_sfc_flux_old_zm(0,:),lat1,net_sfc_flux_new_zm(0,:),lat2,net_sfc_flux_obs_zm(0,:),lat5)


;=================semi-hemisphere asymmetry
prect_asy = hemis_asymmetry(prect,prect&line,prect&lat)
LWCF_asy = hemis_asymmetry(LWCF,LWCF&line,LWCF&lat)
SWCF_asy = hemis_asymmetry(SWCF,SWCF&line,SWCF&lat)
net_sfc_flux_asy = hemis_asymmetry(net_sfc_flux,net_sfc_flux&line,net_sfc_flux&lat)


;create plot
wks = gsn_open_wks("x11","./figure/zonal-mean-Pr-SWCF-LWCF-netsfcflx")
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


res@tiYAxisString      = "Precipitation (mm/day)" 
plot(0)  = gsn_csm_xy (wks,prect&lat,prect,res) ; create plot

res@tiYAxisString      = "Precipitation difference (mm/day)"
plot(1)  = gsn_csm_xy (wks,prect_asy&lat,prect_asy,res)

res@tiYAxisString      = "SWCF (W/m~S~2~N~)" 
plot(2)  = gsn_csm_xy (wks,SWCF&lat,SWCF,res) ; create plot

res@tiYAxisString      = "SWCF difference (W/m~S~2~N~)"
plot(3)  = gsn_csm_xy (wks,SWCF_asy&lat,SWCF_asy,res)

res@tiYAxisString      = "LWCF (W/m~S~2~N~)" 
plot(4)  = gsn_csm_xy (wks,LWCF&lat,LWCF,res) ; create plot

res@tiYAxisString      = "LWCF difference (W/m~S~2~N~)"
plot(5)  = gsn_csm_xy (wks,LWCF_asy&lat,LWCF_asy,res)

res@tiYAxisString      = "Net Surface Flux (W/m~S~2~N~)" 
plot(6)  = gsn_csm_xy (wks,net_sfc_flux&lat,net_sfc_flux,res) ; create plot

res@tiYAxisString      = "Net Surface Flux difference (W/m~S~2~N~)"
plot(7)  = gsn_csm_xy (wks,net_sfc_flux_asy&lat,net_sfc_flux_asy,res)

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
amres@amJust = "TopLeft"
amres@amParallelPosF = -0.5
amres@amOrthogonalPosF = -0.5

annoid = gsn_add_annotation(plot(0),legend,amres)


gsn_panel(wks,plot,(/4,2/),False)


end
