function [sockVis2Ephys,sockEphys2Vis] = establishMSocketEphys(d,options)

if nargin < 2
    options = [];
end

ipVis = getOr(options,'partnerIP','128.32.177.185');
inputAddress = getOr(options,'inputAddress',3000);
outputAddress = getOr(options,'outputAddress',4000);
handshake_in = getOr(options,'handshakeIn','port0/line17');
handshake_out = getOr(options,'handshakeOut','port0/line5');

% ipVis = options.partnerIP;
% inputAddress = options.inputAddress;
% outputAddress = options.outputAddress;
% handshake_in = options.handshakeIn;
% handshake_out = options.handshakeOut;

% sockVis2Ephys has address 3000, sockEphys2Vis has address 4000

% if nargin < 2
%     ipVis = '128.32.177.185';
%     inputAddress = 3000;
%     outputAddress = 4000;
% end

% %%
% handshake_in = 'port0/line17';
% handshake_out = 'port0/line5';

% d = daq.createSession('ni');

%%
[lkat,newin] = add_and_id(d,'InputOnly',handshake_in);

%%
[shoutat,newout] = add_and_id(d,'OutputOnly',handshake_out);

%%
go_down(d,shoutat)

%%
wait_for_up(d,lkat)

%%
go_up(d,shoutat)

%%
sockVis2Ephys = msconnect(ipVis,inputAddress);
disp('->Ephys socket established')
%%
go_down(d,shoutat)

%%
wait_for_down(d,lkat)

%%
go_up(d,shoutat)

%%
wait_for_up(d,lkat)

%%

% set up msocket

srvsock = mslisten(outputAddress);
sockEphys2Vis = msaccept(srvsock);
msclose(srvsock);
disp('Ephys-> socket established')

%%
wait_for_down(d,lkat)

%%
go_down(d,shoutat)

if newin
    remove_temp_channel(d,handshake_in);
end

if newout
    remove_temp_channel(d,handshake_out);
end

%%

function lkat= id_channel(d,polarity,line_name)
is_input = zeros(size(d.Channels));
for i=1:numel(is_input)
    if ~strcmp(d.Channels(i).MeasurementType,'Voltage')
        if strcmp(d.Channels(i).MeasurementType,polarity)
            is_input(i) = 1;
        end
    else
        if strcmp(polarity,'InputOnly')
            if strcmp(d.Channels(i).ID(1:2),'ai')
                is_input(i) = 1;
            end
        else
            if strcmp(d.Channels(i).ID(1:2),'ao')
                is_input(i) = 1;
            end
        end
    end
end
lkat = logical(zeros(1,sum(is_input)));
inputs = find(is_input);
for i=1:numel(inputs)
    if strcmp(d.Channels(inputs(i)).ID,line_name)
        lkat(i) = 1;
    end
end

function [lkat,new] = add_and_id(d,polarity,line_name)
new = false;
lkat = id_channel(d,polarity,line_name);
%%
if ~sum(lkat)
    new = true;
    d.addDigitalChannel('Dev1',line_name,polarity);
    lkat = id_channel(d,polarity,line_name);
end

function val = read(d,lkat)
TTLin = d.inputSingleScan;
val = TTLin(lkat);

function write(d,shoutat,val)
TTLout = zeros(size(shoutat));
TTLout(shoutat) = val;
d.outputSingleScan(TTLout)

function remove_temp_channel(d,handshake_chan)
chIDs = {d.Channels(:).ID};
for i=1:numel(chIDs)
    if strcmp(chIDs{i},handshake_chan)
        d.removeChannel(i);
    end
end

function go_up(d,shoutat)
write(d,shoutat,1)

function go_down(d,shoutat)
write(d,shoutat,0)


function wait_for_up(d,lkat)
handshook = false;
while ~handshook
    handshook = read(d,lkat);
end

function wait_for_down(d,lkat)
handshook = false;
while ~handshook
    handshook = ~read(d,lkat);
end

function result = getOr(struct,arg,default)
if isfield(struct,arg)
    result = getfield(struct,arg);
else
    result = default;
end