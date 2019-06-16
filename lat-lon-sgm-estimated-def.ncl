load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/FC5_f09f09_MG15/atm/hist/"
fn1 = "FC5_f09f09_MG15.cam.h0.ANN.nc"

f1 = addfile(fdir1+fn1,"r")

;========directly output subgrid scale variance: sgmqt
sgmqt = f1->sgmqt(0,{900},:,:)
sgmqt = sgmqt*1000.
printVarSummary(sgmqt)
sgmqt@units = "g/kg"



;=========use output Temperature to estimate subgrid scale variance: sgm
CLDLOW = f1->AST(0,{900},:,:)
RH = f1->RELHUM(0,{900},:,:)

RH = RH/100.

RH = mask(RH,RH.lt.0.9,False)

Temp = f1->T(0,{900},:,:)

;change unit from K to celcius degree
TC = Temp-273.15
; saturation vapor pressure
es = 611*exp(17.27*TC/(TC+237.3))
; saturation specific humidity
qs = 0.622*es/(900.0*100.)

; calculate subgrid scale variance: sgm = 1/sqrt(6.0)*(1-Ucl)*qs
sgm = 1/sqrt(6.0)*(1-0.89)*qs
sgm = sgm*1000.

copy_VarCoords(Temp,sgm)

printVarSummary(sgm)

printMinMax(sgmqt,False)
printMinMax(sgm,False)





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
res@cnMaxLevelValF       = 1.0
res@cnMinLevelValF       = 0.
res@cnLevelSpacingF      = 0.02

res@lbLabelStride = 5.

;res@gsnRightString = "g/kg"

res@gsnLeftString = "(a) sgm_tota"
plot1 = gsn_csm_contour_map_ce(wks,sgm,res)

plot2 = gsn_csm_contour_map_ce(wks,sgmqt,res)

plot3 = gsn_csm_contour_map_ce(wks,CLDLOW,res)

gsn_panel(wks,(/plot1,plot2,plot3/),(/3,1/),False)


end
