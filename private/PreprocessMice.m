function data = PreprocessMice(data)

%temp = [data{1:end}];
%MouseIDs = {temp.MouseID};
%[~,indx] = SelectMice(MouseIDs);
newdata = data(indx);

f = waitbar(0,'Please wait...'); % create wait bar
for i = 1:length(data)
    waitstr = "Preprocessing raw data... (" + data{i}.MouseID + ")";
    waitbar(i/length(data),f,waitstr);
    data{i}.Sessions = PreprocessReachEvents(data{i}.RawData);
    % index reach max here or in PRE ?
    data{i}.Status = 'Kinematics Extracted';
end
close(f)

data = SessionLevelData(data);

%data(indx) = newdata;

ReviewFinalTrajectories(data)
