function [info] = minorChangesFixAlgorithm(info, param)
info = fixOutOfArenaJump(info, param);
info = connectObviousErrors(info, param);
fliesToIgnore = [];
relevantLastOccurrences = getRelevantFliesLastOccurrences(info, param, fliesToIgnore);
while any(relevantLastOccurrences.frame < param.numberOfFrames)
    firstFlyDisappear = relevantLastOccurrences(1, :);
    [info, fliesToIgnore] = connectFirstDisappearece(info, param, firstFlyDisappear, fliesToIgnore);
    relevantLastOccurrences = getRelevantFliesLastOccurrences(info, param, fliesToIgnore);
end
info = deleteRemainingTracks(info, param);
end

function info = fixOutOfArenaJump(info, param)
for i = 0:max(info.trackingData.identity)
    info = deleteOutOfArenaJumps(info, param, i);
end
end

function info = connectObviousErrors(info, param)
info = fixCloseErrors(info, param);
info = fixSingleErrors(info, param);
end

function info = fixCloseErrors(info, param)
allLastOccurrences = getAllLastOccurrences(info, param);
lFrames = allLastOccurrences.frame;
lX = allLastOccurrences.x_pos;
lY = allLastOccurrences.y_pos;
lIdentity = allLastOccurrences.identity;
for i = 1:length(allLastOccurrences)
    followedFirstOccurrences = getFollowedFirstOccurrences(info, param, lFrames(i), lIdentity(i));   
    distances = getDistance(lX(i), lY(i), followedFirstOccurrences.x_pos, followedFirstOccurrences.y_pos, param.mmPerPixel);
    timeCondition = followedFirstOccurrences.frame - lFrames(i) < (param.maxObviousTime / param.secPerFrame);
    distanceCondition = distances < param.minObviousDistance;
    fliesToConnect = followedFirstOccurrences(timeCondition & distanceCondition, :);
    if ~isempty(fliesToConnect)
        [info, allLastOccurrences] = handleFliesConnection(info, allLastOccurrences, allLastOccurrences(i, :), fliesToConnect(1, :));
        continue;
    end
    timeCondition = followedFirstOccurrences.frame - lFrames(i) < (param.minObviousTime / param.secPerFrame);
    distanceCondition = distances < param.maxObviousDistance;
    fliesToConnect = followedFirstOccurrences(timeCondition & distanceCondition, :);
    if ~isempty(fliesToConnect)
        [info, allLastOccurrences] = handleFliesConnection(info, allLastOccurrences, allLastOccurrences(i, :), fliesToConnect(1, :));
        continue;
    end
end
end
   
function allLastOccurrences = getAllLastOccurrences(info, param)
[~,ia,~] = unique(info.trackingData.identity, 'last');
allLastOccurrences = info.trackingData(ia, :);
allLastOccurrences = sortrows(allLastOccurrences, 7);
end

function followedFirstOccurrences = getFollowedFirstOccurrences(info, param, firstFrame, curIdentity)
[~,ia,~] = unique(info.trackingData.identity, 'first');
followedFirstOccurrences = info.trackingData(ia, :);
followedFirstOccurrences = followedFirstOccurrences(followedFirstOccurrences.frame >= firstFrame, :);
followedFirstOccurrences = followedFirstOccurrences(followedFirstOccurrences.identity ~= curIdentity, :);
if curIdentity >= 0 && curIdentity < param.numberOfFlies
    followedFirstOccurrences = followedFirstOccurrences(followedFirstOccurrences.identity >= param.numberOfFlies, :);
end
followedFirstOccurrences = sortrows(followedFirstOccurrences, 7);
end

function distances = getDistance(x1, y1, x2, y2, mmPerPixel)
distances = sqrt(((x1 - x2).^2) + ((y1 - y2).^2)) .* mmPerPixel;
end

function [info, allLastOccurrences] = handleFliesConnection(info, allLastOccurrences, flyDisappearData, flyAppearData)
indexs = (info.trackingData.frame <= flyAppearData.frame & info.trackingData.identity == flyAppearData.identity) | (info.trackingData.frame >= flyDisappearData.frame & info.trackingData.identity == flyDisappearData.identity);
info.trackingData = info.trackingData(~indexs, :);
info.trackingData.identity(info.trackingData.identity == flyAppearData.identity) = flyDisappearData.identity;
info = connectFliesPaths(info, flyDisappearData, flyAppearData);
allLastOccurrences.identity(allLastOccurrences.identity == flyAppearData.identity) = flyDisappearData.identity;
end

