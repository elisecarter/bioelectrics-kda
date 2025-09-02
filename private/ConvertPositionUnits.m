function data = ConvertPositionUnits(data)
% converts units from pixels to mm and removes multipliers

% hand position has 100x multiplier, 9 pixels/mm
data.handX = data.handX_100/900; 
data.handY = -1*data.handY_100/900; 
data.handZ = data.handZ_100/900; 

% remove old data
data = rmfield(data,'handX_100');
data = rmfield(data,'handY_100');
data = rmfield(data,'handZ_100');