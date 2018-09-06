function acqGUI(arguments)
%TrialGithub
% Assigns value to input variable 'arguments' in case it is initialized for the first time
if nargin == 0
    arguments = 'init';
end

% If GUI is already opened retrieves data
if  ~strcmp(arguments,'init')
handles = get(gcf,'UserData');
    if ~strcmp(handles{1},'main_fig')
        handles = get(handles{1},'UserData');
    end
    
guiS = handles{2};
expS = handles{3};
s0 = handles{4};

end

% Specifications of outputs
switch arguments
    
%--------------------------------------------------------------------------
% LAYOUT CREATION
%--------------------------------------------------------------------------
% If the application is opening this creates the layout
    case 'init'
        
        % Define structured variables that will contain information

        %EXPERIMENTAL INFO
        expS = struct;
        %GUI INTERACTIVE INFO
        guiS = struct;        


        %Main figure
        guiS.main_fig = figure ('NumberTitle','off','position',[150 600 1500 500]);
        % Pushbutton for starting record
        uicontrol(guiS.main_fig,'Style','pushbutton','units','normalized','String','StartRec','position',[ 0.02 0.32 0.08 0.04],'Callback','acqGUI(''record'')');
        % Saving
        uicontrol(guiS.main_fig,'Style','pushbutton','units','normalized','String','Save','position',[0.02 0.10 0.08 0.04],'Callback','acqGUI(''save'')')
        guiS.main.saveEd_h = uicontrol('Style','edit','units','normalized','Position',[0.12 0.1 0.08 0.04]);
        % Load confing 
        uicontrol(guiS.main_fig,'Style','pushbutton','units','normalized','String','loadConfig','position',[0.02 0.2 0.08 0.04],'Callback','acqGUI(''loadConfig'')')
        guiS.main.configEd_h = uicontrol('Style','edit','units','normalized','Position',[0.12 0.2 0.08 0.04]);
        % Load exp
        uicontrol(guiS.main_fig,'Style','pushbutton','units','normalized','String','loadExp','position',[0.02 0.15 0.08 0.04],'Callback','acqGUI(''loadExp'')')
        guiS.main.expEd_h = uicontrol('Style','edit','units','normalized','Position',[0.12 0.15 0.08 0.04]);
        % Load experiment - pending
        % Sampling frequency
        uicontrol('style','text','backgroundcolor',[0.8 0.8 0.8],'string','SamplingFreq','Units','normalized','position',[0.15 0.30 0.1 0.04]);
        guiS.main.sfEd_h = uicontrol('Style','edit','string',20,'units','normalized','Position',[ 0.25 0.3 0.1 0.05],'Callback','acqGUI(''setAcq_params'')');
        % Total acquisition time
        uicontrol('style','text','backgroundcolor',[0.8 0.8 0.8],'string','acqTime','Units','normalized','position',[0.36 0.30 0.1 0.04]);
        guiS.main.acqTimeEd_h = uicontrol('Style','edit','string',1,'units','normalized','Position',[ 0.46 0.3 0.1 0.05],'Callback','acqGUI(''setAcq_params'')');
        % Time between episodes
        uicontrol('style','text','backgroundcolor',[0.8 0.8 0.8],'string','timeBetweenEpisodesStart','Units','normalized','position',[0.57 0.30 0.1 0.04]);
        guiS.main.timeBEpEd_h = uicontrol('Style','edit','string',2,'units','normalized','Position',[ 0.67 0.3 0.1 0.05],'Callback','acqGUI(''setAcq_params'')');
        % Number of episodes
        uicontrol('style','text','backgroundcolor',[0.8 0.8 0.8],'string','numberOfEpisodes','Units','normalized','position',[0.78 0.30 0.1 0.04]);
        guiS.main.numbEpEd_h = uicontrol('Style','edit','string',3,'units','normalized','Position',[ 0.88 0.3 0.1 0.05],'Callback','acqGUI(''setAcq_params'')');
    
        %FIGURE PANEL FOR VISUALIZATION
        guiS.display.fig_h = figure ('NumberTitle','off','position',[150 600 1500 500]);
        %Set main figure handle as userdata
        set(guiS.display.fig_h,'UserData',{guiS.main_fig});
        %Axes creation
        guiS.display.axe_h = axes ('Position',[0.15 0.40 0.80 0.55],'FontUnits','normalized','xlimmode','manual');
        
        %FIGURE PANEL FOR DIGITAL OUTPUTS
        guiS.dig.fig_h = figure ('NumberTitle','off','position',[150 50 800 450]);
        %Set main figure handle as userdata
        set(guiS.dig.fig_h,'UserData',{guiS.main_fig});
        guiS.dig.axe_h = axes('FontUnits','normalized','Position',[0.15 0.05 0.8 0.5],'xlimmode','manual');
        % Table for digital output waveforms
        guiS.dig.tbl_h = uitable(guiS.dig.fig_h,'Data',zeros(8,4),'ColumnName',{'number','start','timeUp','timeDown'},'ColumnEditable',[true,true,true,true],'RowName',{'DO_0','DO_1','DO_2','DO_3','DO_4','DO_5','DO_6','DO_7'},'Units','normalized');
        ext_dig_t = get(guiS.dig.tbl_h,'Extent');
        set(guiS.dig.tbl_h,'Position',[0.15 0.6 ext_dig_t(3) ext_dig_t(4)]);
        % Pushbutton for updating digital outputvalues
        uicontrol(guiS.dig.fig_h,'Style','pushbutton','units','normalized','String','updateDOs','position',[ 0.75 0.75 0.12 0.08],'Callback','acqGUI(''update_DO'')');


        %FIGURE PANELS FOR ANALOG OUTPUTS
        guiS.an.fig_h = figure ('NumberTitle','off','position',[1000 200 750 300]);
        %Set main figure handle as userdata
        set(guiS.an.fig_h,'UserData',{guiS.main_fig});
        guiS.an.axe_h = axes('FontUnits','normalized','Position',[0.15 0.05 0.8 0.5],'xlimmode','manual');
        % Table for analog output waveforms
        guiS.an.tbl_h = uitable(guiS.an.fig_h,'Data',zeros(4,5),'ColumnName',{'number','start','timeUp','timeDown','amp'},'ColumnEditable',[true,true,true,true,true],'RowName',{'AO_0','AO_1','AO_2','AO_3'},'Units','normalized');
        ext_an_t = get(guiS.an.tbl_h,'Extent');
        set(guiS.an.tbl_h,'Position',[0.15 0.6 ext_an_t(3) ext_an_t(4)]);
        % Pushbutton for updating digital outputvalues
        uicontrol(guiS.an.fig_h,'Style','pushbutton','units','normalized','String','updateAOs','position',[ 0.75 0.75 0.12 0.08],'Callback','acqGUI(''update_AO'')');


        %Setup DAQ - 
        % Create session for NI acquisition
        s0 = daq.createSession('ni');

        % Create channels for input/output data - IT IS IMPORTANT THAT THE CHANNELS BE DEFINED IN THIS ORDER : ai --> then ao --> the do
        [ch_AI,idx_AI] = s0.addAnalogInputChannel('Dev1',0:1,'Voltage'); %AnalogInputs
        for i = 1: size(ch_AI,2)
           ch_AI(i).InputType = 'SingleEnded';
        end

        % Create analog outputs
        s0.addAnalogOutputChannel('Dev1',0:3,'Voltage'); %AnalogOutputs
        s0.addDigitalChannel('Dev1','Port0/Line0:7','OutputOnly'); %DigitalOutputs


        % Storing handles 
        set(0,'currentfigure',guiS.main_fig)
        handles = {'main_fig',guiS,expS,s0};
        set(gcf,'UserData',handles);





    case 'setAcq_params'
        
        % Callback function for storing values coming from main figure
        expS.sampFreq = str2num(get(guiS.main.sfEd_h,'string'));
        expS.sampleTime = 1/expS.sampFreq;
        expS.acqTime = str2num(get(guiS.main.acqTimeEd_h,'string'));
        expS.IEpStart = str2num (get(guiS.main.timeBEpEd_h,'string'));
        expS.numbEp = str2num(get(guiS.main.numbEpEd_h,'string')); 
        
        % SAVE 
        handles{3} = expS;
        set(guiS.main_fig,'UserData',handles)
        
        % Transfer changes to analog and digital output panels_ REVIEW
        acqGUI('update_DO')
        acqGUI('update_AO')

    case 'update_DO'
  
        DO_out = get(guiS.dig.tbl_h,'Data');
        axes(guiS.dig.axe_h)
        cla(guiS.dig.axe_h)
        expS.output.digital = zeros(expS.acqTime*1000/expS.sampleTime,8);

        for i = 1 : size(DO_out,1)
            expS.output.digital(:,i) = stepPulse(expS.sampleTime,expS.acqTime,DO_out(i,1),DO_out(i,2),DO_out(i,3),DO_out(i,4),1);
            plot(expS.output.digital(:,i))
            hold on
        end
        
        % SAVE
        handles{3} = expS;
        set(guiS.main_fig,'UserData',handles)
    
    case 'update_AO'
        
        AO_out = get(guiS.an.tbl_h,'Data');
        axes(guiS.an.axe_h)
        cla(guiS.an.axe_h)
        expS.output.analog = zeros(expS.acqTime*1000/expS.sampleTime,4);
        
        for i = 1:size(AO_out,1)
            expS.output.analog(:,i) = stepPulse(expS.sampleTime,expS.acqTime,AO_out(i,1),AO_out(i,2),AO_out(i,3),AO_out(i,4),AO_out(i,5));
            plot(expS.output.analog(:,i))
            hold on
        end
        
        % SAVE
        handles{3} = expS;
        set(guiS.main_fig,'UserData',handles)        
    
    case 'record'      
        
        % Set specific parameters for session
        s0.Rate = expS.sampFreq*1000;
        % Re-scale analog outputs before sending by multiclamp in mV/V pa/V
        % - Pending
        outputMat = [expS.output.analog, expS.output.digital];
        
        % Timer object to trigger sweep acquisition - Saving occurs inside
        % timer end function
        timerObj = timer('TimerFcn',{@singleAc_GUI,s0,outputMat,guiS.display.axe_h},'StartFcn',@initTimer,'StopFcn',{@endTimer,expS,guiS,handles},'TaskstoExecute', expS.numbEp, 'Period',expS.IEpStart,'ExecutionMode','fixedRate');
        start(timerObj)
    
    case 'loadConfig'
        
        [~,~,cnfgData] = xlsread(get((guiS.main.configEd_h),'String'),'B2:C3');        
        expS.input.analog.units = cnfgData{1,1};
        expS.input.analog.scale = cnfgData{1,2};
        expS.output.analog.units = cnfgData{2,1};
        expS.output.analog.scale = cnfgData{2,2};         
        
        %Set axis units
        ylabel(guiS.display.axe_h,expS.input.analog.units);
        ylabel(guiS.an.axe_h,expS.output.analog.units);
        
        
        %SAVE
        handles{3} = expS;
        set(guiS.main_fig,'UserData',handles)
        
    case 'loadExp'
        exp_AO = xlsread(get(guiS.main.expEd_h,'String'),'B3:F6'); 
        exp_DO = xlsread(get(guiS.main.expEd_h,'String'),'B10:E17');   
        set(guiS.an.tbl_h,'Data',exp_AO)
        set(guiS.dig.tbl_h,'Data',exp_DO)
        acqGUI('update_AO')
        acqGUI('update_DO')
        
    case 'save'     
       disp ('Saving data')
       save(get(guiS.main.saveEd_h,'string'),'-struct','expS') 
        
end