function info = fixSingleErrors(info, param)
allLastOccurrences = getAllLastOccurrences(info, param);
lFrames = allLastOccurrences.frame;
lX = allLastOccurrences.x_pos;
lY = allLastOccurrences.y_pos;
lIdentity = allLastOccurrences.identity;
for i = 1:length(allLastOccurrences) - 1
    followedFirstOccurrences = getFollowedFirstOccurrences(info, param, lFrames(i), lIdentity(i));
    if isempty(followedFirstOccurrences)
        break;
    end
    nextAppearance = true;
    if size(followedFirstOccurrences, 1) > 1
        nextAppearance = followedFirstOccurrences.frame(2) - lFrames(i) > param.maxErrorLength;
    end
    current = followedFirstOccurrences.frame(1) - lFrames(i) < param.maxErrorLength;
    nextDisappearance = lFrames(i + 1) - followedFirstOccurrences.frame(1) > param.maxErrorLength;
    if nextAppearance && current && nextDisappearance
        [info, allLastOccurrences] = handleFliesConnection(info, allLastOccurrences, allLastOccurrences(i, :), followedFirstOccurrences(1, :));
    end
end
followedFirstOccurrences = getFollowedFirstOccurrences(info, param, lFrames(end), lIdentity(end));
if isempty(followedFirstOccurrences)
    return;
end
nextAppearance = true;
if size(followedFirstOccurrences, 1) > 1
    nextAppearance = followedFirstOccurrences.frame(2) - lFrames(end) > param.maxErrorLength;
end
current = followedFirstOccurrences.frame(1) - lFrames(end) < param.maxErrorLength;
if nextAppearance && current 
    [info, ~] = handleFliesConnection(info, allLastOccurrences, allLastOccurrences(end, :), followedFirstOccurrences(1, :));
end
end

function relevantLastOccurrences = getRelevantFliesLastOccurrences(info, param, fliesToIgnore)
relevantLastOccurrences = getAllLastOccurrences(info, param);
relevantLastOccurrences(relevantLastOccurrences.identity >= param.numberOfFlies, :) = [];
relevantLastOccurrences(ismember(relevantLastOccurrences.identity, fliesToIgnore), :) = [];
end

function [info, fliesToIgnore] = connectFirstDisappearece(info, param, firstFlyDisappear, fliesToIgnore)
followedFirstOccurrences = getFollowedFirstOccurrences(info, param, firstFlyDisappear.frame, firstFlyDisappear.identity);
if isempty(followedFirstOccurrences)
    fliesToIgnore = [fliesToIgnore, firstFlyDisappear.identity];
    return;
end
flyToConnect = chooseFlyToConnect(info, param, firstFlyDisappear, followedFirstOccurrences);
if isempty(flyToConnect)
    fliesToIgnore = [fliesToIgnore, firstFlyDisappear.identity];
    return;
end
indexs = (info.trackingData.frame <= flyToConnect.frame & info.trackingData.identity == flyToConnect.identity) | (info.trackingData.frame >= firstFlyDisappear.frame & info.trackingData.identity == firstFlyDisappear.identity);
info.trackingData = info.trackingData(~indexs, :);
info.trackingData.identity(info.trackingData.identity == flyToConnect.identity) = firstFlyDisappear.identity;
info = connectFliesPaths(info, firstFlyDisappear, flyToConnect);
end

function flyToConnect = chooseFlyToConnect(info, param, firstFlyDisappear, followedFirstOccurrences)
speeds = getSpeed(info, param, firstFlyDisappear, followedFirstOccurrences);
followedFirstOccurrences(speeds > param.maxFlySpeed, :) = [];
if isempty(followedFirstOccurrences)
    flyToConnect = [];
else
    flyToConnect = followedFirstOccurrences(1, :);
end
end

function speeds = getSpeed(info, param, firstFlyDisappear, followedFirstOccurrences)
distances = getDistance(firstFlyDisappear.x_pos, firstFlyDisappear.y_pos, followedFirstOccurrences.x_pos, followedFirstOccurrences.y_pos, param.mmPerPixel);
times = (followedFirstOccurrences.frame - firstFlyDisappear.frame) * param.secPerFrame;
speeds = distances ./ times;
end

function info = deleteRemainingTracks(info, param)
falseFlies = info.trackingData.identity(info.trackingData.identity >= param.numberOfFlies);
framesChanged = info.trackingData.frame(ismember(info.trackingData.identity, falseFlies));
if ~isempty(framesChanged)
    info = updateChangesPerFrame(info, framesChanged, 'delete');
end
info.trackingData(ismember(info.trackingData.identity, falseFlies), :) = [];
end