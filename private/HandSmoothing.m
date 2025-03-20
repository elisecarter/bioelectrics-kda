function smooth_euc = HandSmoothing(euc)

x_smooth = smoothdata(euc(:,1), 'movmedian',3);
y_smooth = smoothdata(euc(:,2), 'movmedian',3);
z_smooth = smoothdata(euc(:,3), 'movmedian',5);

smooth_euc = [x_smooth y_smooth z_smooth];
