function DataSummary(data,window)

disp_text = cell(1,length(data));
for i = 1:length(data)
    switch data{i}.Status
        case 'Raw'
            disp_text{1,i} = sprintf('Mouse ID: %s ',data{i}.MouseID);
            disp_text{2,i} = sprintf('Status: %s ',data{i}.Status);
            disp_text{3,i} = '';

        case 'Preprocessed'
            disp_text{1,i} = sprintf('Mouse ID: %s ',data{i}.MouseID);
            disp_text{2,i} = sprintf('Status: %s ',data{i}.Status);
            disp_text{3,i} = '';
    end
end

uicontrol(window, "Style", 'text', ...
    'String', disp_text, ...
    'BackgroundColor', '#DCFFE6', ...
    'Position', [155 150 250 200]);