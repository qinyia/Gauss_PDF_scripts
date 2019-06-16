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


f1 = addfile(fdir+fname1+fdir_append+fname1+append,"r")
f2 = addfile(fdir+fname2+fdir_append+fname2+append,"r")
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
fils_def = systemfunc ("ls "+fdir+fname1+fdir_append+fname1+".cam.h0.000[2-6].nc") ; file paths
fils_new = systemfunc ("ls "+fdir+fname2+fdir_append+fname2+".cam.h0.000[2-6].nc") ; file paths

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
wks = gsn_open_wks("pdf","figure/lat-lon-prect-stippling")
gsn_define_colormap(wks,"BlueRed")

plot = new(6,graphic)

 cmap1 = read_colormap_file("BlAqGrYeOrReVi200")
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
  res@mpMinLatF            =  -40.
  res@mpMaxLatF            =  40.

  res@gsnRightString = "Precipitation Rate (mm/day)"

  res@gsnLeftStringFontHeightF = 0.015
  res@gsnRightStringFontHeightF = 0.015

  res@cnLevelSelectionMode="ManualLevels"
  res@cnMinLevelValF = 0.
  res@cnMaxLevelValF = 17.
  res@cnLevelSpacingF = 1.

res@lbLabelBarOn = False
res@gsnLeftString = "Park_RH"
plot(0) = gsn_csm_contour_map_ce (wks,PRECT_interp(0,:,:),res)
res@gsnLeftString = "Gauss_PDF"
plot(2) = gsn_csm_contour_map_ce (wks,PRECT_interp(1,:,:),res)
res@lbLabelBarOn = True
res@gsnLeftString = "GPCP"
plot(4) = gsn_csm_contour_map_ce (wks,PRECT_interp(2,:,:),res)


  res2 = res
  delete(res2@cnFillPalette)
  res2@cnFillPalette = cmap2(:,:)

  res2@cnLevelSelectionMode="ManualLevels"
  res2@cnMinLevelValF = -6.
  res2@cnMaxLevelValF = 6.
  res2@cnLevelSpacingF = 0.5

res2@lbLabelBarOn = False
res2@gsnLeftString = "RH-GPCP"
plot(1) = gsn_csm_contour_map_ce (wks,PRECTdiff(0,:,:),res2)
res2@gsnLeftString = "PDF-GPCP"
plot(3) = gsn_csm_contour_map_ce (wks,PRECTdiff(1,:,:),res2)
res2@lbLabelBarOn = True
res2@gsnLeftString = "PDF-RH"
plot(5) = gsn_csm_contour_map_ce (wks,PRECTdiff(2,:,:),res2)

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
  overlay (plot(5), plot2)
  draw(plot(5))
  frame(wks)

  plot3   = gsn_csm_contour(wks,gsn_add_cyclic_point(prob(:,:)), res3) 
  plot3   = ShadeLtContour(plot3, 0.06, 17) ; shade all areas < 0.07 contour
  overlay (plot(5), plot3)
  draw(plot(5))
  frame(wks)




;gsn_panel(wks,plot,(/3,2/),resP)
end
