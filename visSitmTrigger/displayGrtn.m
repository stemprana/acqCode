%UPDATED180225
function displayGrtn(tex,expP,screenP)      
%Function displayGrtn has been substantially changed from original           
            for i = 0:(expP.movieDurationFrames-1) % expP.movieDurationFrames -> all frames to show during he whole simulation
                Screen('DrawTexture', screenP.w, tex(mod(i,expP.numFrames)+1));
                Screen('Flip', screenP.w);                
            end          
            

            Screen('DrawTexture',screenP.w,screenP.BG);
            Screen('Flip', screenP.w);
            
            %SGT_ Taking out his code solved he problem with persisteny
            %last frame
            %Screen('Close',tex(:));        


end