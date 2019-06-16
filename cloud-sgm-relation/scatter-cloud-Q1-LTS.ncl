
load "./eis-annual.ncl"

;----------------------------------------------------------------------
; Function to attach a labelbar outside of an XY plot
;----------------------------------------------------------------------
function attach_labelbar(wks,plot,labels,colors)
local lbres, vph, vpw, nboxes
begin
  nboxes = dimsizes(labels)
  getvalues plot                      ; Get plot size for use in
    "vpHeightF" : vph                 ; creating labelbar.
    "vpWidthF"  : vpw
  end getvalues

  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = False          ; Necessary to control sizes
  lbres@lbPerimOn          = False
  lbres@vpWidthF           = 0.2 * vpw     ; labelbar width
  lbres@vpHeightF          = vph           ; labelbar height
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.02          ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
  lbres@lbBoxLinesOn       = False

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)
;
; Now, create some annotation resources indicating how we want to
; attach the labelbar to the plot.
;                                                                 
  amres                = True
  amres@amParallelPosF = 0.61     ; Move away from plot
  annoid = gsn_add_annotation(plot,lbid,amres)

  return(annoid)
  delete([/lbres,vph,vpw,nboxes,lbid,amres,annoid/])

end 


begin

fdir			= "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append		= "/atm/hist/"
case			= "new-cldfrac16-1d-MG15-revise-2-COSP"
append			= ".cam.h0."

fdir_regrid		= "/home/lyl/WORK3/qinyi/mid-data/"
project			= "cloud-sgm-relation/"

;files			= systemfunc("ls "+fdir+case+fdir_append+case+append+"0002-??.nc")
;files			= systemfunc("ls "+fdir+case+fdir_append+case+append+"ANN.nc")
files			= systemfunc("ls "+fdir_regrid+project+case+append+"ANN_regrid.nc")

f1			= addfiles(files,"r")

CLOUD			= f1[:]->CLOUD
sgm			= f1[:]->sgm_tota
deltaq			= f1[:]->delta_q
aa			= f1[:]->aa
temp			= f1[:]->T
qv			= f1[:]->Q
CLDLOW			= f1[:]->CLDLOW

landfrac		= f1[:]->LANDFRAC
landfrac_4D		= conform(CLOUD,landfrac,(/0,2,3/))

time			= CLOUD&time
lev			= CLOUD&lev
lat			= CLOUD&lat
lon			= CLOUD&lon

result			= get_eis(temp,qv,lev)
LTS_tmp			= result[0]
EIS_tmp			= result[1]
printMinMax(LTS_tmp,False)

LTS			= conform(CLOUD,LTS_tmp,(/0,2,3/))
copy_VarCoords(CLOUD,LTS)
printVarSummary(LTS)

lat_4D			= conform(CLOUD,lat,(/2/))
printVarSummary(lat_4D)



sgm			= sqrt(sgm)*1e3
deltaq			= deltaq*1e3

CLOUD@_FillValue	= 1e20
sgm@_FillValue		= 1e20
deltaq@_FillValue	= 1e20
LTS@_FillValue		= 1e20

; mask land regions
CLOUD			= where(landfrac_4D.gt.0.9,CLOUD@_FillValue,CLOUD)
sgm			= where(landfrac_4D.gt.0.9,sgm@_FillValue,sgm)
deltaq			= where(landfrac_4D.gt.0.9,deltaq@_FillValue,deltaq)
LTS			= where(landfrac_4D.gt.0.9,LTS@_FillValue,LTS)

sgm			= where(sgm.lt.1e-4,sgm@_FillValue,sgm)

Q1			= aa*deltaq/2./where(sgm.ne.0,sgm,sgm@_FillValue)
;Q1			= where(abs(Q1).lt.10,Q1,Q1@_FillValue)
copy_VarCoords(sgm,Q1)
printVarSummary(Q1)
printMinMax(Q1,False)
;-------------------------------------------
LTSSA			= (/2,12,16/)
LTSEA			= (/12,15,30/)

vector			= (/0,1,2/)
LTSS			= LTSSA(vector)
LTSE			= LTSEA(vector)

binning=False
if(binning)then
;------------------
; based on another three- or four-dimension variables to bin
;------------------
CLOUD_sp		= CLOUD(:,{600:990},:,:)
sgm_sp			= sgm(:,{600:990},:,:)
deltaq_sp		= deltaq(:,{600:990},:,:)
Q1_sp			= Q1(:,{600:990},:,:)
LTS_sp			= LTS(:,{600:990},:,:)

