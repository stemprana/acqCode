function pulseVector = stepPulse(sampleTime,timeAcq,numb,start,timeUP,timeDOWN,amp)

numbSamples = timeAcq*1000/sampleTime;
sampleStart = start/sampleTime;
samplesUP = timeUP/sampleTime;
samplesDOWN = timeDOWN/sampleTime;
samplesTOTAL = samplesUP+samplesDOWN;

% 0/1 output vetor to be multiplied later by amplitude
pulseVector = zeros(numbSamples,1);

for i = 0:numb-1
    pulseVector(sampleStart+samplesTOTAL*i:sampleStart+samplesTOTAL*i+samplesUP) = 1;
end
% Multiply pulse vector by amplitude
pulseVector = pulseVector*amp;

end



