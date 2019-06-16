
function ave_std(data[*][*][*]:numeric,nVar:integer,total_num:integer,nBin:integer)

begin

; data(nVar,total_num,nBin)
;print(data(0,200000:200100,49))
;exit


yy_data = new((/2,nVar,nBin/),float)

; ==========0: average mean; 1: standard deviation
yy_data(0,:,:) = dim_avg_n_Wrap(data,1)
yy_data(1,:,:) = dim_stddev_n_Wrap(data,1)

return(yy_data)

end

;=======================================================
function cal_theta(T[*][*][*][*]:numeric,P[*][*][*][*]:numeric,P0:numeric)

begin

theta = T*(P0/P)^0.286
copy_VarCoords(T,theta)

return(theta)

end


