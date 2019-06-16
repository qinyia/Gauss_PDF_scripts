load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

fdir1 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/new-cldfrac15-1d/atm/hist/"
fn1 = "new-cldfrac15-1d.cam.h0.ANN.nc"

f1 = addfile(fdir1+fn1,"r")

CLDLOW = f1->CLDLOW		;time*lat*lon
sgm_turb = f1->sgm_tota(0,{900},:,:)
sgm_shal = f1->sgm_shal(0,{900},:,:)
sgm_deep = f1->sgm_turb(0,{900},:,:)

var0 = sqrt(sgm_turb)
var0 = var0*1000.


var1 = sqrt(abs(sgm_shal))
var1 = var1*1000.

var2 = sqrt(abs(sgm_deep))
var2 = var2*1000.

copy_VarCoords(sgm_turb,var0)
copy_VarCoords(sgm_shal,var1)
copy_VarCoords(sgm_deep,var2)


;create plot
wks = gsn_open_wks("x11","./figure/lat-lon-sgm-900hPa")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

;plot= new(6,graphic)

res = True

res@gsnFrame = False
res@gsnDraw = False

res@gsnSpreadColors = True
res@gsnSpreadColorStart = 2
res@gsnSpreadColorEnd = 200



res@gsnSpreadColors = True
res@cnLinesOn = False
res@cnFillOn = True

res@mpMinLonF = 0
res@mpMaxLonF = 360
res@mpCenterLonF = 180

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 0.5
res@cnMinLevelValF       = 0.
res@cnLevelSpacingF      = 0.02

res@lbLabelStride = 5.

;res@gsnRightString = "g/kg"

res@gsnLeftString = "(a) sgm_tota"
plot1 = gsn_csm_contour_map_ce(wks,var0,res)

res@gsnLeftString = "(b) sgm_shal"
plot2 = gsn_csm_contour_map_ce(wks,var1,res)


res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 0.3
res@cnMinLevelValF       = 0.
res@cnLevelSpacingF      = 0.02

res@gsnLeftString = "(c) sgm_turb"
plot3 = gsn_csm_contour_map_ce(wks,var2,res)

gsn_panel(wks,(/plot1,plot2,plot3/),(/3,1/),False)


end
