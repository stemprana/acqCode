function triggerScreen()
%Needs to be a function so I can further define a callback funcion

% triggerScreen:
%   _ Sets up a set of stimuli to show based on Orientation and Contrast parameters
%   _ Display them upon listening an input line from the DAQ using an extremely long session

% Set triggerMode 
%   _ 'Internal' --> Use of global timer
%   _ 'External' --> Triggered by TTL in analog input #0
triggerMode = 'External';

% Set up saving structure
savePath = 'C:\Users\slmadesnik\Documents\SilvioLocalData\';
saveName = '05Dic2018_9839_last';
saveS = struct;
saveS.stim.orientation = [];
saveS.stim.size = [];
saveS.stim.stimTimeStamp = [];
saveS.stim.duration = [];

%Visual stim section -----------------------------------------------------
% Defining input parameters----------------------
%   _for different trials whithin the experiment
trialsP.orientations = [0:45:315];%_R
trialsP.sizes = [35];%_R
%   _for this particular experiment 
%       _likely to change

expP.isi = 1;% _R %parameter only useful if we want trigger using timer
expP.DScreen = 7;%~~~~~~~!!!!!!!;    %distance of animal from screen in cm _R
expP.xposStim = 0; %_R In Dregrees, centered in 0
expP.yposStim = 0;%_R In Degrees, centered in 0
expP.result.repetitions  =  20; %_R
expP.totalTrialsN = numel(trialsP.orientations)*numel(trialsP.sizes)*expP.result.repetitions;
expP.stimduration = 1;% _R
expP.contrast  = 1; % _R
expP.VertScreenSize = 6.3;% vertical size of the screen in cm %_R
%       _unlikely to change
expP.gf = 5;%.Gaussian width factor 5: reveal all .5 normal fall off %_R
expP.result.numFrames = 300;% _R not found 
expP.Bcol = 128; % Background 0 black, 255 white  _R
expP.method = 'symmetric'; % _R
expP.gtype = 'box'; % _R
expP.cyclesPerVisDeg = .04;   % spatial frequency % _R
expP.cyclesPerSecond = 2;    % drift frequency % _R
expP.prestimtimems  =  0; % _R
expP.xRes = 1920; % _R
expP.yRes = 1080; % _R
%       _values set from pre-defined values

% Degrees of the whole vertical screen
expP.VertScreenDimDeg = atand(expP.VertScreenSize/expP.DScreen); % in visual degrees % _R not found
% Amount of pixels per each degree
expP.PixperDeg = expP.yRes/expP.VertScreenDimDeg; % _R
% expP.sizes -> size in pixels/2; x0, y0 
expP.PatchRadiusPix = ceil(trialsP.sizes.*expP.PixperDeg/2); % radius!! % _R
expP.x0 = floor(expP.xRes/2 + expP.xposStim*expP.PixperDeg - trialsP.sizes.*expP.PixperDeg/2); % _R
expP.y0 = floor(expP.yRes/2 - expP.yposStim*expP.PixperDeg - trialsP.sizes.*expP.PixperDeg/2); % _R

% Make backgorund array 
expP.bg = ones(expP.yRes,expP.xRes)*expP.Bcol;%_R


% Catch error on size
if ~isempty(find(expP.x0<1)) | ~isempty(find(expP.y0<1))
    disp('too big for the monitor, dude! try other parameters');
    return;
end
%------------------------------------------------
%Setting trials ---------------------------------
% Create array with combinations of orientations and size for each trial - 28NOV2018
[all_Orient,all_Sizes] = meshgrid(trialsP.orientations,trialsP.sizes);
combNum = numel(trialsP.orientations)*numel(trialsP.sizes);
conds = [reshape(all_Orient,[1,combNum]) ; reshape(all_Sizes,[1,combNum])];

    
%SGT_ WARNING Control condition was deleted
%------------------------------------------------- 
%Setting up the screen---------------------------- 
% 'Break and issue an eror message if the installed Psychtoolbox is not based on OpenGL or Screen() is not working properly.'
AssertOpenGL;
screens = Screen('Screens');%_L
screenNumber = max(screens);%_L
expP.result.frameRate = Screen('FrameRate',screenNumber);% _L

% numFrames -> Number of frames that consitutes one cycle
expP.numFrames = ceil(expP.result.frameRate/expP.cyclesPerSecond);%_R
% movieDurationFrames -> Total number of frames to show
expP.movieDurationFrames = round(expP.stimduration * expP.result.frameRate);%_R


%'Disable all cleverness, take noisy timestamps. This is the behaviour you’d get from any other psychophysics toolkit, as far as we know.'
Screen('Preference', 'VBLTimestampingMode', -1);
% The followin is o avoid crashing
Screen('Preference','SkipSyncTests', 0);

% Open window to how stimuli
screenP.w = Screen('OpenWindow',0);%_R
priorityLevel = MaxPriority(screenP.w);
Priority(priorityLevel);

