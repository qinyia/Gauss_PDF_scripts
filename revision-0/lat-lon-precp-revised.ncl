load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_lat_interpolate.ncl"

begin

fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/FC5_f09f09_MG15_COSP/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-revise-2-COSP/atm/hist/"
fdir3 = "/home/lyl/WORK3/qinyi/data/obs_data/"

fn1 = "FC5_f09f09_MG15_COSP.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d-MG15-revise-2-COSP.cam.h0.ANN.nc"
fn3 = "GPCP_ANN_climo.nc"

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


precl_old = f1->PRECL(0,:,:)		;time*lat*lon
precc_old = f1->PRECC(0,:,:)
precp_old = precl_old+precc_old
;precp_old = precl_old

copy_VarCoords(precl_old,precp_old)

precl_new = f2->PRECL(0,:,:)		;time*lat*lon
precc_new = f2->PRECC(0,:,:)
precp_new = precl_new+precc_new
;precp_new = precl_new

copy_VarCoords(precl_new,precp_new)

precp_obs = f3->PRECT(0,:,:)

;change to mm/day
precp_old = precp_old*8.64e7
precp_new = precp_new*8.64e7

;global mean
precp_old_mean = wgt_areaave(precp_old,gw1,1.0,0)

precp_new_mean = wgt_areaave(precp_new,gw1,1.0,0)

precp_obs_mean = wgt_areaave(precp_obs,gw2,1.0,0)

;interpolate

precp = lat_lon_interpolate(precp_old,lat1,lon1,precp_new,lat2,lon2,precp_obs,lat3,lon3)

;difference
diff_old_obs = precp(0,:,:)-precp(2,:,:)
diff_new_obs = precp(1,:,:)-precp(2,:,:)
diff_new_old = precp(1,:,:)-precp(0,:,:)
copy_VarCoords(precp(0,:,:),diff_old_obs)
copy_VarCoords(precp(0,:,:),diff_new_obs)
copy_VarCoords(precp(0,:,:),diff_new_old)



;create plot
wks = gsn_open_wks("x11","./figure/lat-lon-precp-revised")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
plot= new(6,graphic)
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
res@lbLabelStride = 4
res@lbLabelBarOn = False               ; turn off the label bar

res@mpMinLonF = 0
res@mpMaxLonF = 360
res@mpCenterLonF = 180

;res@mpMinLatF = -30
;res@mpMaxLatF = 30


;=========For Indian Ocean===========
;res@mpMinLonF = 30
;res@mpMaxLonF = 120
;;res@mpCenterLonF = 180
;res@mpMinLatF = -30
;res@mpMaxLatF = 30
;=====================================

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 15       ; min level
res@cnMinLevelValF       = 0.5
res@cnLevelSpacingF      = 0.5

res@gsnLeftStringFontHeightF = 0.03
;res@gsnRightStringFontHeightF = 0.03



res@gsnLeftString = "(a) RH"
;res@gsnRightString = "mm/day"
plot0(0) = gsn_csm_contour_map(wks,precp(0,:,:),res)

res@gsnLeftString = "(b) GPCP"
;res@gsnRightString = "mm/day"
res@lbLabelBarOn = True
res@pmLabelBarWidthF = 0.8
plot0(1) = gsn_csm_contour_map_ce(wks,precp(2,:,:),res)

resPanel                 = True                 ; panel mods desired
resPanel@gsnPanelLabelBar= True                 ; label bar on panel
resPanel@gsnMaximize     = True                 ; fill up the page
;gsn_panel(wks,plot,(/3,1/),resPanel)

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

;res2@mpMinLatF = -30
;res2@mpMaxLatF = 30

; ==========for Indian Ocean=======
;res2@mpMinLonF = 30
;res2@mpMaxLonF = 120
;;re2s@mpCenterLonF = 180
;res2@mpMinLatF = -30
;res2@mpMaxLatF = 30
;==================================



res2@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res2@cnMaxLevelValF       = 4
res2@cnMinLevelValF       = -4
res2@cnLevelSpacingF      = 0.5
res2@cnFillPalette = "BlueRed"

res2@gsnLeftStringFontHeightF = 0.03
;res2@gsnRightStringFontHeightF = 0.03

res2@gsnLeftString = "(c) RH-GPCP"
;res2@gsnRightString = "mm/day"
plot1(0) = gsn_csm_contour_map(wks,diff_old_obs,res2)

res2@gsnLeftString = "(d) PDF-RH" 
;res2@gsnRightString = "mm/day"
res2@lbLabelBarOn = True
res2@pmLabelBarWidthF = 0.8
plot1(1) = gsn_csm_contour_map(wks,diff_new_old,res2)
;plot1(1) = gsn_csm_contour_map(wks,diff_new_obs,res2)


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
