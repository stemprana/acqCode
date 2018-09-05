function endTimer (src, event,expS,guiS,handles)
    disp('calling timer end function')
    expS.input.analog = get(src,'UserData');
    handles{3} = expS;
    set(guiS.main_fig,'UserData',handles) 
end