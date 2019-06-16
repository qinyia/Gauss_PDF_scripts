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


stress_def = get_STRESS_MAG(f1,outptr1)
U1_def = get_TAUX_OCEAN(f1,outptr1)
V1_def = get_TAUY_OCEAN(f1,outptr1)

stress_new = get_STRESS_MAG(f2,outptr2)
U1_new = get_TAUX_OCEAN(f2,outptr2)
V1_new = get_TAUY_OCEAN(f2,outptr2)

stress_obs = f3->STRESS_MAG(0,{-90:90},:)
U1_obs = f3->TAUX(0,{-90:90},:) 
V1_obs = f3->TAUY(0,{-90:90},:) 

printVarSummary(stress_obs)

lat1 = f1->lat
lon1 = f1->lon
lat2 = f2->lat
lon2 = f2->lon
lat3 = f3->lat
lon3 = f3->lon

; interpolate data
stress_interp = lat_lon_interpolate(stress_def,lat1,lon1,stress_new,lat2,lon2,stress_obs,lat3,lon3)
U1_interp = lat_lon_interpolate(U1_def,lat1,lon1,U1_new,lat2,lon2,U1_obs,lat3,lon3)
V1_interp = lat_lon_interpolate(V1_def,lat1,lon1,V1_new,lat2,lon2,V1_obs,lat3,lon3)

printVarSummary(stress_interp)


Udiff = U1_interp
Udiff(0,:,:) = (/U1_interp(0,:,:)-U1_interp(2,:,:) /) ; def-obs
Udiff(1,:,:) = (/U1_interp(1,:,:)-U1_interp(2,:,:) /) ; new-obs
Udiff(2,:,:) = (/U1_interp(1,:,:)-U1_interp(0,:,:) /) ; new-def

Vdiff = V1_interp
Vdiff(0,:,:) = (/V1_interp(0,:,:)-V1_interp(2,:,:) /) ; def-obs
Vdiff(1,:,:) = (/V1_interp(1,:,:)-V1_interp(2,:,:) /) ; new-obs
Vdiff(2,:,:) = (/V1_interp(1,:,:)-V1_interp(0,:,:) /) ; new-def

stressdiff = stress_interp
stressdiff(0,:,:) = (/stress_interp(0,:,:)-stress_interp(2,:,:) /) ; def-obs
stressdiff(1,:,:) = (/stress_interp(1,:,:)-stress_interp(2,:,:) /) ; new-obs
stressdiff(2,:,:) = (/stress_interp(1,:,:)-stress_interp(0,:,:) /) ; new-def


printVarSummary(stressdiff)

;************************create plot***************
wks = gsn_open_wks("x11","figure/lat-lon-wind-stress")
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
  res@gsnScalarContour     = True               ; contours desired
  res@cnFillPalette        = cmap1(17:,:)        ; subset the color map

  res@mpLandFillColor      = "gray"            ; set land to be gray

  res@mpCenterLonF         = 180.
  res@mpMinLatF            =  -40.
  res@mpMaxLatF            =  40.

;  res@lbOrientation            = "Vertical"     ; vertical label bar
;  res@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer

  res@vcRefMagnitudeF           = 0.06             ; define vector ref mag
  res@vcRefLengthF              = 0.04          ; define length of vec ref
  res@vcRefAnnoOrthogonalPosF   = -1.0            ; move ref vector
  res@vcRefAnnoArrowLineColor   = "black"         ; change ref vector color
  res@vcRefAnnoArrowUseVecColor = False           ; don't use vec color for ref

  res@vcGlyphStyle            = "CurlyVector"     ; turn on curly vectors
  res@vcLineArrowColor        = "white"           ; change vector color
  res@vcLineArrowThicknessF   = 3.0               ; change vector thickness
  res@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last

  res@vcMinDistanceF    = 0.025 ; control the density of arrows: smaller value -> dense

  res@vcRefAnnoFontHeightF = 0.013 ; a minor bug in gsn_csm_vector_scalar_map_ce
  				   ; if not specified it, warning would appear.
  res@gsnRightString = "Surface Stress"

  res@gsnLeftStringFontHeightF = 0.015
  res@gsnRightStringFontHeightF = 0.015

  res@cnLevelSelectionMode="ManualLevels"
  res@cnMinLevelValF = 0.04
  res@cnMaxLevelValF = 0.20
  res@cnLevelSpacingF = 0.02


  res2 = res
  delete(res2@cnFillPalette)
  res2@cnFillPalette = cmap2(:,:)
  res2@vcRefMagnitudeF           = 0.01             ; define vector ref mag

  res2@cnLevelSelectionMode="ManualLevels"
  res2@cnMinLevelValF = -0.12
  res2@cnMaxLevelValF = 0.12
  res2@cnLevelSpacingF = 0.02

res@lbLabelBarOn = False
res@gsnLeftString = "Park_RH"
plot(0) = gsn_csm_vector_scalar_map_ce (wks,U1_interp(0,:,:),V1_interp(0,:,:),stress_interp(0,:,:),res)
res@gsnLeftString = "Gauss_PDF"
plot(2) = gsn_csm_vector_scalar_map_ce (wks,U1_interp(1,:,:),V1_interp(1,:,:),stress_interp(1,:,:),res)
res@lbLabelBarOn = True
res@gsnLeftString = "MERRA"
plot(4) = gsn_csm_vector_scalar_map_ce (wks,U1_interp(2,:,:),V1_interp(2,:,:),stress_interp(2,:,:),res)


res2@lbLabelBarOn = False
res2@gsnLeftString = "RH-MERRA"
plot(1) = gsn_csm_vector_scalar_map_ce (wks,Udiff(0,:,:),Vdiff(0,:,:),stressdiff(0,:,:),res2)
res2@gsnLeftString = "PDF-MERRA"
plot(3) = gsn_csm_vector_scalar_map_ce (wks,Udiff(1,:,:),Vdiff(1,:,:),stressdiff(1,:,:),res2)
res2@lbLabelBarOn = True
res2@gsnLeftString = "PDF-RH"
plot(5) = gsn_csm_vector_scalar_map_ce (wks,Udiff(2,:,:),Vdiff(2,:,:),stressdiff(2,:,:),res2)

resP = True
;resP@gsnAttachBorderOn = False
;resP@gsnPanelBottom = 0.2
;resP@gsnPanelTop = 0.9
gsn_panel(wks,(/plot(0),plot(2),plot(4)/),(/3,1/),resP)
gsn_panel(wks,(/plot(1),plot(3),plot(5)/),(/3,1/),resP)

gsn_panel(wks,plot,(/3,2/),resP)
end
