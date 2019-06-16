

nplvlM = 25
plvlM = (/ 30., 50., 70.,100.,150.,200.,250.,300.,350.,400.,450.,500., 550., \
           600.,650.,700.,750.,800.,850.,875.,900.,925.,950.,975.,1000. /)
plvlM@units = "mb"

plvlO = (/30.,50.,70.,100.,150.,200.,250.,300.,400.,500.,600.,700., \
          775.,850.,925.,1000./)
plvlO@units = "mb" 
nplvlO = 16

interp = 2
p0 = 1000.
extrap = False


function vertical_ZMMSF (inptr:file,outptr:file)
begin

  if (isfilevar(outptr,"ZMMSF")) then
    zmmsf = outptr->ZMMSF
  else
;jt    lat = inptr->lat
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if
      delete(tmp)
    v = inptr->V(0,:,:,:)
;jt    ps = inptr->PS(0,:,:)
    tmp = inptr->PS(0,:,:)
    if (typeof(tmp).eq."double") then
      ps = dble2flt(tmp)
    else
      ps = tmp
    end if
    delete(tmp)
    presPa = plvlM*100.            ; convert to Pa
    presPa@units = "Pa"
    if (inptr@source .eq. "GFDL") then
      tmp = int2p_n_Wrap(plvlG,v(lat|:,lon|:,lev|::-1),plvlM,2,0)
      zmmsf = zonal_mpsi(tmp(lev|:,lat|:,lon|:),lat,presPa,ps)
      zmmsf!0 = "lev"
      zmmsf&lev = tmp&lev
      zmmsf!1 = "lat"
      zmmsf&lat = tmp&lat
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
      vp = vinth2p(v,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      tmp = vp(:,:,0)                      ; (lev,lat) 
      tmp = zonal_mpsi(vp,lat,presPa,ps)
      if (typeof(tmp).eq."double") then
        zmmsf = dble2flt(tmp)
      else
        zmmsf = tmp
      end if
      assignFillValue(zmmsf,zmmsf)
    end if
    zmmsf = (/zmmsf/1.e9/)      ; scaled for plots
    zmmsf@long_name = "Merid stream function"
    zmmsf@units = "kg/s x 10~S~9~N~"
;    outptr->ZMMSF = zmmsf
  end if
  return (zmmsf(::-1,:))
end

;#############################################################
function vertical_OMEGA (inptr:file,outptr:file,compare:string)
begin
  if (isfilevar(outptr,"OMEGA")) then
    omega = outptr->OMEGA
  else
    om = inptr->OMEGA(0,:,:,:)
    if (inptr@source .eq. "GFDL") then
      if (compare .eq. "OBS")
        tmp = int2p_n_Wrap(plvlG,om,plvlO(::-1),2,0)
      else
        tmp = int2p_n_Wrap(plvlG,om,plvlM(::-1),2,0)
      end if
      omega = dim_avg_n_Wrap(tmp, 1)
      omega = (/omega*864./)     ; 86400/100 to convert to mb/day
      omega@units = "mb/day"
      omega@long_name = "Vertical pressure velocity"
      outptr->OMEGA = omega(::-1,:)           ; Top to botom 
      return (omega)                          ; bottom to TOP  for plots
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if
      delete(tmp)
      if (compare .eq. "OBS") then
        tmp = vinth2p(om,hyam,hybm,plvlO,ps,interp,p0,1,extrap)
      else
        tmp = vinth2p(om,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      end if
      if (typeof(tmp).eq."double") then
        omega3 = dble2flt(tmp)
      else
        omega3 = tmp
      end if
      omega = dim_avg_Wrap(omega3)
      omega = (/omega*864./)     ; 86400/100 to convert to mb/day
      omega@derive_op = "OMEGA*864."
      omega@units = "mb/day"
      omega@long_name = "Vertical pressure velocity"
      assignFillValue(omega,omega)
      outptr->OMEGA = omega
    end if
  end if
  return (omega(::-1,:))
end

