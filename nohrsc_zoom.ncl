; ===========================================
; Plotting GFS archive overnight to correct
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "~/ncl/lib/tTick.ncl"
load "~/ncl/lib/ut_string.ncl"
load "~/ncl/lib/latlon.ncl"
load "~/ncl/lib/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
; ===========================================

;system("setenv NCARG_COLORMAPS /home/Alicia.Bentley/colormaps")

begin

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")

period = 36     ;36

name = "nohrsc_"+period+"h_valid2020121800"

;-------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------

	timeUnits = "hours since 1800-01-01 00:00:00"
 
	syyyy = 2020 
	smm = 12
	sdd = 16
	shh = 12+6

        eyyyy = 2020
        emm = 12
        edd = 18
        ehh = 0

        sdate = cd_inv_calendar(syyyy,smm,sdd,shh,00,00,timeUnits,0)
        edate = cd_inv_calendar(eyyyy,emm,edd,ehh,00,00,timeUnits,0)

	print("sdate:  "+ut_string(sdate,""))
	print("edate: "+ut_string(edate,""))
    

;*****************************************************

segments=period/6.
print(segments)

  nohrsc_array = new((/toint(segments),1377,2145/),float)
  h= 0 

do tim = sdate,edate,6

        ; Set date strings
        ymd = ut_string(tim,"%Y%N%D")
        hour = ut_string(tim,"%H")
        print("ymd+hour: "+ymd+hour)

       anlfile = "./analyses/sfav2_CONUS_6h_"+ymd+hour+"_grid184.grb2"
       if (isfilepresent(anlfile)) then
          print("NOHRSC analysis file found!")
       else
          print("NOHRSC analysis file is missing...")
          system("pwd")
       end if

       anl=addfile(anlfile,"r")


      precip_anl = anl->ASNOW_P8_L1_GLC0_acc(:,:)
;      printVarSummary(precip_anl)
      precip_anl=precip_anl*39.3701
      lat2d = anl->gridlat_0
      lon2d = anl->gridlon_0
      precip_anl@lat2d = lat2d
      precip_anl@lon2d = lon2d
;      printMinMax(precip_anl,True)
      nohrsc_array(h,:,:) = precip_anl
      h=h+1

end do

      precipplot_anl=dim_sum_n_Wrap(nohrsc_array,0)
;      precipplot_anl@lat2d = lat2d
;      precipplot_anl@lon2d = lon2d

printMinMax(precipplot_anl,True)

print("Successfully got data from files!")

;=============================================

folder = (/"EC"/)
;folder = (/"northamer","pacific","atlantic","europe","southpac","southamer","india","australia","africa","asia"/)   
enddomain = dimsizes(folder)

do x = 0,enddomain-1

domain = folder(x)

print(" ")
print("Plotting maps for: "+domain)	      	

dir_plot = "images/"	         
dir_out = dir_plot


;==============================================
; Create Shaded Map
;==============================================

wks_type = "png"

wks_type@wkWidth = 1600
wks_type@wkHeight = 1600

wks = gsn_open_wks(wks_type,dir_plot+name)

gsn_define_colormap(wks,"tempprac")
;**********************************************

res = True

res@gsnFrame = False                                             ;DO NOT PLOT FIRST MAP
res@gsnDraw = False

res@mpDataBaseVersion = "MediumRes"                              ; Country Outlines
res@mpDataSetName = "Earth..4"
res@mpOutlineBoundarySets = "National"

res@cnLineLabelsOn = False
res@cnFillOn = True                                              ; Turn on color fill
res@cnFillMode = "AreaFill"
res@cnRasterSmoothingOn = True
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLinesOn = False                               ; Turn off contour lines
res@cnLevelSpacingF = 1                            ; Shading interval
;res@cnLevels = (/30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110/)
res@cnLevels = (/0.1,1.0,2.0,3.0,4.0,6.0,8.0,12.0,18.0,24.0,30.0,36.0,48.0/)
res@cnFillColors = (/-1,44,45,48,50,52,63,69,75,80,84,24,27,30,33,35/)
;20,17,15,12,

