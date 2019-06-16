load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/FC5_f09f09_MG15/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-revise/atm/hist/"

fn1 = "FC5_f09f09_MG15.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d-MG15-revise.cam.h0.ANN.nc"

f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")

lon1 = f1->lon
lat1 = f1->lat
lev = f1->lev


ZMDT_old = f1->ZMDT(0,:,:,:)
ZMDT_new = f2->ZMDT(0,:,:,:)

CMFDT_old = f1->CMFDT(0,:,:,:)
CMFDT_new = f2->CMFDT(0,:,:,:)

MACPDT_old = f1->MACPDT(0,:,:,:)
MACPDT_new = f2->MACPDT(0,:,:,:)

MPDT_old = f1->MPDT(0,:,:,:)
MPDT_new = f2->MPDT(0,:,:,:)

tten_PBL_old = f1->tten_PBL(0,:,:,:)
tten_PBL_new = f2->tten_PBL(0,:,:,:)

DTCOND_old = f1->DTCOND(0,:,:,:)
DTCOND_new = f2->DTCOND(0,:,:,:)



MACPDT_old = MACPDT_old/1004*8.64e4
MACPDT_new = MACPDT_new/1004*8.64e4

MPDT_old = MPDT_old/1004*8.64e4
MPDT_new = MPDT_new/1004*8.64e4

CMFDT_old = CMFDT_old*8.64e4
CMFDT_new = CMFDT_new*8.64e4

ZMDT_old = ZMDT_old*8.64e4
ZMDT_new = ZMDT_new*8.64e4

tten_PBL_old = tten_PBL_old*8.64e4
tten_PBL_new = tten_PBL_new*8.64e4

DTCOND_old = DTCOND_old*8.64e4
DTCOND_new = DTCOND_new*8.64e4


MACPDT_diff = MACPDT_new - MACPDT_old
copy_VarCoords(MACPDT_old,MACPDT_diff)
printMinMax(MACPDT_diff,False)

MPDT_diff = MPDT_new - MPDT_old
copy_VarCoords(MPDT_old,MPDT_diff)
printMinMax(MPDT_diff,False)

CMFDT_diff = CMFDT_new - CMFDT_old
copy_VarCoords(CMFDT_old,CMFDT_diff)
printMinMax(CMFDT_diff,False)

ZMDT_diff = ZMDT_new - ZMDT_old
copy_VarCoords(ZMDT_old,ZMDT_diff)
printMinMax(ZMDT_diff,False)

tten_PBL_diff = tten_PBL_new - tten_PBL_old
copy_VarCoords(tten_PBL_old,tten_PBL_diff)
printMinMax(tten_PBL_diff,False)

DTCOND_diff = DTCOND_new - DTCOND_old
copy_VarCoords(DTCOND_old,DTCOND_diff)
printMinMax(DTCOND_diff,False)



tend_old = new((/5,dimsizes(lev),dimsizes(lat1),dimsizes(lon1)/),float)
tend_old(0,:,:,:) = CMFDT_old
tend_old(1,:,:,:) = MACPDT_old
tend_old(2,:,:,:) = MPDT_old
tend_old(3,:,:,:) = tten_PBL_old
tend_old(4,:,:,:) = DTCOND_old

tend_new = new((/5,dimsizes(lev),dimsizes(lat1),dimsizes(lon1)/),float)
tend_new(0,:,:,:) = CMFDT_new
tend_new(1,:,:,:) = MACPDT_new
tend_new(2,:,:,:) = MPDT_new
tend_new(3,:,:,:) = tten_PBL_new
tend_new(4,:,:,:) = DTCOND_new

tend_tota = new((/10,dimsizes(lev),dimsizes(lat1),dimsizes(lon1)/),float)
tend_tota(0:4,:,:,:) = tend_old
tend_tota(5:9,:,:,:) = tend_new


diff_tend = new((/5,dimsizes(lev),dimsizes(lat1),dimsizes(lon1)/),float)
diff_tend(0,:,:,:) = CMFDT_diff
diff_tend(1,:,:,:) = MACPDT_diff
diff_tend(2,:,:,:) = MPDT_diff
diff_tend(3,:,:,:) = tten_PBL_diff
diff_tend(4,:,:,:) = DTCOND_diff

color1 = (/"blue","red","black","darkorange","purple"/)
color2 = (/"blue","red","black","darkorange","purple"/)
color = (/"blue","red","black","darkorange","purple","blue","red","black","darkorange","purple"/)

dash1 = (/0,0,0,0,0/)
dash2 = (/16,16,16,16,16/)
dash = (/0,0,0,0,0,16,16,16,16,16/)

;create plot
wks = gsn_open_wks("x11","./figure/lon-height-Ttend-20S")


res = True
res@trYReverse = True

res@gsnFrame = False
res@gsnDraw = False

res@trYMinF = 500.

res@xyLineColors = color
res@xyDashPatterns = dash 
res@xyLineThicknessF = 3.0
res@xyMarkLineModes = "Lines"


;res@gsnYAxisIrregular2Linear = True
res@tiYAxisString = "Pressure(hPa)"
res@tiXAxisString = "Temperature Tendency (K/day)"

plot = gsn_xy(wks,tend_tota(:,:,{-20},{285}),lev,res)

;==============================Attach a legend
lgres1 = True
lgres1@lgLineColors =color1
lgres1@lgLineThicknessF = res@xyLineThicknessF
lgres1@lgDashIndexes = dash1
lgres1@lgItemTypes = res@xyMarkLineModes
lgres1@lgLabelFontHeightF = .08 
lgres1@vpWidthF = 0.22
lgres1@vpHeightF = 0.28
lgres1@lgPerimThicknessF = 1.0
lgres1@lgPerimOn = False

lgres2 = True
lgres2@lgLineColors = color2
lgres2@lgLineThicknessF = res@xyLineThicknessF
lgres2@lgDashIndexes = dash2
lgres2@lgItemTypes = res@xyMarkLineModes
lgres2@lgLabelFontHeightF = .08 
lgres2@vpWidthF = 0.22
lgres2@vpHeightF = 0.28
lgres2@lgPerimThicknessF = 1.0
lgres2@lgPerimOn = False



label1 = (/"CMFDT-RH","MACPDT-RH","MPDT-RH","PBLT-RH","DTCOND-RH"/)
label2 = (/"CMFDT-PDF","MACPDT-PDF","MPDT-PDF","PBLT-PDF","DTCOND-PDF"/)

legend1 = gsn_create_legend(wks,5,label1,lgres1)
legend2 = gsn_create_legend(wks,5,label2,lgres2)

amres1 = True
amres1@amJust = "TopRight"
amres1@amParallelPosF = 0.5
amres1@amOrthogonalPosF = -0.5 
annoid1 = gsn_add_annotation(plot,legend1,amres1)

amres2 = True
amres2@amJust = "TopLeft"
amres2@amParallelPosF = -0.5
amres2@amOrthogonalPosF = -0.5 
annoid2 = gsn_add_annotation(plot,legend2,amres2)


draw(plot)
frame(wks)

plot = gsn_xy(wks,diff_tend(:,:,{-20},{285}),lev,res)

annoid3 = gsn_add_annotation(plot,legend1,amres1)
annoid4 = gsn_add_annotation(plot,legend2,amres2)


draw(plot)
frame(wks)




end
