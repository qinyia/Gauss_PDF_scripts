;*****************************************************
; taylor_7.ncl     **Basic* Model-to-Model comparison
;*****************************************************
load "./taylor_diagram.ncl"
;;load "./taylor_metrics_table.ncl"
; ---------------------------------------------
; User specified parameters
; -------------------------
; Make use of NCL's scoping rules [same as Pascal].
; Define "global" variables. These can be "seen"
; by all cade that follows. NCL has no explicit
; way to define global variables. However, the NCL 
; convention is to make them all capital letters
;----------------------------------------------

  CNTL_DIR      = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/climo/F_2000_CAM5_f09f09/"
  TEST_DIR      = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/climo/new-cldfrac15-1d/"
  REF_DIR       = "/home/lyl/WORK3/qinyi/scripts/amwg_diag/obs_data"

; CNTL_DIR     = "/project/cas/shea/CCM/b30.081/"            ; Reference dataset    
; TEST_DIR     = (/ "/project/cas/shea/CCM/b30.081_di/" /)   ; Test dataset directories

  REF_CASE     = "OBS"
  CNTL_CASE    = "F_2000_CAM5_f09f09" 
  TEST_CASE    = (/ "new-cldfrac15-1d" /)                          ; one or more TEST cases 
                                

  SEASONS      = (/ "DJF", "JJA", "ANN" /) 
  VAR_COMPARE  = (/ "PSL", "CLDTOT" , "FLNTC" \
                   ,"PRC", "STRESS_SFC", "U300", "LHFLX_TropPac" /)
  CASES        = (/ CNTL_CASE, TEST_CASE /)        ; possibly rename if TEST_CASE is long          

                                        ; OPTIONAL
  TEST_MARKERS = (/ 16,16 /)               ; one for each TEST_CASE
  TEST_COLORS  = (/ "magenta","red" /)     
  PRINT_MINMAX = True
  PLOT_TYPE    = "png"

;===========================================================
;===========================================================

    pUnit    = flt2string( 1./(1000*86400) )  ; a034

     ;  Model   ,   Reference   ,unit ,latS,latN,lonL,lonR, ls(1=land, 0=ocn), lev
  VAR_TAYLOR  = (/  \       ; start VAR_TAYLOR   \
    \;                                                          (1=lnd,0=ocn)
    \;  Case    , Reference    ,Unit ,   latS , latN, lonL, lonR,  ls ,  lev, label
    \;------------------------------------------------------------------------------------
    (/"PSL"    , "ERAI"    ,    "100.",   "-90", "90",  "0","360",   "-1",  "0"   , "Sea Level Pressure (ERAI)" /),\
    (/"SWCF"   , "CERES-EBAF",  "1.0",   "-90", "90",  "0","360",   "-1",  "0"    , "SW Cloud Forcing (CERES-EBAF)" /),\
    (/"LWCF"   , "CERES-EBAF",  "1.0",   "-90", "90",  "0","360",   "-1",  "0"    , "LW Cloud Forcing (CERES-EBAF)" /),\
    (/"PRECT"  , "GPCP",        pUnit,   "-30", "30",  "0","360",    "1",  "0"    , "Land Rainfall (30N-30S, GPCP)" /),\
    (/"PRECT"  , "GPCP",        pUnit,   "-30", "30",  "0","360",    "0",  "0"    , "Ocean Rainfall (30N-30S, GPCP)" /),\
    (/"TREFHT" , "WILLMOTT",    "1.0",   "-90", "90",  "0","360",    "1",  "0"    , "Land 2-m Temperature (Willmott)" /),\
    (/"STRESS" , "ERS",        "-1.0",    "-5",  "5","135","270",    "0",  "0"    , "Pacific Surface Stress (5N-5S,ERS)" /),\
    (/"U"      , "ERAI",       "1.0",   "-90", "90",  "0","360",   "-1","300"    , "Zonal Wind (300mb, ERAI)" /),\
    (/"RELHUM" , "ERAI",       "1.0",   "-90", "90",  "0","360",   "-1",  "0"    , "Relative Humidity (ERAI)" /),\
    (/"T"      , "ERAI",       "1.0",   "-90", "90",  "0","360",   "-1",  "0"    , "Temperature (ERAI)" /),\
    \;------------------------------------------------------------------------------------
    (/"0","0","0","0","0","0","0","0","0","0"/) /)          ; end VAR_TAYLOR

    
    dimVar      = dimsizes( VAR_TAYLOR  )
    nVar        = dimVar(0)  - 1

    caseVarCompare  = VAR_TAYLOR(0:nVar-1,0)
    refDsetCompare   = VAR_TAYLOR(0:nVar-1,1)
    unitScaleFactor = stringtofloat  ( VAR_TAYLOR(0:nVar-1,2) )

    latS            = stringtofloat  ( VAR_TAYLOR(0:nVar-1,3) )
    latN            = stringtofloat  ( VAR_TAYLOR(0:nVar-1,4) )
    lonL            = stringtofloat  ( VAR_TAYLOR(0:nVar-1,5) ) ; Left
    lonR            = stringtofloat  ( VAR_TAYLOR(0:nVar-1,6) ) ; Right
    lsFlag          = stringtointeger( VAR_TAYLOR(0:nVar-1,7) )

