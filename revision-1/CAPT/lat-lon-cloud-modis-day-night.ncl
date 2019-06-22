
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
begin
fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt2-vocals/run/hourmean/"
;fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt-vocals-shalcld-output2/run/hourmean/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt-vocals-revise-2/run/hourmean/"
fdir3 = "/home/lyl/WORK3/qinyi/data/VOCALS/modis_cloud/"

fname1 = "day03.nc"
fname2 = "day03.nc"
fname3 = "MOD08_D3.051.timeAverage.0_day.nc"
fname4 = "MOD08_D3.051.timeAverage.0_nig.nc"


;******************read data*******
f1 = addfile(fdir1+fname1,"r")
f2 = addfile(fdir2+fname2,"r")
f3 = addfile(fdir3+fname3,"r")
f4 = addfile(fdir3+fname4,"r")

cld_old = f1->CLDLOW(:,:,:)
cld_new = f2->CLDLOW(:,:,:)
cld_obs_day_avg = f3->Cloud_Fraction_Day_Mean(:,:)
cld_obs_nig_avg = f4->Cloud_Fraction_Night_Mean(:,:)


;=============day mean
cld_old_day = cld_old(5:7,:,:)
cld_new_day = cld_new(5:7,:,:)

cld_old_day_avg = dim_avg_n(cld_old_day,0)
cld_new_day_avg = dim_avg_n(cld_new_day,0)

;=============night mean
cld_old_nig = cld_old(1:4,:,:)
cld_new_nig = cld_new(1:4,:,:)
cld_old_nig_avg = dim_avg_n(cld_old_nig,0)
cld_new_nig_avg = dim_avg_n(cld_new_nig,0)

;==============assign required attributes
cld_old_day_avg!1 = "lon"
cld_old_day_avg!0 = "lat"
cld_old_nig_avg!1 = "lon"
cld_old_nig_avg!0 = "lat"

cld_new_day_avg!1 = "lon"
cld_new_day_avg!0 = "lat"
cld_new_nig_avg!1 = "lon"
cld_new_nig_avg!0 = "lat"


lat = cld_old&lat
lon = cld_old&lon

cld_old_day_avg&lon = lon
cld_old_day_avg&lat = lat
cld_old_nig_avg&lon = lon
cld_old_nig_avg&lat = lat
cld_old_day_avg&lon@units = "degrees_east"
cld_old_day_avg&lat@units = "degrees_north"
cld_old_nig_avg&lon@units = "degrees_east"
cld_old_nig_avg&lat@units = "degrees_north"

cld_new_day_avg&lon = lon
cld_new_day_avg&lat = lat
cld_new_nig_avg&lon = lon
cld_new_nig_avg&lat = lat
cld_new_day_avg&lon@units = "degrees_east"
cld_new_day_avg&lat@units = "degrees_north"
cld_new_nig_avg&lon@units = "degrees_east"
cld_new_nig_avg&lat@units = "degrees_north"


;*******************plot*************************
;create plot
;wks = gsn_open_wks("eps","../figure/fig2-lat-lon-cloud-modis-day-night-eps")
wks = gsn_open_wks("pdf","../figure/fig2-lat-lon-cloud-modis-day-night")

plot = new(6,graphic)

;gsn_define_colormap(wks,"MPL_rainbow")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
;gsn_define_colormap(wks,"MPL_Greys")

res = True
res@gsnDraw = False
res@gsnFrame = False
res@gsnSpreadColorStart = 2 
res@gsnSpreadColorEnd = 180

res@vpWidthF = 0.4
res@vpHeightF = 0.6

res@lbLabelBarOn = False

res@cnFillOn = True
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 0.
res@cnMaxLevelValF = 1.
res@cnLevelSpacingF = 0.02

res@gsnSpreadColors = True
res@cnInfoLabelOn = False
res@gsnLeftString = ""
res@gsnRightString = ""

res@gsnAddCyclic = False
res@mpCenterLonF = 282.5
res@mpMinLonF = 240.
res@mpMaxLonF = 290.
res@mpMinLatF = -30.
res@mpMaxLatF = -0.

res2 = True
res2@gsnDraw = False
res2@gsnFrame = False
res2@cnFillOn = False
res2@cnLinesOn = True
res2@cnLineLabelsOn = False
res2@cnInfoLabelOn = False
res2@cnLevelSelectionMode = "ExplicitLevels"
res2@cnLevels = (/0.20/)
res2@cnLineThicknessF = 3.0
res2@gsnLeftString = ""
res2@gsnRightString = ""
res2@cnLineColor = "black"


ft								= 0.015
res@gsnLeftStringFontHeightF	= ft
res@tmXTOn						= False
res@tmYROn						= False
res@tmXBLabelFontHeightF		= ft
res@tmYLLabelFontHeightF		= ft 

res@gsnLeftString = "(a) MODIS_day"
plot(0) = gsn_csm_contour_map_ce(wks,cld_obs_day_avg,res)
plot1 = gsn_csm_contour(wks,cld_obs_day_avg,res2)
overlay(plot(0),plot1)

res@gsnLeftString = "(b) MODIS_night"
plot(1) = gsn_csm_contour_map_ce(wks,cld_obs_nig_avg,res)
plot1 = gsn_csm_contour(wks,cld_obs_nig_avg,res2)
overlay(plot(1),plot1)


res@gsnLeftString = "(c) RH_day"
plot(2) = gsn_csm_contour_map_ce(wks,cld_old_day_avg,res)
plot1 = gsn_csm_contour(wks,cld_old_day_avg,res2)
overlay(plot(2),plot1)


res@gsnLeftString = "(d) RH_night"
plot(3) = gsn_csm_contour_map_ce(wks,cld_old_nig_avg,res)
plot1 = gsn_csm_contour(wks,cld_old_nig_avg,res2)
overlay(plot(3),plot1)


res@gsnLeftString = "(e) PDF_day"
plot(4) = gsn_csm_contour_map_ce(wks,cld_new_day_avg,res)
plot1 = gsn_csm_contour(wks,cld_new_day_avg,res2)
overlay(plot(4),plot1)


res@gsnLeftString = "(f) PDF_night"
plot(5) = gsn_csm_contour_map_ce(wks,cld_new_nig_avg,res)
plot1 = gsn_csm_contour(wks,cld_new_nig_avg,res2)
overlay(plot(5),plot1)


xmarkers = (/-75,-85,-95/)
ymarkers = (/-20,-20,-20/)

pmres = True
pmres@gsMarkerIndex = (/12,12,12/)
pmres@gsMarkerSizeF = 0.02
pmres@gsMarkerColor = "gray36"
pmres@gsMarkerThicknessF = 2.0

dum1 = gsn_add_polymarker(wks,plot(0),xmarkers,ymarkers,pmres)
;dum2 = gsn_add_polymarker(wks,plot(1),xmarkers,ymarkers,pmres)
;dum3 = gsn_add_polymarker(wks,plot(2),xmarkers,ymarkers,pmres)
;dum4 = gsn_add_polymarker(wks,plot(3),xmarkers,ymarkers,pmres)
;dum5 = gsn_add_polymarker(wks,plot(4),xmarkers,ymarkers,pmres)
;dum6 = gsn_add_polymarker(wks,plot(5),xmarkers,ymarkers,pmres)


resP = True
;resP@txString = "Cloud Fraction"
resP@gsnPanelLabelBar = True
;resP@lbOrientation     = "vertical"
resP@pmLabelBarWidthF  = 0.78
resP@pmLabelBarHeightF = 0.075
resP@lbLabelStride = 5.

gsn_panel(wks,plot,(/3,2/),resP)
end
