
function getdata(fdir_obs:string,fname_obs:string,fdir_mod:string,fdir_mod_app:string,fname_mod_app:string,fcase:string,var:string,sta_id:numeric)
begin

Cp = 1.00464e3   ; J/(K*kg)
gravit  = 9.80616     ; m/s^2
Lv  = 2.501e6     ; J/kg


f1 = addfile(fdir_obs+fname_obs,"r")

slat = f1->slat(sta_id)
slon = f1->slon(sta_id)
station = f1->STATIONS(sta_id,:)

print(slat+"  "+slon)

if (isfilevar(f1,var)) then
	tmp_1 = f1->$var$(sta_id,:)

else
	print("double check your variable!")
end if

if(var.eq."S".or.var.eq."T")then
	p_obs = f1->plev_atmo
end if

if(var.eq."H".or.var.eq."Q")then
	p_obs = f1->plev_trop
end if

; get p_mod
f_2_tmp = addfile(fdir_mod+fcase(0)+fdir_mod_app+fcase(0)+fname_mod_app,"r")
p_mod = f_2_tmp->lev


; interpolate tmp_1 to tmp_2 pressure level; interpolation here is not necessary. ---- this follows AMWG
;tmp_1_inter = int2p_n_Wrap(p_obs,tmp_1,p_obs,1,0) ;(p_in,t_in,p_out,linlog,lev_dim)
;data_out = new((/dimsizes(fcase)+1,dimsizes(p_obs)/),float)
;data_out_obs = new((/1,dimsizes(p_obs)/),float)
;data_out_mod = new((/dimsizes(fcase),dimsizes(p_obs)/),float)
;data_out_obs(0,:) = tmp_1_inter


; define output by the maximum level numbers
dimXY = (/dimsizes(p_obs),dimsizes(p_mod)/)
nMax = max(dimXY)

Xdata_out = new((/dimsizes(fcase)+1,nMax/),float)
Ydata_out = new((/dimsizes(fcase)+1,nMax/),float)

Xdata_out_obs = new((/1,dimsizes(p_obs)/),float)
Xdata_out_mod = new((/dimsizes(fcase),dimsizes(p_mod)/),float)

Ydata_out_obs = new((/1,dimsizes(p_obs)/),float)
Ydata_out_mod = new((/dimsizes(fcase),dimsizes(p_mod)/),float)


Xdata_out_obs(0,:) = tmp_1
Ydata_out_obs(0,:) = p_obs

do ifile=0,dimsizes(fcase)-1

f2 = addfile(fdir_mod+fcase(ifile)+fdir_mod_app+fcase(ifile)+fname_mod_app,"r")

	if(var.eq."T")then
		tmp_2 = f2->T(0,:,{slat},{slon})
	end if
	if(var.eq."Q")then
		tmp_2 = f2->Q(0,:,{slat},{slon})
	end if
	if(var.eq."H")then
		tmp_2_1 = f2->T(0,:,{slat},{slon})
		tmp_2_2 = f2->Z3(0,:,{slat},{slon})
		tmp_2_3 = f2->Q(0,:,{slat},{slon})
		tmp_2 = (Cp*tmp_2_1 + gravit*tmp_2_2 + Lv*tmp_2_3)/1000.
		delete ([/tmp_2_1,tmp_2_2,tmp_2_3/])
	end if
	if(var.eq."S")then
		tmp_2_1 = f2->T(0,:,{slat},{slon})
		tmp_2_2 = f2->Z3(0,:,{slat},{slon})
		tmp_2 = (Cp*tmp_2_1 + gravit*tmp_2_2)/1000.
		delete ([/tmp_2_1,tmp_2_2/])
	end if

;	; interpolate tmp_2 to tmp_1 pressure level
;	tmp_2_inter = int2p_n_Wrap(p_mod,tmp_2,p_obs,1,0) ;(p_in,t_in,p_out,linlog,lev_dim)
;	printVarSummary(tmp_2_inter)
;	data_out_mod(ifile,:) = tmp_2_inter


Xdata_out_mod(ifile,:) = tmp_2
; the level is double, and needs to be converted to float.
Ydata_out_mod(ifile,:) = dble2flt(p_mod)

delete( [/ tmp_2/] )

end do ; do ifile=

