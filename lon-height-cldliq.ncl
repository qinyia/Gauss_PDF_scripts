load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

fdir1 = "/home2/data/qiny/data/AMIP/F_2000_CAM5_f19f19.def/atm/hist/"
fdir2 = "/home2/data/qiny/data/NEWCLDFRAC/new-cldfrac6/atm/hist/"

fn1 = "F_2000_CAM5_f19f19.def.cam.h0.0002-3.nc"
fn2 = "new-cldfrac6.cam.h0.0002-3.nc"



f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")

lon = f1->lon
lat = f1->lat

CLDLIQ1 = f1->CLDLIQ(0,:,:,:)
CLDLIQ2 = f2->CLDLIQ(0,:,:,:)


;create plot
wks = gsn_open_wks("x11","./figure/lon-height-cloud")
plot = new(6,graphic)

res = True
res@gsnDraw = False
res@gsnFrame = False
res@trYReverse = True
res@gsnSpreadColors = True
res@cnLinesOn = False
res@cnFillOn = True

res@lbBoxLinesOn         = False     ; Turn off labelbar box lines

res@trYMinF = 750.

res@gsnYAxisIrregular2Linear = True
res@tiYAxisString = "Pressure(hPa)"

res@tmXBTickSpacingF= 15.

;res@cnLevelSelectionMode = "ManualLevels"
;res@cnMinLevelValF = 0 
;res@cnMaxLevelValF = 10. 
;res@cnLevelSpacingF = 0.5


res@gsnLeftString = "New"
res@gsnRightString = "10S"

plot(0) = gsn_csm_contour(wks,CLDLIQ1(:,{-10},{220:290}),res)

res@gsnRightString = "20S"

plot(1) = gsn_csm_contour(wks,CLDLIQ1(:,{-20},{220:290}),res)

res@gsnLeftString = "Old"
res@gsnRightString = "10S"

plot(2) = gsn_csm_contour(wks,CLDLIQ2(:,{-10},{220:290}),res)

res@gsnRightString = "20S"

plot(3) = gsn_csm_contour(wks,CLDLIQ2(:,{-20},{220:290}),res)


gsn_panel(wks,plot,(/3,2/),False)
end
