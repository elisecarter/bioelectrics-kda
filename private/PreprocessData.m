function  [Session] = PreprocessData(RawData)
% iterates through all reaches in each session and filters data to 
% keep only reach events, calculates interpolated position/velocity, 
% dynamic time warping of hand position, hand arc length, 
% and normalizes dynamic time warped hand data to pellet location

% NEXT STEPS: add a function to select number of interpolated pts?

% preallocate session structure
Session(length(RawData)) = struct('SessionID',[],'InitialToMax',[],...
    'InitialToEnd',[],'StimLogical',[]);

for i = 1 : length(RawData) % i: session
    sessionData = RawData(i);
    indx = table2array(sessionData.ReachIndexPairs);

    %preallocate structs to hold data indexed at reach events for each session
    init2max = struct('handX_100',[],'handY_100',[],'handZ_100',[], ...
        'handConfXY_10k',[],'handConfZ_10k',[],'pelletX_100',[], ...
        'pelletY_100',[],'pelletZ_100',[],'pelletConfXY_10k',[], ...
        'pelletConfZ_10k',[]);
    init2end = struct('handX_100',[],'handY_100',[],'handZ_100',[], ...
        'handConfXY_10k',[],'handConfZ_10k',[],'pelletX_100',[], ...
        'pelletY_100',[],'pelletZ_100',[],'pelletConfXY_10k',[], ...
        'pelletConfZ_10k',[]);

    % save session level info before deleting so we can use structfun
    Session(i).SessionID = sessionData.Session;
    Session(i).StimLogical = sessionData.StimLogical;

    % remove unneeded fields
    sessionData = rmfield(sessionData, 'Session');
    sessionData = rmfield(sessionData, 'ReachIndexPairs');
    sessionData = rmfield(sessionData, 'StimLogical');

    for j = 1 : height(indx) % j: reach event
        startInd = indx(j,1); % reach start index
        maxInd = indx(j,2); % reach max index
        endInd = indx(j,3); % reach end index

        % index only reach events
        init2max = structfun(@(x) x(startInd:maxInd), sessionData, ...
            'UniformOutput', false);
        init2end = structfun(@(x) x(startInd:endInd), sessionData, ...
            'UniformOutput', false);

        % mean pellet location in this reach 
        % (given confidence in the location of pellet > 90 percent)
        if init2max.pelletConfXY_10k(1:3) > 9000 || init2max.pelletConfZ_10k(1:3) > 9000
            pellet_loc_euc(j,:) = mean([init2max.pelletX_100',init2max.pelletY_100',init2max.pelletZ_100']);

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
        DTW_norm_max = NormalizeToPellet(DTW_euc_max, sessionData);


        %         % velocity preprocessing - initial to max (pixels/frame)
        %         for k = 1 : height(tempeuc_max) - 1
        %             absVel_max(k,1)=norm(tempeuc_max(k+1,:) - tempeuc_max(k,:));
        %             interpVel_max(k,:)=tempeuc_max(k+1,:) - tempeuc_max(k,:); %(x, y, z)
        %         end
        %
        %         interpVel_max(:,2) = interpVel_max(:,2)*-1;
        %         rawVel_max = interpVel_max;
        %         samplePts = 1:size(interpVel_max,1);
        %         temp = (length(samplePts)-1)/99;
        %         queryPts = 1:temp:length(samplePts); % interpolate to have 100 pts
        %         interpVel_max = interp1(samplePts,interpVel_max,queryPts,'pchip');
        %         absVel_max = interp1(samplePts,absVel_max,queryPts,'pchip')';
        %


        %         % velocity preprocessing - intitial to end (pixels/frame)
        %         for k = 1 : height(tempeuc_end) - 1
        %             absVel_end(k,1)=norm(tempeuc_end(k+1,:) - tempeuc_end(k,:));
        %             interpVel_end(k,:)=tempeuc_end(k+1,:) - tempeuc_end(k,:); %(x, y, z)
        %         end
        %         interpVel_end(:,2) = interpVel_end(:,2)*-1;
        %         rawVel_end = interpVel_end;
        %         samplePts = 1:size(interpVel_end,1);
        %         temp = (length(samplePts)-1)/99;
        %         queryPts = 1:temp:length(samplePts); % interpolate to have 100 pts
        %         interpVel_end = interp1(samplePts,interpVel_end,queryPts,'pchip');
        %         absVel_end = interp1(samplePts,absVel_end,queryPts,'pchip')';


        %         x_smooth_max = smoothdata(tempeuc_max(:,1), 'movmedian',3);
        %         y_smooth_max = smoothdata(tempeuc_max(:,2), 'movmedian',3);
        %         z_smooth_max = smoothdata(tempeuc_max(:,3), 'movmedian',5);
        %
        %         samplePts = 1:length(tempeuc_max(:,1));
        %         temp = (length(samplePts)-1)/99;
        %         queryPts = 1:temp:length(samplePts);
        %         interpX_max = interp1(samplePts,x_smooth,queryPts,'pchip')';
        %         interpY_max = interp1(samplePts,y_smooth,queryPts,'pchip')';
        %         interpZ_max = interp1(samplePts,z_smooth,queryPts,'pchip')';
        %         interpEuc_max = [interpX_max interpY_max interpZ_max];
        %
        %         % hand position preprocessing - initial to end
        %         x_smooth_end = smoothdata(init2end.handX_100, 'movmedian',3);
        %         y_smooth_end = smoothdata(init2end.handY_100, 'movmedian',3);
        %         z_smooth_end = smoothdata(init2end.handZ_100, 'movmedian',5);
        %
        %         samplePts = 1:length(init2end.handX_100);
        %         temp = (length(samplePts)-1)/99;
        %         queryPts = 1:temp:length(samplePts);
        %         interpX_end = interp1(samplePts,x_smooth,queryPts,'pchip')';
        %         interpY_end = interp1(samplePts,y_smooth,queryPts,'pchip')';
        %         interpZ_end = interp1(samplePts,z_smooth,queryPts,'pchip')';
        %         interpEuc_end = [interpX_end interpY_end interpZ_end];

        %data = DynamicTimeWarping(init2end)


        % store initial to max data
        Session(i).InitialToMax(j).RawData = init2max; % raw data
        Session(i).InitialToMax(j).RawVelocity = rawVel_max;
        Session(i).InitialToMax(j).InterpolatedVelocity = interpVel_max;
        Session(i).InitialToMax(j).AbsoluteVelocity = absVel_max;
        %         Session(i).InitialToMax(j).InterpolatedHandX_100 = interpX_max;
        %         Session(i).InitialToMax(j).InterpolatedHandY_100 = interpY_max;
        %         Session(i).InitialToMax(j).InterpolatedHandZ_100 = interpZ_max;
        Session(i).InitialToMax(j).InterpolatedHandEuc_100 = interp_hand_max;
        Session(i).InitialToMax(j).DTWHandEuc = DTW_euc_max;
        Session(i).InitialToMax(j).HandArcLength = arc_length_max;

        % store initial to end data
        Session(i).InitialToEnd(j).RawData = init2end; % raw data
        Session(i).InitialToEnd(j).RawVelocity = rawVel_end;
        Session(i).InitialToEnd(j).InterpolatedVelocity = interpVel_end;
        Session(i).InitialToEnd(j).AbsoluteVelocity = absVel_end;
        %         Session(i).InitialToEnd(j).InterpolatedHandX_100 = interpX_end;
        %         Session(i).InitialToEnd(j).InterpolatedHandY_100 = interpY_end;
        %         Session(i).InitialToEnd(j).InterpolatedHandZ_100 = interpZ_end;
        Session(i).InitialToEnd(j).InterpolatedHandEuc_100 = interp_hand_end;
        Session(i).InitialToEnd(j).DTWHandEuc = DTW_euc_end;
        Session(i).InitialToEnd(j).HandArcLength = arc_length_end;

    end

end
