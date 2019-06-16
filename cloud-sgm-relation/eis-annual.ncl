
function get_eis(temp[*][*][*][*]:numeric,qv[*][*][*][*]:numeric,lev[*]:numeric)
;temp (time,lev,lat,lon)

begin

; 1. define constant parameters
RV 			= 461.5 ; J/kg/K
RD 			= 287.04 ; J/kg/K
EPS 			= RD/RV
CPD 			= 1005.7 ; J/kg/K
CPV 			= 1870.0 ; J/kg/K
P0 			= 1000.0 ; hPa
LV 			= 2501000 ; J/kg
gravit 			= 9.8 ; m/s2

; 1. calculate potential temperature ------------------------------------
P 			= conform(temp,lev,1)	; hPa
theta	 		= temp*(P0/P)^0.286 ; K
copy_VarCoords(temp,theta)
printVarSummary(theta)

; 2. calculate moist-adiabatic potential temp. gradient Gamma_m ---------------------
; 2.1 convert spc humidty to mixing ratio first
mr			= qv/(1.-qv)
copy_VarCoords(qv,mr)
printVarSummary(mr)

; 2.2 get saturation mixing ratio
; water vapor pressure
ev			 = mr*P/(EPS+mr) 
copy_VarCoords(mr,ev)
printVarSummary(ev)
; saturation water vapor pressure (hPa)
es			=6.112*exp(17.67*(temp-273.15)/(243.5+(temp-273.15)))
copy_VarCoords(temp,es)
printVarSummary(es)
; saturation mixing ratio
mrs			= EPS*es/(P-es)
copy_VarCoords(es,mrs)
printVarSummary(mrs)
; saturation spc humidity
qs			= mrs/(1.+mrs)
copy_VarCoords(mrs,qs)

; 2.3 get moist-adiabatic potential temperature gradient 
Gamma		= gravit/CPD*(1.0-(1.0+LV*qs/RD/temp)/(1.0+LV^2*qs/CPD/RV/temp^2))
copy_VarCoords(qs,Gamma)

; 3. calculate lifting condensation level: Bolton (1980) Eq.(21) ----------------------------
TC		= 2840.0/(3.5*log(temp(:,29,:,:))-log(ev(:,29,:,:))-4.805)+55.0
copy_VarCoords(temp(:,0,:,:),TC)
plcl		= P(:,29,:,:)*((TC/temp(:,29,:,:))^3.48)
copy_VarCoords(temp(:,0,:,:),plcl)


; 4. get z700 and zlcl ---------------------------------------------------------------------
z700		= (RD*temp(:,29,:,:)/gravit)*log(P0/700.)
zlcl 		= (RD*temp(:,29,:,:)/gravit)*log(P0/plcl)

copy_VarCoords(temp(:,29,:,:),z700)
copy_VarCoords(temp(:,29,:,:),zlcl)

printMinMax(z700,True)

; 5. calculate estimated inversion strength (EIS) ------------------------------------------
LTS			= theta(:,{700},:,:)-theta(:,29,:,:)
Gamma_850		= Gamma(:,{850},:,:)
dz			= z700-zlcl
EIS			= where(dz.lt.0,LTS,LTS-Gamma(:,{850},:,:)*dz)
copy_VarCoords(temp(:,0,:,:),LTS)
copy_VarCoords(temp(:,0,:,:),EIS)

return([/LTS,EIS/])

delete([/temp,qv,theta,mr,ev,es,mrs,qs,Gamma,TC,plcl,z700,zlcl,dz,Gamma_850/])

end ; function get_eis

