load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

fdir1 = "/home2/data/qiny/data/NEWCLDFRAC/new-cldfrac7-1d/atm/hist/"
fdir2 = "/home2/data/qiny/data/ISCCP/"
fdir3 = "/home2/data/qiny/data/CERES/"

fn1 = "new-cldfrac7-1d.cam.h0.0002-3.nc"
fn2 = "ISCCP_ANN_climo.nc"
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

cldsim = f1->CLDLOW		;time*lat*lon
cldobs = f2->CLDLOW
swcfsim = f1->SWCF
swcfobs = f3->SWCF

print(max(swcfsim))
print(min(swcfsim))

cldsim = cldsim*100.


tmpcld = cldobs

tmpcld = linint2(lon1,lat1,cldsim,True,lon2,lat2,0)

diff_cld = tmpcld-cldobs
copy_VarCoords(cldobs,diff_cld)

tmpswcf = swcfsim

tmpswcf = linint2(lon3,lat3,swcfobs,True,lon1,lat1,0)

diff_swcf = swcfsim-tmpswcf
copy_VarCoords(swcfsim,diff_swcf)


;create plot
wks = gsn_open_wks("x11","./figure/cloud-swcf-obs")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
plot= new(6,graphic)

res = True
res@gsnFrame = False
res@gsnDraw = False
res@gsnSpreadColors = True
res@cnLinesOn = False
res@cnFillOn = True
res@lbLabelStride = 8

res@mpMinLonF = 0
res@mpMaxLonF = 360
res@mpCenterLonF = 180

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 98        ; min level
res@cnMinLevelValF       = 2
res@cnLevelSpacingF      = 4

res@tiMainString = "Low Cloud"
res@gsnLeftString = "ISCCP"
res@gsnRightString = "%"
plot(0) = gsn_csm_contour_map_ce(wks,cldobs(0,:,:),res)


res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 20        ; min level
res@cnMinLevelValF       = -180
res@cnLevelSpacingF      = 10

res@tiMainString = "SWCF"
res@gsnLeftString = "CERES-EBAF"
res@gsnRightString = "W/m~S~2~N~"
plot(1) = gsn_csm_contour_map_ce(wks,tmpswcf(0,:,:),res)

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 98        ; min level
res@cnMinLevelValF       = 2
res@cnLevelSpacingF      = 4

res@tiMainString = ""
res@gsnLeftString = "CAM5"
res@gsnRightString = "%"
plot(2) = gsn_csm_contour_map_ce(wks,tmpcld(0,:,:),res)

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 20        ; min level
res@cnMinLevelValF       = -180
res@cnLevelSpacingF      = 10
res@gsnRightString = "W/m~S~2~N~"
plot(3) = gsn_csm_contour_map_ce(wks,swcfsim(0,:,:),res)

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 50        ; min level
res@cnMinLevelValF       = -50
res@cnLevelSpacingF      = 5

res@gsnLeftString = "model-obs"
res@gsnRightString = "%"
plot(4) = gsn_csm_contour_map_ce(wks,diff_cld(0,:,:),res)

res@gsnRightString = "W/m~S~2~N~"
plot(5) = gsn_csm_contour_map_ce(wks,diff_swcf(0,:,:),res)

gsn_panel(wks,plot,(/3,2/),False)

end
