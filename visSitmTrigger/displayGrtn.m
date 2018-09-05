%UPDATED180225
function displayGrtn(tex,expP,screenP)      
%Function displayGrtn has been substantially changed from original           
            for i = 1:expP.movieDurationFrames
                Screen('DrawTexture', screenP.w, tex(expP.movieFrameIndices(i)));
                Screen('Flip', screenP.w);                
            end          
            

            Screen('DrawTexture',screenP.w,screenP.BG);
            Screen('Flip', screenP.w);
            
            %SGT_ Taking out his code solved he problem with persisteny
            %last frame
            %Screen('Close',tex(:));        


end