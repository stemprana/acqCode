function tex = makingTex(thisdeg,ii,thiswidth,x,y,expP,screenP)           
            
  clear tex;%_I
      for i = 1:expP.numFrames,
             clear T G;
             phase = (i/expP.numFrames)*2*pi;
                
             angle = thisdeg*pi/180; % 30 deg orientation.
             f = (expP.cyclesPerVisDeg)/expP.PixperDeg*2*pi; % cycles/pixel
             a = cos(angle)*f;
             b = sin(angle)*f;
             g0 = exp(-((x/(expP.gf*thiswidth)).^2)-((y/(expP.gf*thiswidth)).^2));
             if streq(expP.gtype,'sine'),
                 G0 = g0.*sin(a*x+b*y+phase);
             elseif streq(expP.gtype,'box'),
                 s = sin(a*x+b*y+phase);
                 ext = max(max(max(s)),abs(min(min(s))));
                 G0=ext*((s>0)-(s<0));%.*g0;
             end
             if streq(expP.method,'symmetric'),
                 incmax = min(255-expP.Bcol,expP.Bcol);
                 G = (floor(expP.contrast*(incmax*G0)+expP.Bcol));
             elseif streq(expP.method,'cut'),
                 incmax = max(255-expP.Bcol,expP.Bcol);
                 G = (floor(expP.contrast*(incmax*G0)+expP.Bcol));
                 G = max(G,0);G = min(G,255);
             end

             T = expP.bg;
             T(expP.y0(ii):expP.y0(ii)+size(G,2)-1,expP.x0(ii):expP.x0(ii)+size(G,2)-1) = G;
             tex(i) = Screen('MakeTexture', screenP.w, T);
      end
         
end