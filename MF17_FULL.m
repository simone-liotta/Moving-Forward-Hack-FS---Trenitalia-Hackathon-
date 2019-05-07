%%          MOVING FORWARD HACK 2017 by TRENITALIA e CODEMOTION
%                  LUISS ENLABS, Via Marsala 29/h, Roma
%                             SIMONE LIOTTA
%
% Soluzione proposta nell'ambito della Challenge 1: CUSTOMER EXPERIENCE,
%                  'Check in, check out a bordo treno'.
% dal titolo:
%        "Check in/out a bordo treno basata su sistema di rilevamento/
%               riconoscimento facciale e geolocalizzazione"

%% CAMERA 1 (SEAT)

clc
clear all
LAT_0 = 123456;
LONG_0 = 1435677;
while (1==1)
    data=arduinoGPS;
    for h=1:(length(data)-1)
        
        LAT_CURR=double(data{1,h});
        LONG_CURR=double(data{1,h+1});
    end
    
    if (LAT_CURR == LAT_0 & LONG_CURR == LONG_0)
        
       rmdir P_01 s
       movefile('Utente_due','P_01'); 
        
    end
    
[bbox,videoFrame] = Realtime_Face_Detection;

if ~isempty(bbox)
    
    %FACE RECOGNITION
    faccia_test = imcrop(videoFrame,bbox);
    
    
    %imshow(faccia_test);
    faccia_test = rgb2gray(faccia_test);
    faccia_test = imresize(faccia_test,[128 128]);
    %faccia_test=imread(faccia_test);
    
    bool = LBP_Face_Recognition(faccia_test);
    
    cd User_Interfaces
    
    if bool==1 %predizioneLabel
        
        ui=imread('on_board.bmp');
        figure,imshow(ui)
    else
        
        er=imread('error.bmp');
        figure,imshow(er)
    end
%else
%% %% CAMERA 2 (SEAT)
%RL=1;
  %  while (RL<10)
    [bboxes,frame] = detect_camera_2;
    
    if (bool==1)  %sto seduto
        fprintf("INTRUSO! \n");
        %er=imread('error.bmp');
       % figure,imshow(er)
    else %se non sto seduto controlla se sono io
        crop=imcrop(frame,bboxes);
        faccia_test=imresize(crop,[128 128]);
        bool = LBP_Face_Recognition(faccia_test);
        if (bool==1) 
            fprintf("OK! \n");
        else
            fprintf("INTRUSO! \n");
        end
    end
   % RL=RL+1;
 %   end
else 
        bool=1;
        [bboxes,frame] = detect_camera_2;
        if (bool==1)  %sto seduto
        fprintf("INTRUSO! \n");
    else %se non sto seduto controlla se sono io
        crop=imcrop(frame,bboxes);
        faccia_test=imresize(crop,[128 128]);
        bool = LBP_Face_Recognition(faccia_test);
        if (bool==1) 
            fprintf("OK! \n");
        else
            fprintf("INTRUSO! \n");
        end
    end
end
end
