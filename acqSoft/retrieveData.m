function expS = retrieveData()
    % Function used if you want to get data from running experiment
    
    handles = get(gcf,'UserData');
    if ~strcmp(handles{1},'main_fig')
        handles = get(handles{1},'UserData');
    end
    
    expS = handles{3};
end