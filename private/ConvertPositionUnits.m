function data = ConvertPositionUnits(data)
% converts units from pixels to mm and removes multipliers
% assumptions from CLARA: 9 pixels/mm

data.handX = data.handX_100./900; 
data.handY = data.handY_100./900; 
data.handZ = data.handZ_100./900; 

% data.pelletX = data.pelletX_100./900; %mm
% data.pelletY = data.pelletY_100./900; %mm
% data.pelletZ = data.pelletZ_100./900; %mm

%remove converted fields
data = rmfield(data,'handX_100');
data = rmfield(data,'handY_100');
data = rmfield(data,'handZ_100');
% data = rmfield(data,'pelletX_100');
% data = rmfield(data,'pelletY_100');
% data = rmfield(data,'pelletZ_100');