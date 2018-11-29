function triggerScreen()
%Needs to be a function so I can further define a callback funcion

% triggerScreen:
%   _ Sets up a set of stimuli to show based on Orientation and Contrast parameters
%   _ Display them upon listening an input line from the DAQ using an extremely long session

% Set triggerMode 
%   _ 'Internal' --> Use of global timer
%   _ 'External' --> Triggered by TTL in analog input #0
triggerMode = 'External';

%Visual stim section -----------------------------------------------------
% Defining input parameters----------------------
%   _for different trials whithin the experiment
trialsP.orientations = [0,45,90];%_R
trialsP.sizes = [20];%_R
%   _for this particular experiment 
%       _likely to change

expP.isi = 1;% _R %parameter only useful if we want trigger using timer
expP.DScreen = 5;%~~~~~~~!!!!!!!;    %distance of animal from screen in cm _R
expP.xposStim = 0; %_R not found
expP.yposStim = 0;%_R not found
expP.result.repetitions  =  3; %_R
expP.stimduration = 1;% _R
expP.contrast  = 1; % _R
expP.VertScreenSize = 6.5;% vertical size of the screen in cm %_R
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
expP.VertScreenDimDeg = atand(expP.VertScreenSize/expP.DScreen); % in visual degrees % _R not found
expP.PixperDeg = expP.yRes/expP.VertScreenDimDeg; % _R
expP.PatchRadiusPix = ceil(trialsP.sizes.*expP.PixperDeg/2); % radius!! % _R
expP.x0 = floor(expP.xRes/2 + expP.xposStim*expP.PixperDeg - trialsP.sizes.*expP.PixperDeg/2); % _R
expP.y0 = floor(expP.yRes/2 - expP.yposStim*expP.PixperDeg - trialsP.sizes.*expP.PixperDeg/2); % _R
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
% movieFrameIndices 
expP.movieFrameIndices = mod(0:(expP.movieDurationFrames-1), expP.numFrames) + 1;%_R

%'Disable all cleverness, take noisy timestamps. This is the behaviour you�d get from any other psychophysics toolkit, as far as we know.'
Screen('Preference', 'VBLTimestampingMode', -1);
% The followin is o avoid crashing
Screen('Preference','SkipSyncTests', 0);

% Open window to how stimuli
screenP.w = Screen('OpenWindow',0,0,[50 50 200 200]);%_R
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
trkVars.repNum = 1;
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
            boolDisp = (event.Data(end)-event.Data(1))>4;
        end       
        
    % Actual code to execute        
        if boolDisp  
            
            disp('pulse here') 
            
            if strcmp(triggerMode,'External')
            % Output TTL to get stim start
                DaqDOut(dq,1,255);           
                DaqDOut(dq,1,0);
            end            
            tic
            displayGrtn(tex,expP,screenP)
            stimMeasuredDur = toc;
            if strcmp(triggerMode,'External')
            % Output TTL to get stim end
                DaqDOut(dq,1,255);          
                DaqDOut(dq,1,0);
            end      
            
            thiscondind = ceil(rand*size(trkVars.tmpcond,2));%_L
            thiscond = trkVars.tmpcond(:,thiscondind);%_L
            trkVars.tmpcond(:,thiscondind)  =  [];%_L
            thisdeg = thiscond(1);%_I
            thissize = thiscond(2);%_L 
            ii = find(trialsP.sizes==thissize);%_I 
            thiswidth = expP.PatchRadiusPix(ii);%_I
            [x,y] = meshgrid([-thiswidth:thiswidth],[-thiswidth:thiswidth]);%_I        
            tex = makingTex(thisdeg,ii,thiswidth,x,y,expP,screenP); 
            
            [~,~,keyCode] = KbCheck;        
            
            if keyCode(escapeKey)
                    %Functions for closing screens
                    Screen('CloseAll');
                    Priority(0);
                    stop(s0)
            end
            % Starting a new repetition - need to repopulate trkVars.tmpcond
            % and refresh current repetition
            if isempty(trkVars.tmpcond)
               disp(trkVars.repNum) 
               trkVars.tmpcond = conds;
               trkVars.repNum = trkVars.repNum + 1;
               % Close everything when done with repetitions
               if (trkVars.repNum > expP.result.repetitions)
                    %Functions for closing screens
                    Screen('CloseAll');
                    Priority(0);
                    stop(s0)
               end               
            end
            
        end
    end





%Set escape key
escapeKey = KbName('ESC');

if strcmp(triggerMode,'External')
    %DAQ section
    %------------------------------------------------------------

    %DAQ
    s0 = daq.createSession('ni');
    [ch_AI,idx_AI] = s0.addAnalogInputChannel('Dev2',0,'Voltage');
    s0.NotifyWhenDataAvailableExceeds = 50;
    s0.DurationInSeconds = 200;
    %s0.IsContinuous = true;
    s0.Rate = 20000;
    lh = addlistener(s0,'DataAvailable',@(src,event) updateScrnFnc(src,event));

    %Notifying acquisition
    dq = DaqFind;
    err = DaqDConfigPort(dq,1,0);

    s0.startForeground();
   
elseif strcmp(triggerMode,'Internal')
    
    timerObj = timer('TimerFcn',@updateScrnFnc,'TaskstoExecute', 5, 'Period',2,'ExecutionMode','fixedRate');
    start(timerObj)
    
    
end
%------------------------------------------------- 

%--------------------------------------------------------------------
end