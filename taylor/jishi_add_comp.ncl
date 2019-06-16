
 ;**********************************************************
 ; computations: scalar/vector
 ;**********************************************************
                                       
          if (vClass.eq."scalar") then    ; =====> SCALAR <===== 
                                          ; [S]PACE

              if ((CC_TIME .or. CC_SPACE_TIME) .and. SEASONS(ns).eq."ANN") then 
                                          ; SCALAR [S]pace-[T]ime
                                          ; temporary variables
                                          ; 3D (12,lat,lon) stuff
              sumwgt_S      = sum(wgt_S)      ; wgt_S(12,lat,lon) 
              sumwr         = sum(wgt_S*vref_S); (12,lat,lon)*(12,lat,lon)
              sumwc         = sum(wgt_S*vcase_S)

                                      ; weighted S mean 
              wmean_ref_S   = sumwr/sumwgt_S
              wmean_case_S  = sumwc/sumwgt_S   
              bias_S        = wmean_case_S - wmean_ref_S
              if (wmean_ref_S.ne.0) then
                  bias_S    = abs(bias_S/wmean_ref_S)*100   ; bias [%]  
              else
                  bias_S    = bias_metric_S@_FillValue
              end if
                                      ; wgted ratio space-time var [scalar]
                                      ; [(time,lat,lon) - mean_S]^2
              wvar_ref_S    = sum(wgt_S*(vref_S -wmean_ref_S )^2)/sumwgt_S  
              wvar_case_S   = sum(wgt_S*(vcase_S-wmean_case_S)^2)/sumwgt_S  
              wvar_ratio_S  = (wvar_case_S/wvar_ref_S)^0.5 

                                      ; wgted space-time cc [scalar]
              wcc_numer_S   = (sum(wgt_S*vref_S*vcase_S) - sumwr*sumwc/sumwgt_S )
              wcc_denom_S   = ((sum(wgt_S*(vref_S^2 )) - sumwr^2/sumwgt_S)*\
                               (sum(wgt_S*(vcase_S^2)) - sumwc^2/sumwgt_S))        
              if (wcc_denom_S.gt.0.) then 
                  wcc_S = wcc_numer_S/sqrt(wcc_denom_S) 
              else
                  wcc_S = cc_metric_S@_FillValue
 	      end if

                  bias_metric_S(nc,0,nv)   = bias_S
                  ratio_metric_T(nc,0,nv)   = wvar_ratio_T 
                  ratio_metric_S(nc,0,nv)  = wvar_ratio_S 
                  mean_T(0,nc,0,nv)         = wmean_ref_T  
                  mean_S(0,nc,0,nv)        = wmean_ref_S  
                  mean_T(1,nc,0,nv)         = wmean_case_T  
                  mean_S(1,nc,0,nv)        = wmean_case_S  

                  delete(cc_T)              
                  delete( vref_mean_T )
                  delete( vcase_mean_T)
                  delete( vref_var_T  )
                  delete( vcase_var_T )
	      end if
