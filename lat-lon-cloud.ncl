load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_lat_interpolate.ncl"

begin

fdir1 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/F_2000_f09f09_MG1.5/atm/hist/"
;fdir2 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/new-cldfrac16-1d/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d/atm/hist/"

fdir3 = "/home/lyl/WORK3/qinyi/data/obs_data/"

fn1 = "F_2000_f09f09_MG1.5.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d.cam.h0.ANN.nc"
fn3 = "ISCCP_ANN_climo.nc"

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


cld_old = f1->CLDLOW(0,:,:)		;time*lat*lon
cld_new = f2->CLDLOW(0,:,:)		;time*lat*lon
cld_obs = f3->CLDLOW(0,:,:)


cld_old = cld_old*100.
cld_new = cld_new*100.

;global mean
cld_old_mean = wgt_areaave(cld_old,gw1,1.0,0)

cld_new_mean = wgt_areaave(cld_new,gw1,1.0,0)

cld_obs_mean = wgt_areaave(cld_obs,gw2,1.0,0)

;interpolate

cld = lat_lon_interpolate(cld_old,lat1,lon1,cld_new,lat2,lon2,cld_obs,lat3,lon3)

;difference
diff_old_obs = cld(0,:,:)-cld(2,:,:)
diff_new_obs = cld(1,:,:)-cld(2,:,:)
diff_new_old = cld(1,:,:)-cld(0,:,:)
copy_VarCoords(cld(0,:,:),diff_old_obs)
copy_VarCoords(cld(0,:,:),diff_new_obs)
copy_VarCoords(cld(0,:,:),diff_new_old)


;create plot
wks = gsn_open_wks("x11","./figure/lon-lat-cloud")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
plot = new(6,graphic)
plot0 = new(3,graphic)
plot1 = new(3,graphic)

res = True
res@gsnFrame = False
res@gsnDraw = False
res@gsnSpreadColors = True
res@gsnSpreadColorStart = 2
res@gsnSpreadColorEnd = 200

res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnFillOn = True
res@lbLabelStride = 2
res@lbLabelBarOn = False               ; turn off the label bar

res@mpMinLonF = 0
res@mpMaxLonF = 360
res@mpCenterLonF = 180

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 98        ; min level
res@cnMinLevelValF       = 2
res@cnLevelSpacingF      = 4

res@gsnLeftString = "(a) CAM5_Old mean="+cld_old_mean
res@gsnRightString = "%"
plot0(0) = gsn_csm_contour_map(wks,cld(0,:,:),res)

res@gsnLeftString = "(b) CAM5_New mean="+cld_new_mean
res@gsnRightString = "%"
plot0(1) = gsn_csm_contour_map_ce(wks,cld(1,:,:),res)

res@gsnLeftString = "(c) ISCCP mean="+cld_obs_mean
res@gsnRightString = "%"
res@lbLabelBarOn = True
res@pmLabelBarWidthF = 0.8
plot0(2) = gsn_csm_contour_map_ce(wks,cld(2,:,:),res)

resPanel                 = True                 ; panel mods desired
resPanel@gsnPanelLabelBar= True                 ; label bar on panel
resPanel@gsnMaximize     = True                 ; fill up the page
;gsn_panel(wks,plot0,(/3,1/),resPanel)
gsn_panel(wks,plot0,(/3,1/),False)

;=============
res2 = True
res2@gsnFrame = False
res2@gsnDraw = False

res2@cnLinesOn = False
res2@cnLineLabelsOn = False
res2@cnFillOn = True
res2@lbLabelStride = 2
res2@lbLabelBarOn = False               ; turn off the label bar

res2@mpMinLonF = 0
res2@mpMaxLonF = 360
res2@mpCenterLonF = 180

res2@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res2@cnMaxLevelValF       = 40       ; min level
res2@cnMinLevelValF       = -40
res2@cnLevelSpacingF      = 5
res2@cnFillPalette = "BlueRed"

res2@gsnLeftString = "(d) CAM5_Old-Obs"
res2@gsnRightString = "%"
plot1(0) = gsn_csm_contour_map(wks,diff_old_obs,res2)

res2@gsnLeftString = "(e) CAM5_New-Obs"
res2@gsnRightString = "%"
plot1(1) = gsn_csm_contour_map(wks,diff_new_obs,res2)

res2@gsnLeftString = "(f) CAM5_New-CAM5_Old" 
res2@gsnRightString = "%"
res2@lbLabelBarOn = True
res2@pmLabelBarWidthF = 0.8
plot1(2) = gsn_csm_contour_map(wks,diff_new_old,res2)


resPanel                 = True                 ; panel mods desired
resPanel@gsnPanelLabelBar= True                 ; label bar on panel
resPanel@gsnMaximize     = True                 ; fill up the page
;gsn_panel(wks,plot1,(/3,1/),resPanel)
;gsn_panel(wks,plot1,(/3,1/),False)

plot(0) = plot0(0)
plot(1) = plot1(0)
plot(2) = plot0(1)
plot(3) = plot1(1)
plot(4) = plot0(2)
plot(5) = plot1(2)

gsn_panel(wks,plot,(/3,2/),False)

end