dsizes			= dimsizes(CLOUD_sp)
nt_sp			= dsizes(0)
nlev_sp			= dsizes(1)
nlat_sp			= dsizes(2)
nlon_sp			= dsizes(3)

CLOUD_1D		= ndtooned(CLOUD_sp)
sgm_1D			= ndtooned(sgm_sp)
deltaq_1D		= ndtooned(deltaq_sp)
Q1_1D			= ndtooned(Q1_sp)

LTS_1D			= ndtooned(LTS_sp)

nbin			= dimsizes(LTSS)

CLOUD_bin		= new((/nbin,dimsizes(CLOUD_1D)/),float)
sgm_bin			= new((/nbin,dimsizes(sgm_1D)/),float)
deltaq_bin		= new((/nbin,dimsizes(deltaq_1D)/),float)
Q1_bin			= new((/nbin,dimsizes(Q1_1D)/),float)


do ibin=0,nbin-1
do id=0,dimsizes(LTS_1D)-1
	print("-------------------------------------------")
	print("ibin=	"+ibin+"	id="+id)
	tmpind			= ind(LTS_1D(id).gt.LTSS(ibin).and.LTS_1D(id).lt.LTSE(ibin))
	if(.not.all(ismissing(tmpind)).and.LTS_1D(id).gt.LTSS(ibin).and.LTS_1D(id).lt.LTSE(ibin))then
	CLOUD_bin(ibin,id)	= CLOUD_1D(id)
	sgm_bin(ibin,id)	= sgm_1D(id)
	deltaq_bin(ibin,id)	= deltaq_1D(id)
	Q1_bin(ibin,id)		= Q1_1D(id)
	end if
	delete(tmpind)
end do ; do id=
end do ; do ibin=

printVarSummary(CLOUD_bin)

delete(CLOUD_1D)
delete(sgm_1D)
delete(deltaq_1D)
delete(Q1_1D)
delete(LTS_1D)

CLOUD_bin_nd			= onedtond(CLOUD_bin,(/3,nt_sp,nlev_sp,nlat_sp,nlon_sp/))

CLOUD_bin_nd!0			= "bin"
CLOUD_bin_nd&bin		= fspan(0,nbin-1,nbin)
CLOUD_bin_nd!1			= "time"
CLOUD_bin_nd&time		= CLOUD_sp&time
CLOUD_bin_nd!2			= "lev"
CLOUD_bin_nd&lev		= CLOUD_sp&lev
CLOUD_bin_nd!3			= "lat"
CLOUD_bin_nd&lat		= CLOUD_sp&lat
CLOUD_bin_nd!4			= "lon"
CLOUD_bin_nd&lon		= CLOUD_sp&lon

sgm_bin_nd			= onedtond(sgm_bin,(/3,nt_sp,nlev_sp,nlat_sp,nlon_sp/))
deltaq_bin_nd			= onedtond(deltaq_bin,(/3,nt_sp,nlev_sp,nlat_sp,nlon_sp/))
Q1_bin_nd			= onedtond(Q1_bin,(/3,nt_sp,nlev_sp,nlat_sp,nlon_sp/))
copy_VarCoords(CLOUD_bin_nd,sgm_bin_nd)
copy_VarCoords(CLOUD_bin_nd,deltaq_bin_nd)
copy_VarCoords(CLOUD_bin_nd,Q1_bin_nd)

printVarSummary(Q1_bin_nd)

delete(CLOUD_sp)
delete(sgm_sp)
delete(deltaq_sp)
delete(Q1_sp)
delete(LTS_sp)

system("/bin/rm -f ./LTS-binning-Q1.nc")
ncdf                    = addfile("./LTS-binning-Q1.nc","c")
ncdf->CLOUD_bin		= CLOUD_bin
ncdf->sgm_bin		= sgm_bin		
ncdf->deltaq_bin	= deltaq_bin		
ncdf->Q1_bin		= Q1_bin		

ncdf->CLOUD_bin_nd	= CLOUD_bin_nd
ncdf->sgm_bin_nd	= sgm_bin_nd
ncdf->deltaq_bin_nd	= deltaq_bin_nd
ncdf->Q1_bin_nd		= Q1_bin_nd

exit

end if ; binning

ncdf                    = addfile("./LTS-binning-Q1.nc","r")
CLOUD_bin		= ncdf->CLOUD_bin
sgm_bin			= ncdf->sgm_bin
deltaq_bin		= ncdf->deltaq_bin
Q1_bin			= ncdf->Q1_bin

