load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;fdir1 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/F_2000_f09f09_MG1.5/atm/hist/"
;fdir2 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/new-cldfrac14-1d/atm/hist/"
fdir1 = "/home/lyl/WORK3/qinyi/data/calipso/temp/"

; should add observed dataset

fn1 = "clcalipso_obs4MIPs_CALIOP_L3_CALIPSO-GOCCP-v2.1_clm.nc"

f1 = addfile(fdir1+fn1,"r")

lon = f1->lon
lat = f1->lat
alt = f1->alt40

cld_obs = f1->clcalipso(0,:,:,:)

cld_obs = cld_obs*100.

;form an standard temperature profile
T0 = 288.15	;K
lapse = -0.0065	;K/m
T = T0+lapse*alt
;T1 = conform(cld_obs,doubletofloat(T),0)
;copy_VarCoords(cld_obs,T1)
;printVarSummary(T1)

;; convert height [m] into pressure[hPa]
P0 = 1000.0
gravit = 9.8
RD = 287.04
Pres = P0*exp(-gravit*alt/RD/T)
;print(Pres)

cld_obs!0 = "lev"
cld_obs&lev = Pres
cld_obs&lev@units = "hPa"

printVarSummary(cld_obs)

;create plot
wks = gsn_open_wks("x11","./figure/lon-height-cloud")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

res = True
;res@gsnDraw = False
;res@gsnFrame = False
res@trYReverse = True
res@gsnSpreadColors = True
res@gsnSpreadColorStart = 2
;res@gsnSpreadColorEnd = 200

res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnFillOn = True
;res@cnlbLabelStride = 4
;res@lbLabelBarOn = False

res@lbBoxLinesOn         = False     ; Turn off labelbar box lines

res@cnInfoLabelOn = False

res@trYMinF = 750.
;res@trYMaxF = 3000.

res@gsnYAxisIrregular2Linear = True
res@tiYAxisString = "Pressure(hPa)"


res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 10. 
res@cnMaxLevelValF = 80. 
res@cnLevelSpacingF = 5.

;=======================================
lres = True
lres@gsnDraw = False
lres@gsnFrame = False
lres@xyLineThicknessF = 2.0 
lres@gsnLeftString = ""
lres@gsnRightString = ""

plot = gsn_csm_contour(wks,cld_obs(:,{-15},{240:280}),res)
end
