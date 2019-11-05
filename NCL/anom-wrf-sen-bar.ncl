levels2 := (/-50.,-40.,-30.,-25.,-20.,-18.,-16.,-14.,-12.,-10.,\
        -9.,-8.,-7.,-6,-5,-4.,-3.,-2.,-1.,-0.9,-0.8,-0.7,-0.6,\
        -0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,\
        0.8,0.9,1.,2.,3.,4.,5.,6.,7.,8.,9.,10.,12.,14.,16.,18,\
        20.,25.,30.,40.,50/) 
begin
    f_data_vnp  = "/data/users/jticse/Tesis-Maestria/SALIDAS/csv/VNP.csv"
    fc_vnp     := asciiread(f_data_vnp,-1,"string")
    fc_vnp     := str_split_csv(fc_vnp(1:),",",0)
    dim_fc      = dimsizes(fc_vnp(:,0))

    f_data_anom = "/data/users/jticse/Tesis-Maestria/SALIDAS/csv/anom-wrf-sen.csv"
    fc_anom    := asciiread(f_data_anom,-1,"string")
    fc_anom    := str_split_csv(fc_anom(1:),",",0)
    ;dim_fc      = dimsizes(fc_anom(:,0))

    periodos:= (/"2017-01-14","2017-01-21","2017-01-24","2017-01-30","2017-02-02",\
        "2017-02-25","2017-03-08","2017-03-13","2017-03-21","2017-03-25",\
        "2018-01-10","2018-01-16","2018-01-21","2018-02-14","2018-02-17",\
        "2018-03-05","2018-03-17","2018-03-22"/)

    ;---Calculate number of models
    nmons    = 5                ; Jan, Mar, May
    nmodels  = 3                ; The -1 is for the min/max/avg header
    nmodmon  = nmodels*nmons

    periodos := periodos(:9)
    ;periodos := periodos(10:)

    res = True
    res@trXMinF  = -2.0              ; bottom of X-scale
    res@trXMaxF  =  2.0  
    res@tiMainString      = "Scatter Plot"           ; add title
    res@xyMarkLineModes   = "Markers"                ; choose which have markers
    res@xyMarkers         =  16                      ; choose type of marker  
    res@xyMarkerColor     = "red"                    ; Marker color
    res@xyMarkerSizeF     = 0.01                     ; Marker size (default 0.01)

    do j=0,dim_fc-1
        cod_est    := fc_vnp(j,16)
        id_est     := str_match_ind(fc_anom(:,20),cod_est)
        if (.not.all(ismissing(id_est))) then
            ;¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
            ;----- creando mapa ------;
            type    = "png"
            ;type    = "x11"
            dirS    = "/data/users/jticse/Tesis-Maestria/SALIDAS/figuras/"
            wks     = gsn_open_wks(type,dirS+"anom-WRF-SE-CU-"+cod_est)
            plot    = new(dimsizes(periodos)*3,graphic)
            do i=0,dimsizes(periodos)-1
                periodo = periodos(i)
                year    = stringtoint(str_get_cols(periodo,0,3))
                mes     = stringtoint(str_get_cols(periodo,5,6))
                dia     = stringtoint(str_get_cols(periodo,8,9))
                do k=0,2
                    t_se        = cd_inv_calendar(year,mes,dia+k,0,0,0,"days since 1971-1-1",0)
                    fecha_s     = cd_string(t_se,"%D-%N-%Y")
                    id_fe      := str_match_ind(fc_anom(id_est,1),fecha_s)
                    anom        = fc_anom(id_fe,2)-fc_anom(id_fe,3)       
                    plot(3*i+k) = gsn_csm_xy (wks,anom,fc_anom(id_est,8),res)             
                end do
            end do
            resP             = True
            resP@gsnMaximize = True
            gsn_panel(wks,plot,(/3,dimsizes(periodos)/),resP)
        end if
    end do