CLOUD_bin_nd		= ncdf->CLOUD_bin_nd
sgm_bin_nd		= ncdf->sgm_bin_nd
deltaq_bin_nd		= ncdf->deltaq_bin_nd
Q1_bin_nd		= ncdf->Q1_bin_nd

; -----------Specify regions------------------------------------------
latS			= (/-90,0,-90/)
latE			= (/90,90,0/)

wks_type                        = "pdf"
wks_type@wkPaperWidthF          = 8.3 
wks_type@wkPaperHeightF         = 8.3 

wks				= gsn_open_wks(wks_type,"./figure/cloud-Q1-bin-by-LTS-lat")

;gsn_define_colormap(wks,"circula-blugreenred-256colors")
gsn_define_colormap(wks,"NCV_banded")

do ilat=0,dimsizes(latS)-1

CLOUD_bin_nd_sp		= CLOUD_bin_nd(:,:,:,{latS(ilat):latE(ilat)},:)
Q1_bin_nd_sp		= Q1_bin_nd(:,:,:,{latS(ilat):latE(ilat)},:)
printVarSummary(CLOUD_bin_nd_sp)

dsizes			= dimsizes(CLOUD_bin_nd_sp)
nbin_sp			= dsizes(0)
nt_sp			= dsizes(1)
nlev_sp			= dsizes(2)
nlat_sp			= dsizes(3)
nlon_sp			= dsizes(4)

bin_sp			= CLOUD_bin_nd_sp&bin
time_sp			= CLOUD_bin_nd_sp&time
lev_sp			= CLOUD_bin_nd_sp&lev
lat_sp			= CLOUD_bin_nd_sp&lat
lon_sp			= CLOUD_bin_nd_sp&lon

tmp			= CLOUD_bin_nd_sp(lon|:,bin|:,time|:,lev|:,lat|:)
CLOUD_bin_nd_lon	= reshape(tmp,(/nlon_sp,nbin_sp*nt_sp*nlev_sp*nlat_sp/))
delete(tmp)
tmp			= CLOUD_bin_nd_sp(lat|:,bin|:,time|:,lev|:,lon|:)
CLOUD_bin_nd_lat	= reshape(tmp,(/nlat_sp,nbin_sp*nt_sp*nlev_sp*nlon_sp/))
delete(tmp)
tmp			= CLOUD_bin_nd_sp(lev|:,bin|:,time|:,lat|:,lon|:)
CLOUD_bin_nd_lev	= reshape(tmp,(/nlev_sp,nbin_sp*nt_sp*nlat_sp*nlon_sp/))
delete(tmp)
tmp			= CLOUD_bin_nd_sp(bin|:,time|:,lev|:,lat|:,lon|:)
CLOUD_bin_nd_bin	= reshape(tmp,(/nbin_sp,nt_sp*nlev_sp*nlat_sp*nlon_sp/))
delete(tmp)

printVarSummary(CLOUD_bin)
printVarSummary(CLOUD_bin_nd_bin)
;print("CLOUD_bin="+CLOUD_bin(0,:)+"CLOUD_bin_nd_bin="+CLOUD_bin_nd_bin(0,:))

tmp			= Q1_bin_nd_sp(lon|:,bin|:,time|:,lev|:,lat|:)
Q1_bin_nd_lon		= reshape(tmp,(/nlon_sp,nbin_sp*nt_sp*nlev_sp*nlat_sp/))
delete(tmp)
tmp			= Q1_bin_nd_sp(lat|:,bin|:,time|:,lev|:,lon|:)
Q1_bin_nd_lat		= reshape(tmp,(/nlat_sp,nbin_sp*nt_sp*nlev_sp*nlon_sp/))
delete(tmp)
tmp			= Q1_bin_nd_sp(lev|:,bin|:,time|:,lat|:,lon|:)
Q1_bin_nd_lev		= reshape(tmp,(/nlev_sp,nbin_sp*nt_sp*nlat_sp*nlon_sp/))
delete(tmp)
tmp			= Q1_bin_nd_sp(bin|:,time|:,lev|:,lat|:,lon|:)
Q1_bin_nd_bin		= reshape(tmp,(/nbin_sp,nt_sp*nlev_sp*nlat_sp*nlon_sp/))
delete(tmp)

;===================================================
; Plotting starts here....
;===================================================

;===================================================================
; Plot about bins based on another 3D or 4D variables
;===================================================================

