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
fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

fdir_obs = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/obs_data/"

fname1 = "FC5_f09f09_MG15_COSP"

;fname2 = "new-cldfrac16-1d-MG15-revise-COSP"
fname2 = "new-cldfrac16-1d-MG15-revise-2-COSP"

fname3 = "ISCCP_ANN_climo.nc"

append = ".cam.h0.ANN.nc"


f1 = addfile(fdir+fname1+fdir_append+fname1+append,"r")
f2 = addfile(fdir+fname2+fdir_append+fname2+append,"r")
f3 = addfile(fdir_obs+fname3,"r")


CLDLOW_def = f1->CLDLOW(0,:,:)
CLDLOW_new = f2->CLDLOW(0,:,:)
CLDLOW_obs = f3->CLDLOW(0,{-90:90},:)

CLDLOW_def = CLDLOW_def*100.
CLDLOW_new = CLDLOW_new*100.


lat1 = f1->lat
lon1 = f1->lon
lat2 = f2->lat
lon2 = f2->lon
lat3 = f3->lat
lon3 = f3->lon

; interpolate data
CLDLOW_interp = lat_lon_interpolate(CLDLOW_def,lat1,lon1,CLDLOW_new,lat2,lon2,CLDLOW_obs,lat3,lon3)


CLDLOWdiff = CLDLOW_interp
CLDLOWdiff(0,:,:) = (/CLDLOW_interp(0,:,:)-CLDLOW_interp(2,:,:) /) ; def-obs
CLDLOWdiff(1,:,:) = (/CLDLOW_interp(1,:,:)-CLDLOW_interp(2,:,:) /) ; new-obs
CLDLOWdiff(2,:,:) = (/CLDLOW_interp(1,:,:)-CLDLOW_interp(0,:,:) /) ; new-def

;=================================
;========= significance test

; monthly dataset
;fils_def = systemfunc ("ls "+fdir+fname1+fdir_append+fname1+".cam.h0.000[2-6]-??.nc") ; file paths
;fils_new = systemfunc ("ls "+fdir+fname2+fdir_append+fname2+".cam.h0.000[2-6]-??.nc") ; file paths

; annual dataset
fils_def = systemfunc ("ls "+fdir+fname1+fdir_append+fname1+".cam.h0.000[2-6].nc") ; file paths
fils_new = systemfunc ("ls "+fdir+fname2+fdir_append+fname2+".cam.h0.000[2-6].nc") ; file paths

fs1 = addfiles (fils_def, "r")   
ListSetType (fs1, "cat")        ; concatenate (=default)

CLDLOW_def_mon = get_CLDLOW_mon(fs1)

printVarSummary(CLDLOW_def_mon)

fs2 = addfiles (fils_new, "r")   
ListSetType (fs2, "cat")        ; concatenate (=default)
CLDLOW_new_mon = get_CLDLOW_mon(fs2)

CLDLOW_def_mon_tmp = CLDLOW_def_mon(lat|:,lon|:,time|:)
CLDLOW_new_mon_tmp = CLDLOW_new_mon(lat|:,lon|:,time|:)

CLDLOW_def_mon_ave = dim_avg_Wrap(CLDLOW_def_mon_tmp)
CLDLOW_new_mon_ave = dim_avg_Wrap(CLDLOW_new_mon_tmp)

CLDLOW_def_mon_var = dim_variance_Wrap(CLDLOW_def_mon_tmp)
CLDLOW_new_mon_var = dim_variance_Wrap(CLDLOW_new_mon_tmp)


; estimate the number of independent values of a series of correlated observations.
sigr = 0.01
CLDLOW_def_mon_eqv = equiv_sample_size (CLDLOW_def_mon_tmp, sigr,0)
CLDLOW_new_mon_eqv = equiv_sample_size (CLDLOW_new_mon_tmp, sigr,0)

gw = f1->gw
CLDLOW_def_mon_N = wgt_areaave(CLDLOW_def_mon_eqv,gw,1.0,0)
CLDLOW_new_mon_N = wgt_areaave(CLDLOW_new_mon_eqv,gw,1.0,0)

