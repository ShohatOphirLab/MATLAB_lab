function [interactions, noInteractions, txtFileName] = computeAllMovieInteractions_new(savenames, param)
load(savenames{1});
maxNumberOfInteractions = sum([pairtrx.nframes]);
load(savenames{2});
maxNumberOfInteractions = maxNumberOfInteractions + pairtrx(1).nframes;
maxNumberOfInteractions = maxNumberOfInteractions * length(pairtrx);
interactions = repmat(-1, 1, maxNumberOfInteractions);
iInter = 1;
noInteractions = repmat(-1, 1, maxNumberOfInteractions);
iNo = 1;
spaces = repmat(-1, 1, maxNumberOfInteractions);
iSpaces = 1;
[filepath,~,~] = fileparts(savenames{1});
txtFileName = fullfile(filepath, ['Allinteraction_frame_', num2str(param.startFrame), '_to_', num2str(param.endFrame), '_gap_', num2str(param.oneInteractionThreshold), '.mat']);
interactionMatrixLength = zeros(length(savenames), length(savenames));
interactionMatrixNumber = zeros(length(savenames), length(savenames));
undirectedInteractionMatrixLength = zeros(length(savenames), length(savenames));
undirectedInteractionMatrixNumber = zeros(length(savenames), length(savenames));
interactionFrameMatrix = cell(length(savenames), length(savenames));
new_interactionFrameMatrix = cell(length(savenames), length(savenames));

for i = 1:length(savenames)
    cur = ['fly ', num2str(i)];
    disp(cur);
    for j = 1:length(savenames)
        if i ~= j
            [newInteractions, newNoInteractions, newSpaces, frames] = computeTwoFliesInteractions(j, savenames{i}, param, 'off');
            interactionMatrixLength(i, j) = sum(newInteractions) / pairtrx(1).nframes;
            interactionMatrixNumber(i, j) = length(newInteractions);
            interactionFrameMatrix{i, j} = frames;
            interactions(iInter:length(newInteractions) + iInter - 1) = newInteractions;
            iInter = length(newInteractions) + iInter;
            noInteractions(iNo:length(newNoInteractions) + iNo - 1) = newNoInteractions;
            iNo = length(newNoInteractions) + iNo;
            spaces(iSpaces:length(newSpaces) + iSpaces - 1) = newSpaces;
            iSpaces = length(newSpaces) + iSpaces;
        end
    end
end

interactions(interactions == -1) = [];
noInteractions(noInteractions == -1) = [];
spaces(spaces == -1) = [];


%% save interaction matrix according to the directed value

if (~param.directed)
    for i = 1:length(savenames)
        for  j = (i + 1) :length(savenames)
            allFrames = unique([interactionFrameMatrix{i, j}; interactionFrameMatrix{j, i}]);
            new_interactionFrameMatrix{i,j} = allFrames;
            undirectedInteractionMatrixLength(i, j) = length(allFrames) / pairtrx(1).nframes;
            undirectedInteractionMatrixLength(j, i) = length(allFrames) / pairtrx(1).nframes;
            if isempty(allFrames)
                groups = 0;
            else
                diffFrames = diff(allFrames);
                groups = length(diffFrames(diffFrames > param.oneInteractionThreshold)) + 1;
            end
            undirectedInteractionMatrixNumber(i, j) = groups;
            undirectedInteractionMatrixNumber(j, i) = groups;
        end
    end
end

save(fullfile(filepath, 'Allinteraction'), 'new_interactionFrameMatrix'); %maybe also add extension to backmean
