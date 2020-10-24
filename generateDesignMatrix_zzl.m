% This file is to generate design matrix
% Organize both stimulus image and stimulus order information into
% BrainImageNet(BIN) structure

%% Directory setting
stimDir =  '/nfs/e1/BrainImageNet/stim';
imgDir = fullfile(stimDir,'images');
designDir = fullfile(stimDir,'designMatrix');


%% Load super class  
% read super class info
fid = fopen(fullfile(designDir,'superClassMapping.csv'));
C = textscan(fid, '%s %d %s %d','Headerlines',1, 'Delimiter',',');
fclose(fid);
classID = C{1};
superClassID = C{2}; 
superClassName = C{3}; 



%% Organize stimulus according to the super class info 
stimulus = cell(1000,80);
for i = 1:length(classID) % class loop
    imageName = dir(fullfile(imgDir,classID{i})); 
    imageName = extractfield(imageName(3:end), 'name');
    stimulus(i,:) = imageName(randperm(length(imageName)));
    imageName = [];
end


%% Load optseq of super class 
optSeqSuperClass = NaN(1000,80,3);
for s = 1:80 % session loop
    % read par from optseq
    optSeqSuperClassFile = fullfile(designDir,'ExpsessionorderTR1',...
        sprintf('BIN-static-session-%03d.csv',s));
    fid = fopen(file);
    optSeq = textscan(fid, '%d %d %d %d %s');
    fclose(fid);

    % remove null event and assemble optSeqSuperClass
    optSeq = cell2mat(optSeq(1:3));
    optSeq = optSeq(optSeq(:,2) ~= 0,:);
    d(s) = length(optSeq);
    optSeqSuperClass(:,s,:) = optSeq;
    optSeq = [];
end

%% Translate superClass optSeq to class optSeq
optSeqClass = NaN(size(optSeqSuperClass));
for s = 1:80 % session loop
    for c = 1:30 % class loop
        superClassTrial = optSeqSuperClass(:,s,2) == c-1;
        classTrial = find(superClassID == c-1);       
        optSeqClass(superClassTrial,s,2) = classTrial(randperm(length(classTrial))) ;
    end
end


%% Pack and save BIN strcture
BIN.desp = 'BrainImageNet session-level paradigm';
BIN.classID = classID;
BIN.superClassName = superClassIDName;
BIN.superClassID = superClassID;
BIN.stimulus = stimulus;
BIN.paradigmSuperClass = optSeqSuperClass;
BIN.paradigmClass = optSeqClass;

% save BIN
% save('BIN.mat', 'BIN');
