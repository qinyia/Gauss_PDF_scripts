external EX01 "./discretize.so"
external EX02 "./discretize2.so"

function discretize(omega[*]:numeric,newvar[*]:numeric,nbins:integer,total_num:integer)

begin

outside = False
mnmxint = nice_mnmxintvl(min(omega), max(omega), nbins, outside)
xMin    = mnmxint(0)
xMax    = mnmxint(1)
binBound    = fspan(xMin,xMax,nbins+1)

yy_data = new((/total_num,nbins/),float)
yy_data@_FillValue = 9.9692100E+36

;print(omega(200000:200100))


EX01::discretize(omega,newvar,nbins,total_num,binBound,yy_data)
;exit

;print(yy_data(200000:200100,49))
;print(yy_data(200000,:))
;exit


return(yy_data)

end

;==========================================
function discretize2(xLTS[*]:numeric,xRH[*]:numeric,xnewvar[*]:numeric,nbins1:integer,nbins2:integer,total_num:integer)

begin

outside = False
mnmxint1 = nice_mnmxintvl(min(xLTS),max(xLTS),nbins1,outside)
xMin1 = mnmxint1(0)
xMax1 = mnmxint1(1)
binBound1 = fspan(xMin1,xMax1,nbins1+1)

outside = False
mnmxint2 = nice_mnmxintvl(min(xRH),max(xRH),nbins2,outside)
xMin2 = mnmxint2(0)
xMax2 = mnmxint2(1)
binBound2 = fspan(xMin2,xMax2,nbins2+1)

yy_data = new((/total_num,nbins1,nbins2/),float)

printVarSummary(xLTS)

EX02::discretize2(xLTS,xRH,xnewvar,nbins1,nbins2,total_num,binBound1,binBound2,yy_data)

return yy_data

end
