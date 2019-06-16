load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_lat_interpolate.ncl"
;load "./functions_hemisphere_asymmetry.ncl"

function get_data(inptr_obs:file,inptr_def:file,inptr_new:file,var:string)
begin

lat_obs = inptr_obs->lat
lat_def = inptr_def->lat
lat_new = inptr_new->lat

LANDFRAC = inptr_def->LANDFRAC

if(isfilevar(inptr_obs,var).and.isfilevar(inptr_def,var).and.isfilevar(inptr_new,var))then
    tmp_def = inptr_def->$var$
    tmp_new = inptr_new->$var$
    tmp_obs = inptr_obs->$var$

else
    if(var.eq."PRECT")then
    tmp_obs = inptr_obs->PRECT

    tmp_def_1 = inptr_def->PRECL
    tmp_def_2 = inptr_def->PRECC
    tmp_def = tmp_def_1
    tmp_def = (/tmp_def_1+tmp_def_2/)

    tmp_new_1 = inptr_new->PRECL
    tmp_new_2 = inptr_new->PRECC
    tmp_new = tmp_new_1
    tmp_new = (/tmp_new_1+tmp_new_2/)
    end if

    if(var.eq."LWP")then
    tmp_obs = inptr_obs->TGCLDLWP_OCEAN
    tmp_def_all = inptr_def->TGCLDLWP
    tmp_new_all = inptr_new->TGCLDLWP

    tmp_def = mask(tmp_def_all,LANDFRAC,0)
    tmp_new = mask(tmp_new_all,LANDFRAC,0)
    end if

    if(var.eq."net_surf_flux")then
    tmp_def_FSNS  = inptr_def->FSNS
    tmp_def_FLNS  = inptr_def->FLNS
    tmp_def_LHFLX = inptr_def->LHFLX
    tmp_def_SHFLX = inptr_def->SHFLX
    tmp_def = tmp_def_FSNS-tmp_def_FLNS-tmp_def_LHFLX-tmp_def_SHFLX

    tmp_new_FSNS  = inptr_new->FSNS
    tmp_new_FLNS  = inptr_new->FLNS
    tmp_new_LHFLX = inptr_new->LHFLX
    tmp_new_SHFLX = inptr_new->SHFLX
    tmp_new = tmp_new_FSNS-tmp_new_FLNS-tmp_new_LHFLX-tmp_new_SHFLX

    tmp_obs_FSNS  = inptr_obs->FSNS
    tmp_obs_FLNS  = inptr_obs->FLNS
    tmp_obs_LHFLX = inptr_obs->LHFLX
    tmp_obs_SHFLX = inptr_obs->SHFLX
    tmp_obs = (-1.0)*tmp_obs_FSNS-tmp_obs_FLNS-tmp_obs_LHFLX-tmp_obs_SHFLX

    end if


end if


if(var.eq."CLDLOW".or.var.eq."CLDMED".or.var.eq."CLDHGH".or.var.eq."CLDTOT")then
tmp_def = tmp_def*100.
tmp_new = tmp_new*100.
end if

if(var.eq."PRECT")then
tmp_def = tmp_def*8.64e7
tmp_new = tmp_new*8.64e7
end if

if(var.eq."LWP")then
tmp_def = tmp_def*1e3
tmp_new = tmp_new*1e3
end if

if(var.eq."FSNS")then
tmp_obs = tmp_obs*(-1.0)
end if




tmp_def_zm = dim_avg_Wrap(tmp_def)
tmp_new_zm = dim_avg_Wrap(tmp_new)
tmp_obs_zm = dim_avg_Wrap(tmp_obs)

;interpolate data
; for cloudsat data
if(var.eq."CLDLOW".or.var.eq."CLDMED".or.var.eq."CLDHGH".or.var.eq."CLDTOT")then
data = lat_interpolate(tmp_def_zm(0,:),lat_def,tmp_new_zm(0,:),lat_new,tmp_obs_zm(:),lat_obs)
else
data = lat_interpolate(tmp_def_zm(0,:),lat_def,tmp_new_zm(0,:),lat_new,tmp_obs_zm(0,:),lat_obs)
end if

delete([/tmp_def,tmp_new,tmp_obs,tmp_def_zm,tmp_new_zm,tmp_obs_zm/])


return(data)

end

begin
fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/FC5_f09f09_MG15/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-revise-2-COSP/atm/hist/"
fdir3 = "/home/lyl/WORK3/qinyi/data/obs_data/"

fn1 = "FC5_f09f09_MG15.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d-MG15-revise-2-COSP.cam.h0.ANN.nc"

