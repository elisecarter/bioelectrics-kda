function data = LoadRawData(data, MATpath, CURdir)
% load raw data for selected mouse from Curator and Matlab 3D folders

% go into the Curator folder for the mouse and pull out session names
mouseDir = dir(fullfile(CURdir.folder, CURdir.name));
mouseFiles = {mouseDir.name};
% use only excel file names
mouseFiles = mouseFiles(contains(mouseFiles,'.xlsx'));

% find Matlab_3D files with names matching mouse curator files and load
for i = 1 : length(mouseFiles)
fileStr = [mouseFiles{i}(1:27), '3D.mat'];
MATfiles(i) = load(fullfile(MATpath,fileStr)); % uint16 array
end

rawData = struct('pelletX_100',[],'pelletY_100',[],'pelletZ_100',[],...
    'pelletConfXY_10k',[],'pelletConfZ_10k',[],'handX_100',[],...
    'handY_100',[],'handZ_100',[],'handConfXY_10k',[],...
    'handConfZ_10k',[],'cropPts',[]);
% convert uint16 data in table3D to double, store in rawData
for i = 1 : length(MATfiles)
    for j = 1 : 10
    %rawData(i).table3D{1,j}{:,:}=double(MATfiles(i).table3D{1,j}{:,:});
    rawData(i).pelletX_100 = double(MATfiles(i).table3D{1,1}{:,:});
    rawData(i).pelletY_100 = double(MATfiles(i).table3D{1,2}{:,:});
    rawData(i).pelletZ_100 = double(MATfiles(i).table3D{1,3}{:,:});
    rawData(i).pelletConfXY_10k = double(MATfiles(i).table3D{1,4}{:,:});
    rawData(i).pelletConfZ_10k = double(MATfiles(i).table3D{1,5}{:,:});
    rawData(i).handX_100 = double(MATfiles(i).table3D{1,6}{:,:});
    rawData(i).handY_100 = double(MATfiles(i).table3D{1,7}{:,:});
    rawData(i).handZ_100 = double(MATfiles(i).table3D{1,8}{:,:});
    rawData(i).handConfXY_10k = double(MATfiles(i).table3D{1,9}{:,:});
    rawData(i).handConfZ_10k = double(MATfiles(i).table3D{1,10}{:,:});
    rawData(i).cropPts = MATfiles(i).table3D{1,11}{:,:};
    end
end

data = struct(...
    'RawData', rawData);