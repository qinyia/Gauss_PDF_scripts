load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/FC5_f09f09_MG15/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-revise-2-COSP/atm/hist/"

fn1 = "FC5_f09f09_MG15.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d-MG15-revise-2-COSP.cam.h0.ANN.nc"

f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")

CLDLOW = f1->CLDLOW		;time*lat*lon
sgm_turb = f2->sgm_tota(0,{912},:,:)
sgm_shal = f2->sgm_shal(0,{912},:,:)
sgm_deep = f2->sgm_turb(0,{912},:,:)

var0 = sqrt(sgm_turb)
var0 = var0*1000.


var1 = sqrt(abs(sgm_shal))
var1 = var1*1000.

var2 = sqrt(abs(sgm_deep))
var2 = var2*1000.

copy_VarCoords(sgm_turb,var0)
copy_VarCoords(sgm_shal,var1)
copy_VarCoords(sgm_deep,var2)

;========directly output subgrid scale variance: sgmqt
;sgmqt = f2->sgmqt(0,{912},:,:)
;sgmqt = sgmqt*1000.
;printVarSummary(sgmqt)
;sgmqt@units = "g/kg"



;create plot
wks = gsn_open_wks("x11","./figure/lat-lon-sgm-revised-912hPa")
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

res@lbLabelStride = 5.

;res@gsnRightString = "g/kg"
res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 2.
res@cnMinLevelValF       = 0.
res@cnLevelSpacingF      = 0.1

res@gsnRightString = ""

res@gsnLeftStringFontHeightF = 0.03

;res@gsnLeftString = "(a) sgmqt_RH"
;plot1 = gsn_csm_contour_map_ce(wks,sgmqt,res)

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 0.5
res@cnMinLevelValF       = 0.
res@cnLevelSpacingF      = 0.02

res@gsnLeftString = "(a) sgm_tota"
plot2 = gsn_csm_contour_map_ce(wks,var0,res)

res@gsnLeftString = "(b) sgm_shal"
plot3 = gsn_csm_contour_map_ce(wks,var1,res)


res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 0.3
res@cnMinLevelValF       = 0.
res@cnLevelSpacingF      = 0.02

res@gsnLeftString = "(c) sgm_turb"
plot4 = gsn_csm_contour_map_ce(wks,var2,res)

pres = True
;pres@gsnPanelRowSpec = True                   ; tell panel what order to plot

gsn_panel(wks,(/plot2,plot3,plot4/),(/3,1/),pres)


end
