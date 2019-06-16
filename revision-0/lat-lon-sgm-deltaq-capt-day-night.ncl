
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
begin
;fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt-vocals-revise/run/hourmean/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt-vocals-shalcld-output2/run/hourmean/"

fname2 = "day03.nc"

;******************read data*******
f2 = addfile(fdir2+fname2,"r")

sgm_tota = f2->sgm_tota(:,{900},:,:)
sgm_tota = sqrt(abs(sgm_tota))*1e3

sgm_shal = f2->sgm_shal(:,{900},:,:)
sgm_shal = sqrt(abs(sgm_shal))*1e3

sgm_turb = f2->sgm_turb(:,{900},:,:)
sgm_turb = sqrt(abs(sgm_turb))*1e3

deltaq_sat = f2->deltaq_sat(:,{900},:,:)
deltaq_sat = deltaq_sat*1e3


;=============day mean
sgm_tota_day = sgm_tota(5:5,:,:)
sgm_tota_day_avg = dim_avg_n_Wrap(sgm_tota_day,0)

sgm_shal_day = sgm_shal(5:5,:,:)
sgm_shal_day_avg = dim_avg_n_Wrap(sgm_shal_day,0)

sgm_turb_day = sgm_turb(5:5,:,:)
sgm_turb_day_avg = dim_avg_n_Wrap(sgm_turb_day,0)

deltaq_sat_day = deltaq_sat(5:5,:,:)
deltaq_sat_day_avg = dim_avg_n_Wrap(deltaq_sat_day,0)



;=============night mean
sgm_tota_nig = sgm_tota(2:2,:,:)
sgm_tota_nig_avg = dim_avg_n_Wrap(sgm_tota_nig,0)

sgm_shal_nig = sgm_shal(2:2,:,:)
sgm_shal_nig_avg = dim_avg_n_Wrap(sgm_shal_nig,0)

sgm_turb_nig = sgm_turb(2:2,:,:)
sgm_turb_nig_avg = dim_avg_n_Wrap(sgm_turb_nig,0)

deltaq_sat_nig = deltaq_sat(2:2,:,:)
deltaq_sat_nig_avg = dim_avg_n_Wrap(deltaq_sat_nig,0)



printVarSummary(sgm_turb_nig_avg)

;*******************plot*************************
;create plot
wks = gsn_open_wks("x11","./figure/lat-lon-sgm-deltaq-capt-day-night")
plot = new(8,graphic)

;gsn_define_colormap(wks,"MPL_rainbow")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

res = True
res@gsnDraw = False
res@gsnFrame = False
res@gsnSpreadColorStart = 2 
res@gsnSpreadColorEnd = 180

res@vpWidthF = 0.35
res@vpHeightF = 0.55

res@lbLabelBarOn = False

res@cnFillOn = True
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 0.
res@cnMaxLevelValF = 0.5
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
res2@cnLevels = (/0.05/)
res2@cnLineThicknessF = 3.0
res2@gsnLeftString = ""
res2@gsnRightString = ""

res@gsnLeftStringFontHeightF = 0.015
res@gsnRightStringFontHeightF = 0.015


res@gsnLeftString = "(a) PDF_day"
res@gsnRightString = "sgm_tota"
plot(0) = gsn_csm_contour_map_ce(wks,sgm_tota_day_avg,res)
plot1 = gsn_csm_contour(wks,sgm_tota_day_avg,res2)
overlay(plot(0),plot1)

res@gsnLeftString = "(b) PDF_night"
res@gsnRightString = "sgm_tota"
plot(1) = gsn_csm_contour_map_ce(wks,sgm_tota_nig_avg,res)
plot1 = gsn_csm_contour(wks,sgm_tota_nig_avg,res2)
overlay(plot(1),plot1)

res@gsnLeftString = "(c) PDF_day"
res@gsnRightString = "sgm_shal"
plot(2) = gsn_csm_contour_map_ce(wks,sgm_shal_day_avg,res)
plot1 = gsn_csm_contour(wks,sgm_shal_day_avg,res2)
overlay(plot(2),plot1)

res@gsnLeftString = "(d) PDF_night"
res@gsnRightString = "sgm_shal"
plot(3) = gsn_csm_contour_map_ce(wks,sgm_shal_nig_avg,res)
plot1 = gsn_csm_contour(wks,sgm_shal_nig_avg,res2)
overlay(plot(3),plot1)

res@gsnLeftString = "(e) PDF_day"
res@gsnRightString = "sgm_turb"
plot(4) = gsn_csm_contour_map_ce(wks,sgm_turb_day_avg,res)
plot1 = gsn_csm_contour(wks,sgm_turb_day_avg,res2)
overlay(plot(4),plot1)

res@gsnLeftString = "(f) PDF_night"
res@gsnRightString = "sgm_turb"
plot(5) = gsn_csm_contour_map_ce(wks,sgm_turb_nig_avg,res)
plot1 = gsn_csm_contour(wks,sgm_turb_nig_avg,res2)
overlay(plot(5),plot1)

res@gsnLeftString = "(g) PDF_day"
res@gsnRightString = "deltaq_sat"
plot(6) = gsn_csm_contour_map_ce(wks,deltaq_sat_day_avg,res)
plot1 = gsn_csm_contour(wks,deltaq_sat_day_avg,res2)
overlay(plot(6),plot1)

res@gsnLeftString = "(h) PDF_night"
res@gsnRightString = "deltaq_sat"
plot(7) = gsn_csm_contour_map_ce(wks,deltaq_sat_nig_avg,res)
plot1 = gsn_csm_contour(wks,deltaq_sat_nig_avg,res2)
overlay(plot(7),plot1)


xmarkers = (/-75,-85/)
ymarkers = (/-20,-20/)

pmres = True
pmres@gsMarkerIndex = (/12,12,12/)
pmres@gsMarkerSizeF = 0.02
pmres@gsMarkerColor = "Black"

dum1 = gsn_add_polymarker(wks,plot(0),xmarkers,ymarkers,pmres)
dum2 = gsn_add_polymarker(wks,plot(1),xmarkers,ymarkers,pmres)






resP = True
;resP@txString = "Cloud Fraction"
resP@gsnPanelLabelBar = True
;resP@lbOrientation     = "vertical"
;resP@pmLabelBarWidthF  = 0.75
;resP@pmLabelBarHeightF = 0.073
resP@lbLabelStride = 5.

resP@lbOrientation = "vertical"
resP@pmLabelBarWidthF  = 0.10
resP@pmLabelBarHeightF = 0.90
resP@pmLabelBarOrthogonalPosF = 0.03

gsn_panel(wks,plot,(/4,2/),resP)
end
