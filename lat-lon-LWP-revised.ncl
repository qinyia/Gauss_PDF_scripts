load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_lat_interpolate.ncl"

begin

fdir1 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/F_2000_f09f09_MG1.5/atm/hist/"
;fdir2 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/new-cldfrac15-1d/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-revise/atm/hist/"
fdir3 = "/home/lyl/WORK3/qinyi/data/obs_data/"

fn1 = "F_2000_f09f09_MG1.5.cam.h0.ANN.nc"
;fn2 = "new-cldfrac15-1d.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d-MG15-revise.cam.h0.ANN.nc"

;fn3 = "SSMI_ANN_climo.nc"
fn3 = "NVAP_ANN_climo.nc"

f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")
f3 = addfile(fdir3+fn3,"r")

lon1 = f1->lon
lat1 = f1->lat

lon2 = f2->lon
lat2 = f2->lat

lon3 = f3->lon
lat3 = f3->lat

LANDFRAC = f1->LANDFRAC(0,:,:)

gw1 = f1->gw

gw2 = f3->gw

LWP_old = f1->TGCLDLWP(0,:,:)		;time*lat*lon
LWP_new = f2->TGCLDLWP(0,:,:)		;time*lat*lon
LWP_obs = f3->TGCLDLWP_OCEAN(0,:,:)

;change unit from kg/m2 to g/m2
LWP_old = LWP_old*1000.
LWP_new = LWP_new*1000.

;mask land fraction
LWP_old_ocean = mask(LWP_old,LANDFRAC,0)
LWP_new_ocean = mask(LWP_new,LANDFRAC,0)
LWP_obs_ocean = LWP_obs

copy_VarCoords(LWP_old,LWP_old_ocean)
copy_VarCoords(LWP_new,LWP_new_ocean)

;global mean
LWP_old_mean = wgt_areaave(LWP_old_ocean,gw1,1.0,0)
LWP_new_mean = wgt_areaave(LWP_new_ocean,gw1,1.0,0)
LWP_obs_mean = wgt_areaave(LWP_obs,gw2,1.0,0)

;interpolate
LWP_ocean = lat_lon_interpolate(LWP_old_ocean,lat1,lon1,LWP_new_ocean,lat2,lon2,LWP_obs_ocean,lat3,lon3)

;difference
diff_old_obs = LWP_ocean(0,:,:)-LWP_ocean(2,:,:)
diff_new_obs = LWP_ocean(1,:,:)-LWP_ocean(2,:,:)
diff_new_old = LWP_ocean(1,:,:)-LWP_ocean(0,:,:)
copy_VarCoords(LWP_ocean(0,:,:),diff_old_obs)
copy_VarCoords(LWP_ocean(0,:,:),diff_new_obs)
copy_VarCoords(LWP_ocean(0,:,:),diff_new_old)



;create plot
wks = gsn_open_wks("pdf","./figure/lon-lat-LWP-revised")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
plot = new(4,graphic)
plot0 = new(2,graphic)
plot1 = new(2,graphic)

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
res@cnMaxLevelValF       = 200        ; min level
res@cnMinLevelValF       = 10
res@cnLevelSpacingF      = 10

res@gsnLeftStringFontHeightF = 0.03

;res@gsnLeftString = "(a) CAM5_Old mean="+LWP_old_mean
res@gsnLeftString = "(a) RH"
;res@gsnRightString = "g/m~S~2~N~"
plot0(0) = gsn_csm_contour_map_ce(wks,LWP_ocean(0,:,:),res)

;res@gsnLeftString = "(b) CAM5_PDF mean="+LWP_new_mean
res@gsnLeftString = "(b) Obs"
;res@gsnRightString = "g/m~S~2~N~"
res@lbLabelBarOn = True
res@pmLabelBarWidthF = 0.8
plot0(1) = gsn_csm_contour_map_ce(wks,LWP_ocean(2,:,:),res)

resPanel                 = True                 ; panel mods desired
resPanel@gsnPanelLabelBar= True                 ; label bar on panel
resPanel@gsnMaximize     = True                 ; fill up the page
;gsn_panel(wks,plot0,(/3,1/),resPanel)

;=======
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
res2@cnMaxLevelValF       = 100        ; min level
res2@cnMinLevelValF       = -100
res2@cnLevelSpacingF      = 10
res2@cnFillPalette = "BlueRed"

res2@gsnLeftStringFontHeightF = 0.03

res2@gsnLeftString = "(c) RH-Obs"
;res2@gsnRightString = "g/m~S~2~N~"
plot1(0) = gsn_csm_contour_map(wks,diff_old_obs,res2)

res2@gsnLeftString = "(d) PDF-RH" 
;res2@gsnRightString = "g/m~S~2~N~"
res2@lbLabelBarOn = True
res2@pmLabelBarWidthF = 0.8
plot1(1) = gsn_csm_contour_map_ce(wks,diff_new_old,res2)

resPanel                 = True                 ; panel mods desired
resPanel@gsnPanelLabelBar= True                 ; label bar on panel
resPanel@gsnMaximize     = True                 ; fill up the page
;gsn_panel(wks,plot1,(/3,1/),resPanel)

plot(0) = plot0(0)
plot(1) = plot1(0)
plot(2) = plot0(1)
plot(3) = plot1(1)
gsn_panel(wks,plot,(/2,2/),False)


end
