load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 


load "./functions_lat_interpolate.ncl"
load "./functions_getvar.ncl"

begin


ss = systemfunc("rm ./tmp*")

ncdf_mode = "create"

;***************file 1********************
;fdir = "/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision-1/data/output/"
fdir = "/home/lyl/WORK3/qinyi/mid-data/newcldfrac/revision-1/"

fdir_append = ""

fdir_obs = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/obs_data/"

;fname1 = "FC5_f09f09_MG15"
fname1 = "FC5_f09f09_MG15_COSP"

;fname2 = "new-cldfrac16-1d-MG15-revise-COSP"
fname2 = "new-cldfrac16-1d-MG15-revise-2-COSP"

;fname3 = "ERAI_ANN_climo.nc"
fname3 = "GPCP_ANN_climo.nc"

append = ".cam.h0.ANN.nc"

outptr1 = addfile("./tmp1.nc","c")
outptr2 = addfile("./tmp2.nc","c")
outptr3 = addfile("./tmp3.nc","c")


f1 = addfile(fdir+fname1+"/"+fname1+append,"r")
f2 = addfile(fdir+fname2+"/"+fname2+append,"r")
f3 = addfile(fdir_obs+fname3,"r")


PRECT_def = get_PRECT(f1,outptr1)

PRECT_new = get_PRECT(f2,outptr2)

PRECT_obs = f3->PRECT(0,{-90:90},:)


lat1 = f1->lat
lon1 = f1->lon
lat2 = f2->lat
lon2 = f2->lon
lat3 = f3->lat
lon3 = f3->lon

; interpolate data
PRECT_interp = lat_lon_interpolate(PRECT_def,lat1,lon1,PRECT_new,lat2,lon2,PRECT_obs,lat3,lon3)


PRECTdiff = PRECT_interp
PRECTdiff(0,:,:) = (/PRECT_interp(0,:,:)-PRECT_interp(2,:,:) /) ; def-obs
PRECTdiff(1,:,:) = (/PRECT_interp(1,:,:)-PRECT_interp(2,:,:) /) ; new-obs
PRECTdiff(2,:,:) = (/PRECT_interp(1,:,:)-PRECT_interp(0,:,:) /) ; new-def


;=================================
;========= significance test

; monthly dataset
;fils_def = systemfunc ("ls "+fdir+fname1+fdir_append+fname1+".cam.h0.000[2-6]-??.nc") ; file paths
;fils_new = systemfunc ("ls "+fdir+fname2+fdir_append+fname2+".cam.h0.000[2-6]-??.nc") ; file paths

; annual dataset
fils_def = systemfunc ("ls "+fdir+fname1+"/"+fname1+".cam.h0.000[2-6].nc") ; file paths
fils_new = systemfunc ("ls "+fdir+fname2+"/"+fname2+".cam.h0.000[2-6].nc") ; file paths

fs1 = addfiles (fils_def, "r")   
ListSetType (fs1, "cat")        ; concatenate (=default)

PRECT_def_mon = get_PRECT_mon(fs1)


fs2 = addfiles (fils_new, "r")   
ListSetType (fs2, "cat")        ; concatenate (=default)
PRECT_new_mon = get_PRECT_mon(fs2)

PRECT_def_mon_tmp = PRECT_def_mon(lat|:,lon|:,time|:)
PRECT_new_mon_tmp = PRECT_new_mon(lat|:,lon|:,time|:)

PRECT_def_mon_ave = dim_avg_Wrap(PRECT_def_mon_tmp)
PRECT_new_mon_ave = dim_avg_Wrap(PRECT_new_mon_tmp)

PRECT_def_mon_var = dim_variance_Wrap(PRECT_def_mon_tmp)
PRECT_new_mon_var = dim_variance_Wrap(PRECT_new_mon_tmp)


; estimate the number of independent values of a series of correlated observations.
sigr = 0.01
PRECT_def_mon_eqv = equiv_sample_size (PRECT_def_mon_tmp, sigr,0)
PRECT_new_mon_eqv = equiv_sample_size (PRECT_new_mon_tmp, sigr,0)

gw = f1->gw
PRECT_def_mon_N = wgt_areaave(PRECT_def_mon_eqv,gw,1.0,0)
PRECT_new_mon_N = wgt_areaave(PRECT_new_mon_eqv,gw,1.0,0)

iflag = False

prob = PRECT_def_mon_ave

prob=ttest(PRECT_def_mon_ave,PRECT_def_mon_var,PRECT_def_mon_N,PRECT_new_mon_ave,PRECT_new_mon_var,PRECT_new_mon_N,iflag,False)

prob@_FillValue = 9.96921e+36
prob@long_name = "Probability:difference between means"

prob_1 = where(prob.lt.0.05,prob,prob@_FillValue)

;************************create plot***************
;wks = gsn_open_wks("eps","../figure/fig11-lat-lon-prect-ttest-eps")
wks = gsn_open_wks("pdf","../figure/fig11-lat-lon-prect-ttest")

plot = new(6,graphic)

 cmap1 = read_colormap_file("WhiteBlueGreenYellowRed")
 cmap2 = read_colormap_file("BlueRed")

  res                      = True               ; plot mods desired

  res@gsnDraw = False
  res@gsnFrame = False
  
