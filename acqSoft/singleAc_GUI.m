function singleAc_GUI(obj, event, s0_c,outputMat,ax_0)

data = [];
queueOutputData(s0_c,outputMat);
s0_c.NotifyWhenDataAvailableExceeds =1000;
axes(ax_0)
cla(ax_0)
xlim([0,s0_c.DurationInSeconds*s0_c.Rate])
ln = line([0,0],[0,0]);
lh = addlistener(s0_c,'DataAvailable',@updateAcq);

    function updateAcq(src,event)
        data = [data; event.Data];
        set(ln,'xdata',1:numel(data(:,1)),'ydata',data(:,1))
    end

obj.UserData = cat(3,get(obj,'UserData'),s0_c.startForeground());
delete(lh)    

end