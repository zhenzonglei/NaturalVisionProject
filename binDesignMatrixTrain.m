% The script generates design matrix for BrainImageNet train set
% Organize both stimulus image and stimulus order information into
% BrainImageNet(BIN) structure

clc;clear;
%% Directory setting
stimDir =  'D:\fMRI\BrainImageNet\stim';
imgDir = fullfile(stimDir,'images');
designDir = fullfile(stimDir,'designMatrix');

%% Load super class  
% read super class info
fid = fopen(fullfile(designDir,'superClassMapping.csv'));
C = textscan(fid, '%s %d %s %s','Headerlines',1, 'Delimiter',',');
fclose(fid);
classID = C{1};
superClassID = C{2};
className = C{3}; 
superClassName = unique(C{4}, 'stable'); 

nClass = 1000; 
nSuperClass = 30;
nSession = 80;

%% Organize stimulus according to the super class info 
stimulus = cell(nClass,nSession);
for i = 1:length(classID) % class loop
    imageName = dir(fullfile(imgDir,classID{i})); 
    imageName = extractfield(imageName(3:end), 'name');
    stimulus(i,:) = imageName(randperm(length(imageName)));
    imageName = [];
end


%% Load optseq of super class 
optSeqSuperClass = NaN(nClass,nSession,3);% [onset, class, dur]
for s = 1:nSession % session loop
    % Read par from optseq
    optSeqSuperClassFile = fullfile(designDir,'ExpsessionorderTR1',...
        sprintf('BIN-static-session-%03d.csv',s));
    fid = fopen(optSeqSuperClassFile);
    optSeq = textscan(fid, '%d %d %d %d %s');
    fclose(fid);

    % Remove null event and assemble optSeqSuperClass
    optSeq = cell2mat(optSeq(1:3));
    optSeq = optSeq(optSeq(:,2) ~= 0,:);
    optSeqSuperClass(:,s,:) = optSeq;
    optSeq = [];
end

%% Translate superClass optSeq to class optSeq
optSeqClass = optSeqSuperClass;
for s = 1:nSession % session loop
    for c = 1:nSuperClass % class loop
        superClassTrial = (optSeqSuperClass(:,s,2) == c);
        classTrial = find(superClassID == c);       
        optSeqClass(superClassTrial,s,2) = classTrial(randperm(length(classTrial))) ;
    end
end

%% Replace optSeq timing with Kay design
nRun = 10; runDur = 476; trialDur = 4; % in seconds
kaySeq = 0:trialDur:runDur; % Trials are uniformly-spaced in time(i.e., 4s)
kaySeq(6:6:length(kaySeq)) = []; % Remove null trials(evey sixth trials)
onset = repmat(kaySeq, [1,nRun]);
for s = 1:nSession
    optSeqClass(:,s,1) = onset;
end
 
%% Pack and save BIN strcture
Train.desp = 'BrainImageNet session-level paradigm';
Train.classID = classID;
Train.superClassName = superClassName;
Train.superClassID = superClassID;
Train.stimulus = stimulus;
Train.paradigmSuperClass = optSeqSuperClass;
Train.paradigmClass = optSeqClass;

% Save BIN to design dir
save(fullfile(designDir,'BIN.mat'), 'BIN');
