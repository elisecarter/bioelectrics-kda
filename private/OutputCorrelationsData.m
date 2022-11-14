function OutputCorrelationsData(data, OUTpath)

corr_folder = "CorrelationCoefficients";
corr_folder_path = fullfile(OUTpath,corr_folder);
if ~exist(corr_folder_path,'dir')
    mkdir(corr_folder_path)
end

for i = 1:length(data)
    filename = [data{i}.MouseID '.xlsx'];
    filepath = fullfile(corr_folder_path,filename);
    
    Session = [data{i}.Sessions.SessionID]';
    correlations = [data{i}.Sessions.Correlations];

    AllReachesToExpert = [correlations.AllReachesToExpert]';
    SuccessToExpert = [correlations.SuccessToExpert]';
    FailToExpert = [correlations.FailToExpert]';

    corr_table = table(Session,AllReachesToExpert,SuccessToExpert,FailToExpert);
    
    writetable(corr_table,filepath)

    SaveKdaFile(data{i},corr_folder_path)
end

