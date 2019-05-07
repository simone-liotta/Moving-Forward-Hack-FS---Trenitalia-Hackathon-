function bool = LBP_Face_Recognition(faccia_test)

cd P_01

percorso ='C:\';
fileFolder = fullfile(percorso);
dirOutput = dir(fullfile(fileFolder,'*.jpg'));
list = struct2cell((dirOutput));
test_list=cell(1,(length(dirOutput)));

n = length(dirOutput);

% Create a detector object.
faceDetector = vision.CascadeObjectDetector;

if ~isempty(dirOutput)
    %for g=1:1
    
    % test_list{1,g}=list{1,g};
    %  sample_face = Database_Face_detection(test_list);
    sample_face = imread(list{1,1});
    
    
    bboxes = step(faceDetector, sample_face);
    sample_face = imcrop(sample_face, bboxes);
    
    sample_face = rgb2gray(sample_face);
    sample_face = imresize(sample_face,[128 128]);
    % test_list{1,1}=[];
    %end
end

numNeighbors = 8;
NCelle =4; %16

finestre = [NCelle NCelle];
numCells = prod(size(sample_face))/ (prod(finestre));
numBins = numNeighbors*(numNeighbors-1)+3;
m = numCells * numBins;

features_Vect = double(zeros(n,m));



if ~isempty(dirOutput)
    
    for k=1:(length(dirOutput))
        
        test_list{1,k}=list{1,k};
        I = imread(test_list{1,k});
        
        % Detect faces.
        bboxes = step(faceDetector, I);
        data_face = imcrop(I, bboxes);
        % data_face = Database_Face_detection(test_list);
        %I = imread(data_face);
        I = rgb2gray(data_face);
        I = imresize(I,[128 128]);
        
        Feature = extractLBPFeatures(I,'CellSize',finestre);%,'Normalization','None'
        %Feature = extractLBPFeatures(I);
        features_Vect(k,:)= Feature;
    end
end

%vettore delle etichette di apprendimento [-1,+1] infatti linspace genera
%un vettore lineare casuale della lunghezza di lq_list nell'intervallo
%[-1,-1] e nell'intervallo [+1,+1] per hq_list. Ottengo cioè un vettore con
%tanti 1 quante sono le immagini HQ e tanti -1 quante sono le immagini LQ
trainI = features_Vect;
%trainL = cell(1);

%trainL =[1;-1];
if  (rem(n,2)== 0)
    trainL =[linspace(1,1,(n/2))';...
        linspace(-1,-1,(n/2))'];
else
    trainL =[linspace(1,1,round(n/2))';...
        linspace(-1,-1,(round(n/2)-1))'];
end
%trainL{1,1} = 1;
%trainL{2,1} = -1;

%calcolo infine il modello facedoil training secondo i parametri
%della libreria svm
modelL=svmtrain(trainL,trainI,'-s 0 -t 0 -b 1');

Feature_test = double(extractLBPFeatures(faccia_test,'CellSize',finestre,'Normalization','None'));
test_Label = linspace(1,1,1);
%Feature = extractLBPFeatures(I);
% test_features_Vect(k,:)= Feature_test;

[predictLabelL,accuracyLI,decision_valueL]=svmpredict(test_Label,Feature_test,modelL,'-b 1');
%applicazione per visualizzare l'esito della classificazione
if predictLabelL==1 %predizioneLabel
    bool=1;
    %ui=imread('ui.bmp');
    %imshow(ui);
else
    bool=0;
    % er=imread('error.bmp');
    %imshow(er);
end
end
