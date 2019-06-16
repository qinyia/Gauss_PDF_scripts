
 ;**********************************************************
 ; computations: scalar/vector
 ;**********************************************************
                                       
          if (vClass.eq."scalar") then    ; =====> SCALAR <===== 
                                          ; [S]PACE
              sumwgt_S      = sum(wgt_S)  
                                          ; temporary variables
              sumwr         = sum(wgt_S*vref_S) ; (lat,lon)*(lat,lon)
              sumwc         = sum(wgt_S*vcase_S)

                                          ; wgted areal (spatial) means
              wmean_ref_S   = sumwr/sumwgt_S
              wmean_case_S  = sumwc/sumwgt_S
              bias_S        = wmean_case_S - wmean_ref_S
              if (wmean_ref_S.ne.0) then
                  bias_S    = abs(bias_S/wmean_ref_S)*100  ; bias [%]
              else
                  bias_S    = bias_metric_S@_FillValue
              end if

                                          ; wgted areal variance
              wvar_ref_S    = sum(wgt_S*(vref_S -wmean_ref_S )^2)/sumwgt_S  
              wvar_case_S   = sum(wgt_S*(vcase_S-wmean_case_S)^2)/sumwgt_S  
              wvar_ratio_S  = (wvar_case_S/wvar_ref_S)^0.5 

                                          ; variance (wgt_numerator/wgt_denominator)
              wcc_numer_S   = (sum(wgt_S*vref_S*vcase_S) - sumwr*sumwc/sumwgt_S )
              wcc_denom_S   = ((sum(wgt_S*(vref_S^2 )) - sumwr^2/sumwgt_S)*\
                               (sum(wgt_S*(vcase_S^2)) - sumwc^2/sumwgt_S) )        
              if (wcc_denom_S.gt.0.) then 
                  wcc_S = wcc_numer_S/sqrt(wcc_denom_S) ; wgted spatial correlation coef
              else
                  wcc_S = cc_metric_S@_FillValue
 	      end if
                                          ; arrays used for plot/netCDF
              cc_metric_S(nc,ns,nv)     = wcc_S
              ratio_metric_S(nc,ns,nv)  = wvar_ratio_S 
              bias_metric_S(nc,ns,nv)   = bias_S  

              mean_S(0,nc,ns,nv)        = wmean_ref_S  
              mean_S(1,nc,ns,nv)        = wmean_case_S  

              if ((CC_TIME .or. CC_SPACE_TIME) .and. SEASONS(ns).eq."ANN") then 
                                          ; SCALAR [S]pace-[T]ime
                                          ; temporary variables
                                          ; 3D (12,lat,lon) stuff
                  sumw_ST       = sum(wt)      ; wt(12,lat,lon) 
                  sumwr_ST      = sum(wt*rdata); (12,lat,lon)*(12,lat,lon)
                  sumwc_ST      = sum(wt*cdata)

                                          ; weighted ST mean 
                  wmean_ref_ST  = sumwr_ST/sumw_ST
                  wmean_case_ST = sumwc_ST/sumw_ST   
                  bias_ST       = wmean_case_ST - wmean_ref_ST
                  if (wmean_ref_ST.ne.0) then
                      bias_ST   = abs(bias_ST/wmean_ref_ST)*100   ; bias [%]  
                  else
                      bias_ST   = bias_metric_S@_FillValue
                  end if
                                          ; wgted ratio space-time var [scalar]
                                          ; [(time,lat,lon) - mean_ST]^2
                  wvar_ref_ST   = sum(wt*(rdata-wmean_ref_ST )^2)/sumw_ST  
                  wvar_case_ST  = sum(wt*(cdata-wmean_case_ST)^2)/sumw_ST  
                  wvar_ratio_ST = (wvar_case_ST/wvar_ref_ST)^0.5 

                                          ; wgted space-time cc [scalar]
                  wcc_numer_ST  = (sum(wt*rdata*cdata) - sumwr_ST*sumwc_ST/sumw_ST )
                  wcc_denom_ST  = ((sum(wt*(rdata^2))  - sumwr_ST^2/sumw_ST)*\
                                   (sum(wt*(cdata^2))  - sumwc_ST^2/sumw_ST))        
                  if (wcc_denom_ST.gt.0.) then 
                      wcc_ST = wcc_numer_ST/sqrt(wcc_denom_ST) 
                  else
                      wcc_ST = cc_metric_ST@_FillValue
 	          end if
                                          ; [T]emporal cor coef (local)
