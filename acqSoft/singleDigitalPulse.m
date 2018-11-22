function singleDigitalPulse(s0,channel)
% order is first analog, then digital. This sends a single digital pulse
% channel is 0-indexed; that is, DO_0 corresponds to 0
n_analog = 4;
n_digital = 8;
outputMat = zeros(1,n_analog+n_digital);
outputMat(n_analog+1+channel) = 1;
s0.outputSingleScan(0*outputMat);
s0.outputSingleScan(1*outputMat);
s0.outputSingleScan(0*outputMat);