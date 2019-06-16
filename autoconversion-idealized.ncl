load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin

qc = fspan(0.1e-3,1.1e-3,1001) ; kg/kg

nc = fspan(10,150,1001) ; cm-3

reff = new((/1001,1001/),"float")

qc_1 = conform(reff,qc,0)
nc_1 = conform(reff,nc,1)

autoconv = 1350.0*qc_1^2.47*nc_1^(-1.79)


printMinMax(autoconv,False)

autoconv!0 = "qc"
autoconv&qc = qc
autoconv!1 = "nc"
autoconv&nc = nc

minval = 1.e-9
maxval = 1.e-7

wks = gsn_open_wks("x11","figure/cloud-conden")

res = True

res@cnFillOn = True


res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = minval
res@cnMaxLevelValF = maxval
res@cnLevelSpacingF = (maxval-minval)/101.

;res@xyLineThicknessF = 3.0
;res@xyLineColor = "red"

plot = gsn_csm_contour(wks,autoconv,res)





end