;  res@gsnMaximize = True

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels
  res@cnFillPalette        = cmap1(:200,:)        ; subset the color map

  res@mpLandFillColor      = "gray"            ; set land to be gray

  res@mpCenterLonF         = 180.
;  res@mpMinLatF            =  -40.
;  res@mpMaxLatF            =  40.

  res@gsnRightString = "PRECT (mm day~S~-1~N~)"

;  res@gsnLeftStringFontHeightF = 0.025
;  res@gsnRightStringFontHeightF = 0.025

  res@cnLevelSelectionMode="ManualLevels"
  res@cnMinLevelValF = 0.
  res@cnMaxLevelValF = 17.
  res@cnLevelSpacingF = 1.

ft                              = 0.028
res@gsnStringFontHeightF        = ft
res@tmXBMinorOn                 = False
res@tmYLMinorOn                 = False
res@tmXTOn                      = False
res@tmYROn                      = False
res@tmXBTickSpacingF            = 60.
res@tmXBLabelFontHeightF        = ft
res@tmYLLabelFontHeightF        = ft

res@pmLabelBarOrthogonalPosF    = 0.20
res@lbLabelStride               = 2.

;res@lbLabelBarOn = False
res@gsnLeftString = "(a) Park_RH"
plot(0) = gsn_csm_contour_map_ce (wks,PRECT_interp(0,:,:),res)
res@gsnLeftString = "(b) Gauss_PDF"
plot(1) = gsn_csm_contour_map_ce (wks,PRECT_interp(1,:,:),res)
res@gsnLeftString = "(c) GPCP"
plot(2) = gsn_csm_contour_map_ce (wks,PRECT_interp(2,:,:),res)


res2 = res
delete(res2@cnFillPalette)
res2@cnFillPalette = cmap2(:,:)

res2@cnLevelSelectionMode="ManualLevels"
res2@cnMinLevelValF = -6.
res2@cnMaxLevelValF = 6.
res2@cnLevelSpacingF = 0.5

;res2@lbLabelBarOn = False
res2@gsnLeftString = "(d) Park_RH-GPCP"
plot(3) = gsn_csm_contour_map_ce (wks,PRECTdiff(0,:,:),res2)
res2@gsnLeftString = "(e) Gauss_PDF-GPCP"
plot(4) = gsn_csm_contour_map_ce (wks,PRECTdiff(1,:,:),res2)
res2@gsnLeftString = "(f) Gauss_PDF-Park_RH"
plot(5) = gsn_csm_contour_map_ce (wks,PRECTdiff(2,:,:),res2)

;;;; stippling

  res3 = True                            ; res2 probability plots
  res3@gsnDraw             = False       ; Do not draw plot
  res3@gsnFrame            = False       ; Do not advance frome
  res3@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
  res3@cnMinLevelValF      = 0.00        ; set min contour level
  res3@cnMaxLevelValF      = 1.05        ; set max contour level
  res3@cnLevelSpacingF     = 0.05        ; set contour spacing
  res3@cnInfoLabelOn       = False
  res3@cnLinesOn           = False       ; do not draw contour lines
  res3@cnLineLabelsOn      = False       ; do not draw contour labels
  res3@cnFillScaleF        = 0.6         ; add extra density
                                         ; add cyclic point
  res3@gsnLeftString = ""
  res3@gsnRightString = ""

  plot2   = gsn_csm_contour(wks,gsn_add_cyclic_point(prob(:,:)), res3) 
  plot2   = ShadeLtContour(plot2, 0.07, 17) ; shade all areas < 0.07 contour
  overlay (plot(5), plot2)

;;;; panel finally
;pres1 = True
;pres1@gsnPanelLabelBar = True
;pres1@gsnFrame = False
;pres1@gsnPanelTop = 0.9
;pres1@gsnPanelBottom = 0.6
;pres1@pmLabelBarWidthF = 0.70
;pres1@pmLabelBarHeightF = 0.07
;pres1@lbLabelStride = 2
;pres1@pmLabelBarOrthogonalPosF = -0.015
;
;gsn_panel(wks,plot(0:2),(/1,3/),pres1)
;
;pres2 = True
;pres2@gsnPanelLabelBar = True
;pres2@gsnPanelTop = 0.6
;pres2@gsnPanelBottom = 0.3
;pres2@pmLabelBarWidthF = 0.70
;pres2@pmLabelBarHeightF = 0.07
;pres2@lbLabelStride = 2
;pres2@pmLabelBarOrthogonalPosF = -0.015
;
;gsn_panel(wks,plot(3:5),(/1,3/),pres2)


resP                                = True
resP@gsnPanelXWhiteSpacePercent     = 5.0
resP@gsnPanelYWhiteSpacePercent     = 5.0

plotall = (/plot(0),plot(3),plot(1),plot(4),plot(2),plot(5)/)
;gsn_panel(wks,ndtooned((/plot(0:2),plot(3:5)/)),(/2,3/),resP)
gsn_panel(wks,plotall,(/3,2/),resP)

end 

