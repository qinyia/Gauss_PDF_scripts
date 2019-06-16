load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_lat_interpolate.ncl"
load "./functions_read_file.ncl"
load "./functions_calculate.ncl"
load "./functions_plot.ncl"
begin

dir1 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/"
dir2 = "/home/lyl/WORK3/qinyi/data/"

fdir1 = dir1+"F_2000_f09f09_MG1.5/atm/hist/"
fdir2 = dir1+"new-cldfrac15-1d/atm/hist/"
fdir3 = dir2+"obs_data/"

fn1 = "F_2000_f09f09_MG1.5.cam.h0.ANN.nc"
fn2 = "new-cldfrac15-1d.cam.h0.ANN.nc"
fn3 = "CERES-EBAF_ANN_climo.nc"

f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")
f3 = addfile(fdir3+fn3,"r")

lon1 = f1->lon
lat1 = f1->lat

lon2 = f2->lon
lat2 = f2->lat

lon3 = f3->lon
lat3 = f3->lat

gw1 = f1->gw

gw2 = f3->gw


SWCF_old = f1->SWCF(0,:,:)		;time*lat*lon
SWCF_new = f2->SWCF(0,:,:)		;time*lat*lon
SWCF_obs = f3->SWCF(0,:,:)

LWCF_old = f1->LWCF(0,:,:)		;time*lat*lon
LWCF_new = f2->LWCF(0,:,:)		;time*lat*lon
LWCF_obs = f3->LWCF(0,:,:)

;=============Interpolate to the same grid 
SWCF = lat_lon_interpolate(SWCF_old,lat1,lon1,SWCF_new,lat2,lon2,SWCF_obs,lat3,lon3)
LWCF = lat_lon_interpolate(LWCF_old,lat1,lon1,LWCF_new,lat2,lon2,LWCF_obs,lat3,lon3)

;==============Global Mean Value
SWCF_old_mean = wgt_areaave(SWCF(0,:,:),gw2,1.0,0)
SWCF_new_mean = wgt_areaave(SWCF(1,:,:),gw2,1.0,0)
LWCF_old_mean = wgt_areaave(LWCF(0,:,:),gw2,1.0,0)
LWCF_new_mean = wgt_areaave(LWCF(1,:,:),gw2,1.0,0)


;================Model-Obs difference
SWCF_old_obs = SWCF(0,:,:)-SWCF(2,:,:)
SWCF_new_obs = SWCF(1,:,:)-SWCF(2,:,:)

copy_VarCoords(SWCF(0,:,:),SWCF_old_obs)
copy_VarCoords(SWCF(0,:,:),SWCF_new_obs)

LWCF_old_obs = LWCF(0,:,:)-LWCF(2,:,:)
LWCF_new_obs = LWCF(1,:,:)-LWCF(2,:,:)

copy_VarCoords(LWCF(0,:,:),LWCF_old_obs)
copy_VarCoords(LWCF(0,:,:),LWCF_new_obs)


;================Model-Obs difference global mean value
SWCF_old_obs_mean = wgt_areaave(SWCF_old_obs,gw2,1.0,0)
SWCF_new_obs_mean = wgt_areaave(SWCF_new_obs,gw2,1.0,0)

LWCF_old_obs_mean = wgt_areaave(LWCF_old_obs,gw2,1.0,0)
LWCF_new_obs_mean = wgt_areaave(LWCF_new_obs,gw2,1.0,0)


;create plot
wks = gsn_open_wks("x11","./figure/lon-lat-SWCF-LWCF")
plot= new(3,graphic)

res = True
res@gsnFrame = False
res@gsnDraw = False
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnFillOn = True
res@lbLabelStride = 4
res@lbLabelBarOn = False               ; turn off the label bar

res@mpMinLonF = 0
res@mpMaxLonF = 360
res@mpCenterLonF = 180

plots1 = new(2,graphic)
plots2 = new(2,graphic)
plots3 = new(2,graphic)
plots4 = new(2,graphic)

res1 = res
res1@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res1@cnMaxLevelValF       = 0        ; min level
res1@cnMinLevelValF       = -150
res1@cnLevelSpacingF      = 15
res1@cnFillPalette = "WhiteBlueGreenYellowRed"
res1@gsnSpreadColors = True
res1@gsnSpreadColorStart = 2
res1@gsnSpreadColorEnd = 198


res1@gsnLeftString = "(a) SWCF CAM5_Old mean="+SWCF_old_mean
res1@gsnRightString = "W/m~S~2~N~"
plots1(0) = gsn_csm_contour_map(wks,SWCF(0,:,:),res1)

