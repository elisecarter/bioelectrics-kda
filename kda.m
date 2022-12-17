function kda
% Main function
%     Performs kinematic data analysis of mouse reach events
%     with data obtained from the CLARA system. User is required to 
%     navigate to Curator and Matlab_3D folders.
%
% Required add-ons (already included in private folder):
%     interparc by John D'Errico: https://www.mathworks.com/matlabcentral/fileexchange/34874-interparc
%     arclength by John D'Errico: https://www.mathworks.com/matlabcentral/fileexchange/34871-arclength

% Licensing
%    bioelectrics-kda 
%         MIT License
%         
%         Copyright (c) 2022 Elise Carter
%         
%         Permission is hereby granted, free of charge, to any person obtaining a copy
%         of this software and associated documentation files (the "Software"), to deal
%         in the Software without restriction, including without limitation the rights
%         to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%         copies of the Software, and to permit persons to whom the Software is
%         furnished to do so, subject to the following conditions:
%         
%         The above copyright notice and this permission notice shall be included in all
%         copies or substantial portions of the Software.
%         
%         THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%         IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%         FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%         AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%         LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%         OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%         SOFTWARE.
% 
%     arclength & interparc:
%         Copyright (c) 2012, John D'Errico
%         All rights reserved.
%         
%         Redistribution and use in source and binary forms, with or without
%         modification, are permitted provided that the following conditions are
%         met:
%         
%             * Redistributions of source code must retain the above copyright
%               notice, this list of conditions and the following disclaimer.
%             * Redistributions in binary form must reproduce the above copyright
%               notice, this list of conditions and the following disclaimer in
%               the documentation and/or other materials provided with the distribution
%         
%         THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%         AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%         IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%         ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%         LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%         CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%         SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%         INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%         CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%         ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%         POSSIBILITY OF SUCH DAMAGE.


%% Create GUI
% turn off TEX interpreter
set(0, 'DefaulttextInterpreter', 'none');

% create main window
window = figure( ...
    'Name', 'Kinematic Data Analyis', ...
    'NumberTitle', 'off', ...
    'Color', '#DCFFE6', ...
    'MenuBar', 'none', ...
    'HandleVisibility','off');
movegui(window,'center')

% text to display on window
opening_str = {'','Kinematic Data Analysis for use with CLARA', ...
    '', '', '', 'Navigate using Toolbar'};
uicontrol(window, "Style", 'text', ...
    'String', opening_str, ...
    'BackgroundColor', '#DCFFE6', ...
    'Position', [155 120 250 200]);

% file menu
menu_file = uimenu(window, 'Label', 'File');
uimenu(menu_file, 'Text', 'Load Raw Data', 'Callback', @FileLoadData)
uimenu(menu_file, 'Text', 'Load Saved Session File(s)', 'Callback', @FileLoadSavedSession)
uimenu(menu_file, 'Text', 'Save Session', 'Callback', @FileSaveSession)
uimenu(menu_file, 'Text', 'Quit', 'Callback', @FileQuit)

% analysis menu
menu_analysis = uimenu(window, 'Label', 'Analysis');
uimenu(menu_analysis, 'Text', 'Extract Kinematics', 'Callback', @AnalysisExtractKinematics)

% export menu
menu_export = uimenu(window, 'Label', 'Export');
uimenu(menu_export, 'Text', 'Session Means', 'Callback', @ExportSessionMeans)

% initialize data for nested functions
data = [];

%% File Menu

