function data = PreprocessMice(data)

temp = [data{1:end}];
MouseIDs = {temp.MouseID};
[~,indx] = SelectMice(MouseIDs);
newdata = data(indx);

f = waitbar(0,'Please wait...'); % create wait bar
for i = 1:length(newdata)
    waitstr = "Preprocessing raw data... (" + newdata{i}.MouseID + ")";
    waitbar(i/length(newdata),f,waitstr);
    newdata{i}.Sessions = PreprocessReachEvents(newdata{i}.RawData);
    newdata{i}.Status = 'Kinematics Extracted';
end
close(f)

data(indx) = newdata;

ReviewFinalTrajectories(data)
