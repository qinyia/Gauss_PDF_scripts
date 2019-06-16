
;**********************************************************************
; poly_15.ncl
;
; Concepts illustrated:
;   - Drawing polymarkers at station locations 
;**********************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


fdir = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/obs_data/"
fnme = "RAOBS.nc"

f1 = addfile(fdir+fnme,"r")
slat = f1->slat
slon = f1->slon
STATIONS = f1->STATIONS
station_id = f1->station_id
printVarSummary(station_id)

print(station_id+"  "+STATIONS+"  "+slat+"  "+slon)

  wks = gsn_open_wks("x11","sounding-location") ; send graphics to PNG file

  res                             = True
  res@gsnFrame                    = False   ; So we can draw markers
  res@gsnMaximize                 = True    ; affects ps, eps, pdf only
;  res@gsnPaperOrientation         = "portrait"  ; force portrait 

  res@tiMainString                = "Sounding Locations"


;  res@mpFillOn                    = False
;  res@mpOutlineDrawOrder          = "PreDraw"
;  res@mpFillDrawOrder             = "PostDraw"
;  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
;  res@mpUSStateLineColor          = "Gray10"
;  res@mpUSStateLineDashPattern    = 2

  res@pmTickMarkDisplayMode       = "Always"
  res@mpMinLonF = 0 
  res@mpMaxLonF = 360 
  res@mpCenterLonF = 180
;
; Draw the map (frame won't get advanced because gsnFrame was set to False).
;
  map = gsn_csm_map(wks,res)
;
; Draw markers on the plot in the lat/lon locations.
;
  mkres               = True
  mkres@gsMarkerIndex = 17     ; Filled circle
  mkres@gsMarkerSizeF = 0.03

  map@locations = gsn_add_polymarker(wks,map,slon,slat,mkres)

  tres       =  True
  tres@txFontHeightF = 0.01
  ; keeping the text as string type is necessary. So here convert int to string by sprinti.
  text = gsn_add_text(wks,map,sprinti("%0.2i",station_id),slon+3.,slat+3.,tres)

  draw(map)
  frame(wks)   ; Now advance the frame.
