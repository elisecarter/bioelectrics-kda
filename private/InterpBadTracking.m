function data = InterpBadTracking(data)
% this function removes poorly tracked positional data points
% and dropped frame values (zeros) and replaces those datapoints with
% interpolated values using the pchip method

for i = 1:length(data.RawData) % iterate thru sessions
    session = data.RawData(i);

    xs = session.handX_100; %sample x vals
    ys = session.handY_100; %sample y vals
    zs = session.handZ_100; %sample z vals
    frames = 1:length(xs); %sample frames

    % hand confidence vector for this session
    conf_XY = session.handConfXY_10k./10000; %remove the multiplier
    conf_Z = session.handConfZ_10k./10000;

    lowConf_XY = (conf_XY < .9); % poorly tracked = less than 90% confident
    lowConf_Z = (conf_Z < .9);

    xq = frames; %query pts
    x_XY = frames; %sample pts for side camera
    x_Z = frames; % sample pts for front camera

    % remove poorly tracked datapoints
    x_XY(lowConf_XY) = []; 
    x_Z(lowConf_Z) = [];

    xs(lowConf_XY) = []; 
    ys(lowConf_XY) = []; 
    zs(lowConf_Z) = [];
    
    % interpolate
    xsq = interp1(x_XY,xs,xq,"pchip");
    ysq = interp1(x_XY,ys,xq,"pchip");
    zsq = interp1(x_Z,zs,xq,"pchip");
    
    % store new vectors
    data.RawData(i).handX_100 = xsq';
    data.RawData(i).handY_100 = ysq';
    data.RawData(i).handZ_100 = zsq';
end