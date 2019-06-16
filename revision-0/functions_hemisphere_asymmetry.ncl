function hemis_asymmetry (a[*][*]:numeric,line[*]:numeric,lat1[*]:numeric)

begin

nlat1 = dimsizes(lat1)
nline = dimsizes(line)

N1 = nlat1/2	; semi-hemisphere's latitude grid number

minlat = min(abs(lat1))

if(minlat.ne.0)then

	xasy = new((/nline,N1/),"float")
	newlat = new((/N1/),"float")
	
	; ===========North Hemisphere minus South Hemisphere
	;do i = 0, N1-1
	;	xasy(:,i) = a(:,N1+i) - a(:,N1-1-i)
	;	newlat(i) = lat1(N1+i)
	;end do
	
	; ===========South Hemisphere minus North Hemisphere
	do i = 0, N1-1
	;	xasy(:,i) = a(:,i) - a(:,nlat1-1-i)
		xasy(:,i) = a(:,N1-1-i) - a(:,N1+i)
		newlat(i) = lat1(N1+i)
	end do

else

	xasy = new((/nline,N1+1/),"float")
	newlat = new((/N1+1/),"float")
	
	; ===========North Hemisphere minus South Hemisphere
	;do i = 0, N1
	;	xasy(:,i) = a(:,N1+i) - a(:,N1-i)
	;	newlat(i) = lat1(N1+i)
	;end do
	
	; ===========South Hemisphere minus North Hemisphere
	do i = 0, N1
	;	xasy(:,i) = a(:,i) - a(:,nlat1-1-i)
		xasy(:,i) = a(:,N1-i) - a(:,N1+i)
		newlat(i) = lat1(N1+i)
	end do

end if


  xasy!0 = "line"
  xasy&line = (/0,1,2/)
  xasy!1 = "lat"
  xasy&lat = newlat

return(xasy)

end