% UI navigate to dirs, UI select mice, load raw data
    function FileLoadData(varargin)
        %add to session or new session
        if  ~isempty(data)
            quest = 'Would you like to start a new session or add the the current session?';
            dlgtitle = 'New Session or Add to Session';
            btn1 = 'New Session';
            btn2 = 'Add to current session';
            defbtn = 'Add to current session';
            answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);

            if strcmpi(answer,btn1)
                data = [];
            end
        end

        % user naviagate to Matlab_3D folder
        msg1 = msgbox('Select Matlab_3D Folder');
        %if canceled then return
        uiwait(msg1)
        MATpath = uigetdir();
        if MATpath == 0
            warning('User cancelled: No Matlab_3D folder selected.')
            return
        end

        % user navigate to curator folder
        msg2 = msgbox('Select Curators Folder');
        uiwait(msg2)
        CURpath = uigetdir();
        if CURpath == 0
            warning('User cancelled: No Curator folder selected.')
            return
        end

        [mouseIDs,CURdir] = GetMouseIDs(CURpath);
        [mouseIDs,indx] = SelectMice(mouseIDs);
        CURdir = CURdir(indx);
        
        % datacount should be zero if nothing loaded
        datacount = length(data);
        
        % create data structures for mice to process
        for i = 1:length(mouseIDs)
            data{datacount+i} = struct('MouseID',mouseIDs(i));
        end
        
        data = LoadRawData(data,MATpath,CURdir);
        DataSummary(data,window)
    end

    function FileLoadSavedSession(varargin)
        %add to session or new session
        if  ~isempty(data)
            quest = 'Would you like to start a new session or add the the current session?';
            dlgtitle = 'New Session or Add to Session';
            btn1 = 'New Session';
            btn2 = 'Add to current session';
            defbtn = 'Add to current session';
            answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);

            if strcmpi(answer,btn1)
                data = [];
            end
        end

        datacount = length(data);

        %user navigate to .kda file(s)
        [file, path] = uigetfile('*.kda', 'Select Session File','MultiSelect','on');
        if ~iscell(file)
            if file == 0
                warning('User cancelled: No session folder selected.')
                return
            end
            datacount = datacount+1;
            data{datacount} = load(fullfile(path,file),'-mat');
        elseif iscell(file)
            for i = 1:length(file)
                datacount = datacount+1;
                data{datacount} = load(fullfile(path,file{i}),'-mat');
            end
        end

        DataSummary(data,window)
    end

    function FileSaveSession(varargin)
        if isempty(data)
            err1 = msgbox('No data to save.');
            uiwait(err1)
            return
        end

        % save data as .kda file (.mat file)
        path = uigetdir();
        if path == 0
            warning('User cancelled: No output folder selected.')
            return
        end

        for i = 1:length(data)
            SaveKdaFile(data{i},path)
        end
    end

    function FileQuit(varargin)
        close ('all','hidden')
    end

%% Analysis Menu
    function AnalysisExtractKinematics(varargin)
        % check that mice are loaded and have correct status
        if isempty(data)
            err1 = msgbox(['No data to process. Please load raw ' ...
                'data before extracting kinematics.']);
            uiwait(err1)
            return
        elseif any(cellfun(@(x) ~strcmp(x.Status,'Raw'), data))
            err2 = msgbox(['Data does not have correct status. ' ...
                'Please load raw data before extracting kinematics.']);
            uiwait(err2)
            return
        end
        % user navigate to output directory
        msg3 = msgbox('Navigate to Output Directory');
        uiwait(msg3)
        OUTpath = uigetdir();
        if OUTpath == 0
            warning('User cancelled: No output folder selected.')
            return
        end
        
        user_selections = UserSelections('ExtractKinematics');
        data = PreprocessMice(data);
        DataSummary(data,window)
        OutputData(data, OUTpath,user_selections)
    end

%% Export Menu
    function ExportSessionMeans(varargin)
        % check that mice are loaded and have correct status
        if isempty(data)
            err1 = msgbox(['No data to process. Please load data with ' ...
                'kinematics extracted before exporting session means.']);
            uiwait(err1)
            return
        elseif any(cellfun(@(x) ~strcmp(x.Status,'KinematicsExtracted'),data))
            err2 = msgbox(['Data does not have correct status. ' ...
                'Please extract kinematics before exporting session means.']);
            uiwait(err2)
            return
        end

        % user navigate to output directory
        msg4 = msgbox('Navigate to Output Directory');
        uiwait(msg4)
        OUTpath = uigetdir();
        if OUTpath == 0
            warning('User cancelled: No output folder selected.')
            return
        end

        quest = 'Would you like to group by cohort?';
        dlgtitle = 'Group Option';
        btn1 = 'Yes';
        btn2 = 'No';
        defbtn = 'Yes';
        answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);
        
        % ui select mice to group
        if strcmpi(answer,btn1)
            % user input number of cohorts
            prompt = {'Enter the number of cohorts:'};
            dlgtitle = 'Number of Cohorts';
            dims = [1 35];
            definput = {'2'};
            num_cohorts = str2double(inputdlg(prompt,dlgtitle,dims,definput));
            [cohort, cohortID] = SelectCohorts(data,num_cohorts);  

        elseif strcmpi(answer,btn2)
            % single cohort
            cohort{1} = data;
            % name cohort
            prompt = sprintf('Enter the identifier for cohort 1');
            dlgtitle = 'Input Cohort Name';
            dims = [1 35];
            definput = {''};
            cohortID{1} = inputdlg(prompt,dlgtitle,dims,definput);
        end
        
        OutputSessionMeans(cohort,cohortID,OUTpath)

    end

end