;; not yet avail  cc_T          = escorc_n(cdata, rdata, 0 )  ; (lat,lon)  
                  cc_T          = escorc(cdata(lat|:,lon|:,time|:) \  ; local     
                                        ,rdata(lat|:,lon|:,time|:) )  ; (lat,lon)  
                  copy_VarCoords(cdata(0,:,:), cc_T)
                  cc_T@long_name= "spatial avg of temporal lin cor: "+VAR_ID_PLOT(nv) 
                                          ; wgt spatial avg of cc_T
                  wcc_T         = sum(wgt_S*cc_T)/sumwgt_S            

                                          ; temporal mean at each grid point
                  vref_mean_T   = dim_avg_n(rdata, 0 )  ; local
                  vcase_mean_T  = dim_avg_n(cdata, 0 )  ; (lat,lon) 
                ;;vref_mean_T   = dim_avg(rdata(lat|:,lon|:,time|:) )  ; local
                ;;vcase_mean_T  = dim_avg(cdata(lat|:,lon|:,time|:) )  ; (lat,lon) 

                                          ; wgt spatial avg of _T grid point means 
                  wmean_ref_T   = sum(wgt_S*vref_mean_T)/sumwgt_S   
                  wmean_case_T  = sum(wgt_S*vcase_mean_T)/sumwgt_S   
                                          ; bias of _T
                  bias_T        = wmean_case_T - wmean_ref_T
                  if (wmean_ref_T.ne.0) then
                      bias_T    = abs(bias_T/wmean_ref_T)*100  ; bias [%]
                  else
                      bias_T    = bias_metric_T@_FillValue
                  end if
                                          ; temporal variance at each grid point [local]
                  vref_var_T    = dim_variance_n(rdata, 0 )  ; (lat,lon) 
                  vcase_var_T   = dim_variance_n(cdata, 0 )
                ;;vref_var_T    = dim_variance(rdata(lat|:,lon|:,time|:) )  ; (lat,lon) 
                ;;vcase_var_T   = dim_variance(cdata(lat|:,lon|:,time|:) )

                                          ; wgted areal *local* temporal variance
                  wvar_ref_T    = sum(wgt_S*vref_var_T)/sumwgt_S   
                  wvar_case_T   = sum(wgt_S*vcase_var_T)/sumwgt_S   
                                          ; ratio
                  wvar_ratio_T  = (wvar_case_T/wvar_ref_T)^0.5 
                                                ; arrays used for plot/netCDF
                  cc_metric_T(nc,0,nv)      = wcc_T
                  cc_metric_ST(nc,0,nv)     = wcc_ST
                  bias_metric_T(nc,0,nv)    = bias_T
                  bias_metric_ST(nc,0,nv)   = bias_ST
                  ratio_metric_T(nc,0,nv)   = wvar_ratio_T 
                  ratio_metric_ST(nc,0,nv)  = wvar_ratio_ST 
                  mean_T(0,nc,0,nv)         = wmean_ref_T  
                  mean_ST(0,nc,0,nv)        = wmean_ref_ST  
                  mean_T(1,nc,0,nv)         = wmean_case_T  
                  mean_ST(1,nc,0,nv)        = wmean_case_ST  

                  delete(cc_T)              
                  delete( vref_mean_T )
                  delete( vcase_mean_T)
                  delete( vref_var_T  )
                  delete( vcase_var_T )
	      end if
