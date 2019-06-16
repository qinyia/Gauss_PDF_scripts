function add_error_bar(wks,res2,xx[*][*]:numeric,xnewvar[*][*][*]:numeric,nVar:integer,nBin:integer,colors[*]:string)

begin

over_plot = new(nVar,graphic)

res2@tiXAxisString = "Omega500 (hPa/day)"

pmres = True
pmres@gsMarkerIndex = 1
pmres@gsMarkerSizeF = 0.02

plres = True
plres@gsLineThicknessF = 1.0

plres@tiXAxisString = "Omega500 (hPa/day)"

plot = gsn_csm_xy(wks,xx(0,:),xnewvar(0,0,:),res2)


centers = new((/nVar,nBin/),graphic)
error_bar = new((/nVar,nBin/),graphic)

do j = 0,nVar-1
	res2@xyLineColors = colors(j)
	pmres@gsMarkerColor = colors(j)
	plres@gsLineColor = colors(j)

	over_plot(j) = gsn_csm_xy(wks,xx(j,:),xnewvar(0,j,:),res2)
do i = 35,65

;	centers(j,i) = gsn_add_polymarker(wks,over_plot(j),xx(j,i),xnewvar(0,j,i),pmres)
	error_bar(j,i) = gsn_add_polyline(wks,over_plot(j),(/xx(j,i),xx(j,i)/),(/xnewvar(0,j,i)+xnewvar(1,j,i),xnewvar(0,j,i)-xnewvar(1,j,i)/),plres)

end do

overlay(plot,over_plot(j))

end do

str1 = unique_string("centers")
str2 = unique_string("error_bar")

plot@$str1$ = centers 
plot@$str2$ = error_bar 

;draw(plot)
;frame(wks)

return(plot)

end

;=====================================================

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
  lbres@vpWidthF           = 0.1 * vpw     ; labelbar width
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
end

;=========================================================
function add_LTS_RH(wks,res,LTS[*]:numeric,RELHUM[*]:numeric,CLDLOW[*]:numeric,total_num:integer,levels[*]:integer,nlevels:integer,colors[*]:numeric,markers[*]:numeric,labels[*]:string)

begin

plot = gsn_csm_xy(wks,LTS,RELHUM,res)

mkres = True
dum = new(total_num,graphic)

mkres@gsMarkerThicknessF = 0.25

do j = 0,total_num-1
	do i=0,nlevels-2
	if(levels(i).le.CLDLOW(j).and.\
		CLDLOW(j).lt.levels(i+1))then
	ii = i
	end if
	end do
	
	mkres@gsMarkerColor = colors(ii)
	mkres@gsMarkerIndex = markers(ii)
	dum(j) = gsn_add_polymarker(wks,plot,LTS(j),\
				     RELHUM(j),mkres)
end do

;===Attach a labelbar
;labelbar = attach_labelbar(wks,plot,labels,colors)

str1 = unique_string("dum")

plot@$str1$ = dum 

return(plot)

end


;=========================================================
function add_PBLH_RH(wks,res,LTS[*]:numeric,RELHUM[*]:numeric,CLDLOW[*]:numeric,total_num:integer,levels[*]:integer,nlevels:integer,colors[*]:numeric,markers[*]:numeric,labels[*]:string)

begin

plot = gsn_csm_xy(wks,LTS,RELHUM,res)

mkres = True
dum = new(total_num,graphic)

mkres@gsMarkerThicknessF = 0.05
mkres@gsMarkerOpacityF=0.7

do j = 0,total_num-1
	do i=0,nlevels-2
	if(levels(i).le.CLDLOW(j).and.\
		CLDLOW(j).lt.levels(i+1))then
	ii = i
	end if
	end do
	
	mkres@gsMarkerColor = colors(ii)
	mkres@gsMarkerIndex = markers(ii)
	dum(j) = gsn_add_polymarker(wks,plot,LTS(j),\
				     RELHUM(j),mkres)
end do

;===Attach a labelbar
;labelbar = attach_labelbar(wks,plot,labels,colors)

str1 = unique_string("dum")

plot@$str1$ = dum 

return(plot)

end
