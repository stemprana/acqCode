function sendHoloRequest()
disp('requesting holograms')
ROIdata = [];
holoRequest = [];
acqGUI('sendVar','holo',ROIdata);
acqGUI('sendVar','holo',holoRequest);

disp('success')