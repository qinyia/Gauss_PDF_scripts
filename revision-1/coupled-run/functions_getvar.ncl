function get_STRESS_MAG (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"STRESS_MAG")) then
    stress_mag = outptr->STRESS_MAG
  else
    if (isfilevar(inptr,"TAUX") .and. isfilevar(inptr,"TAUY")) then
      tx = inptr->TAUX(0,:,:)
      ty = inptr->TAUY(0,:,:)
      taux = tx
      tauy = ty
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC(0,:,:)
        taux = (/-1.0*mask(tx,ocnfrac.ge.0.5,True)/)
        tauy = (/-1.0*mask(ty,ocnfrac.ge.0.5,True)/)
      else 
        if (isfilevar(inptr,"ORO")) then 
          oro = inptr->ORO(0,:,:)
          taux = (/-1.0*mask(tx,oro,0)/)         ; mask with ocean
          tauy = (/-1.0*mask(ty,oro,0)/)         ; mask with ocean
        else 
          print("STRESS_MAG: no ORO or OCNFRAC variables")
          stress_mag = -999.0
          return (stress_mag)
        end if
      end if

      tmp = taux 
      tmp = (/sqrt(taux^2+tauy^2)/)
      if (typeof(tmp).eq."double") then 
        stress_mag = dble2flt(tmp)
      else
        stress_mag = tmp
      end if
      stress_mag@units = "N/m~S~2~N~"
      stress_mag@long_name = "Surface stress magnitude"
      stress_mag@derive_op = "sqrt(taux^2+tauy^2)"
      assignFillValue(stress_mag,stress_mag)
      outptr->STRESS_MAG = stress_mag
    else
      stress_mag = -999.0
    end if
  end if
  return (stress_mag)
end


function get_TAUX_OCEAN (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TAUX")) then
    taux = outptr->TAUX
  else
    if (isfilevar(inptr,"TAUX")) then
      tx = inptr->TAUX(0,:,:)
      tmp = tx
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC(0,:,:)
        tmp = (/-1.0*mask(tx,ocnfrac.ge.0.5,True)/)
      else
        if (isfilevar(inptr,"ORO")) then
          oro = inptr->ORO(0,:,:)
          tmp = (/-1.0*mask(tx,oro,0)/)         ; mask with ocean
        else
          print("TAUX: no ORO or OCNFRAC variables")
          taux = -999.0
          return (taux)
        end if
      end if
      if (typeof(tmp).eq."double") then
        taux = dble2flt(tmp)
      else
        taux = tmp
      end if
      taux@units = "N/m~S~2~N~"
      taux@long_name = "Surface zonal stress"
      taux@derive_op = "-TAUX masked by ocean"
      assignFillValue(taux,taux)
      outptr->TAUX = taux
    else
      taux = -999.0
    end if
  end if
  return (taux)
end

function get_TAUY_OCEAN (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TAUY")) then
    tauy = outptr->TAUY
  else
    if (isfilevar(inptr,"TAUY")) then
      ty = inptr->TAUY(0,:,:)
      tmp = ty
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC(0,:,:)
        tmp = (/-1.0*mask(ty,ocnfrac.ge.0.5,True)/)
      else
        if (isfilevar(inptr,"ORO")) then
          oro = inptr->ORO(0,:,:)
          tmp = (/-1.0*mask(ty,oro,0)/)         ; mask with ocean
        else
          print("TAUY: no ORO or OCNFRAC variables")
          tauy = -999.0
          return (tauy)
        end if
      end if
      if (typeof(tmp).eq."double") then
        tauy = dble2flt(tmp)
      else
        tauy = tmp
      end if
      tauy@units = "N/m~S~2~N~"
      tauy@long_name = "Surface merid stress"
      tauy@derive_op = "-TAUY masked by ocean"
      assignFillValue(tauy,tauy)
      outptr->TAUY = tauy
    else
      tauy = -999.0
    end if
  end if
  return (tauy)
end

function get_PSL (inptr:file,outptr:file)
begin
 if (isfilevar(outptr,"PSL")) then 
    psl = outptr->PSL
  else 
    if (isfilevar(inptr,"PSL")) then 
      tmp = inptr->PSL(0,:,:)  ; Pa 
      tmp = (/tmp/100./)       ; convert to mb
      if (typeof(tmp).eq."double") then 
        psl = dble2flt(tmp)
      else 
        psl = tmp
      end if
      psl@long_name = "Sea-level pressure"
      psl@units = "millibars"
      psl@derive_op = "PSL divided by 100."
      assignFillValue(psl,psl)
      outptr->PSL = psl
    else 
      psl = -999.0
    end if
  end if
  return (psl)
end

function get_PRECT (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PRECT")) then 
    prect = outptr->PRECT
  else 
    precc = inptr->PRECC(0,:,:)   ; m/s
    precl = inptr->PRECL(0,:,:)   ; m/s
    tmp = precc     
    tmp = (/(precc+precl)*8.64e7/)  ; convert to mm/day
    if (typeof(tmp).eq."double") then 
      prect = dble2flt(tmp)
    else 
      prect = tmp
    end if
    prect@units = "mm/day"
    prect@long_name = "Precipitation rate" 
    prect@derive_op = "(PRECC+PRECL)*8.64e7"
    assignFillValue(prect,prect)
    outptr->PRECT = prect
  end if
  return (prect)
end

function get_PRECT_mon (inptr:list)
begin

    precc = inptr[:]->PRECC(:,:,:)   ; m/s
    precl = inptr[:]->PRECL(:,:,:)   ; m/s
    tmp = precc     
    tmp = (/(precc+precl)*8.64e7/)  ; convert to mm/day
    if (typeof(tmp).eq."double") then 
      prect = dble2flt(tmp)
    else 
      prect = tmp
    end if
    prect@units = "mm/day"
    prect@long_name = "Precipitation rate" 
    prect@derive_op = "(PRECC+PRECL)*8.64e7"
    assignFillValue(prect,prect)
  return (prect)
end


function get_TGCLDLWP (inptr:file)
begin
    tmp = inptr->TGCLDLWP(0,:,:)
    gw = inptr->gw
    LANDFRAC = inptr->LANDFRAC(0,:,:)
    ; change units from kg/m2 to g/m2
    tmp = tmp*1e3
    ; mask land fraction
    tmp_ocean = mask(tmp,LANDFRAC,0)
    copy_VarCoords(tmp,tmp_ocean)
    LWP = tmp_ocean
    printVarSummary(LWP)

  return (LWP)
end

function get_TGCLDLWP_mon (inptr:list)
begin
    tmp = inptr[:]->TGCLDLWP(:,:,:)
    LANDFRAC = inptr[:]->LANDFRAC(:,:,:)
    ; change units from kg/m2 to g/m2
    tmp = tmp*1e3
    ; mask land fraction
    tmp_ocean = mask(tmp,LANDFRAC,0)
    copy_VarCoords(tmp,tmp_ocean)
    LWP = tmp_ocean
    printVarSummary(LWP)

  return (LWP)
end



function get_CLDLOW_mon (inptr:list)
begin

    CLDLOW = inptr[:]->CLDLOW(:,:,:)
  return (CLDLOW)
end
