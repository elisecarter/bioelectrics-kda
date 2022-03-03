%% FUNCTION DRAFTS

%

% function LoadDataMenu
%     if  isempty(data)
%         LoadRawData(varargin)
%     else
%         answer =  questdlg('Do you want to start a new session? Unsaved data will be lost.');
%     end
% % end

    

        for i = 1 : length(MATfiles)
            data_files.rawData(i) = load(fullfile(MATPath, MATfiles(i).name));
        end

        for i = 1 : length(CURfiles)
            data_files.CURData(i) = load(fullfile(CURPath, CURfiles(i).name));
        end

                % COMPARE NUMBERS FROM FILES TO INDEX FILES THAT MATCH
    else
        answer =  questdlg('Do you want to start a new session? Unsaved data will be lost.');
        if answer == 1
        end   

    end
end