;********************************************

res@lbLabelBarOn = True
res@lbAutoManage = False                   ; Label Bar Information
res@pmLabelBarOrthogonalPosF = -.03  
res@pmLabelBarHeightF = 0.08
res@pmLabelBarWidthF = 0.61
res@lbLabelAutoStride = True
res@lbLabelFontHeightF = 0.011
res@lbBoxLinesOn  = True                   ; Outline the color bar 
res@lbTopMarginF = .3

; *********************************************

res@mpGeophysicalLineThicknessF = 10.0
res@mpNationalLineThicknessF = 10.0
res@mpUSStateLineThicknessF = 10.0
res@mpOutlineSpecifiers = (/"United States"/)+" : States"

res@mpGeophysicalLineColor = "grey29"
res@mpNationalLineColor = "grey29"
res@mpUSStateLineColor = "grey29"

; *********************************************

res@mpGridAndLimbOn = True
res@mpGridLineDashPattern = 5
res@mpGridLatSpacingF = 10.
res@mpGridLonSpacingF = 10.
res@mpGridLineThicknessF = 2
res@mpGridLineColor = "grey40"
res@pmTickMarkDisplayMode = "Always"

tmres = True
tmres@tmXBLabelFontHeightF = .013
tmres@tmYLLabelFontHeightF = .013
tmres@tmYLLabelFontHeightF = .013

tmres@tmXBMajorLengthF = .01
tmres@tmXBMinorLengthF = .006

tmres@tmYRMinorValues = (/-75,-70,-65,-55,-50,-45,-35,-30,-25,-15,-10,-5,5,10,15,25,30,35,45,50,55,65/)
tmres@tmYLMinorValues = (/-75,-70,-65,-55,-50,-45,-35,-30,-25,-15,-10,-5,5,10,15,25,30,35,45,50,55,65/);tmres@tmXBMinorValues = (/-175,-170,-165,-160,-155,-150,-145,-135,-130,-125,-120,-115,-110,-105,-95,-90,-85,-80,-75,-70,-65,-55,-50,-45,-40,-35,-30,-25,-15,-10,-5,0,5,10,15,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120,125,130,135,145,150,155,160,165,170,175/)
tmres@tmXBMinorValues = ispan(-180,179,5)
; *************************************************************


if domain .eq. "northamer"
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 31
res@mpLambertParallel1F = 11
res@mpLambertMeridianF = -100
res@mpLimitMode = "LatLon"
res@mpMinLatF = 8.
res@mpMaxLatF = 72.
res@mpMinLonF = -151.
res@mpMaxLonF = -49.
delete(tmres@tmXBValues)
tmres@tmXBValues = ispan(-180,179,20)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,20)
tmres@tmYRValues = ispan(0,80,20)
end if

if domain .eq. "conus" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 35
res@mpLambertParallel1F = 25
res@mpLambertMeridianF = -95
res@mpLimitMode = "LatLon"
res@mpMinLatF = 19.
res@mpMaxLatF = 57.
res@mpMinLonF = -123.25
res@mpMaxLonF = -67.
delete(tmres@tmXBValues)
tmres@tmXBValues = ispan(-180,179,10)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,10)
tmres@tmYRValues = ispan(0,80,10)
end if

if domain .eq. "other" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 35
res@mpLambertParallel1F = 25
res@mpLambertMeridianF = -100
res@mpLimitMode = "LatLon"
res@mpMinLatF = 23.
res@mpMaxLatF = 52.
res@mpMinLonF = -122.
res@mpMaxLonF = -72.
delete(tmres@tmXBValues)
tmres@tmXBValues = ispan(-180,179,10)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,10)
tmres@tmYRValues = ispan(0,80,10)
end if