;===============================================================
;===============================================================

    
; ---------------------------------------------
; End user specified parameters
; ---------------------------------------------
; Optional:
; Not implemented. Must follow some rules.
; User specified function to read/process data.
; Same argument sequence as predefined "getData"
; Allows users to create own getData module.
;----------------------------------------------
;undef("getDataUser")
;function getDataUser (f:file          \  ; file reference [pointer]
;                     ,varName:string  \  ; variable name
;                     ,monsea:string   \  ; month/season name
;                     ,w[*]:numeric    \  ; weights
;                     ,opt:logical)    \  ; opt arguments [not used]
;
;begin
;    vFlag = False                    ; flag if variable found
;    return()
;end

;#################################################################
;####################   LOAD LIBRARIES   #########################
;#################################################################
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; These files still have to be loaded manually  
load "./taylor_diagram_cam.ncl"
;;load "./taylor_metrics_table.ncl"

;#################################################################
;####################   LOCAL FUNCTIONS  #########################
;#################################################################

;================================================
; function to read scalar or vector components for 
; user specified variable [varName] and 
; month/season [monsea] from a file pointed to by "f"
;================================================

undef("getData")
function getData (f:file          \  ; file reference [pointer]
                 ,varName:string  \  ; variable name
                 ,monsea:string   \  ; month/season name
                 ,w[*]:numeric    \  ; weights
                 ,opt:logical)    \  ; optional argument [not used]

