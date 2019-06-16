load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

load "./functions_lat_interpolate.ncl"
load "./functions_getvar.ncl"

begin


ss = systemfunc("rm ./tmp*")

ncdf_mode = "create"

;***************file 1********************
fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

fdir_obs = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/obs_data/"

fname1 = "FC5_f09f09_MG15"

;fname2 = "new-cldfrac16-1d-MG15"
fname2 = "new-cldfrac16-1d-MG15-revise-2-COSP"

;fname3 = "ERAI_ANN_climo.nc"
fname3 = "MERRA_ANN_climo.nc"

append = ".cam.h0.ANN.nc"


f1 = addfile(fdir+fname1+fdir_append+fname1+append,"r")
f2 = addfile(fdir+fname2+fdir_append+fname2+append,"r")
f3 = addfile(fdir_obs+fname3,"r")

outptr1 = addfile("./tmp1.nc","c")
outptr2 = addfile("./tmp2.nc","c")
outptr3 = addfile("./tmp3.nc","c")


PSL_def = get_PSL(f1,outptr1)

PSL_new = get_PSL(f2,outptr2)

PSL_obs = f3->PSL(0,{-90:90},:)

printVarSummary(PSL_obs)

lat1 = f1->lat
lon1 = f1->lon
lat2 = f2->lat
lon2 = f2->lon
lat3 = f3->lat
lon3 = f3->lon

; interpolate data
PSL_interp = lat_lon_interpolate(PSL_def,lat1,lon1,PSL_new,lat2,lon2,PSL_obs,lat3,lon3)

printVarSummary(PSL_interp)

PSLdiff = PSL_interp
PSLdiff(0,:,:) = (/PSL_interp(0,:,:)-PSL_interp(2,:,:) /) ; def-obs
PSLdiff(1,:,:) = (/PSL_interp(1,:,:)-PSL_interp(2,:,:) /) ; new-obs
PSLdiff(2,:,:) = (/PSL_interp(1,:,:)-PSL_interp(0,:,:) /) ; new-def


printVarSummary(PSLdiff)

;************************create plot***************
wks = gsn_open_wks("pdf","figure/lat-lon-SLP")
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

  res@gsnRightString = "Sea-level pressure"

  res@gsnLeftStringFontHeightF = 0.015
  res@gsnRightStringFontHeightF = 0.015

  res@cnLevelSelectionMode="ManualLevels"
  res@cnMinLevelValF = 980.
  res@cnMaxLevelValF = 1020.
  res@cnLevelSpacingF = 5.



  res2 = res
  delete(res2@cnFillPalette)
  res2@cnFillPalette = cmap2(:,:)

  res2@cnLevelSelectionMode="ManualLevels"
  res2@cnMinLevelValF = -4.
  res2@cnMaxLevelValF = 4.
  res2@cnLevelSpacingF = 0.5

res@lbLabelBarOn = False
res@gsnLeftString = "Park_RH"
plot(0) = gsn_csm_contour_map_ce (wks,PSL_interp(0,:,:),res)
res@gsnLeftString = "Gauss_PDF"
plot(2) = gsn_csm_contour_map_ce (wks,PSL_interp(1,:,:),res)
res@lbLabelBarOn = True
res@gsnLeftString = "MERRA"
plot(4) = gsn_csm_contour_map_ce (wks,PSL_interp(2,:,:),res)


res2@lbLabelBarOn = False
res2@gsnLeftString = "RH-MERRA"
plot(1) = gsn_csm_contour_map_ce (wks,PSLdiff(0,:,:),res2)
res2@gsnLeftString = "PDF-MERRA"
plot(3) = gsn_csm_contour_map_ce (wks,PSLdiff(1,:,:),res2)
res2@lbLabelBarOn = True
res2@gsnLeftString = "PDF-RH"
plot(5) = gsn_csm_contour_map_ce (wks,PSLdiff(2,:,:),res2)

resP = True
;resP@gsnAttachBorderOn = False
;resP@gsnPanelBottom = 0.2
;resP@gsnPanelTop = 0.9
gsn_panel(wks,(/plot(0),plot(2),plot(4)/),(/3,1/),resP)
gsn_panel(wks,(/plot(1),plot(3),plot(5)/),(/3,1/),resP)

gsn_panel(wks,plot,(/3,2/),resP)
end
