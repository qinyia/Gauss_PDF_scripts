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
;/home/lyl/WORK3/qinyi/mid-data/newcldfrac/revision-1/
;fdir = "/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision-1/data/output/"
fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = ""

fdir_obs = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/obs_data/"

fname1 = "FC5_f09f09_MG15_COSP"

fname2 = "new-cldfrac16-1d-MG15-revise-2-COSP"

fname3 = "CERES-EBAF_ANN_climo.nc"

append = ".cam.h0.ANN.nc"


f1 = addfile(fdir+fname1+"/atm/hist/"+fname1+append,"r")
f2 = addfile(fdir+fname2+"/atm/hist/"+fname2+append,"r")
f3 = addfile(fdir_obs+fname3,"r")


LWCF_def = f1->LWCF(0,:,:) 
LWCF_new = f2->LWCF(0,:,:) 
LWCF_obs = f3->LWCF(0,:,:) 


lat1 = f1->lat
lon1 = f1->lon
lat2 = f2->lat
lon2 = f2->lon
lat3 = f3->lat
lon3 = f3->lon

; interpolate data
LWCF_interp = lat_lon_interpolate(LWCF_def,lat1,lon1,LWCF_new,lat2,lon2,LWCF_obs,lat3,lon3)


LWCFdiff = LWCF_interp
LWCFdiff(0,:,:) = (/LWCF_interp(0,:,:)-LWCF_interp(2,:,:) /) ; def-obs
LWCFdiff(1,:,:) = (/LWCF_interp(1,:,:)-LWCF_interp(2,:,:) /) ; new-obs
LWCFdiff(2,:,:) = (/LWCF_interp(1,:,:)-LWCF_interp(0,:,:) /) ; new-def

;=================================
;========= significance test

; monthly dataset
;fils_def = systemfunc ("ls "+fdir+fname1+fdir_append+fname1+".cam.h0.000[2-6]-??.nc") ; file paths
;fils_new = systemfunc ("ls "+fdir+fname2+fdir_append+fname2+".cam.h0.000[2-6]-??.nc") ; file paths

; annual dataset
fils_def = systemfunc ("ls "+fdir+fname1+"/atm/hist/"+fname1+".cam.h0.000[2-6].nc") ; file paths
fils_new = systemfunc ("ls "+fdir+fname2+"/atm/hist/"+fname2+".cam.h0.000[2-6].nc") ; file paths

fs1 = addfiles (fils_def, "r")   
ListSetType (fs1, "cat")        ; concatenate (=default)

LWCF_def_mon = fs1[:]->LWCF
printVarSummary(LWCF_def_mon)

fs2 = addfiles (fils_new, "r")   
ListSetType (fs2, "cat")        ; concatenate (=default)
LWCF_new_mon = fs2[:]->LWCF

printVarSummary(LWCF_new_mon)

LWCF_def_mon_tmp = LWCF_def_mon(lat|:,lon|:,time|:)
LWCF_new_mon_tmp = LWCF_new_mon(lat|:,lon|:,time|:)

LWCF_def_mon_ave = dim_avg_Wrap(LWCF_def_mon_tmp)
LWCF_new_mon_ave = dim_avg_Wrap(LWCF_new_mon_tmp)

LWCF_def_mon_var = dim_variance_Wrap(LWCF_def_mon_tmp)
LWCF_new_mon_var = dim_variance_Wrap(LWCF_new_mon_tmp)


; estimate the number of independent values of a series of correlated observations.
sigr = 0.01
LWCF_def_mon_eqv = equiv_sample_size (LWCF_def_mon_tmp, sigr,0)
LWCF_new_mon_eqv = equiv_sample_size (LWCF_new_mon_tmp, sigr,0)

gw = f1->gw
LWCF_def_mon_N = wgt_areaave(LWCF_def_mon_eqv,gw,1.0,0)
LWCF_new_mon_N = wgt_areaave(LWCF_new_mon_eqv,gw,1.0,0)

iflag = False

prob = LWCF_def_mon_ave

prob=ttest(LWCF_def_mon_ave,LWCF_def_mon_var,LWCF_def_mon_N,LWCF_new_mon_ave,LWCF_new_mon_var,LWCF_new_mon_N,iflag,False)

prob@_FillValue = 9.96921e+36
prob@long_name = "Probability:difference between means"

prob_1 = where(prob.lt.0.05,prob,prob@_FillValue)

;************************create plot***************
date=systemfunc("date")
print(date)
wks = gsn_open_wks("pdf","../figure/lat-lon-LWCF-ttest-"+date)
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

res@gsnRightString = "LWCF(W/m~S~2~N~)"

res@gsnLeftStringFontHeightF =  0.025
res@gsnRightStringFontHeightF = 0.025

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 80.
res@cnMinLevelValF       = 0.
res@cnLevelSpacingF      = 10.

res@lbLabelBarOn = False
res@gsnLeftString = "(a) Park_RH"
plot(0) = gsn_csm_contour_map_ce (wks,LWCF_interp(0,:,:),res)
res@gsnLeftString = "(b) Gauss_PDF"
plot(1) = gsn_csm_contour_map_ce (wks,LWCF_interp(1,:,:),res)
res@gsnLeftString = "(c) CERES-EBAF"
plot(2) = gsn_csm_contour_map_ce (wks,LWCF_interp(2,:,:),res)

res2 = res
delete(res2@cnFillPalette)
res2@cnFillPalette = cmap2(:,:)

res2@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res2@cnMaxLevelValF       = 40       ; min level
res2@cnMinLevelValF       = -40
res2@cnLevelSpacingF      = 5

res2@lbLabelBarOn = False
res2@gsnLeftString = "(d) RH-CERES-EBAF"
plot(3) = gsn_csm_contour_map_ce (wks,LWCFdiff(0,:,:),res2)
res2@gsnLeftString = "(e) PDF-CERES-EBAF"
plot(4) = gsn_csm_contour_map_ce (wks,LWCFdiff(1,:,:),res2)
res2@gsnLeftString = "(f) PDF-RH"
plot(5) = gsn_csm_contour_map_ce (wks,LWCFdiff(2,:,:),res2)

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
pres1 = True
pres1@gsnPanelLabelBar = True
pres1@gsnFrame = False
pres1@gsnPanelTop = 0.9
pres1@gsnPanelBottom = 0.6
pres1@pmLabelBarWidthF = 0.70
pres1@pmLabelBarHeightF = 0.07
pres1@lbLabelStride = 2
pres1@pmLabelBarOrthogonalPosF = -0.015

gsn_panel(wks,plot(0:2),(/1,3/),pres1)

pres2 = True
pres2@gsnPanelLabelBar = True
pres2@gsnPanelTop = 0.6
pres2@gsnPanelBottom = 0.3
pres2@pmLabelBarWidthF = 0.70
pres2@pmLabelBarHeightF = 0.07
pres2@lbLabelStride = 2
pres2@pmLabelBarOrthogonalPosF = -0.015

gsn_panel(wks,plot(3:5),(/1,3/),pres2)




end
