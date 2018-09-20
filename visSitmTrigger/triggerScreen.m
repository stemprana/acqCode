function triggerScreen()
%Needs to be a function so I can further define a callback funcion

% triggerScreen:
%   _ Sets up a set of stimuli to show based on Orientation and Contrast parameters
%   _ Display them upon listening an input line from the DAQ using an extremely long session    


%Visual stim section %-----------------------------------------------

% Defining input parameters----------------------
%   _for different trials whihin the experiment
trialsP.orientations = [0,45,90];%_R
trialsP.sizes = [20];%_R
%   _for this particular experiment 
%       _likely to change

expP.isi = 1;% _R %parameter only useful if we want trigger using timer
expP.DScreen = 5;%~~~~~~~!!!!!!!;    %distance of animal from screen in cm _R
expP.xposStim = 0; %_R not found
expP.yposStim = -8;%_R not found
expP.result.repetitions  =  2; %_R
expP.stimduration = 1;% _R
expP.contrast  = 1; % _R
expP.VertScreenSize = 6.5;% vertical size of the screen in cm %_R
%       _unlikely to change
expP.gf = 5;%.Gaussian width factor 5: reveal all .5 normal fall off %_R
%Definition of frameRate here not necessary because it is taken again from the monitor
expP.result.frameRate = 60; % _R
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

%SGT_ Erase light dimension in nConds because no light stim is going to be
%given. Changes in nConds and conds
nConds  =  [length(trialsP.orientations) length(trialsP.sizes)]; % _L
allConds  =  prod(nConds); % _L 
repPerCond  =  allConds./nConds; % _L
conds  =  [	reshape(repmat(trialsP.orientations,repPerCond(1),1)',1,allConds);
    reshape((trialsP.sizes'*ones(1,allConds/(nConds(2))))',1,allConds);];
    
%SGT_ WARNING Control condition was deleted
%------------------------------------------------- 
%Setting up the screen----------------------------
AssertOpenGL;
screens = Screen('Screens');%_L
screenNumber = max(screens);%_L
frameRate = Screen('FrameRate',screenNumber);% _L
if(frameRate == 0)  %if MacOSX does not know the frame rate the 'FrameRate' will return 0.
    frameRate = 60;
end
expP.result.frameRate  =  frameRate;%_R
%Need to define here because frameRate is not given before
expP.numFrames = ceil(expP.result.frameRate/expP.cyclesPerSecond);%_R
expP.movieDurationFrames = round(expP.stimduration * expP.result.frameRate);%_R
expP.movieFrameIndices = mod(0:(expP.movieDurationFrames-1), expP.numFrames) + 1;%_R

Screen('Preference', 'VBLTimestampingMode', -1);
Screen('Preference','SkipSyncTests', 0);
screenP.w = Screen('OpenWindow',0);%_R
priorityLevel = MaxPriority(screenP.w);
Priority(priorityLevel);

load('GammaTable.mat');
CT = (ones(3,1)*correctedTable(:,2)')'/255;% _L
Screen('LoadNormalizedGammaTable',screenP.w, CT);

%Drawing of background texture
screenP.BG = Screen('MakeTexture', screenP.w, expP.bg);%_R

Screen('DrawTexture',screenP.w, screenP.BG);
Screen('TextFont',screenP.w, 'Courier New');
Screen('TextSize',screenP.w, 14);
Screen('TextStyle', screenP.w, 1+2);
Screen('Flip',screenP.w);
%------------------------------------------------- 
% Tracking variables
t0  =  GetSecs;
trkVars.trnum = 0;
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
        
        
        if strcmp(triggerMode,'Internal') 
            boolDisp = 1;
        elseif strcmp(triggerMode,'External')
            boolDisp = (event.Data(end)-event.Data(1))>4;
        end
        %If ... "starting a new repetition"
            %trkVars.tmpcond = conds;
        if boolDisp
            
            disp('pulse here')
            
            if strcmp(triggerMode,'External')
                DaqDOut(dq,1,255);           
                DaqDOut(dq,1,0);
            end
            
            tic
            displayGrtn(tex,expP,screenP)
            toc
            if strcmp(triggerMode,'External')
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
        
             
        end
    end



triggerMode = 'Internal';

if strcmp(triggerMode,'External')
    %DAQ section
    %------------------------------------------------------------

    %DAQ
    s0 = daq.createSession('ni');
    [ch_AI,idx_AI] = s0.addAnalogInputChannel('Dev2',0,'Voltage');
    s0.NotifyWhenDataAvailableExceeds = 50;
    s0.DurationInSeconds = 600;
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
%Functions for closing screens
%Screen('CloseAll');
%Priority(0);
%--------------------------------------------------------------------
end