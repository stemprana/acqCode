function var = receiveMSocket(sock,d,options)

if nargin < 3
    options = [];
end

handshake_in = getOr(options,'handshakeIn','port0/line3');
handshake_out = getOr(options,'handshakeOut','port0/line6');

%%
[lkat,newin] = add_and_id(d,'InputOnly',handshake_in);

%%
[shoutat,newout] = add_and_id(d,'OutputOnly',handshake_out);

wait_for_up(d,lkat)

%%
go_up(d,shoutat)

%%
var = msrecv(sock);

%%
go_down(d,shoutat)

%%
wait_for_down(d,lkat)

%%
if newin
    remove_temp_channel(d,handshake_in);
end

if newout
    remove_temp_channel(d,handshake_out);
end


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