function stimSpots()

expName = 'C:\Users\User\Documents\MATLAB\acqCode\acqSoft\dpm_holo_trigs_180910.xlsx';

expS = acqGUI('checkStatus');

if ~expS.msocket.establishedHolo
    disp('setting up connection with holo PC')
    expS = acqGUI('createMSocketServer');
end

if ~expS.msocket.establishedSI
    disp('setting up connection with scanimage PC')
    expS = acqGUI('createMSocketServerSI');
end

% telling scanimage PC to request holos
%%
expS = acqGUI('sendVar','si','requestVanillaHolos');

% receiving one input from scanimage PC
%%
expS = acqGUI('receiveVar','si');
holoRequest = expS.msocket.varLoading;

%% choosing stim orders

for i=1:cycleIterations
    holoRequest.Sequence{i} = randperm(numel(holoRequest.rois));
end

%% % forwarding to holo PC

expS = acqGUI('sendVar','holo',{'genHolos',{'cycleIterations',1}});
expS = acqGUI('sendVar','holo',holoRequest);

% receiving diffraction efficiencies from holo PC
%%
expS = acqGUI('receiveVar','holo');
DE_list = expS.msocket.varLoading;
holoRequest.DE_list = DE_list;

% sending one input to scanimage PC
%%
% expS = acqGUI('sendVar','si',depths);
%%
expS.numbEp = 1; %cycleIterations;
expS.acqTime = 1*numel(DE_list);
expS.IEpStart = expS.acqTime + 1;
expS = acqGUI('copyAcq_params',expS);

acqGUI('loadExp',expName);

output = genPowerNormOutputs('holoRequest',holoRequest);

expS.output.softwareAO = 1;
expS.output.analog(:,3) = output;

expS = acqGUI('copyAcq_params',expS);

% load and/or set the relevant triggers:

%%
for i=1:LZ
    
    disp('move to a good location on the slide, and set scanimage to loop')
    result = input('press any key when ready');
    
    acqGUI('record')
end