local vClm, vClmx, vClmy, vFlag, vClass, dNam, i, i3, month, sea3
begin
    vFlag = False                    ; flag if variable found
                                     ; READ FULL CLIMATOLOGY (12,:,:)
    if (isfilevar(f, varName)) then
        vClm       = f->$varName$    
        vFlag      = True
        vClass     = "scalar"
        vClm@class =  vClass
        vClm@wgt   = w
    else                             ; must not be on the file
    
        if (varName.eq."PRC") then
            vClm   = f->PRECL 
            vClm   = vClm + f->PRECC
            vClm@long_name = "Total prc: (PRECL + PRECC)"
            vFlag  = True
            vClass = "scalar"
            vClm@wgt   = w
            vClm@class = vClass
        end if
    
        if (varName.eq."U300") then
            vClm   = f->U(:,{300},:,:)
            vClm@long_name = "U300"
            vFlag  = True
            vClass = "scalar"
            vClm@wgt   = w
            vClm@class = vClass
        end if
    
        if (varName.eq."LHFLX_TropPac") then
            vClm   = f->LHFLX(:,{-10:10},{150:260})
            vClm@long_name = vClm@long_name+": 10S-10N , 150-260"
            vFlag  = True
            vClass = "scalar"
            vClm@wgt   = w({-10:10})
            vClm@class = vClass
        end if

        if (varName.eq."STRESS_SFC") then
            vClmx  = f->TAUX
            vClmy  = f->TAUY
            vFlag  = True
            vClass = "vector"
            vClmx@class = vClass
            vClmy@class = vClass
            vClmx@wgt   = w
            vClmy@wgt   = w
        end if

        if (.not.vFlag) then
           ;if (isdefined("getDataUser")) then   ; has user defined function
           ;    vClm = getDataUser( f, varName, monsea, gw, opt ) 
           ;    if (all(ismissing(vClm))) then
           ;    
           ;    end if
           ;end if

            print("------------------------------------------")
            print("-->TAYLOR: getData: "+varName+" not found <--")
            print("------------------------------------------")
            vClm = 1e20
            vClm@_FillValue = 1e20
            return(vClm)
        end if
   end if
                                       ; select appropriate month/season
                                       ; perform averaging ... if needed

   month = (/"JAN","FEB","MAR","APR","MAY","JUN" \
            ,"JUL","AUG","SEP","OCT","NOV","DEC" /)

   sea3  = (/"DJF","JFM","FMA","MAM","AMJ","MJJ" \
            ,"JJA","JAS","ASO","SON","OND","NDJ" /)

   i3    = (/(/12,1,2/),(/1,2,3/),(/2,3,4/),(/3,4,5/) \ 
            ,(/ 4,5,6/),(/5,6,7/),(/6,7,8/),(/7,8,9/) \ 
            ,(/ 8,9,10/),(/9,10,11/),(/10,11,12/),(/11,12,1/) /)
   i3    = i3-1    ; NCL is zero based

   if (vClass.eq."scalar") then        ; "METHODS" for scalar
       i = ind(month.eq.monsea)
       if (.not.ismissing(i)) then
           data = vClm(i,:,:)          ; extract specified month
           return( data )
       end if

       dNam  = getvardims ( vClm )     ; get dimension names

       if (monsea.eq."ANN") then
           data = dim_avg_n_Wrap( vClm, 0 )
           data@long_name = "ANN: "+vClm@long_name
           return( data )
       end if

       i  = ind(sea3.eq.monsea)
       if (.not.ismissing(i)) then
           data = dim_avg_n_Wrap( vClm(i3(i,:),:,:), 0 )
           data@long_name = monsea+": "+vClm@long_name
           return( data )
       end if
   end if

   if (vClass.eq."vector") then        ; "METHODS" for vector
       dimv = dimsizes( vClmx )
       data = new ( (/2,dimv(1),dimv(2)/), typeof(vClmx), getFillValue(vClmx) )

       i = ind(month.eq.monsea)
       if (.not.ismissing(i)) then
           data(0,:,:) = vClmx(i,:,:)  ; extract specified month
           data(1,:,:) = (/ vClmy(i,:,:) /) 
           data@long_name = monsea+": "+varName
           return( data )
       end if

       dNam  = getvardims ( vClmx )    ; get dimension names

       if (monsea.eq."ANN") then
           data(0,:,:) = dim_avg_n_Wrap( vClmx, 0 )
           data(1,:,:) = (/ dim_avg_n  ( vClmy, 0 ) /)
           data@long_name = monsea+": "+varName
           return( data )
       end if

       i  = ind(sea3.eq.monsea)
       if (.not.ismissing(i)) then
           data(0,:,:) = dim_avg_n_Wrap( vClmx(i3(i,:),:,:), 0 )
           data(1,:,:) = (/ dim_avg_n  ( vClmy(i3(i,:),:,:), 0) /)
           data@long_name = monsea+": "+varName
           return( data )
       end if
   end if

   print("------------------------------------------")
   print("-->TAYLOR: getData: "+varName+" <--")
   print("--> Not sure how we got here  <--")
   print("------------------------------------------")
   exit

end
;#################################################################
;#################### Main [driver] Script #######################
;#################################################################

begin
    nSeason     = dimsizes( SEASONS )
;    nVar        = dimsizes( VAR_COMPARE )
    nVar        = dimsizes( refDsetCompare )

    nCase       = dimsizes( CASES )

    ratio       = new ((/nCase, nVar/), "double" )  
    cc          = new ((/nCase, nVar/), "double" ) 
    table       = new ((/nCase,nSeason,nVar/), typeof(ratio) )

;----------------------------------------------
; Generate one Taylor diagram per season
;----------------------------------------------

    CNTL_FILE   = CNTL_CASE+"_MONTHS_climo.nc"

    fc = addfile(CNTL_DIR+CNTL_FILE, "r") ; open control file with monthly files   
    gw = fc->gw                           ; gw(nlat)
    

