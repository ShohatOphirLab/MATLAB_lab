function landmark_params = createLandmarkParamsStruct()
landmark_params = struct();
landmark_params.arena_center_mm_x = 0;
landmark_params.arena_center_mm_y = 0;
landmark_params.arena_radius_mm = 60;
landmark_params.arena_type = 'circle';