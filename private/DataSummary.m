function DataSummary(data,handle)
% updates text on kda window showing loaded data and status

set(handle,'Style','edit','max',2,'min',0,'enable','inactive',...
    'Position',[130,75,300,280])

disp_text = cell(1,length(data));
for i = 1:length(data)
    switch data{i}.Status
        case 'Raw'
            disp_text{1,i} = sprintf('Mouse ID: %s ',data{i}.MouseID);
            disp_text{2,i} = sprintf('Number of Sessions: %d ',length(data{i}.RawData));
            disp_text{3,i} = sprintf('Status: %s ',data{i}.Status);
            disp_text{4,i} = '';

        case 'KinematicsExtracted'
            disp_text{1,i} = sprintf('Mouse ID: %s ',data{i}.MouseID);
            disp_text{2,i} = sprintf('Number of Sessions: %d ',length(data{i}.Sessions));
            disp_text{3,i} = sprintf('Status: %s ',data{i}.Status);
            disp_text{4,i} = '';
    end
end

set(handle,"String",disp_text)