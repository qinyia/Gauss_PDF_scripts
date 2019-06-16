function lat_regrids (a[*]:numeric,lat1[*]:numeric,b[*]:numeric,lat2[*]:numeric,c[*]:numeric,lat3[*]:numeric)

begin

nlat1 = dimsizes(lat1)
nlat2 = dimsizes(lat2)
nlat3 = dimsizes(lat3)

; =======find the minlatimum lat number
minlat = nlat1
if(minlat.ge.nlat2)then
	minlat = nlat2
end if
if(minlat.ge.nlat3)then
	minlat = nlat3
end if

if(minlat.eq.nlat1)then
	lat_regrid = lat1
	copy_VarCoords(lat1,lat_regrid)
end if
if(minlat.eq.nlat2)then
	lat_regrid = lat2
	copy_VarCoords(lat2,lat_regrid)
end if
if(minlat.eq.nlat3)then
	lat_regrid = lat3
	copy_VarCoords(lat3,lat_regrid)
end if


;==============regrid data
plat = minlat


ydata = new((/3,plat/),"float")
ydata(0,:) = linint1 (lat1,a,False,lat_regrid,0)   
ydata(1,:) = linint1 (lat2,b,False,lat_regrid,0)
ydata(2,:) = linint1 (lat3,c,False,lat_regrid,0)

  ydata!0 = "line"
  ydata&line = (/0,1,2/)
  ydata!1 = "lat"
  ydata&lat = lat_regrid

return(ydata)

end



function lat_lon_regrids (a[*][*]:numeric,lat1[*]:numeric,lon1[*]:numeric,b[*][*]:numeric,lat2[*]:numeric,lon2[*]:numeric,c[*][*]:numeric,lat3[*]:numeric,lon3[*]:numeric)

begin

nlat1 = dimsizes(lat1)
nlat2 = dimsizes(lat2)
nlat3 = dimsizes(lat3)

nlon1 = dimsizes(lon1)
nlon2 = dimsizes(lon2)
nlon3 = dimsizes(lon3)


; =======find the minlatimum lat number
minlat = nlat1
pointer = 1

if(minlat.ge.nlat2)then
	minlat = nlat2
	minlon = nlon2
	pointer = 2
end if
if(minlat.ge.nlat3)then
	minlat = nlat3
	minlon = nlon3
	pointer = 3
end if

if(minlat.eq.nlat1)then
	lat_regrid = lat1
	lon_regrid = lon1
	copy_VarCoords(lat1,lat_regrid)
	copy_VarCoords(lon1,lon_regrid)
end if
if(minlat.eq.nlat2)then
	lat_regrid = lat2
	lon_regrid = lon2
	copy_VarCoords(lat2,lat_regrid)
	copy_VarCoords(lon2,lon_regrid)
end if
if(minlat.eq.nlat3)then
	lat_regrid = lat3
	lon_regrid = lon3
	copy_VarCoords(lat3,lat_regrid)
	copy_VarCoords(lon3,lon_regrid)
end if

print(pointer)


;==============regrid data
plat = minlat
plon = minlon


ydata = new((/3,plat,plon/),"float")
ydata(0,:,:) = linint2 (lon1,lat1,a,False,lon_regrid,lat_regrid,0)   

ydata(1,:,:) = linint2 (lon2,lat2,b,False,lon_regrid,lat_regrid,0)
ydata(2,:,:) = linint2 (lon3,lat3,c,False,lon_regrid,lat_regrid,0)

  ydata!0 = "line"
  ydata&line = (/0,1,2/)
  ydata!1 = "lat"
  ydata&lat = lat_regrid
  ydata!2 = "lon"
  ydata&lon = lon_regrid

return(ydata)

end

function time_lat_lon_regrids (a[*][*][*]:numeric,ntime[*]:numeric,lat1[*]:numeric,lon1[*]:numeric,b[*][*][*]:numeric,lat2[*]:numeric,lon2[*]:numeric,c[*][*][*]:numeric,lat3[*]:numeric,lon3[*]:numeric)

begin

nlat1 = dimsizes(lat1)
nlat2 = dimsizes(lat2)
nlat3 = dimsizes(lat3)

nlon1 = dimsizes(lon1)
nlon2 = dimsizes(lon2)
nlon3 = dimsizes(lon3)


; =======find the minlatimum lat number
minlat = nlat1
minlon = nlon1
pointer = 1

if(minlat.ge.nlat2)then
	minlat = nlat2
	minlon = nlon2
	pointer = 2
end if
if(minlat.ge.nlat3)then
	minlat = nlat3
	minlon = nlon3
	pointer = 3
end if

if(minlat.eq.nlat1)then
	lat_regrid = lat1
	lon_regrid = lon1
	copy_VarCoords(lat1,lat_regrid)
	copy_VarCoords(lon1,lon_regrid)
end if
if(minlat.eq.nlat2)then
	lat_regrid = lat2
	lon_regrid = lon2
	copy_VarCoords(lat2,lat_regrid)
	copy_VarCoords(lon2,lon_regrid)
end if
if(minlat.eq.nlat3)then
	lat_regrid = lat3
	lon_regrid = lon3
	copy_VarCoords(lat3,lat_regrid)
	copy_VarCoords(lon3,lon_regrid)
end if

print(pointer)


;==============regrid data
plat = minlat
plon = minlon


ydata = new((/3,ntime,plat,plon/),"float")

