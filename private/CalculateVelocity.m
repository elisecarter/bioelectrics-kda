function [interp_velocity, vel_mag, vel, flag] = CalculateVelocity(euc,UI)
%calculates velocity using raw euclidean matrices

fps = 150; %CLARA 150 fps
vel = diff(euc).*fps;
vel_mag = vecnorm(vel')';
vel(:,2) = vel(:,2)*-1; %y direction flipped on tracking

if isfield(UI,'VelocityTresh')
    flag = vel_mag > velThresh; % for interpolating thru high velocity
else
    flag = zeros(height(vel_mag),1);
end

% interpolate to have 100 pts
samplePts = 1:size(vel,1);
temp = (length(samplePts)-1)/99;
queryPts = 1:temp:length(samplePts); 
interp_velocity = interp1(samplePts,vel,queryPts,'pchip');
vel_mag = interp1(samplePts,vel_mag,queryPts,'pchip')';
