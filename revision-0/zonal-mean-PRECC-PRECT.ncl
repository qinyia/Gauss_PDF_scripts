load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

function get_data(fname:string)
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


prect = new((/dimsizes(fname),dimsizes(lat)/),float)
data_part = new((/dimsizes(fname)*2,dimsizes(lat)/),float)
data_prec = new((/dimsizes(fname)*2,dimsizes(lat)/),float)


do ifile = 0,dimsizes(fname)-1

f_tmp = addfile(fdir+fname(ifile)+fdir_append+fname(ifile)+append,"r")

precl_tmp = f_tmp->PRECL(:,:,:)
precc_tmp = f_tmp->PRECC(:,:,:)
prect_tmp = precl_tmp+precc_tmp
printVarSummary(prect_tmp)

precc_tmp = precc_tmp*8.64e7
precl_tmp = precl_tmp*8.64e7
prect_tmp = prect_tmp*8.64e7
copy_VarCoords(precl_tmp,prect_tmp)


;===============partitioning
precl_part = precl_tmp/prect_tmp
precc_part = precc_tmp/prect_tmp
copy_VarCoords(precl_tmp,precl_part)
copy_VarCoords(precc_tmp,precc_part)

;=============zonal mean
prect_zm = dim_avg_Wrap(prect_tmp)
precl_zm = dim_avg_Wrap(precl_tmp)
precc_zm = dim_avg_Wrap(precc_tmp)


precl_part_zm = dim_avg_Wrap(precl_part)
precc_part_zm = dim_avg_Wrap(precc_part)



prect(ifile,:) = prect_zm

data_part(ifile*2,:)   = precl_part_zm
data_part(ifile*2+1,:) = precc_part_zm

data_prec(ifile*2,:)   = precl_zm
data_prec(ifile*2+1,:) = precc_zm

printVarSummary(data_part)

end do

return( [/prect,data_prec,data_part/] )

end

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

begin

fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

fname1 = "FC5_f09f09_MG15_COSP"
fname2 = "new-cldfrac16-1d-MG15-revise-2-COSP"

append = ".cam.h0.ANN.nc"

fname = (/fname1,fname2/)

result = get_data(fname)

prect = result[0]
data_prec = result[1]
data_part = result[2]

printVarSummary(data_prec)



;create plot
wks = gsn_open_wks("x11","./figure/zonal-mean-PRECC-PRECL-partition")
plot= new(8,graphic)

res = True
;res@gsnFrame = False
;res@gsnDraw = False

;colors1 = (/"black","RoyalBlue","LightSkyBlue",\
;           "PowderBlue","lightseagreen","PaleGreen","Wheat","Brown",\
;           "Pink"/)
;colors2 = (/"black","black","RoyalBlue","RoyalBlue","LightSkyBlue","LightSkyBlue",\
;           "PowderBlue","PowderBlue","lightseagreen","lightseagreen","PaleGreen","PaleGreen","Wheat","Wheat","Brown",\
;           "Pink"/)


colors1 = (/"blue","red","grey","yellow","Pink","Green"/)
;colors2 = (/"blue","blue","red","red","green","green"/)
colors2 = (/"blue","blue","red","red","grey","grey","yellow","yellow","Pink","Pink","Green","Green"/)


dash1 = (/1,1,1,1,1,1,1/)
dash2 = (/0,1,0,1,0,1,0,1,0,1,0,1/)

res@xyMarkLineMode = "Lines"               ; Markers *and* lines
res@xyLineColors = colors1
res@xyLineThicknessF = 3.0
res@xyDashPatterns = dash1

res2 = True
res2@xyLineColors = colors2
res2@xyLineThicknessF = 3.0
res2@xyDashPatterns = dash2

res@tiYAxisString      = "PRECT (mm/day)"
plot(0)  = gsn_csm_xy (wks,prect&lat,prect,res)

res2@tiYAxisString      = "PRECC/PRECL (mm/day)" 
plot(1)  = gsn_csm_xy (wks,data_prec&lat,data_prec,res2)

res2@tiYAxisString      = "Pr. Partition"
plot(2)  = gsn_csm_xy (wks,data_part&lat,data_part,res2)




;========================
;Attach a legend
lgres1 = True
lgres1@lgLineColors = colors1
lgres1@lgItemType = "Lines"
lgres1@lgLabelFontHeightF = .08
lgres1@vpWidthF = 0.30
lgres1@vpHeightF = 0.25
lgres1@lgPerimThicknessF = 2.0
lgres1@lgDashIndexes = dash1

labels1 = fname

;2017-01-18 09:41:07
gsn_legend_ndc(wks,dimsizes(fname),labels1,0.05,0.30,lgres1)


lgres2 = True
lgres2@lgLineColors = colors2
lgres2@lgItemType = "Lines"
lgres2@lgLabelFontHeightF = .08
lgres2@vpWidthF = 0.30
lgres2@vpHeightF = 0.25
lgres2@lgPerimThicknessF = 2.0
lgres2@lgDashIndexes = dash2

labels2 = (/fname(0)+"_LP",fname(0)+"_CP",\
            fname(1)+"_LP",fname(1)+"_CP"\
            /)

; 2017-01-18 09:44:26
gsn_legend_ndc(wks,dimsizes(fname)*2,labels2,0.40,0.20,lgres2)


gsn_panel(wks,plot,(/1,3/),False)

frame(wks)





end
