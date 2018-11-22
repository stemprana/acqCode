function runXYZcalibration()

expName = 'C:\Users\User\Documents\MATLAB\acqCode\acqSoft\dpm_xyz_calib_trigs_180930.xlsx';

expS = acqGUI('checkStatus');

if ~expS.msocket.establishedHolo
    disp('set up connection with holo PC')
    expS = acqGUI('createMSocketServerHolo');
end
if ~expS.msocket.establishedSI
    disp('set up connection with scanimage PC')
    expS = acqGUI('createMSocketServerSI');
end

% receiving two inputs from holo PC
%%
expS = acqGUI('receiveVar','holo');
depths = expS.msocket.varLoading;
LZ = numel(depths);
%%
expS = acqGUI('sendVar','si',depths);
%%
expS = acqGUI('receiveVar','holo');
LP = expS.msocket.varLoading;
%%
expS = acqGUI('sendVar','si',LP);

% sending one input to scanimage PC
%%
% expS = acqGUI('sendVar','si',depths);
%%
expS.numbEp = LP;
expS.acqTime = 0.5;
expS.IEpStart = 1;
expS = acqGUI('copyAcq_params',expS);

acqGUI('loadExp',expName);

% load and/or set the relevant triggers:

counter = 1;
%%
while counter <= LZ
    
    disp('move to a good location on the slide, and set scanimage to loop')
%     result = input('press any key when ready');
    expS = acqGUI('receiveVar','si');
    result = expS.msocket.varLoading;
    
    acqGUI('record')
    
    expS = acqGUI('checkStatus');
    assert(expS.acquiring);
    
%     inp = input('after loop has completed, hit enter'); % replace this with 
    % checking acquisition status; prob save a variable related to
    % timerObj?
    done = 0;
    while ~done
        expS = acqGUI('checkStatus');
        done = ~expS.acquiring;
        pause(3);
    end
    
    expS = acqGUI('receiveVar','si');
    inp = expS.msocket.varLoading;
    
    acqGUI('pulse',3)
    
    expS = acqGUI('sendVar','holo',inp);
    
    if inp
        counter = counter+1;
    end
end