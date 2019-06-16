
subroutine discretize(omega,xnewvar,nbins,total_num,binBound,yy_data)

implicit none

integer, intent(in) :: nbins
integer, intent(in) :: total_num
real, intent(in) :: omega(total_num)
real, intent(in) :: xnewvar(total_num)
real, intent(in) :: binBound(nbins+1)

real, intent(out) :: yy_data(nbins,total_num)

integer :: i,nb
integer :: countnum
real :: aver(nbins)

print*,'qinyi'
!print*,omega(200000:200100)


yy_data = 9.9692100E+36

! for ISSCP cloud data, -1000.f is the missing value.
! for model output data, 9..... is the FillValue.

do nb = 1,nbins
    countnum = 0
    do i=1,total_num
        if((omega(i).ge.binBound(nb)) .and. (omega(i).lt.binBound(nb+1)))then
            yy_data(nb,i) = xnewvar(i)

            if(yy_data(nb,i).ne.9.9692100E+36.and.yy_data(nb,i).ne.-1000.)then
            aver(nb) = aver(nb)+xnewvar(i)
            countnum = countnum+1
            endif

        end if
    enddo

    if(countnum.ne.0)then
    aver(nb) = aver(nb)/countnum
    else
    aver(nb) =0.0
    endif
    print*,'nb=',nb
    print*,'countnum=',countnum
!    print*,'ave=',aver(nb)

enddo 

!print*,yy_data(200000:200100,50)
!print*,yy_data(1:100,200001)


return

end subroutine discretize
