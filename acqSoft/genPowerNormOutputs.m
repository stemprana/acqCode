function output = genPowerNormOutputs(varargin)

p = inputParser;
p.addParameter('pulseDuration',5); %ms
p.addParameter('stimFreq',40); % hz
p.addParameter('avgPower',0.075); % W
p.addParameter('unitLength',200); % ms
p.addParameter('startTime',500); % ms
p.addParameter('pulseNumber',5); % pulses
p.addParameter('holoRequest',[]); % pulses
p.addParameter('seqInd',1); % pulses

expS = acqGUI('checkStatus');

p.parse(varargin{:});

result = p.Results;

% load('Z:\holography\SatsumaRig\HoloRequest-DAQ\holoRequest.mat')
locations = SatsumaRigFile();
load(locations.PowerCalib,'LaserPower');
DE_list=result.holoRequest.DE_list;

Fs = expS.sampFreq*1000; % convert sampling rate to Hz from kHz
output=zeros(size(expS.output.analog,1),1);
startTime = result.startTime;
for j=1:numel(result.holoRequest.Sequence{result.seqInd});
    thisTarget=result.holoRequest.Sequence{result.seqInd}(j);
    targets=result.holoRequest.rois{thisTarget};
    PowerRequest = (result.avgPower*numel(targets))/DE_list(thisTarget);
    Volt = function_EOMVoltage(LaserPower.EOMVoltage,LaserPower.PowerOutputTF,PowerRequest);
    if isnan(Volt)
      %  errordlg('Could not set voltage picked 3 Volts')
            Volt =0;% function_EOMVoltage(LaserPower.EOMVoltage,LaserPower.PowerOutputTF,max(LaserPower.PowerOutputTF));
    end
    Q=makepulseoutputs(startTime,result.pulseNumber,result.pulseDuration,Volt,result.stimFreq,Fs,size(output,1)/Fs);
    output=output+Q;
    startTime=startTime+result.unitLength;
end
% 
% ExpStruct.StimLaserEOM=output;
% updateAOaxes();
disp('done')