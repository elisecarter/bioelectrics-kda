function DataSummary(data,handle)
% updates text on kda window showing loaded data and status

set(handle,'Style','edit','max',2,'min',0,'enable','inactive',...
    'Position',[130,75,300,315])

disp_text = cell(1,length(data));
for i = 1:length(data)
    disp_text{1,i} = sprintf('Mouse ID: %s ',data{i}.MouseID);
    disp_text{2,i} = sprintf('Phase: %s ',data{i}.Phase);
    disp_text{3,i} = sprintf('Number of Sessions: %d ',length(data{i}.RawData));
    disp_text{4,i} = sprintf('Status: %s ',data{i}.Status);
    disp_text{5,i} = '';
end

set(handle,"String",disp_text)