; the first dimension is for obs.
; here, use (/.../) can not assign the coordinate from right variable to the left.
Xdata_out(0,0:dimsizes(p_obs)-1) = (/Xdata_out_obs/)
Xdata_out(1:,0:dimsizes(p_mod)-1) = (/Xdata_out_mod/)

Ydata_out(0,0:dimsizes(p_obs)-1) = (/Ydata_out_obs/)
Ydata_out(1:,0:dimsizes(p_mod)-1) = (/Ydata_out_mod/)


return( [/Xdata_out, Ydata_out, station, slat, slon/] )

end

;fdir_obs = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/obs_data/"
fdir_obs = "./"

fname_obs = "RAOBS_ann.nc"


fdir_mod = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_mod_app = "/atm/hist/"
fname_mod_app = ".cam.h0.ANN.nc"

fname1 = "FC5_f09f09_MG15_COSP"
fname2 = "new-cldfrac16-1d-MG15-revise-COSP"
fname3 = "new-cldfrac16-1d-MG15-revise-2-COSP"

fcase = (/fname1,fname2,fname3/)

var = (/"H","S","T","Q"/)
sta_id = 18

plot = new(8,graphic)

  wks = gsn_open_wks("x11","Hawaii") ; send graphics to PNG file


do ivar=0,dimsizes(var)-1

result = getdata(fdir_obs,fname_obs,fdir_mod,fdir_mod_app,fname_mod_app,fcase,var(ivar),sta_id)

Xdata = result[0]
Ydata = result[1]
station = result[2]
slat = result[3]
slon = result[4]


fcase_label = new((/dimsizes(fcase)+1/),string)
fcase_label(0) = "radobs"

do ifile = 0,dimsizes(fcase)-1
if(fcase(ifile).eq."new-cldfrac16-1d-MG15-revise-COSP")then
	fcase_label(ifile+1) = "PDF-1"
end if
if(fcase(ifile).eq."new-cldfrac16-1d-MG15-revise-2-COSP")then
	fcase_label(ifile+1) = "PDF-2"
end if
if(fcase(ifile).eq."FC5_f09f09_MG15_COSP")then
	fcase_label(ifile+1) = "Default"
end if
end do

;===================================



  res                             = True
  res@gsnFrame                    = False   ; So we can draw markers
  res@gsnDraw = False
  res@gsnMaximize                 = True    ; affects ps, eps, pdf only
  res@gsnPaperOrientation         = "portrait"  ; force portrait 
  
  if(slat.gt.0)then
     if(slon.lt.180.)then
         res@tiMainString = station+"("+slat+"N, "+slon+"E)"
     else
         res@tiMainString = station+"("+slat+"N, "+(360.-slon)+"W)"
     end if
  else
     if(slon.lt.180.)then
         res@tiMainString = station+"("+abs(slat)+"S, "+slon+"E)"
     else
         res@tiMainString = station+"("+abs(slat)+"S, "+(360.-slon)+"W)"
     end if
  end if

  res@trYReverse = True

  res@trYMinF = 600.
;  ; here, please pay attention to the different level of obs. and models.
  res@trXMinF = 0.99*min(Xdata(1:,18:))
  res@trXMaxF = 1.01*max(Xdata(1:,18:))

  res@tiYAxisString = "Pressure (mb)"
  res@tiXAxisString = var(ivar)

  res@pmLegendDisplayMode    = "Always"
  res@pmLegendWidthF = 0.15
  res@pmLegendHeightF = 0.11
  res@pmLegendSide           = "Right"
  res@pmLegendParallelPosF   =   .70
  res@pmLegendOrthogonalPosF =  -.30
  res@xyExplicitLegendLabels = fcase_label


  res@xyLineColors    = (/"black","red","blue","green"/)
  res@xyLineThicknesses = (/2,2,2,2/)
  res@xyMarkLineModes   = (/"Markers","Lines","Lines","Lines"/)
  res@xyDashPatterns    = (/0,1,0,0/) 
  res@xyMarkers         = (/16,0,0,0/)

  plot(ivar) = gsn_xy(wks,Xdata,Ydata,res)

;  draw(plot(ivar))
 ; frame(wks)   ; Now advance the frame.

  delete([/res,result,Xdata,Ydata/])

  end do ; do ivar=

  gsn_panel(wks,plot,(/2,2/),False)