res1@gsnLeftString = "(b) SWCF CAM5_New mean="+SWCF_new_mean
res1@gsnRightString = "W/m~S~2~N~"
plots1(1) = gsn_csm_contour_map_ce(wks,SWCF(1,:,:),res1)



res2 = res
res2@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res2@cnMaxLevelValF       = 40        ; min level
res2@cnMinLevelValF       = -40
res2@cnLevelSpacingF      = 5
res2@cnFillPalette = "BlueRed"


res2@gsnLeftString = "(c) SWCF CAM_Old-Obs mean="+SWCF_old_obs_mean
res2@gsnRightString = "W/m~S~2~N~"
plots2(0) = gsn_csm_contour_map_ce(wks,SWCF_old_obs(:,:),res2)

res2@gsnLeftString = "(d) SWCF CAM_New-Obs mean="+SWCF_new_obs_mean
res2@gsnRightString = "W/m~S~2~N~"
plots2(1) = gsn_csm_contour_map_ce(wks,SWCF_new_obs(:,:),res2)

res3 = res
res3@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res3@cnMaxLevelValF       = 80        ; min level
res3@cnMinLevelValF       = 0
res3@cnLevelSpacingF      = 8
res3@cnFillPalette = "WhiteBlueGreenYellowRed"
res3@gsnSpreadColors = True
res3@gsnSpreadColorStart = 2
res3@gsnSpreadColorEnd = 198

res3@gsnLeftString = "(e) LWCF CAM_Old mean="+LWCF_old_mean
res3@gsnRightString = "W/m~S~2~N~"
plots3(0) = gsn_csm_contour_map_ce(wks,LWCF(0,:,:),res3)

res3@gsnLeftString = "(f) LWCF CAM_New mean="+LWCF_new_mean
res3@gsnRightString = "W/m~S~2~N~"
plots3(1) = gsn_csm_contour_map_ce(wks,LWCF(1,:,:),res3)

res4 = res
res4@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res4@cnMaxLevelValF       = 30        ; min level
res4@cnMinLevelValF       = -30
res4@cnLevelSpacingF      = 5
res4@cnFillPalette = "BlueRed"

res4@gsnLeftString = "(g) LWCF CAM_Old-Obs mean="+LWCF_old_obs_mean
res4@gsnRightString = "W/m~S~2~N~"
plots4(0) = gsn_csm_contour_map_ce(wks,LWCF_old_obs(:,:),res4)

res4@gsnLeftString = "(h) LWCF CAM_New-Obs mean="+LWCF_new_obs_mean
res4@gsnRightString = "W/m~S~2~N~"
plots4(1) = gsn_csm_contour_map_ce(wks,LWCF_new_obs(:,:),res4)


;============get ready to panel plots

ypos1 = 0.96
ypos2 = 0.72
ypos3 = 0.48
ypos4 = 0.24

nrows = 4
plot_height = 1./tofloat(nrows)

pres = True
;pres@gsnPanelDebug = True
pres@gsnFrame = False
pres@gsnMaximize = True
;pres@gsnPanelFigureStrings = (/"(a)","(b)"/)


pres@gsnPanelTop = 1.0
pres@gsnPanelBottom = pres@gsnPanelTop - plot_height
pres@gsnPanelYF = (/ypos1,ypos1,ypos1,ypos1/)


pres@gsnPanelLabelBar = True
;pres@pmLabelBarHeightF = 0.03
pres@pmLabelBarWidthF = 0.6
pres@lbLabelFontHeightF = 0.005

gsn_panel(wks,plots1,(/1,2/),pres)

pres@gsnPanelTop = pres@gsnPanelBottom
pres@gsnPanelBottom = pres@gsnPanelTop - plot_height
pres@gsnPanelYF = (/ypos2,ypos2,ypos2,ypos2/)

gsn_panel(wks,plots2,(/1,2/),pres)

pres@gsnPanelTop = pres@gsnPanelBottom
pres@gsnPanelBottom = pres@gsnPanelTop - plot_height
pres@gsnPanelYF = (/ypos3,ypos3,ypos3,ypos3/)

gsn_panel(wks,plots3,(/1,2/),pres)

pres@gsnPanelTop = pres@gsnPanelBottom
pres@gsnPanelBottom = 0.0
pres@gsnPanelYF = (/ypos4,ypos4,ypos4,ypos4/)

gsn_panel(wks,plots4,(/1,2/),pres)


frame(wks)


end