if domain .eq. "zoom" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 35
res@mpLambertParallel1F = 25
res@mpLambertMeridianF = -90
res@mpLimitMode = "LatLon"
res@mpMinLatF = 25.
res@mpMaxLatF = 50.
res@mpMinLonF = -108.
res@mpMaxLonF = -72.
delete(tmres@tmXBValues)
tmres@tmXBValues = ispan(-180,179,10)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,10)
tmres@tmYRValues = ispan(0,80,10)
end if

if domain .eq. "WI" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 35
res@mpLambertParallel1F = 30
res@mpLambertMeridianF = -90
res@mpLimitMode = "LatLon"
res@mpMinLatF = 41.
res@mpMaxLatF = 48.
res@mpMinLonF = -96.5
res@mpMaxLonF = -87.0
delete(tmres@tmXBValues)
tmres@tmYLOn = False
tmres@tmYROn = False
tmres@tmXBOn = False
tmres@tmXBValues = ispan(-180,179,10)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,10)
tmres@tmYRValues = ispan(0,80,10)
end if


if domain .eq. "EC" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 35
res@mpLambertParallel1F = 30
res@mpLambertMeridianF = -90
res@mpLimitMode = "LatLon"
res@mpMinLatF = 35.
res@mpMaxLatF = 47.
res@mpMinLonF = -85.
res@mpMaxLonF = -69.
delete(tmres@tmXBValues)
tmres@tmYLOn = False
tmres@tmYROn = False
tmres@tmXBOn = False
tmres@tmXBValues = ispan(-180,179,10)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,10)
tmres@tmYRValues = ispan(0,80,10)
end if

;**********************************************

  curdate = edate	
  curdate@units = "hours since 1800-01-01 00:00:00"
  fhr_cur = "0"

	res@tiMainString = " "
	res@tiMainJust = "CenterCenter"
	res@tiMainPosition = "Center" 
	res@tiMainOffsetYF = .02
	res@tiXAxisFontHeightF = .015
	
	res@gsnRightString = " "
	
	res@gsnLeftStringFontColor = "black"
	res@gsnLeftString = "36-h NOHRSC Snowfall Analysis (12Z 16 Dec 2020 - 00Z 18 Dec 2020)"
	res@gsnLeftStringOrthogonalPosF = .010
	res@gsnLeftStringFontHeightF = .010
	
	;mres@gsnLeftStringFontColor = "black"
	;mres@gsnLeftString = "Initialized: "+ut_string(curdate,"")+" | Forecast hour: "+fhr_cur+" | Valid: "+ut_string(curdate,"")
	;mres@gsnLeftStringOrthogonalPosF = .010
	;mres@gsnLeftStringFontHeightF = .010


; *************************************************************
res@mpFillOn = True
res@mpOutlineOn = True
res@mpFillDrawOrder = "PreDraw"
res@cnFillDrawOrder = "PreDraw"
;thres@cnLineDrawOrder ="Draw"
;th2res@cnLineDrawOrder ="Draw"
;mres@cnLineDrawOrder ="Draw"
res@mpOutlineDrawOrder = "Draw"
res@mpGridAndLimbDrawOrder = "PostDraw"

plot = gsn_csm_contour_map(wks,precipplot_anl, res)          ; Plot filled contour map
plot = add_map_tickmarks(wks,plot,tmres)

;==============================================

;overlay(plot,other)
;overlay(plot,other2)
;overlay(plot,contours)
;overlay(plot,barbs)

;********************************************

draw(plot)
frame(wks)

;********************************************

;system("pngquant "+dir_plot+name+".png")
;system("'mv' "+dir_plot+name+"-fs8.png "+dir_plot+name+".png") 
system("convert "+dir_plot+name+".png -trim +repage "+dir_out+name+".png")

print("Image created in: "+dir_out)

;**********************************************************************************************************
;**********************************************************************************************************
;**********************************************************************************************************

end do     	; end domain

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
