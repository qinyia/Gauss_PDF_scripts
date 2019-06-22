load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 


load "./functions_lat_interpolate.ncl"
load "./functions_getvar.ncl"

begin


;***************file 1********************
;fdir = "/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision-1/data/output/"
fdir = "/home/lyl/WORK3/qinyi/mid-data/newcldfrac/revision-1/"

fdir_append = ""

fdir_obs = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/obs_data/"

fname1 = "FC5_f09f09_MG15_COSP"

fname2 = "new-cldfrac16-1d-MG15-revise-2-COSP"

append = ".cam.h0.ANN.nc"


f1 = addfile(fdir+fname1+"/"+fname1+append,"r")
f2 = addfile(fdir+fname2+"/"+fname2+append,"r")


PRECL_def = f1->PRECL(0,:,:)
PRECL_new = f2->PRECL(0,:,:)

PRECL_def = PRECL_def*8.64e7
PRECL_new = PRECL_new*8.64e7

PRECC_def = f1->PRECC(0,:,:)
PRECC_new = f2->PRECC(0,:,:)

PRECC_def = PRECC_def*8.64e7
PRECC_new = PRECC_new*8.64e7


PRECLdiff = PRECL_new-PRECL_def
PRECCdiff = PRECC_new-PRECC_def

copy_VarCoords(PRECL_def,PRECLdiff)
copy_VarCoords(PRECC_def,PRECCdiff)

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

PRECL_def_mon = fs1[:]->PRECL
PRECC_def_mon = fs1[:]->PRECC


fs2 = addfiles (fils_new, "r")   
ListSetType (fs2, "cat")        ; concatenate (=default)
PRECL_new_mon = fs2[:]->PRECL
PRECC_new_mon = fs2[:]->PRECC


PRECL_def_mon_tmp = PRECL_def_mon(lat|:,lon|:,time|:)
PRECL_new_mon_tmp = PRECL_new_mon(lat|:,lon|:,time|:)
PRECC_def_mon_tmp = PRECC_def_mon(lat|:,lon|:,time|:)
PRECC_new_mon_tmp = PRECC_new_mon(lat|:,lon|:,time|:)

PRECL_def_mon_ave = dim_avg_Wrap(PRECL_def_mon_tmp)
PRECL_new_mon_ave = dim_avg_Wrap(PRECL_new_mon_tmp)
PRECC_def_mon_ave = dim_avg_Wrap(PRECC_def_mon_tmp)
PRECC_new_mon_ave = dim_avg_Wrap(PRECC_new_mon_tmp)

PRECL_def_mon_var = dim_variance_Wrap(PRECL_def_mon_tmp)
PRECL_new_mon_var = dim_variance_Wrap(PRECL_new_mon_tmp)
PRECC_def_mon_var = dim_variance_Wrap(PRECC_def_mon_tmp)
PRECC_new_mon_var = dim_variance_Wrap(PRECC_new_mon_tmp)

; estimate the number of independent values of a series of correlated observations.
sigr = 0.01
PRECL_def_mon_eqv = equiv_sample_size (PRECL_def_mon_tmp, sigr,0)
PRECL_new_mon_eqv = equiv_sample_size (PRECL_new_mon_tmp, sigr,0)
PRECC_def_mon_eqv = equiv_sample_size (PRECC_def_mon_tmp, sigr,0)
PRECC_new_mon_eqv = equiv_sample_size (PRECC_new_mon_tmp, sigr,0)


gw = f1->gw
PRECL_def_mon_N = wgt_areaave(PRECL_def_mon_eqv,gw,1.0,0)
PRECL_new_mon_N = wgt_areaave(PRECL_new_mon_eqv,gw,1.0,0)
PRECC_def_mon_N = wgt_areaave(PRECC_def_mon_eqv,gw,1.0,0)
PRECC_new_mon_N = wgt_areaave(PRECC_new_mon_eqv,gw,1.0,0)


iflag = False

prob_l = PRECL_def_mon_ave
prob_c = PRECC_def_mon_ave