fn3 = "CLOUDSAT_ANN_climo.nc"
fn4 = "GPCP_ANN_climo.nc"
fn5 = "CERES-EBAF_ANN_climo.nc"
;fn6 = "NVAP_ANN_climo.nc"
fn6 = "SSMI_ANN_climo.nc"
fn7 = "JRA25_ANN_climo.nc"


f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")
f3 = addfile(fdir3+fn3,"r")
f4 = addfile(fdir3+fn4,"r")
f5 = addfile(fdir3+fn5,"r")
f6 = addfile(fdir3+fn6,"r")
f7 = addfile(fdir3+fn7,"r")

LANDFRAC = f1->LANDFRAC(0,:,:)

CLDLOW = get_data(f3,f1,f2,"CLDLOW")
CLDMED = get_data(f3,f1,f2,"CLDMED")
CLDHGH = get_data(f3,f1,f2,"CLDHGH")
CLDTOT = get_data(f3,f1,f2,"CLDTOT")

PRECT = get_data(f4,f1,f2,"PRECT")
SWCF = get_data(f5,f1,f2,"SWCF")
LWCF = get_data(f5,f1,f2,"LWCF")
LWP = get_data(f6,f1,f2,"LWP")
net_surf_flux = get_data(f7,f1,f2,"net_surf_flux")

FSNS = get_data(f7,f1,f2,"FSNS")
FLNS = get_data(f7,f1,f2,"FLNS")
LHFLX = get_data(f7,f1,f2,"LHFLX")
SHFLX = get_data(f7,f1,f2,"SHFLX")



; 2017-05-30 10:53:21 added
CRF = LWCF
CRF = (/SWCF+LWCF/)
printVarSummary(CRF)

colors = (/"blue","red","black"/)


;create plot
wks = gsn_open_wks("pdf","./figure/zonal-mean-function")
plot= new(12,graphic)

res = True

;res@gsnFrame = False
;res@gsnDraw = False

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

;===========================

res@tiYAxisString      = "CLDLOW (%)" 
plot(0)  = gsn_csm_xy (wks,CLDLOW&lat,CLDLOW,res) ; create plot

;==========================
;Use gsn_add_annotation to attach this legend to our existing plot.
;This way, if we resize the plot,the legend will stay with the plot
;and be resized automatically.

amres = True
amres@amJust = "TopLeft"
amres@amParallelPosF = -0.1
amres@amOrthogonalPosF = -0.4
annoid = gsn_add_annotation(plot(0),legend,amres)
;===========================

res@tiYAxisString      = "CLDTOT (%)" 
plot(1)  = gsn_csm_xy (wks,CLDTOT&lat,CLDTOT,res) ; create plot

res@tiYAxisString      = "PRECT (mm/day)" 
plot(2)  = gsn_csm_xy (wks,PRECT&lat,PRECT,res) ; create plot

res@tiYAxisString      = "LWP (g/m2)"
plot(3)  = gsn_csm_xy (wks,LWP&lat,LWP,res)

res@tiYAxisString      = "SWCF (W/m~S~2~N~)"
plot(4)  = gsn_csm_xy (wks,SWCF&lat,SWCF,res)

res@tiYAxisString      = "LWCF (W/m~S~2~N~)"
plot(5)  = gsn_csm_xy (wks,LWCF&lat,LWCF,res)

res@tiYAxisString      = "Net CRF (W/m~S~2~N~)"
plot(6)  = gsn_csm_xy (wks,CRF&lat,CRF,res)

res@tiYAxisString      = "Net Surf Flux (W/m~S~2~N~)"
plot(7)  = gsn_csm_xy (wks,net_surf_flux&lat,net_surf_flux,res)

res@tiYAxisString      = "FSNS (W/m~S~2~N~)"
plot(8)  = gsn_csm_xy (wks,FSNS&lat,FSNS,res)

res@tiYAxisString      = "FLNS (W/m~S~2~N~)"
plot(9)  = gsn_csm_xy (wks,FLNS&lat,FLNS,res)

res@tiYAxisString      = "LHFLX (W/m~S~2~N~)"
plot(10)  = gsn_csm_xy (wks,LHFLX&lat,LHFLX,res)

res@tiYAxisString      = "SHFLX (W/m~S~2~N~)"
plot(11)  = gsn_csm_xy (wks,SHFLX&lat,SHFLX,res)



press = True
press@gsnPanelScalePlotIndex = 2   ; 3rd plot in list, which is the biggest
press@gsnPanelYWhiteSpacePercent = 5.0
press@gsnPanelXWhiteSpacePercent = 5.0
;pres@gsnAttachPlotsXAxis = True

press@amJust = "TopRight"
;press@gsnPanelFigureStrings = (/"(a)","(d)","(b)","(e)","(c)","(f)"/)

gsn_panel(wks,plot,(/4,3/),press)


end
