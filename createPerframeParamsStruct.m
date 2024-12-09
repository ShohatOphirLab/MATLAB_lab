function perframe_params = createPerframeParamsStruct()
perframe_params = struct();
perframe_params.nroi = 0;
perframe_params.nflies_close = [];
perframe_params.fov = pi;
perframe_params.max_dnose2ell_anglerange = 127;
perframe_params.nbodylengths_near = 2.5000;
perframe_params.thetafil = [0.0625 0.2500 0.3750 0.2500 0.0625];