nVar = 1
    do ns=0,nSeason-1                     ; loop over seasons

     do nc=0,nCase-1                      ; loop over all the test cases       
        ft = addfile(TEST_DIR(nc)+TEST_CASE(nc)+"_MONTHS_climo.nc", "r") ;      case/test

      do nv=0,nVar-1
        refVarNames  = getfilevarnames( addfile(REF_DIR+"/"+refDsetCompare(nv)+"_01_climo.nc", "r") )
        flist_obs =  systemfunc("ls -1 "+REF_DIR+"/"+refDsetCompare(nv)+"_{01,02,03,04,05,06,07,08,09,10,11,12}_climo.nc")
        if (.not.isfilepresent("./"+refDsetCompare(nv)+"_MONTHS_climo.nc"))
            flist_obs_ncrcat = systemfunc("ncrcat -O "+REF_DIR+"/"+refDsetCompare(nv)+"_{01,02,03,04,05,06,07,08,09,10,11,12}_climo.nc "+refDsetCompare(nv)+"_MONTHS_climo.nc")
        end if

        fr = addfile("./"+refDsetCompare(nv)+"_MONTHS_climo.nc", "r")

                                          ; READ DATA
         rdata  = getData( fr, caseVarCompare(nv), SEASONS(ns),gw, False ) ; the obs data
         cdata  = getData( fc, caseVarCompare(nv), SEASONS(ns), gw, False ) ; the def data
         tdata  = getData( ft, caseVarCompare(nv), SEASONS(ns), gw, False ) ; the new data

	 ;===qinyi
         ;**********************************************************
         ; HORIZONTAL [SPATIAL] INTERPOLATION
         ;**********************************************************
	 REF_to_CASE = True
         
                  if (REF_to_CASE) then 
                      rdatax = linint2_Wrap(rdata&lon, rdata&lat, rdata, True \
                                           ,tdata&lon, tdata&lat, 0)
                      delete(rdata)
                      rdata   = rdatax     ; keep same name [convenience]
                      delete(rdatax)
                  else 
                      tdatax = linint2_Wrap(tdata&lon, tdata&lat, tdata, True \
                                           ,rdata&lon, rdata&lat, 0)
                      cdatax = linint2_Wrap(cdata&lon, cdata&lat, cdata, True \
                                           ,rdata&lon, rdata&lat, 0)
 
                      delete(tdata)
		      delete(cdata)
                      tdata  = tdatax     ; keep same name [convenience]
                      cdata  = cdatax     ; keep same name [convenience]
                      delete(tdatax)
                      delete(cdatax)
                  end if

		  printVarSummary(rdata)
		  printVarSummary(cdata)
		  printVarSummary(tdata)
         ;**********************************************************
         ; At this point, rdata and cdata are on the SAME GRID.
	 ;=======
 
         vClass = cdata@class
         if (vClass.eq."scalar") then
	     vreff  = rdata
             vcntl  = cdata
             vtest  = tdata
         else                              ; must be vector class
             vreffx = rdata(0,:,:)
             vreffy = rdata(1,:,:)
             vcntlx = cdata(0,:,:)
             vcntly = cdata(1,:,:)
             vtestx = tdata(0,:,:)
             vtesty = tdata(1,:,:)
         end if

         wt = cdata@wgt                    ; weights associated with cdata

         delete(rdata)                     ; no longer needed
         delete(cdata)
         delete(tdata)

         if (PRINT_MINMAX) then
             if (vClass.eq."scalar") then
                 printMinMax(vreff , True )
                 printMinMax(vcntl , False )
                 printMinMax(vtest , False)
             else
                 printMinMax(vreffx, True )
                 printMinMax(vreffy, False)
                 printMinMax(vcntlx, False)
                 printMinMax(vcntly, False)
                 printMinMax(vtestx, False)
                 printMinMax(vtesty, False)
             end if
         end if

         if (vClass.eq."scalar") then 
                                         ; SCALAR
             dims        = dimsizes(vcntl)
             ntim        = dims(0)             
             rank        = dimsizes(dims)    ; all 3D in test

             wgt         = conform(vreff, wt , rank-2) 
  
                                         ; temporary variables
             sumw        = sum(wgt)
             sumwr       = sum(wgt*vreff)
             sumwc       = sum(wgt*vcntl)
             sumwt       = sum(wgt*vtest)
                                         ; wgted areal mean
             wmean_reff  = sumwr/sumw
             wmean_cntl  = sumwc/sumw
             wmean_test  = sumwt/sumw
                                         ; wgted areal variance
             wvar_reff   = sum(wgt*(vreff-wmean_reff)^2)/sumw  
             wvar_cntl   = sum(wgt*(vcntl-wmean_cntl)^2)/sumw  
             wvar_test   = sum(wgt*(vtest-wmean_test)^2)/sumw  
    
                                         ; wgted correlation coef
              wcc         = (sum(wgt*vreff*vcntl) - sumwr*sumwc/sumw )/ \
                          ((sum(wgt*vreff^2) - sumwr^2/sumw) *         \
                           (sum(wgt*vcntl^2) - sumwc^2/sumw) )^0.5        

              wcc         = (sum(wgt*vreff*vtest) - sumwr*sumwt/sumw )/ \
                          ((sum(wgt*vreff^2) - sumwr^2/sumw) *         \
                           (sum(wgt*vtest^2) - sumwt^2/sumw) )^0.5        

             delete( vreff ) 
             delete( vcntl )             ; delete variables which may change
             delete( vtest )             ; rank on next variable iteration
         else                     
                                         ; VECTOR
             dims        = dimsizes(vcntlx)
             ntim        = dims(0)             
             rank        = dimsizes(dims)    ; all 3D in test

             wgt         = conform(vcntlx, wt ,rank-2) 
                                         ; temporary variables
             sumw        = sum(wgt)
             sumwcx      = sum(wgt*vcntlx)
             sumwcy      = sum(wgt*vcntly)
             sumwtx      = sum(wgt*vtestx)
             sumwty      = sum(wgt*vtesty)
                                         ; wgted areal means (vector components)
             wmean_cntlx = sumwcx/sumw
             wmean_cntly = sumwcy/sumw
             wmean_testx = sumwtx/sumw
             wmean_testy = sumwty/sumw
                                         ; wgted areal variance (vector)
             wvar_cntl   = sum(wgt*((vcntlx-wmean_cntl)^2 +\
                                    (vcntly-wmean_cntl)^2))/sumw  
             wvar_test   = sum(wgt*((vtestx-wmean_test)^2 +\
                                    (vtesty-wmean_test)^2))/sumw  
 
                                         ; wgted vector correlation coef [note cross prod)
             wcc         = sum(wgt*( (vcntlx-wmean_cntl)*(vtestx-wmean_test)    \
                                    +(vcntly-wmean_cntl)*(vtesty-wmean_test)))  \
                                    /(sqrt(wvar_cntl*wvar_test)*sumw)

             delete( vcntlx )            ; delete variables which may change
             delete( vcntly )            ; rank on next variable iteration
             delete( vtestx )
             delete( vtesty )
         end if
         delete( dims )
         delete( wgt  )                  ; shape may change
         delete( wt   )                  ; shape may change

         ratio(nc,nv)    = (wvar_test/wvar_cntl)^0.5
         cc(nc,nv)       = wcc
         table(nc,ns,nv) = ratio(0,nv)

      end do                             ; end VARIABLE loop
     end do                              ; end CASE loop



     plot_root_name   = "taylor_"+SEASONS(ns)
     if (isvar("PLOT_TYPE")) then
         plot_type    = PLOT_TYPE
     else
         plot_type    = "ps"
     end if
     plot_file        = plot_root_name +"."+plot_type

     opt              = True
     opt@varLabels    = caseVarCompare
     opt@varLabelsYloc= 0.70
     opt@caseLabels   = CASES
     opt@tiMainString = SEASONS(ns)+": ref case="+REF_CASE

     if (isvar("TEST_MARKERS")) then
         opt@Markers  = TEST_MARKERS 
     end if
     if (isvar("TEST_COLORS")) then
         opt@Colors   = TEST_COLORS
     end if
 
     wks              = gsn_open_wks(plot_type,plot_root_name) 
     plot             = taylor_diagram(wks,ratio,cc,opt)
    end do                              ; end SEASON loop

    tt_opt        = True
    tt_opt@pltType= "png"               ; "eps" [default], "pdf", "ps"
                                        ; "png", "gif" [if you have ImageMajik 'convert']
;;    taylor_metrics_table("taylor.000004", VAR_COMPARE, CASES ,SEASONS, table, tt_opt)

end