prob_l=ttest(PRECL_def_mon_ave,PRECL_def_mon_var,PRECL_def_mon_N,PRECL_new_mon_ave,PRECL_new_mon_var,PRECL_new_mon_N,iflag,False)
prob_c=ttest(PRECC_def_mon_ave,PRECC_def_mon_var,PRECC_def_mon_N,PRECC_new_mon_ave,PRECC_new_mon_var,PRECC_new_mon_N,iflag,False)

prob_l@_FillValue = 9.96921e+36
prob_l@long_name = "Probability:difference between means"

prob_c@_FillValue = 9.96921e+36
prob_c@long_name = "Probability:difference between means"

;************************create plot***************
;wks = gsn_open_wks("eps","../figure/fig12-lat-lon-precc-precl-ttest-eps")
wks = gsn_open_wks("pdf","../figure/fig12-lat-lon-precc-precl-ttest")

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

  res@gsnRightString = "PRECL (mm day~S~-1~N~)"

  res@gsnLeftStringFontHeightF = 0.025
  res@gsnRightStringFontHeightF = 0.025

  res@cnLevelSelectionMode="ManualLevels"
  res@cnMinLevelValF = 0.
  res@cnMaxLevelValF = 14.
  res@cnLevelSpacingF = 1.

;  res@lbLabelStride = 2

ft                              = 0.032
res@gsnStringFontHeightF        = ft
res@tmXBMinorOn                 = False
res@tmYLMinorOn                 = False
res@tmXTOn                      = False
res@tmYROn                      = False
res@tmXBTickSpacingF            = 60.
res@tmXBLabelFontHeightF        = ft
res@tmYLLabelFontHeightF        = ft

res@pmLabelBarOrthogonalPosF    = 0.20
res@lbLabelStride               = 4.

;;;;;;;res2
  res2 = res
  delete(res2@cnFillPalette)
  res2@cnFillPalette = cmap2(:,:)

  res2@cnLevelSelectionMode="ManualLevels"
  res2@cnMinLevelValF = -4.
  res2@cnMaxLevelValF = 4.
  res2@cnLevelSpacingF = 0.5


res@gsnLeftString = "(a) Park_RH"
plot(0) = gsn_csm_contour_map_ce (wks,PRECL_def,res)
res@gsnLeftString = "(b)Gauss_PDF"
plot(1) = gsn_csm_contour_map_ce (wks,PRECL_new,res)
res2@gsnLeftString = "(c) PDF-RH"
plot(2) = gsn_csm_contour_map_ce (wks,PRECLdiff,res2)

res@gsnRightString = "PRECC (mm day~S~-1~N~)"
res2@gsnRightString = "PRECC (mm day~S~-1~N~)"

res@gsnLeftString = "(d) Park_RH"
plot(3) = gsn_csm_contour_map_ce (wks,PRECC_def,res)
res@gsnLeftString = "(e)Gauss_PDF"
plot(4) = gsn_csm_contour_map_ce (wks,PRECC_new,res)
res2@gsnLeftString = "(f) PDF-RH"
plot(5) = gsn_csm_contour_map_ce (wks,PRECCdiff,res2)



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

  plot2   = gsn_csm_contour(wks,gsn_add_cyclic_point(prob_l(:,:)), res3) 
  plot2   = ShadeLtContour(plot2, 0.07, 17) ; shade all areas < 0.07 contour
  overlay (plot(2), plot2)

  plot3   = gsn_csm_contour(wks,gsn_add_cyclic_point(prob_c(:,:)), res3) 
  plot3   = ShadeLtContour(plot3, 0.07, 17) ; shade all areas < 0.07 contour
  overlay (plot(5), plot3)

;  draw(plot(5))
;  frame(wks)


resP = True
resP@gsnPanelXWhiteSpacePercent     = 5.0
resP@gsnPanelYWhiteSpacePercent     = 5.0
gsn_panel(wks,plot,(/2,3/),resP)
end
