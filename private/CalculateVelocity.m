function [interp_velocity,abs_velocity,raw_velocity, flag] = CalculateVelocity(euc)
%calculates velocity using raw euclidean matrices

fps = 150; %CLARA 150 fps

flag = zeros(1, length(euc));
delta = zeros(height(euc),3);
delta_mag = zeros(height(euc),1);
for i = 1 : height(euc) - 1
    delta(i,:)=euc(i+1,:) - euc(i,:); %(x, y, z)
    delta_mag(i,1)=norm(delta(i,:));
end
delta(:,2) = delta(:,2)*-1; %y direction flipped on tracking

flag = (delta_mag.*fps) > 1000; % for interpolating thru high velocity

% interpolate to have 100 pts
samplePts = 1:size(delta,1);
temp = (length(samplePts)-1)/99;
queryPts = 1:temp:length(samplePts); 
interp_delta = interp1(samplePts,delta,queryPts,'pchip');
delta_mag = interp1(samplePts,delta_mag,queryPts,'pchip')';

% multiply by fps to get units of mm/sec
interp_velocity = interp_delta .* fps;
abs_velocity = delta_mag .* fps; 
raw_velocity = delta .* fps;