% Gamma table
load('GammaTable.mat');
CT = (ones(3,1)*correctedTable(:,2)')'/255;% _L
Screen('LoadNormalizedGammaTable',screenP.w, CT);

%Drawing of background texture
screenP.BG = Screen('MakeTexture', screenP.w, expP.bg);%_R
Screen('DrawTexture',screenP.w, screenP.BG);
% Setting text formattin , but up to now no text is being shown
Screen('TextFont',screenP.w, 'Courier New');
Screen('TextSize',screenP.w, 14);
Screen('TextStyle', screenP.w, 1+2);
Screen('Flip',screenP.w);
%------------------------------------------------- 
% Tracking variables
t0  =  GetSecs;
trkVars.trialNum = 0;
trkVars.tmpcond = conds; %_R    
%--------------------------------------------------------------------



%Strategy: The updateScrnFnc funtion will:
%We use a nested function so that it can access the workspace 
% _ Call function to display current grating
% _ Check if we are already done or not. Address if a new repetition is starting
% _ Select randomly a condition
% _ Call function to make new grating  

%Make first basic tex
for i = 1:expP.numFrames
    tex(i) = screenP.BG;
end

    function updateScrnFnc(src,event)        
    % This function can be called from two sources:
    %   > Listener callback [triggerMode == 'External']. Continuously call this function
    %   > Timer callback [triggerMode == 'Internal']. Call this funtion in an episodic way
        if strcmp(triggerMode,'Internal') 
            boolDisp = 1;
        elseif strcmp(triggerMode,'External')
            % Detects if a transition low to high happened
            flag_t = event.Data(end);             
            boolDisp = (flag_t - flag_t_minus1) > 4;
            flag_t_minus1 = flag_t;
        end       
        
    % Actual code to execute        
        if boolDisp  
            
            disp('pulse here') 
            
            if strcmp(triggerMode,'External')
            % Output TTL to get stim start
                DaqDOut(dq,0,255);           
                DaqDOut(dq,0,0);
            end
            stimTimeStamp = clock;
            tic
            displayGrtn(tex,expP,screenP)
            stimMeasuredDur = toc;
            if strcmp(triggerMode,'External')
            % Output TTL to get stim end
                DaqDOut(dq,0,255);          
                DaqDOut(dq,0,0);
            end      
            
            % Save parameters of stimulation            
            saveS.stim.orientation = [saveS.stim.orientation, thisdeg];
            saveS.stim.size = [saveS.stim.size, thissize];
            saveS.stim.stimTimeStamp = [saveS.stim.stimTimeStamp; stimTimeStamp];
            saveS.stim.duration = [saveS.stim.duration, stimMeasuredDur];

            % Picking up random condition for each trial - Strategy at the beggining of each repetition we pass
            % a new copy of the whole conditions which ar depleted randomly
            % Pick random index from remaining conditions
            thiscondind = randi(size(trkVars.tmpcond,2));%_L
            % Select the picked condition and make it the current
            thiscond = trkVars.tmpcond(:,thiscondind);%_L
            % Delete condition from array reducing it's size
            trkVars.tmpcond(:,thiscondind)  =  [];%_L
            
            % Retrieve direction and size for this condition
            thisdeg = thiscond(1);%_I
            thissize = thiscond(2);%_L 
            
            % Retrieve index for the specific size in the array -> Usefull for retrieving:
            % Half size of grating in pixels [expP.PatchRadiusPix]
            % Initial position in screen [expP.x0, expP.y0]
            ii = find(trialsP.sizes==thissize);%_I 
            thiswidth = expP.PatchRadiusPix(ii);%_I
            [x,y] = meshgrid([-thiswidth:thiswidth],[-thiswidth:thiswidth]);%_I        
            tex = makingTex(thisdeg,ii,thiswidth,x,y,expP,screenP); 
            
            [~,~,keyCode] = KbCheck;        
            
            if keyCode(escapeKey)
                    %Functions for closing screens
                    save(strcat(savePath,saveName),'-struct','saveS')
                    Screen('CloseAll');
                    Priority(0);
                    stop(s0)                    
            end
            % Repopulate trkVars if it gets empty
            if isempty(trkVars.tmpcond)               
               trkVars.tmpcond = conds;
            end
           
            trkVars.trialNum = trkVars.trialNum + 1;    
            disp(trkVars.trialNum)    
            % Close everything when done with trials
            if (trkVars.trialNum > expP.totalTrialsN)
                %Functions for closing screens                
                save(strcat(savePath,saveName),'-struct','saveS')
                Screen('CloseAll');
                Priority(0);
                stop(s0)
            end               
          
            
        end
    end


    % EVAN SOLUTION
    %function queueData(src,event)
    %    if ~boolean
    %        src.queueOutputScans(zeros(90000,1));
    %    end
    %end





%Set escape key
escapeKey = KbName('ESC');

%Set variables to save first control grating whihc are going to be overwritten
thisdeg =-1;
thissize=-1;

if strcmp(triggerMode,'External')
    %DAQ section
    %------------------------------------------------------------
    %Flag variable to be called in successive calls of updateScrnFunc
    flag_t = 0;
    flag_t_minus1 = 0;
    %DAQ
    s0 = daq.createSession('ni');
    [ch_AI,idx_AI] = s0.addAnalogInputChannel('Dev2',0,'Voltage');
    
    %EVAN SOLUTION
    %s0.addAnalogOutputChannel('Dev2',3,'Voltage');
    %END EVAN SOLUTION
    
    s0.NotifyWhenDataAvailableExceeds = 1;
    s0.DurationInSeconds = 1500;
    %EVAN SOLUTION - DO NOT DEFINE ONE LONG SESSION - KEEP QUEING DATA
    %s0.queueOuputData(zeros(90000,1));
    %addlistener(s0,'DataRequired',@(src,event) queueData(src,event));
    %END EVAN SOLUTION
    
    %s0.IsContinuous = true;
    s0.Rate = 1000;
    lh = addlistener(s0,'DataAvailable',@(src,event) updateScrnFnc(src,event));
    
    
    %Notifying acquisition
    dq = DaqFind;
    err = DaqDConfigPort(dq,0,0);

    s0.startForeground();
   
elseif strcmp(triggerMode,'Internal')
    
    timerObj = timer('TimerFcn',@updateScrnFnc,'TaskstoExecute', 5, 'Period',expP.isi,'ExecutionMode','fixedRate');
    start(timerObj)
    
    
end
%------------------------------------------------- 

%--------------------------------------------------------------------
end