res			= True
res@gsnFrame		= False
res@gsnDraw		= False
res@xyMarkLineMode	= "Markers"
res@xyMarkerSizeF	= 0.0075
res@xyMarkers		= (/4,4,4/);(/16,16,16/)
res@xyMarkerColors	= (/"red","blue","black"/)
;res@xyMarkerOpacityF	= 0.25
res@trYMaxF		= 5.
res@trYMinF		= -50.
res@trXMaxF		= 1.0
res@trXMinF		= 0.

res@tiXAxisString	= "cloud fraction"

;------------
res1			= res
res1@tiYAxisString	= "Q1-linear"


; add lengends
legends                         = (/"LTS: "+LTSS(0)+"-"+LTSE(0)+"K",\
				    "LTS: "+LTSS(1)+"-"+LTSE(1)+"K",\
				    "LTS: "+LTSS(2)+"-"+LTSE(2)+"K"/)

lgres				= True
lgres@lgItemType                = res@xyMarkLineMode
lgres@lgMarkerIndexes 		= res@xyMarkers
lgres@lgMarkerColors            = res@xyMarkerColors

lgres@lgLabelFontHeightF        = 0.2
lgres@vpWidthF                  = 0.15
lgres@vpHeightF                 = 0.1
lgres@lgPerimOn                 = False

amres                           = True
amres@amJust			= "TopLeft"
amres@amParallelPosF            = -0.50
amres@amOrthogonalPosF          = -0.50

plot1				= gsn_csm_xy(wks,CLOUD_bin(:,::20),Q1_bin(:,::20),res1)

lbid				= gsn_create_legend(wks,dimsizes(legends),legends,lgres)
annoid				= gsn_add_annotation(plot1,lbid,amres)
if(ilat.eq.0)then
gsn_panel(wks,(/plot1/),(/1,1/),False)
end if

;===================================================================
; Plot about bins based on dimension variables
;===================================================================
ress			= True
ress@gsnFrame		= False
ress@gsnDraw		= False
ress@xyMarkLineMode	= "Markers"
ress@xyMarkerSizeF	= 0.0075
ress@xyMarkers		= 4
ress@trYMaxF		= 5.
ress@trYMinF		= -50.
ress@trXMaxF		= 1.0
ress@trXMinF		= 0.

ress@tiXAxisString	= "cloud fraction"

;------------
ress1			= ress
ress1@tiYAxisString	= "Q1-linear"


;----------Setting----------------------
ntmp			= nlat_sp
tmp			= lat_sp

xx1			= CLOUD_bin_nd_lat
yy1			= Q1_bin_nd_lat
;----------Setting----------------------

color1			= toint(fspan(129,2,ntmp/2+1))
color2			= toint(fspan(129,255,ntmp/2))
color			= array_append_record(color1(::-1),color2,0)

labels			= sprintf("%3.1f",tmp)

ress1@gsnLeftString	= latS(ilat)+" - "+latE(ilat)
ress1@xyMarkerColor	= color(0)
plot1			= gsn_csm_xy(wks,xx1(ntmp-2,::20),yy1(ntmp-2,::20),ress1)


do iloop=0,ntmp-1
ress1@gsnLeftString	= ""
ress1@xyMarkerColor	= color(iloop)
ovplot1			= gsn_csm_xy(wks,xx1(iloop,::20),yy1(iloop,::20),ress1)

overlay(plot1,ovplot1)
end do

labelbar		= attach_labelbar(wks,plot1,labels,color)

resP			= True
resP@gsnPanelLeft	= 0.1
resP@gsnPanelRight	= 0.9
;resP@gsnPanelRowSpec	= True

gsn_panel(wks,(/plot1/),(/1,1/),resP)


delete([/color,color1,color2/])
delete([/time_sp,lat_sp,lon_sp,lev_sp/])
delete([/nt_sp,nlat_sp,nlon_sp,nlev_sp/])
delete([/ntmp,tmp,xx1,yy1/])
delete(res)
delete([/CLOUD_bin_nd_lat,CLOUD_bin_nd_lon,CLOUD_bin_nd_lev,CLOUD_bin_nd_bin/])
delete([/Q1_bin_nd_lat,Q1_bin_nd_lon,Q1_bin_nd_lev,Q1_bin_nd_bin/])
delete(CLOUD_bin_nd_sp)
delete(Q1_bin_nd_sp)
delete(labels)

end do ; do ilat=

delete([/CLOUD_bin,Q1_bin/])
delete([/CLOUD_bin_nd,Q1_bin_nd/])


system("date")
end
