function powerMeterVoltage = genPowerCurve(EOMvoltage,wait_ms)
d = daq.createSession('ni');
d.addAnalogOutputChannel('Dev1','ao2','Voltage');
d.addAnalogInputChannel('Dev1','ai1','Voltage');
d.Channels(2).TerminalConfig = 'SingleEnded';
d.outputSingleScan(0)
powerMeterVoltage = zeros(size(EOMvoltage));
for i=1:numel(EOMvoltage)
    d.outputSingleScan(EOMvoltage(i));
    pause(wait_ms/1000);
    powerMeterVoltage(i) = d.inputSingleScan;
    [i powerMeterVoltage(i)]
end
d.outputSingleScan(0)