iflag = False

prob = CLDLOW_def_mon_ave

prob=ttest(CLDLOW_def_mon_ave,CLDLOW_def_mon_var,CLDLOW_def_mon_N,CLDLOW_new_mon_ave,CLDLOW_new_mon_var,CLDLOW_new_mon_N,iflag,False)

prob@_FillValue = 9.96921e+36
prob@long_name = "Probability:difference between means"

prob_1 = where(prob.lt.0.05,prob,prob@_FillValue)

;************************create plot***************
wks = gsn_open_wks("pdf","figure/lat-lon-cloud-ttest")
;gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

plot = new(6,graphic)

;cmap1 = read_colormap_file("BlAqGrYeOrReVi200")
cmap1 = read_colormap_file("WhiteBlueGreenYellowRed")
cmap2 = read_colormap_file("BlueRed")

res                      = True               ; plot mods desired

res@gsnDraw = False
res@gsnFrame = False
 
;  res@gsnMaximize = True

res@cnFillOn             = True               ; turn on color for contours
res@cnLinesOn            = False              ; turn off contour lines
res@cnLineLabelsOn       = False              ; turn off contour line labels
res@cnFillPalette        = cmap1(:150,:)        ; subset the color map

res@mpLandFillColor      = "gray"            ; set land to be gray

res@mpCenterLonF         = 180.
;res@mpMinLatF            =  -40.
;res@mpMaxLatF            =  40.

res@gsnRightString = "CLDLOW(%)"

res@gsnLeftStringFontHeightF =  0.025
res@gsnRightStringFontHeightF = 0.025

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 98        ; min level
res@cnMinLevelValF       = 2
res@cnLevelSpacingF      = 4

res@lbLabelBarOn = False
res@gsnLeftString = "(a) Park_RH"
plot(0) = gsn_csm_contour_map_ce (wks,CLDLOW_interp(0,:,:),res)
res@gsnLeftString = "Gauss_PDF"
;plot(2) = gsn_csm_contour_map_ce (wks,CLDLOW_interp(1,:,:),res)
res@lbLabelBarOn = True
res@lbLabelStride = 4
res@pmLabelBarWidthF = 0.80
res@pmLabelBarOrthogonalPosF = 0.07

res@gsnLeftString = "(b) ISCCP"
;plot(4) = gsn_csm_contour_map_ce (wks,CLDLOW_interp(2,:,:),res)
plot(2) = gsn_csm_contour_map_ce (wks,CLDLOW_interp(2,:,:),res)

  res2 = res
  delete(res2@cnFillPalette)
  res2@cnFillPalette = cmap2(:,:)

res2@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res2@cnMaxLevelValF       = 40       ; min level
res2@cnMinLevelValF       = -40
res2@cnLevelSpacingF      = 5

res2@lbLabelBarOn = False
res2@gsnLeftString = "(c) RH-ISCCP"
plot(1) = gsn_csm_contour_map_ce (wks,CLDLOWdiff(0,:,:),res2)
res2@gsnLeftString = "PDF-ISCCP"
;plot(3) = gsn_csm_contour_map_ce (wks,CLDLOWdiff(1,:,:),res2)
res2@lbLabelBarOn = True
res2@lbLabelStride = 4
res2@pmLabelBarWidthF = 0.80
res2@pmLabelBarOrthogonalPosF = 0.07
res2@gsnLeftString = "(d) PDF-RH"
;plot(5) = gsn_csm_contour_map_ce (wks,CLDLOWdiff(2,:,:),res2)
plot(3) = gsn_csm_contour_map_ce (wks,CLDLOWdiff(2,:,:),res2)

resP = True
;resP@gsnAttachBorderOn = False
;resP@gsnPanelBottom = 0.2
;resP@gsnPanelTop = 0.9

;gsn_panel(wks,(/plot(0),plot(2),plot(4)/),(/3,1/),resP)
;gsn_panel(wks,(/plot(1),plot(3),plot(5)/),(/3,1/),resP)

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
  overlay (plot(3), plot2)

gsn_panel(wks,plot,(/2,2/),resP)
end