ydata(0,:,:,:) = linint2 (lon1,lat1,a,False,lon_regrid,lat_regrid,0)   
ydata(1,:,:,:) = linint2 (lon2,lat2,b,False,lon_regrid,lat_regrid,0)
ydata(2,:,:,:) = linint2 (lon3,lat3,c,False,lon_regrid,lat_regrid,0)

  ydata!0 = "line"
  ydata&line = (/0,1,2/)
  ydata!1 = "time"
  ydata&time = ispan(0,ntime-1,1)
  ydata!2 = "lat"
  ydata&lat = lat_regrid
  ydata!3 = "lon"
  ydata&lon = lon_regrid

return(ydata)

end

function time_lat_lon_regrid_to_specific (ntime[*]:numeric,a[*][*][*]:numeric,lat1[*]:numeric,lon1[*]:numeric,b[*][*][*]:numeric,lat2[*]:numeric,lon2[*]:numeric,c[*][*][*]:numeric,lat3[*]:numeric,lon3[*]:numeric,latf[*]:numeric,lonf[*]:numeric)

begin

;==============regrid data
plat = dimsizes(latf)
plon = dimsizes(lonf)

lat_regrid = latf
lon_regrid = lonf


ydata = new((/3,ntime,plat,plon/),"float")

ydata(0,:,:,:) = linint2 (lon1,lat1,a,True,lon_regrid,lat_regrid,0)   
ydata(1,:,:,:) = linint2 (lon2,lat2,b,True,lon_regrid,lat_regrid,0)
ydata(2,:,:,:) = linint2 (lon3,lat3,c,True,lon_regrid,lat_regrid,0)

  ydata!0 = "line"
  ydata&line = (/0,1,2/)
  ydata!1 = "time"
  ydata&time = ispan(0,ntime-1,1)
  ydata!2 = "lat"
  ydata&lat = lat_regrid
  ydata!3 = "lon"
  ydata&lon = lon_regrid

return(ydata)

end



function lev_lat_lon_regrid (a[*][*][*]:numeric,lev[*]:numeric,lat1[*]:numeric,lon1[*]:numeric,b[*][*][*]:numeric,lat2[*]:numeric,lon2[*]:numeric,c[*][*][*]:numeric,lat3[*]:numeric,lon3[*]:numeric)

begin

nlat1 = dimsizes(lat1)
nlat2 = dimsizes(lat2)
nlat3 = dimsizes(lat3)

nlon1 = dimsizes(lon1)
nlon2 = dimsizes(lon2)
nlon3 = dimsizes(lon3)

nlev = dimsizes(lev)


; =======find the minlatimum lat number
minlat = nlat1
minlon = nlon1
pointer = 1

if(minlat.ge.nlat2)then
	minlat = nlat2
	minlon = nlon2
	pointer = 2
end if
if(minlat.ge.nlat3)then
	minlat = nlat3
	minlon = nlon3
	pointer = 3
end if

if(minlat.eq.nlat1)then
	lat_regrid = lat1
	lon_regrid = lon1
	copy_VarCoords(lat1,lat_regrid)
	copy_VarCoords(lon1,lon_regrid)
end if
if(minlat.eq.nlat2)then
	lat_regrid = lat2
	lon_regrid = lon2
	copy_VarCoords(lat2,lat_regrid)
	copy_VarCoords(lon2,lon_regrid)
end if
if(minlat.eq.nlat3)then
	lat_regrid = lat3
	lon_regrid = lon3
	copy_VarCoords(lat3,lat_regrid)
	copy_VarCoords(lon3,lon_regrid)
end if

print(pointer)


;==============regrid data
plat = minlat
plon = minlon


ydata = new((/3,nlev,plat,plon/),"float")

ydata(0,:,:,:) = linint2 (lon1,lat1,a,False,lon_regrid,lat_regrid,0)   
ydata(1,:,:,:) = linint2 (lon2,lat2,b,False,lon_regrid,lat_regrid,0)
ydata(2,:,:,:) = linint2 (lon3,lat3,c,False,lon_regrid,lat_regrid,0)

  ydata!0 = "line"
  ydata&line = (/0,1,2/)
  ydata!1 = "lev"
  ydata&lev = lev
  ydata!2 = "lat"
  ydata&lat = lat_regrid
  ydata!3 = "lon"
  ydata&lon = lon_regrid

return(ydata)

end


function lev_lat_lon_regrid_2var (a[*][*][*]:numeric,lev[*]:numeric,lat1[*]:numeric,lon1[*]:numeric,b[*][*][*]:numeric,lat2[*]:numeric,lon2[*]:numeric,lon_regrid[*]:numeric,lat_regrid[*]:numeric)

begin


plev = dimsizes(lev)
plat = dimsizes(lat_regrid)
plon = dimsizes(lon_regrid)

ydata = new((/2,plev,plat,plon/),"float")

ydata(0,:,:,:) = linint2 (lon1,lat1,a,True,lon_regrid,lat_regrid,0)   
ydata(1,:,:,:) = linint2 (lon2,lat2,b,True,lon_regrid,lat_regrid,0)

  ydata!0 = "line"
  ydata&line = (/0,1/)
  ydata!1 = "lev"
  ydata&lev = lev
  ydata!2 = "lat"
  ydata&lat = lat_regrid
  ydata!3 = "lon"
  ydata&lon = lon_regrid

return(ydata)

end
