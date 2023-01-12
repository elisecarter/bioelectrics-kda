function data = InterpBadTracking(data)
% this function removes poorly tracked positional data points
% and dropped frame values (zeros) and replaces those datapoints with
% interpolated values using the pchip method

for i = 1:length(data.RawData) % iterate thru sessions
    session = data.RawData(i);

    xs = session.handX_100; %sample x vals
    ys = session.handY_100; %sample y vals
    frames = 1:length(xs); %sample frames

    % hand confidence vector for this session
    conf = session.handConfXY_10k./10000; %remove the multiplier
    lowConf = find(conf<.9); % poorly tracked = less than 90% confident

    xq = frames; %query pts
    x = frames; %sample pts

    % remove poorly tracked datapoints
    x(lowConf) = []; 
    xs(lowConf) = []; 
    ys(lowConf) = []; 
    
    % interpolate
    xsq = interp1(x,xs,xq,"pchip");
    ysq = interp1(x,ys,xq,"pchip");
    
    % store new vectors
    data.RawData(i).handX_100 = xsq';
    data.RawData(i).handY_100 = ysq';
end