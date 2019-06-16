load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

function get_data(fname:string,var:string)
begin

fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"
append = ".cam.h0.ANN.nc"

f1 = addfile(fdir+fname(0)+fdir_append+fname(0)+append,"r")
lon = f1->lon
lat = f1->lat
ilev = f1->ilev
lev = f1->lev
gw = f1->gw

lev@units = "mb"

data_zm_out = new((/dimsizes(fname),dimsizes(lev),dimsizes(lat)/),float)
diff_zm_out = new((/dimsizes(fname)-1,dimsizes(lev),dimsizes(lat)/),float)


do ifile = 0,dimsizes(fname)-1

	f_tmp = addfile(fdir+fname(ifile)+fdir_append+fname(ifile)+append,"r")
	
	if (isfilevar(f_tmp, var)) then
		data_tmp = f_tmp->$var$(0,:,:,:)
	else

	if(var.eq."AREL_frq") then
		msv = -999.
		data_tmp_1 = f_tmp->AREL(0,:,:,:)
		frq = f_tmp->FREQL(0,:,:,:)
		frq = where(frq.ne.0,frq,msv)
		data_tmp = data_tmp_1/frq
		copy_VarCoords(data_tmp_1,data_tmp)
	end if

	if(var.eq."AWNC_frq") then
		msv = -999.
		data_tmp_1 = f_tmp->AWNC(0,:,:,:)
		frq = f_tmp->FREQL(0,:,:,:)
		frq = where(frq.ne.0,frq,msv)
		data_tmp = data_tmp_1/frq
		copy_VarCoords(data_tmp_1,data_tmp)
	end if

	end if

	
	;=============zonal mean
	data_zm = dim_avg_n_Wrap (data_tmp,2)
	printVarSummary(data_zm)
	data_zm_out(ifile,:,:) = data_zm

	data_zm_out!1 = "lev"
	data_zm_out&lev = lev

 	diff_zm_out = data_zm_out(0,:,:)
	if(ifile.gt.0)then
	diff_zm_out(ifile-1,:,:) = data_zm_out(ifile,:,:) - data_zm_out(0,:,:)
	end if


end do

	if(var.eq."AWNC".or.var.eq."AWNC_frq")then
		data_zm_out = data_zm_out*1e-6
		diff_zm_out = diff_zm_out*1e-6
		data_zm_out@units = "cm^-3"
		diff_zm_out@units = "cm^-3"
	end if
	if(var.eq."CLDLIQ")then
		data_zm_out = data_zm_out*1000.
		diff_zm_out = diff_zm_out*1000.
		data_zm_out@units = "g/kg"
		diff_zm_out@units = "g/kg"
	end if


return( [/data_zm_out, diff_zm_out/] )

end

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

begin

fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

fname1 = "FC5_f09f09_MG15_COSP"
fname2 = "new-cldfrac16-1d-MG15-revise-COSP"

append = ".cam.h0.ANN.nc"

fname = (/fname1,fname2/)

;var = (/"AREL","FREQL","AWNC","AREL_frq","AWNC_frq"/)
var = (/"CLDLIQ"/)

do ivar = 0,dimsizes(var)-1

result = get_data(fname,var(ivar))

zm = result[0]
diff = result[1]

zm_1 = zm(0,:,:)
zm_2 = zm(1,:,:)

printMinMax(diff,False)



;create plot
wks = gsn_open_wks("png","./figure/micro/lat-height-"+var(ivar))
plot= new(3,graphic)

res = True

res@gsnFrame = False
res@gsnDraw = False
res@trYReverse = True

res@cnLinesOn = True
res@cnLineLabelsOn = False
res@cnFillOn = True
res@cnInfoLabelOn = False

res@trYMinF = 100.

res@tiYAxisString = "Pressure (hPa)"

;res@gsnYAxisIrregular2Linear = True


;res@cnLevelSelectionMode = "ExplicitLevels"
;res@cnLevels = con(:)
;res@cnLevels = dcon

res@gsnLeftString = var(ivar)

res@cnLevelSelectionMode = "ManualLevels"

if(var(ivar).eq."AREL_frq")then
	res@cnMinLevelValF = 0.
	res@cnMaxLevelValF = 15.
	res@cnLevelSpacingF  = 2.
end if
if(var(ivar).eq."AREL")then
	res@cnMinLevelValF = 0.
	res@cnMaxLevelValF = 2.5
	res@cnLevelSpacingF  = 0.5
end if
if(var(ivar).eq."FREQL")then
	res@cnMinLevelValF = 0.
	res@cnMaxLevelValF = 0.2
	res@cnLevelSpacingF  = 0.02
end if
if(var(ivar).eq."AWNC")then
	res@cnMinLevelValF = 0.
	res@cnMaxLevelValF = 15.
	res@cnLevelSpacingF  = 2.
end if
if(var(ivar).eq."AWNC_frq")then
	res@cnMinLevelValF = 0.
	res@cnMaxLevelValF = 200.
	res@cnLevelSpacingF  = 20.
end if
if(var(ivar).eq."CLDLIQ")then
	res@cnMinLevelValF = 0.
	res@cnMaxLevelValF = 0.05
	res@cnLevelSpacingF= 0.01
end if


;plot(0)  = gsn_csm_pres_hgt (wks,zm_1,res)
;plot(1)  = gsn_csm_pres_hgt (wks,zm_2,res)

plot(0)  = gsn_csm_contour (wks,zm_1,res)
plot(1)  = gsn_csm_contour (wks,zm_2,res)

if(var(ivar).eq."AREL_frq")then
	res@cnMinLevelValF = -3.
	res@cnMaxLevelValF = 3.
	res@cnLevelSpacingF  = 0.5
end if
if(var(ivar).eq."AREL")then
	res@cnMinLevelValF = -0.4
	res@cnMaxLevelValF = 0.4
	res@cnLevelSpacingF  = 0.1
end if
if(var(ivar).eq."FREQL")then
	res@cnMinLevelValF = -0.05
	res@cnMaxLevelValF = 0.05
	res@cnLevelSpacingF  = 0.01
end if
if(var(ivar).eq."AWNC")then
	res@cnMinLevelValF = -4.
	res@cnMaxLevelValF = 4.
	res@cnLevelSpacingF  = 1.
end if
if(var(ivar).eq."AWNC_frq")then
	res@cnMinLevelValF = -40.
	res@cnMaxLevelValF = 40.
	res@cnLevelSpacingF  = 10.
end if
if(var(ivar).eq."CLDLIQ")then
	res@cnMinLevelValF = -0.01
	res@cnMaxLevelValF = 0.01
	res@cnLevelSpacingF= 0.002
end if




;plot(2)  = gsn_csm_pres_hgt (wks,diff(0,:,:),res)
plot(2)  = gsn_csm_contour (wks,diff(0,:,:),res)

gsn_panel(wks,plot,(/1,3/),False)

frame(wks)

delete(zm)
delete(diff)
delete(zm_1)
delete(zm_2)
delete(res)

end do ; do ivar=


end
