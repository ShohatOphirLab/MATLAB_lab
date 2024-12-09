function mergedFileName = mergeTrackingFiles(trackingFiles, movieName)
mergedFileName = getMergedFileName(movieName);
mergeMatFiles(trackingFiles, mergedFileName);
end

function [fileName] = getMergedFileName(movieName)
idx = find(ismember(movieName, './\:'), 1, 'last');
if movieName(idx) == '.'
    movieName(idx:end) = [];
end
fileName = strcat(movieName, '_merged.mat');
end

function mergeMatFiles(trackingFiles, mergedFileName)
vectors = createEmptyVectors();
ntargetsMerged = [0; 0];
addToIdentity = 0.01;
for i = 1:length(trackingFiles)
    [vectors, addToIdentity, ntargetsMerged] = updateMergedVectors(vectors, ntargetsMerged, addToIdentity, char(trackingFiles(i)));
end
merged = dataset(vectors);
merged = sortrows(merged, [7 6]);
load(char(trackingFiles(1)));
saveFile(merged, mergedFileName, timestamps, startframe, ntargetsMerged);
end

function [vectors] = createEmptyVectors()
x_posMerged = [];
y_posMerged = [];
angleMerged = [];
maj_axMerged = [];
min_axMerged = [];
identityMerged = [];
frameMerged = [];
vectors = struct('x_posMerged', x_posMerged, 'y_posMerged', y_posMerged, 'angleMerged', angleMerged, 'maj_axMerged', maj_axMerged, 'min_axMerged', min_axMerged, 'identityMerged', identityMerged, 'frameMerged', frameMerged);
end

function [vectors, addToIdentity, ntargetsMerged] = updateMergedVectors(vectors, ntargetsMerged, addToIdentity, fileName)
angle = {};
load(fileName);
vectors.x_posMerged = [vectors.x_posMerged; x_pos];
vectors.y_posMerged = [vectors.y_posMerged; y_pos];
vectors.angleMerged = [vectors.angleMerged; angle];
vectors.maj_axMerged = [vectors.maj_axMerged; maj_ax];
vectors.min_axMerged = [vectors.min_axMerged; min_ax];
[identity, addToIdentity] = changeIdentities(identity, max(identity), addToIdentity);
vectors.identityMerged = [vectors.identityMerged; identity];
frame = getFrame(ntargets, startframe + 1, length(identity));
vectors.frameMerged = [vectors.frameMerged; frame];
ntargetsMerged(end+1:numel(ntargets)) = 0;
ntargets(end+1:numel(ntargetsMerged)) = 0;
ntargetsMerged = ntargetsMerged + ntargets;
end

function [identity, addToIdentity] = changeIdentities(identity, lastIdentity, addToIdentity)
for i = 0:lastIdentity
    identity(identity == i) = i + addToIdentity;
end
addToIdentity = addToIdentity + 0.01;
end

function [frame] = getFrame(ntargets, frameNumber, lengthOfVectors)
frame = ones(lengthOfVectors, 1);
countNumber = 0;
j = 1;
for i = 1:lengthOfVectors
    countNumber = countNumber + 1;
    frame(i) = frameNumber;
    if ntargets(j) == countNumber
        frameNumber = frameNumber + 1;
        countNumber = 0;
        j = j + 1;
    end
end
end

function saveFile(merged, fileName, timestamps, startframe, ntargets)
x_pos = merged.x_posMerged;
y_pos = merged.y_posMerged;
angle = merged.angleMerged;
maj_ax = merged.maj_axMerged;
min_ax = merged.min_axMerged;
identity = merged.identityMerged;
save(fileName, 'x_pos', 'y_pos', 'angle', 'maj_ax', 'min_ax', 'identity', 'timestamps', 'startframe', 'ntargets');
end