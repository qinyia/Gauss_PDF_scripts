
begin

wks=gsn_open_wks("x11","test")

gsn_define_colormap(wks,"blue-white-red_40colors")
gsn_draw_colormap(wks)

end
