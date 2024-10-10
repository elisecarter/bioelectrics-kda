function  [SessionData] = ProcessReachEvents(RawData,UI)
% iterates through all reaches in each session and filters data to
% keep only reach events, calculates interpolated position/velocity,
% dynamic time warping of hand position, hand arc length,
% and normalizes dynamic time warped hand data to pellet location

% preallocate session structure
SessionData(length(RawData)) = struct('SessionID',[],'InitialToMax',[],...
    'InitialToEnd',[],'StimLogical',[]);

interp_threshold = .5; %percent of datapoints that were poorly tracked (<90 confidence)
for i = 1 : length(RawData) %iterate thru sessions
    session_raw = RawData(i);
    indx = table2array(session_raw.ReachIndexPairs); %pull out reach indices

    % pull out success rate from raw data
    num_success = sum(strcmp(session_raw.Behaviors,'success'));
    num_reaches = sum(~session_raw.Excluded);
    SessionData(i).PercentSuccess = num_success/num_reaches;

    %sort reach inds by start ind
    [~,locs] = sort(indx(:,1));
    indx = indx(locs,:);

    % save session level info (sorted) before deleting so we can use structfun
    SessionData(i).SessionID = session_raw.Session;
    SessionData(i).StimLogical = session_raw.StimLogical(locs);
    SessionData(i).Behavior = session_raw.Behaviors(locs);
    SessionData(i).EndCategory = session_raw.EndCategory(locs);
    SessionData(i).CropPoints = session_raw.CropPoints;
    SessionData(i).frmDropsFront = session_raw.frmDropsFront';
    SessionData(i).frmDropsSide = session_raw.frmDropsSide';
    SessionData(i).frmDropsTop = session_raw.frmDropsTop';
    SessionData(i).Excluded = session_raw.Excluded(locs);
    SessionData(i).Reason = session_raw.Reason(locs);

    % remove unneeded fields
    session_raw = rmfield(session_raw,'Session');
    session_raw = rmfield(session_raw,'ReachIndexPairs');
    session_raw = rmfield(session_raw,'StimLogical');
    session_raw = rmfield(session_raw,'Behaviors');
    session_raw = rmfield(session_raw,'EndCategory');
    session_raw = rmfield(session_raw,'CropPoints');
    session_raw = rmfield(session_raw,'frmDropsSide');
    session_raw = rmfield(session_raw,'frmDropsFront');
    session_raw = rmfield(session_raw,'frmDropsTop');    
    session_raw = rmfield(session_raw,'Excluded');
    session_raw = rmfield(session_raw,'Reason');

    % pellet location
    num_reaches = height(indx);
    k = 1;
    pellet_loc = zeros(1,3);
    for j = 1 : num_reaches 
        % pull out pellet location if confidence is high
        reach_start = indx(j,1);
        init_frames = reach_start:reach_start+3; %first 3 frames of reach
        conf_xy = session_raw.pelletConfXY_10k(init_frames); % initial confidence
        conf_z = session_raw.pelletConfZ_10k(init_frames);
        % high confidence: > 90% (w/ 10k multiplier)
        if mean(conf_xy) > 9000 && mean(conf_z) > 9000
            pellet_loc(k,1) = mean(session_raw.pelletX_100(init_frames)./900); %mm
            pellet_loc(k,2) = mean(session_raw.pelletY_100(init_frames)./900); %mm
            pellet_loc(k,3) = mean(session_raw.pelletZ_100(init_frames)./900); %mm
            k = k + 1;
        end
    end
    SessionData(i).PelletLocation = median(pellet_loc);

    % find multiple attempt reaches
    shift = indx(2:end,1);
    interReachInt = shift - indx(1:end-1,3); %from end to start of next reach
    multReach = interReachInt < 150;
    multReach = [false; multReach];
    if (~isempty(multReach) && UI.SingleReachesOnly)
        newExclude = find((SessionData(i).Excluded==false) & multReach);
        SessionData(i).Excluded(newExclude,1) = true;
        SessionData(i).Reason(newExclude,1) = {'multAttempt'};
    end
    
    % find reaches < 2 frames from init to max
    max_duration = indx(:,2) - indx(:,1); %from init to max
    too_short = max_duration < 2;
    if any(too_short==1)
        newExclude = find((SessionData(i).Excluded==false) & too_short);
        SessionData(i).Excluded(newExclude,1) = true;
        SessionData(i).Reason(newExclude,1) = {'initToMax<2frames'};
    end

    %calculate kinemactic features for included reaches
    k=1; %for saving analyzed reached
    for j = 1 : height(indx) 
        if SessionData(i).Excluded(j)==true
            continue
        end

        start_ind = indx(j,1); % start index
        max_ind = indx(j,2); % max index
        end_ind = indx(j,3); % end index

        % reach duration (150 fps)
        duration_max = (max_ind - start_ind) / 150; %sec
        duration_end = (end_ind - start_ind) / 150; %sec

        % index only reach events from raw data (start to max/end)
        init2max = structfun(@(x) x(start_ind:max_ind), session_raw, ...
            'UniformOutput', false);
        init2end = structfun(@(x) x(start_ind:end_ind), session_raw, ...
            'UniformOutput', false);

        % if percent of poorly tracked data points in this reach is greater
        % than the threshold, delete this reach
        conf = init2end.handConfXY_10k./10000;
        percent_poor = sum(conf<0.9)/length(conf); %percent poorly tracked datapts
        if percent_poor > interp_threshold
            SessionData(i).Excluded(j) = true;
            SessionData(i).Reason(j) = {'poorTracking'};
            continue
        end

        % convert hand position units to mm
        init2max = ConvertPositionUnits(init2max);
        init2end = ConvertPositionUnits(init2end);

        % euclidean matrix of raw hand position data in mm
        tempeuc = [init2end.handX init2end.handY init2end.handZ];

        % index out initial to max euclidean matrix for further processing
        frames_max = max_ind - start_ind + 1; % number of frames from start to max
        tempeuc_max = tempeuc(1:frames_max,:);

        % velocity - interpolated, absolute, and raw in mm/sec
        [interpVel_max,absVel_max,rawVel_max,~] = CalculateVelocity(tempeuc_max);
        [interpVel_end,absVel_end,rawVel_end, flagEnd] = CalculateVelocity(tempeuc);

        % interpolate thru jumps to other objects (i.e. left hand)
        if sum(flagEnd) > 0 % frames velocity > 1000 mm/sec
            locs = find(flagEnd);
            if (length(locs))/height(tempeuc) < 0.5 % less than half the reach will be interpolated
                xs = tempeuc(:,1); %sample x vals
                ys = tempeuc(:,2); %sample y vals
                zs = tempeuc(:,3); %sample z vals
                clear tempeuc
                frames = 1:length(xs); %sample frames

                xq = frames; %query pts
                x_XY = frames; %sample pts for side camera
                x_Z = frames; % sample pts for front camera

                % remove poorly tracked datapoints
                x_XY(locs) = [];
                x_Z(locs) = [];

                xs(locs) = [];
                ys(locs) = [];
                zs(locs) = [];

                % interpolate
                tempeuc(:,1) = interp1(x_XY,xs,xq,"pchip");
                tempeuc(:,2) = interp1(x_XY,ys,xq,"pchip");
                tempeuc(:,3) = interp1(x_Z,zs,xq,"pchip");
                tempeuc_max = tempeuc(1:frames_max,:);

                % recalculate velocities w interpolated position
                [interpVel_max,absVel_max,rawVel_max,~] = CalculateVelocity(tempeuc_max);
                [interpVel_end,absVel_end,rawVel_end, ~] = CalculateVelocity(tempeuc);
            end
        end

        if isfield(UI,'VelocityTresh')
            % if absolute velocity is greater than thresh, delete this reach
            if any(absVel_max > UI.VelocityTresh)
                SessionData(i).Excluded(j) = true;
                SessionData(i).Reason(j) = {'velocityThreshold'};
                continue
            end
        end

        % determine max velocity location as percentage of reach
        [maxVel_max,ind] = max(absVel_max);
        maxVelLoc_max = ind/numel(absVel_max);

        [maxVel_end,ind] = max(absVel_end);
        maxVelLoc_end = ind/numel(absVel_end);

        % hand relative to pellet - POSITION DATA RELATIVE TO PELLET
        % FROM NOW ON
        relative_hand_end = tempeuc - SessionData(i).PelletLocation;
        relative_hand_max = tempeuc_max - SessionData(i).PelletLocation;

        %delete reaches that start outside of our ROI (manual
        %feeding)
        if relative_hand_max(1,1)>0 %reach starts from positive x-direction
            SessionData(i).Excluded(j) = true;
            SessionData(i).Reason(j) = {'outsideROI'};
            continue
        end

        if isfield(UI,'MinStartDist')
            % if start distance from pellet (x dim) is less than thresh,
            % delete this reach
            x_init = -1*relative_hand_max(1,1); %switch sign since input is distance (positive number)
            if x_init < UI.MinStartDist
                SessionData(i).Excluded(j) = true;
                SessionData(i).Reason(j) = {'outsideROI'};
                continue
            end
        end

        

        % % delete reaches that do not move in space
        % % essentially doing the distance formula here
        % delta = diff(relative_hand_max,1,1);
        % dist = [];
        % for n = 1:height(delta)
        %     dist(n) = norm(delta(n,:));
        % end
        % if sum(dist) < 0.5 %mm
        %     SessionData(i).StimLogical(k) = [];
        %     SessionData(i).Behavior(k) = [];
        %     SessionData(i).EndCategory(k) = [];
        %     tooStill(j) = true;
        %     continue
        % end

        % hand position interpolation
        [interp_hand_max] = InterpolatePosition(relative_hand_max);
        [interp_hand_end] = InterpolatePosition(relative_hand_end);

        % dynamic time warping (DTW)
        [DTW_max, flagMax] = DynamicTimeWarping(relative_hand_max);
        [DTW_end, flagEnd] = DynamicTimeWarping(relative_hand_end);
        if flagMax || flagEnd
            SessionData(i).Excluded(j) = true;
            SessionData(i).Reason(j) = {'DTW_error'};
            continue
        end

        % arc length
        % 3D path length
        arcLength3D_max = arclength(interp_hand_max(:,1), interp_hand_max(:,2), interp_hand_max(:,3),'pchip');
        arcLength3D_end = arclength(interp_hand_end(:,1), interp_hand_end(:,2), interp_hand_end(:,3),'pchip');

        % XY path length
        arcLengthXY_max = arclength(interp_hand_max(:,1), interp_hand_max(:,2),'pchip');
        arcLengthXY_end = arclength(interp_hand_end(:,1), interp_hand_end(:,2),'pchip');

        % XZ path length
        arcLengthXZ_max = arclength(interp_hand_max(:,1), interp_hand_max(:,3),'pchip');
        arcLengthXZ_end = arclength(interp_hand_end(:,1), interp_hand_end(:,3),'pchip');

        
        % store initial to max data
        SessionData(i).InitialToMax(k).RawData = struct2table(init2max);
        SessionData(i).InitialToMax(k).StartIndex = start_ind;
        SessionData(i).InitialToMax(k).EndIndex = max_ind;
        SessionData(i).InitialToMax(k).ReachDuration = duration_max;
        SessionData(i).InitialToMax(k).HandPositionNormalized = relative_hand_max;
        SessionData(i).InitialToMax(k).RawVelocity = rawVel_max;
        SessionData(i).InitialToMax(k).InterpolatedVelocity = interpVel_max;
        SessionData(i).InitialToMax(k).AbsoluteVelocity = absVel_max;
        SessionData(i).InitialToMax(k).MaxAbsVelocity = maxVel_max;
        SessionData(i).InitialToMax(k).MaxVelocityLocation = maxVelLoc_max;
        SessionData(i).InitialToMax(k).InterpolatedHand = interp_hand_max;
        SessionData(i).InitialToMax(k).DTWHand = DTW_max;
        SessionData(i).InitialToMax(k).PathLength3D = arcLength3D_max;
        SessionData(i).InitialToMax(k).PathLengthXY = arcLengthXY_max;
        SessionData(i).InitialToMax(k).PathLengthXZ = arcLengthXZ_max;
        SessionData(i).InitialToMax(k).Behavior = SessionData(i).Behavior(j);

        % store initial to end data
        SessionData(i).InitialToEnd(k).RawData = struct2table(init2end);
        SessionData(i).InitialToEnd(k).StartIndex = start_ind;
        SessionData(i).InitialToEnd(k).EndIndex = end_ind;
        SessionData(i).InitialToEnd(k).ReachDuration = duration_end;
        SessionData(i).InitialToEnd(k).HandPositionNormalized = relative_hand_end;
        SessionData(i).InitialToEnd(k).RawVelocity = rawVel_end;
        SessionData(i).InitialToEnd(k).InterpolatedVelocity = interpVel_end;
        SessionData(i).InitialToEnd(k).AbsoluteVelocity = absVel_end;
        SessionData(i).InitialToEnd(k).MaxAbsVelocity = maxVel_end;
        SessionData(i).InitialToEnd(k).MaxVelocityLocation = maxVelLoc_end;
        SessionData(i).InitialToEnd(k).InterpolatedHand = interp_hand_end;
        SessionData(i).InitialToEnd(k).DTWHand = DTW_end;
        SessionData(i).InitialToEnd(k).PathLength3D = arcLength3D_end;
        SessionData(i).InitialToEnd(k).PathLengthXY = arcLengthXY_end;
        SessionData(i).InitialToEnd(k).PathLengthXZ = arcLengthXZ_end;
        SessionData(i).InitialToEnd(k).Behavior = SessionData(i).Behavior(j);

        k = k + 1;
    end

    SessionData(i).AnalyzedReaches = length(SessionData(i).InitialToMax);
    SessionData(i).ReachIndexPairs = indx;
    SessionData(i).CropPoints = RawData(i).CropPoints;

end
