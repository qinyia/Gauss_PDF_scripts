load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_lat_interpolate.ncl"

begin

fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/FC5_f09f09_MG15/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-revise-2-COSP/atm/hist/"
fdir3 = "/home/lyl/WORK3/qinyi/data/obs_data/"

fn1 = "FC5_f09f09_MG15.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d-MG15-revise-2-COSP.cam.h0.ANN.nc"
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



;global mean
SWCF_old_mean = wgt_areaave(SWCF_old,gw1,1.0,0)

SWCF_new_mean = wgt_areaave(SWCF_new,gw1,1.0,0)

SWCF_obs_mean = wgt_areaave(SWCF_obs,gw2,1.0,0)

;interpolate

SWCF = lat_lon_interpolate(SWCF_old,lat1,lon1,SWCF_new,lat2,lon2,SWCF_obs,lat3,lon3)

;difference
diff_old_obs = SWCF(0,:,:)-SWCF(2,:,:)
diff_new_obs = SWCF(1,:,:)-SWCF(2,:,:)
diff_new_old = SWCF(1,:,:)-SWCF(0,:,:)
copy_VarCoords(SWCF(0,:,:),diff_old_obs)
copy_VarCoords(SWCF(0,:,:),diff_new_obs)
copy_VarCoords(SWCF(0,:,:),diff_new_old)


;create plot
wks = gsn_open_wks("pdf","./figure/lat-lon-SWCF-revised-2")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
plot = new(4,graphic)
plot0 = new(2,graphic)
plot1 = new(2,graphic)

res = True
res@gsnFrame = False
res@gsnDraw = False
res@gsnSpreadColors = True
res@gsnSpreadColorStart = 2
res@gsnSpreadColorEnd = 180

res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnFillOn = True
;res@lbLabelStride = 2
res@lbLabelBarOn = False               ; turn off the label bar

res@mpMinLonF = 0
res@mpMaxLonF = 360
res@mpCenterLonF = 180

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 0.
res@cnMinLevelValF       = -160.
res@cnLevelSpacingF      = 15.

res@gsnLeftStringFontHeightF = 0.03

;res@gsnLeftString = "(a) RH mean="+SWCF_old_mean
res@gsnLeftString = "(a) RH"

;res@gsnRightString = "W/m~S~2~N~"
plot0(0) = gsn_csm_contour_map(wks,SWCF(0,:,:),res)

;res@gsnLeftString = "(b) ISCCP mean="+SWCF_obs_mean
res@gsnLeftString = "(b) Obs"

res@lbLabelBarOn = True
res@pmLabelBarWidthF = 0.8
plot0(1) = gsn_csm_contour_map_ce(wks,SWCF(2,:,:),res)

resPanel                 = True                 ; panel mods desired
resPanel@gsnPanelLabelBar= True                 ; label bar on panel
resPanel@gsnMaximize     = True                 ; fill up the page
;gsn_panel(wks,plot0,(/2,1/),resPanel)
;gsn_panel(wks,plot0,(/2,1/),False)


;=============
res2 = True
res2@gsnFrame = False
res2@gsnDraw = False

res2@cnLinesOn = False
res2@cnLineLabelsOn = False
res2@cnFillOn = True
;res2@lbLabelStride = 2
res2@lbLabelBarOn = False               ; turn off the label bar

res2@mpMinLonF = 0
res2@mpMaxLonF = 360
res2@mpCenterLonF = 180

res2@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res2@cnMaxLevelValF       = 40       ; min level
res2@cnMinLevelValF       = -40
res2@cnLevelSpacingF      = 5
res2@cnFillPalette = "BlueRed"

res2@gsnLeftStringFontHeightF = 0.03

res2@gsnLeftString = "(c) RH-Obs"
;res2@gsnRightString = "W/m~S~2~N~"
plot1(0) = gsn_csm_contour_map(wks,diff_old_obs,res2)

res2@gsnLeftString = "(d) PDF-RH" 
res2@lbLabelBarOn = True
res2@pmLabelBarWidthF = 0.8
plot1(1) = gsn_csm_contour_map(wks,diff_new_old,res2)


resPanel                 = True                 ; panel mods desired
resPanel@gsnPanelLabelBar= True                 ; label bar on panel
resPanel@gsnMaximize     = True                 ; fill up the page
;gsn_panel(wks,plot1,(/3,1/),resPanel)
;gsn_panel(wks,plot1,(/3,1/),False)

plot(0) = plot0(0)
plot(1) = plot1(0)
plot(2) = plot0(1)
plot(3) = plot1(1)

gsn_panel(wks,plot,(/2,2/),False)

end
