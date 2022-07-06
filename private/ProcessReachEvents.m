function  [SessionData] = ProcessReachEvents(RawData)
% iterates through all reaches in each session and filters data to 
% keep only reach events, calculates interpolated position/velocity, 
% dynamic time warping of hand position, hand arc length, 
% and normalizes dynamic time warped hand data to pellet location

% NEXT STEPS: add a function to select number of interpolated pts?

% preallocate session structure
SessionData(length(RawData)) = struct('SessionID',[],'InitialToMax',[],...
    'InitialToEnd',[],'StimLogical',[]);

for i = 1 : length(RawData) %iterate thru sessions
    session_data = RawData(i);
    indx = table2array(session_data.ReachIndexPairs);

    %preallocate structs to hold data indexed at reach events for each session
    init2max = struct('handX_100',[],'handY_100',[],'handZ_100',[], ...
        'handConfXY_10k',[],'handConfZ_10k',[],'pelletX_100',[], ...
        'pelletY_100',[],'pelletZ_100',[],'pelletConfXY_10k',[], ...
        'pelletConfZ_10k',[]);
    init2end = struct('handX_100',[],'handY_100',[],'handZ_100',[], ...
        'handConfXY_10k',[],'handConfZ_10k',[],'pelletX_100',[], ...
        'pelletY_100',[],'pelletZ_100',[],'pelletConfXY_10k',[], ...
        'pelletConfZ_10k',[]);

    % remove impossibly short reaches
    end_duration = indx(:,3) - indx(:,1); %frames
    max_duration = indx(:,2) - indx(:,1);
    too_short = end_duration < 5 | max_duration < 2;
    indx(too_short) = [];

    % preprocessing
    k = 1;
    for j = 1 : height(indx) %iterate thru session reaches
         reach_start = indx(j,1);
        % find pellet location
        init_frames = reach_start:reach_start+3; %first 3 frames of reach
        conf_xy = session_data.pelletConfXY_10k(init_frames); 
        conf_z = session_data.pelletConfZ_10k(init_frames);
        if mean(conf_xy) > 9000 && mean(conf_z) > 9000
            x = session_data.pelletX_100(init_frames)';
            y = session_data.pelletY_100(init_frames)';
            z = session_data.pelletZ_100(init_frames)';
            pellet_loc(k,:) = mean([x,y,z]);
            k = k + 1;
        end
    end
    
    % save session level info before deleting so we can use structfun
    SessionData(i).SessionID = session_data.Session;
    SessionData(i).StimLogical = session_data.StimLogical;
    SessionData(i).PelletLocation = median(pellet_loc);

    % remove unneeded fields
    session_data = rmfield(session_data,'Session');
    session_data = rmfield(session_data,'ReachIndexPairs');
    session_data = rmfield(session_data,'StimLogical');
    
    for j = 1 : height(indx) % j: reach event
        startInd = indx(j,1); % reach start index
        maxInd = indx(j,2); % reach max index
        endInd = indx(j,3); % reach end index

        % index only reach events
        init2max = structfun(@(x) x(startInd:maxInd), session_data, ...
            'UniformOutput', false);
        init2end = structfun(@(x) x(startInd:endInd), session_data, ...
            'UniformOutput', false);

        % mean pellet location in this reach 
        % (given confidence in the location of pellet at beginning of reach > 90 percent)
        

        % euclidean matrix of raw hand position data
        tempeuc_max =[init2max.handX_100' init2max.handY_100' init2max.handZ_100'];
        tempeuc_end =[init2end.handX_100' init2end.handY_100' init2end.handZ_100'];

        % velocity - interpolated, absolute, and raw
        [interpVel_max,absVel_max,rawVel_max] = CalculateVelocity(tempeuc_max);
        [interpVel_end,absVel_end,rawVel_end] = CalculateVelocity(tempeuc_end);

        % hand position smoothing
        smooth_euc_max = HandSmoothing(tempeuc_max);
        smooth_euc_end = HandSmoothing(tempeuc_end);

        % hand position interpolation
        [interp_hand_max] = InterpolatePosition(smooth_euc_max);
        [interp_hand_end] = InterpolatePosition(smooth_euc_end);

        % dynamic time warping (DTW)
        [DTW_euc_max,arc_length_max] = DynamicTimeWarping(smooth_euc_max);
        [DTW_euc_end,arc_length_end] = DynamicTimeWarping(smooth_euc_end);

        % DTW normalized to pellet
        DTW_norm_max = DTW_euc_max - SessionData(i).PelletLocation;
        DTW_norm_end = DTW_euc_end - SessionData(i).PelletLocation;

        % store initial to max data
        SessionData(i).InitialToMax(j).RawData = init2max; 
        SessionData(i).InitialToMax(j).RawVelocity = rawVel_max;
        SessionData(i).InitialToMax(j).InterpolatedVelocity = interpVel_max;
        SessionData(i).InitialToMax(j).AbsoluteVelocity = absVel_max;
        SessionData(i).InitialToMax(j).InterpolatedHandEuc_100 = interp_hand_max;
        SessionData(i).InitialToMax(j).DTWHandEuc = DTW_euc_max;
        SessionData(i).InitialToMax(j).HandArcLength = arc_length_max;
        SessionData(i).InitialToMax(j).DTWHandNormalized = DTW_norm_max;

        % store initial to end data
        SessionData(i).InitialToEnd(j).RawData = init2end; 
        SessionData(i).InitialToEnd(j).RawVelocity = rawVel_end;
        SessionData(i).InitialToEnd(j).InterpolatedVelocity = interpVel_end;
        SessionData(i).InitialToEnd(j).AbsoluteVelocity = absVel_end;
        SessionData(i).InitialToEnd(j).InterpolatedHandEuc_100 = interp_hand_end;
        SessionData(i).InitialToEnd(j).DTWHandEuc = DTW_euc_end;
        SessionData(i).InitialToEnd(j).HandArcLength = arc_length_end;
        SessionData(i).InitialToEnd(j).DTWHandNormalized = DTW_norm_end;
    end
end
