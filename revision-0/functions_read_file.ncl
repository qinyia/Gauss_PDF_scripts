
function read_omega(fdir:string,case:string)

begin 
  ;========================
  ; get list of all files and open as "one big file"
  ;========================                             
;     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23]-..\.nc'")
;     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '....-..\.nc'")
     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23456789]-..\.nc'")

     fall      = addfiles (all_files, "r")   ; note the "s" of addfile
  ;========================
  ; choose how files are combined and read in variable across files
  ;========================  
     ListSetType (fall, "cat")             ; concatenate or "merge" (default)

     xx    = fall[:]->OMEGA                     ; note syntax [:]
	 
	 return(xx)
end


function read_SWCF(fdir:string,case:string)

begin 
  ;========================
  ; get list of all files and open as "one big file"
  ;========================                             
;     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23]-..\.nc'")
;     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '....-..\.nc'")
     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23456789]-..\.nc'")


     fall      = addfiles (all_files, "r")   ; note the "s" of addfile
  ;========================
  ; choose how files are combined and read in variable across files
  ;========================  
     ListSetType (fall, "cat")             ; concatenate or "merge" (default)

     xx    = fall[:]->SWCF                     ; note syntax [:]
	 
	 return(xx)

end

function read_LWCF(fdir:string,case:string)

begin 
  ;========================
  ; get list of all files and open as "one big file"
  ;========================                             
;     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23]-..\.nc'")
;all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '....-..\.nc'")
     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23456789]-..\.nc'")

     fall      = addfiles (all_files, "r")   ; note the "s" of addfile
  ;========================
  ; choose how files are combined and read in variable across files
  ;========================  
     ListSetType (fall, "cat")             ; concatenate or "merge" (default)

     xx    = fall[:]->LWCF                     ; note syntax [:]
	 
	 return(xx)

end

function read_CLDLOW(fdir:string,case:string)

begin 
  ;========================
  ; get list of all files and open as "one big file"
  ;========================                             
;     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23]-..\.nc'")
;all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '....-..\.nc'")
     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23456789]-..\.nc'")

     fall      = addfiles (all_files, "r")   ; note the "s" of addfile
  ;========================
  ; choose how files are combined and read in variable across files
  ;========================  
     ListSetType (fall, "cat")             ; concatenate or "merge" (default)

     xx    = fall[:]->CLDLOW                     ; note syntax [:]
	 
	 return(xx)

end

function read_CLDMED(fdir:string,case:string)

begin 
  ;========================
  ; get list of all files and open as "one big file"
  ;========================                             
;     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23]-..\.nc'")
;all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '....-..\.nc'")
     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23456789]-..\.nc'")

     fall      = addfiles (all_files, "r")   ; note the "s" of addfile
  ;========================
  ; choose how files are combined and read in variable across files
  ;========================  
     ListSetType (fall, "cat")             ; concatenate or "merge" (default)

     xx    = fall[:]->CLDMED                     ; note syntax [:]
	 
	 return(xx)

end


function read_CLDHGH(fdir:string,case:string)

begin 
  ;========================
  ; get list of all files and open as "one big file"
  ;========================                             
;     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23]-..\.nc'")
;all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '....-..\.nc'")
     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23456789]-..\.nc'")

     fall      = addfiles (all_files, "r")   ; note the "s" of addfile
  ;========================
  ; choose how files are combined and read in variable across files
  ;========================  
     ListSetType (fall, "cat")             ; concatenate or "merge" (default)

     xx    = fall[:]->CLDHGH                     ; note syntax [:]
	 
	 return(xx)

end

function read_RELHUM(fdir:string,case:string)

begin 
  ;========================
  ; get list of all files and open as "one big file"
  ;========================                             
;     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23]-..\.nc'")
;all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '....-..\.nc'")
     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23456789]-..\.nc'")

     fall      = addfiles (all_files, "r")   ; note the "s" of addfile
  ;========================
  ; choose how files are combined and read in variable across files
  ;========================  
     ListSetType (fall, "cat")             ; concatenate or "merge" (default)

     xx    = fall[:]->RELHUM                     ; note syntax [:]
	 
	 return(xx)

end

function read_T(fdir:string,case:string)

begin 
  ;========================
  ; get list of all files and open as "one big file"
  ;========================                             
;     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23]-..\.nc'")
;all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '....-..\.nc'")
     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23456789]-..\.nc'")

     fall      = addfiles (all_files, "r")   ; note the "s" of addfile
  ;========================
  ; choose how files are combined and read in variable across files
  ;========================  
     ListSetType (fall, "cat")             ; concatenate or "merge" (default)

     xx    = fall[:]->T                     ; note syntax [:]
	 
	 return(xx)

end

function read_PBLH(fdir:string,case:string)

begin 
  ;========================
  ; get list of all files and open as "one big file"
  ;========================                             
;     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23]-..\.nc'")
;all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '....-..\.nc'")
     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23456789]-..\.nc'")

     fall      = addfiles (all_files, "r")   ; note the "s" of addfile
  ;========================
  ; choose how files are combined and read in variable across files
  ;========================  
     ListSetType (fall, "cat")             ; concatenate or "merge" (default)

     xx    = fall[:]->PBLH                     ; note syntax [:]
	 
	 return(xx)

end



function read_level(fdir:string,case:string)

begin 
  ;========================
  ; get list of all files and open as "one big file"
  ;========================                             
     all_files = systemfunc ("ls "+fdir+case+"/atm/hist/* | grep '000[23]-..\.nc'")
     fall      = addfiles (all_files, "r")   ; note the "s" of addfile
  ;========================
  ; choose how files are combined and read in variable across files
  ;========================  
     ListSetType (fall, "cat")             ; concatenate or "merge" (default)

     xx    = fall[:]->lev                     ; note syntax [:]
	 
	 return(xx)

end


