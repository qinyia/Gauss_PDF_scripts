load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
Dir                             = "/home/share3/lyl/work3/qinyi/double-ITCZ/data/"
fdir                    	= (/Dir+"amip/",Dir+"amip/"/)

append 				= "_ANN_climo.nc"

casenames 			= (/"FC5_f09f09_MG15_COSP","new-cldfrac16-1d-MG15-revise-2-COSP"/)
;vars				= (/"ICWMR","ICIMR"/)
;vars_unit			= (/"g/kg","g/kg"/)

vars				= (/"ICWMR"/)
vars_unit			= (/"g/kg"/)



level				= (/950,900,850,800,700,600/)


do ilev=0,dimsizes(level)-1
do icase=0,dimsizes(casenames)-1

do ivar=0,dimsizes(vars)-1

f_tmp 				= addfile(fdir(icase)+casenames(icase)+append,"r")

vartmp	 			= f_tmp->$vars(ivar)$(0,{level(ilev)},:,:)

if(vars(ivar).eq."sgm_tota".or.vars(ivar).eq."sgm_shal".or.vars(ivar).eq."sgm_turb")then
	varLatLon			= sqrt(abs(vartmp))*1e3
end if

if(vars(ivar).eq."CLDLIQ".or.vars(ivar).eq."ICWMR".or.vars(ivar).eq."ICIMR")then
	varLatLon			= vartmp*1e3
end if

copy_VarCoords(vartmp,varLatLon)

dims				= dimsizes(varLatLon)

if(ivar.eq.0.and.icase.eq.0)then
	varsLatLon			= new((/dimsizes(casenames),dimsizes(vars),dims(0),dims(1)/),typeof(varLatLon))
	varsLatLon!0			= "cases"
	varsLatLon!1		 	= "vars"
	varsLatLon(icase,ivar,:,:)	= varLatLon
else
	varsLatLon(icase,ivar,:,:)	= varLatLon
end if

end do ; do ivar=
end do ; do icase=

printVarSummary(varsLatLon)

; Difference between two schemes

varsLatLonDiff			= varsLatLon(1,:,:,:)-varsLatLon(0,:,:,:)
copy_VarCoords_1(varsLatLon(vars|:,lat|:,lon|:,cases|:),varsLatLonDiff)

printVarSummary(varsLatLonDiff)

printMinMax(varsLatLon,True)
printMinMax(varsLatLonDiff,True)

;**********************************************************
; Start Plotting...
;**********************************************************

do ivar=0,dimsizes(vars)-1

;create plot
wks 				= gsn_open_wks("pdf","./figure/Lat-Lon-"+level(ilev)+"hPa-"+vars(ivar))

gsn_define_colormap(wks,"CBR_wet")

res 				= True

res@gsnFrame 			= False
res@gsnDraw 			= False

res@gsnSpreadColors 		= True

res@cnLinesOn 			= False
res@cnFillOn 			= True

res@mpMinLonF 			= 0
res@mpMaxLonF 			= 360
res@mpCenterLonF 		= 180

res@gsnRightString 		= ""
res@gsnStringFontHeightF 	= 0.025

res@lbTitleOn        		= True                  ; turn on title
res@lbTitlePosition  		= "Right"	
res@lbTitleFontHeightF		= .015                ; make title smaller
res@lbTitleDirection 		= "Across"             ; title direction

res@gsnRightString		= level(ilev)+"hPa"

res1				= res

plot				= new(3,graphic)

res1@cnLevelSelectionMode 	= "ManualLevels" ; manually set contour levels
res1@cnMinLevelValF       	= 0.0
res1@cnMaxLevelValF       	= 0.4
res1@cnLevelSpacingF      	= 0.02


do icase=0,dimsizes(casenames)-1
	res1@gsnLeftString 		= casenames(icase)
	res1@lbTitleString    		= vars(ivar)+" ["+vars_unit(ivar)+"]"
	plot(icase)			= gsn_csm_contour_map_ce(wks,varsLatLon(icase,ivar,:,:),res1)
end do ; do icase=

; Plot Difference plot between two schemes
gsn_define_colormap(wks,"BlueDarkRed18")
res2				= res
res2@cnLevelSelectionMode 	= "ManualLevels" ; manually set contour levels
res2@cnMinLevelValF       	= -0.2
res2@cnMaxLevelValF       	= 0.2
res2@cnLevelSpacingF      	= 0.02

res2@gsnLeftString		= "Difference"
res2@lbTitleString    		= vars(ivar)+" ["+vars_unit(ivar)+"]"

plot(2)				= gsn_csm_contour_map_ce(wks,varsLatLonDiff(ivar,:,:),res2)

pres 				= True

gsn_panel(wks,plot,(/2,2/),pres)

end do; do ivar=

end do; do ilev=




end
