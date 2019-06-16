
subroutine discretize2(xLTS,xRH,xnewvar,nbins1,nbins2,total_num,binBound1,binBound2,yy_data)

implicit none

integer, intent(in) :: nbins1,nbins2
integer, intent(in) :: total_num
real, intent(in) :: xLTS(total_num)
real, intent(in) :: xRH(total_num)
real, intent(in) :: xnewvar(total_num)
real, intent(in) :: binBound1(nbins1+1)
real, intent(in) :: binBound2(nbins2+1)

real, intent(out) :: yy_data(nbins2,nbins1,total_num)

integer :: i,nb1,nb2
integer :: countnum

print*,'qinyi'

yy_data = 9.9692100E+36

do nb1 = 1,nbins1
        do nb2 = 1,nbins2
                do i=1,total_num
                    if((xLTS(i).ge.binBound1(nb1)) .and. (xLTS(i).lt.binBound1(nb1+1)))then
                            if((xRH(i).ge.binBound2(nb2)) .and. (xRH(i).lt.binBound2(nb2+1)))then 
                                        yy_data(nb2,nb1,i) = xnewvar(i)
                            end if
                    end if
                enddo
        enddo
enddo 


return

end subroutine discretize2
