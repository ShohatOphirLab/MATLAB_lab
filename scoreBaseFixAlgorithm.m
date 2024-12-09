%% Fix all tracking errors

% Fixes all tracking errors. The algorithm do the following steps:
% Deletes observations where flies jumps outside the arena.
% Removes and connects given flies' tracks with a growing speed threshold.
% Connects the remaining flies' tracks.
function [info] = scoreBaseFixAlgorithm(info, param)
info = fixJumpEvents(info, param);
param.currentSpeedLimit = param.sameFlySpeed;
while param.currentSpeedLimit <= param.maxFlySpeed 
    changed1 = true;
    changed2 = true;
    while changed1 || changed2
        [info, changed1] = handleTracks(info, param, 'remove');
        [info, changed2] = handleTracks(info, param, 'connect');
    end
    param.currentSpeedLimit = param.currentSpeedLimit * 2;
    param.currentTimeLimit = param.currentTimeLimit * 2;
    param.currentDistanceLimit = param.currentDistanceLimit * 2;
end
info = connectRemainingTracks(info, param);
end

% Fixes all flies' jump events.
% Deletes observations of flies that "jumps" out of the arena bounds or
% "jumps" too fast according to the 'maxFlySpeed' parameter.
% If the jump is at the middle of a fly's track, fills the frames before 
% and after the jump to connect the fly's track.
function [info] = fixJumpEvents(info, param)
for i = 0:max(info.trackingData.identity)
    info = fixSameIdentityFramesGap(info, i);
    info = deleteOutOfArenaJumps(info, param, i);
    info = deleteTooFastJumps(info, param, i);
end
end

% Fixes situations when there are missing frames in the middle of a certain
% identity's track. Disconnects the track to two different identities.
function [info] = fixSameIdentityFramesGap(info, flyIdentity)
flyFrames = info.trackingData.frame(info.trackingData.identity == flyIdentity);
if isempty(flyFrames)
    return;
end
allFrames = (flyFrames(1):flyFrames(end)).';
if ~isequal(flyFrames, allFrames)
    i = 2;
    while flyFrames(i) - flyFrames(i - 1) == 1
        i = i + 1;
    end
    info.trackingData.identity(info.trackingData.identity == flyIdentity & info.trackingData.frame >= flyFrames(i)) = max(info.trackingData.identity) + 1;
end
end

% Deletes observations of flies that fly faster than 'maxFlySpeed'.
% If the jump is at the end of the fly's track, delete the jump's frames.
% If the jump is at the middle of the fly's track, fills the frames with the
% fly's approximate location according to its location before and after the jump.
function [info] = deleteTooFastJumps(info, param, flyIdentity)
flyGivenData = info.trackingData(info.trackingData.identity == flyIdentity, :);
frames = flyGivenData.frame;
xVector = flyGivenData.x_pos;
yVector = flyGivenData.y_pos;
for i = 2:length(frames)
    speed = getApproximatedSpeed(xVector(i - 1), xVector(i), yVector(i - 1), yVector(i), param.secPerFrame, param);
    if speed > param.maxFlySpeed && i <= param.maxJumpFrames && frames(1) ~= 1
        info.trackingData(info.trackingData.frame <= frames(i - 1) & info.trackingData.identity == flyIdentity, :) = [];
        info.deletedFliesPerFrame(frames(i - 1)) = info.deletedFliesPerFrame(frames(i - 1)) + 1;
    elseif speed > param.maxFlySpeed && i >= length(frames) - param.maxJumpFrames
        info.trackingData(info.trackingData.frame >= frames(i) & info.trackingData.identity == flyIdentity, :) = [];
        info.deletedFliesPerFrame(frames(i)) = info.deletedFliesPerFrame(frames(i)) + 1;
    elseif speed > param.maxFlySpeed
        nextSpeed = getApproximatedSpeed(xVector(i), xVector(i + 1), yVector(i), yVector(i + 1), param.secPerFrame, param);
        if nextSpeed > param.maxFlySpeed
            info = handleJump(info, frames(i), frames(i), flyIdentity);
        end
    end
end
end

% Finds all errors for the specified action. Finds a block of frames
% representing the same error according to the threshold.
% Do the specified action on the block of frames. The function only fixes
% blocks that has a correct frame before and after them.
% If the data has changed, counts the flies ("count" column is not fixed
% after every error to save time).
function [info, changed] = handleTracks(info, param, action)
changed = false;
errorFrames = getErrors(info, param, action);
if isempty(errorFrames)
    return;
end
firstErrorFrame = errorFrames(1);
for i = 2:length(errorFrames)
    if errorFrames(i) - errorFrames(i - 1) > param.oneErrorThreshold
        lastErrorFrame = errorFrames(i - 1);
        [info, changed] = doGivenAction(info, firstErrorFrame, lastErrorFrame, param, action, changed);
        firstErrorFrame = errorFrames(i);
    end
end
if errorFrames(end) < param.numberOfFrames
    [info, changed] = doGivenAction(info, firstErrorFrame, errorFrames(end), param, action, changed);
end
if changed
    info = countFlies(info);
end
end

% Counts the flies in the tracking data.
% The count is used to find error frames when there are more or less flies
% then the actual number of flies.
% The number of flies in each frame in the last value in the "count" column
% with the specific frame.
function [info] = countFlies(info)
count = ones(length(info.trackingData), 1);
frames = info.trackingData.frame;
countNumber = 1;
count(1) = 1;
for i = 2:length(info.trackingData)
    countNumber = countNumber + 1;
    if frames(i) > frames(i - 1)
        countNumber = 1;
    end
    count(i) = countNumber;
end
info.trackingData.count = count;
end

% Finds the frames with errors according to the given action.
% For action 'remove' finds the frames with more flies than 'numberOfFlies'.
% For action 'connect' uses 'getErrorFrames'.
function [errorFrames] = getErrors(info, param, action)
fliesPerFrame = findFliesPerFrame(info);
if strcmp(action, 'remove')
    errorFrames = find(fliesPerFrame > param.numberOfFlies, param.numberOfFrames);
else
    if abs(param.numberOfFlies - mean(fliesPerFrame)) > param.precisionRate
        errorFrames = getErrorFrames(param, fliesPerFrame);
    else
        errorFrames = find(fliesPerFrame > param.numberOfFlies | fliesPerFrame < param.numberOfFlies, param.numberOfFrames);
    end
end
end

% Finds the frames with the incorrect number of flies.
% The correct number of flies is define according to the most common number
% of flies in the nearby frames.
function [errorFrames] = getErrorFrames(param, fliesPerFrame)
errorFrames = repmat(-1, param.numberOfFrames, 1);
correctFliesNumber = find(fliesPerFrame == param.numberOfFlies, param.numberOfFrames);
currentFliesNumber = param.numberOfFlies;
i = 1;
while i <= param.numberOfFrames
    if i <= length(fliesPerFrame) && fliesPerFrame(i) == currentFliesNumber
        i = i + 1;
    else
        next = correctFliesNumber(find(correctFliesNumber > i, 1));
        if ~isempty(next) && ((next - i) * param.secPerFrame < param.disappearSecThreshold || all(fliesPerFrame(i:next) == fliesPerFrame(i)))
            errorFrames(i:next - 1) = 1;
            i = next + 1;
        else
            currentFliesNumber = fliesPerFrame(i);
            correctFliesNumber = find(fliesPerFrame == currentFliesNumber, param.numberOfFrames);
        end
    end
end
errorFrames = find(errorFrames ~= -1, param.numberOfFrames);
end

% Finds the number of flies in each frame according to the last "count"
% value for each frame in the data.
function [fliesPerFrame] = findFliesPerFrame(info)
fliesPerFrame = splitapply(@length, info.trackingData.count, findgroups(info.trackingData.frame));
end

% Sends the 'info' struct to the correct function according to the 'action'
% value. The function will try to fix the errors between the given frames.
function [info, changed] = doGivenAction(info, firstErrorFrame, lastErrorFrame, param, action, changed)
if strcmp(action, 'remove')
    [info, isChanged] = handleFliesRemoval(info, firstErrorFrame, lastErrorFrame, param);
else
    [info, isChanged] = handleFliesConnection(info, firstErrorFrame, lastErrorFrame, param);
end
if isChanged
    changed = true;
end
end

% Receives the first and last frames with extra number of flies and decides
% which fly/ies to remove. 
% A fly will be removed only if the frames with the correct number of flies
% before and after the error's frames has the same flies' identities.
function [info, changed] = handleFliesRemoval(info, firstErrorFrame, lastErrorFrame, param)
changed = false;
fliesPerFrame = findFliesPerFrame(info);
if sameFlies(info, firstErrorFrame - 1, lastErrorFrame + 1) && fliesPerFrame(firstErrorFrame - 1) == param.numberOfFlies && fliesPerFrame(lastErrorFrame + 1) == param.numberOfFlies
    allFlies = unique(info.trackingData.identity(find(info.trackingData.frame >= firstErrorFrame & info.trackingData.frame <= lastErrorFrame, length(info.trackingData))));
    falseFlies = allFlies(~ismember(allFlies, info.trackingData.identity(info.trackingData.frame == firstErrorFrame - 1)));
    framesChanged = info.trackingData.frame(ismember(info.trackingData.identity, falseFlies));
    info = updateChangesPerFrame(info, framesChanged, 'delete');
    info.trackingData(ismember(info.trackingData.identity, falseFlies), :) = [];
    changed = true;
end
end

% Checks if the two given frames has the same flies' identities.
% Returns 'true' if the frames has the same flies, and 'false' otherwise.
function [bool] = sameFlies(info, firstFrame, lastFrame)
firstData = info.trackingData(info.trackingData.frame == firstFrame, :);
lastData = info.trackingData(info.trackingData.frame == lastFrame, :);
bool = all(ismember(firstData.identity, lastData.identity)) & length(firstData) == length(lastData);
end

% Receives the first and last frames with incorrect number of flies and 
% decides which flies to connect. 
% Flies will be connected according to their score in the scores table.
function [info, changed] = handleFliesConnection(info, firstErrorFrame, lastErrorFrame, param)
changed = false;
fliesAppear = getFliesInfo(info, firstErrorFrame, lastErrorFrame, param, 'appear');
fliesDisappear = getFliesInfo(info, firstErrorFrame, lastErrorFrame, param, 'disappear');
if isempty(fliesAppear) || isempty(fliesDisappear)
    return;
end
scores = getScoresTable(info, fliesAppear, fliesDisappear, lastErrorFrame - firstErrorFrame + 1, param);
[info, changed] = connectAccordingToScores(info, scores, fliesAppear, fliesDisappear, param);
end

% Returns the flies' information according to 'type'.
% For 'appear' flies returns the first observation of every fly.
% For 'disappear' flies returns the last observation of every fly.
% The information includes all the tracking information and the fly's speed.
function [fliesInfo] = getFliesInfo(info, firstErrorFrame, lastErrorFrame, param, type)
if strcmp(type, 'appear')
    [~,ia,~] = unique(info.trackingData.identity, 'first');
    firstOccurrences = info.trackingData(ia, :);
    fliesInfo = firstOccurrences(firstOccurrences.frame >= firstErrorFrame & firstOccurrences.frame <= (lastErrorFrame + 1), :);
else
    [~,ia,~] = unique(info.trackingData.identity, 'last');
    lastOccurrences = info.trackingData(ia, :);
    fliesInfo = lastOccurrences(lastOccurrences.frame >= (firstErrorFrame - 1) & lastOccurrences.frame <= lastErrorFrame, :);
end
fliesInfo.count = [];
fliesInfo.speed = ones(size(fliesInfo, 1), 1);
for i = 1:length(fliesInfo)
    fliesInfo.speed(i) = getAverageSpeed(info, fliesInfo.identity(i), param);
end
end

% Calculates the average fly's speed.
% The fly's speed is calculated every 'secBetweenCalculations' seconds 
% and not every frame to save running time.
function [speed] = getAverageSpeed(info, identity, param)
flyGivenData = info.trackingData(info.trackingData.identity == identity, :);
speeds = repmat(-1, length(flyGivenData) - 1, 1);
xVector = flyGivenData.x_pos;
yVector = flyGivenData.y_pos;
for i = 1:round(param.secBetweenCalculations / param.secPerFrame):length(speeds)
    speeds(i) = getApproximatedSpeed(xVector(i), xVector(i + 1), yVector(i), yVector(i + 1), param.secPerFrame, param);
end
speeds(speeds == -1) = [];
speed = mean(speeds);
end

% Calculates the approximated fly's speed between the start and end points.
function [speed] = getApproximatedSpeed(startX, endX, startY, endY, time, param)
distance = sqrt(((startX - endX)^2) + ((startY - endY)^2)) * param.mmPerPixel;
speed = distance / time;
end

% Creates a table to match the flies disappear with the flies appear.
% The table contains a score for each pair of flies which is calculated
% using the 'calculateFliesScore' function. Flies with the smallest scores 
% will be higher in the table so they will be matched. 
% Flies with speed higher then 'sameFlySpeed' will not be added to the table.
function [scores] = getScoresTable(info, fliesAppear, fliesDisappear, totalErrorFrames, param)
flyDisappear = repmat(-1, length(fliesAppear) * length(fliesDisappear), 1);
flyAppear = repmat(-1, length(fliesAppear) * length(fliesDisappear), 1);
speed = repmat(-1, length(fliesAppear) * length(fliesDisappear), 1);
time = repmat(-1, length(fliesAppear) * length(fliesDisappear), 1);
distance = repmat(-1, length(fliesAppear) * length(fliesDisappear), 1);
score = repmat(-1, length(fliesAppear) * length(fliesDisappear), 1);
decisionInfo = cell(size(flyDisappear));
for i = 1:length(fliesDisappear)
    for j = 1:length(fliesAppear)
        [flyDisappearData, flyAppearData, OverlappingFrames] = getNonOverlappingData(info, fliesDisappear(i, :), fliesAppear(j, :), param);
        if OverlappingFrames == param.noOverlappingFrames
            continue;
        end
        curTime = (flyAppearData.frame - flyDisappearData.frame) * param.secPerFrame;
        curSpeed = getApproximatedSpeed(flyDisappearData.x_pos, flyAppearData.x_pos, flyDisappearData.y_pos, flyAppearData.y_pos, curTime, param);
        curDistance = curSpeed * curTime;
        if curSpeed < param.currentSpeedLimit && curTime < param.currentTimeLimit && curDistance < param.currentDistanceLimit
            index = sub2ind([length(fliesAppear), length(fliesDisappear)], j, i);
            flyDisappear(index) = flyDisappearData.identity;
            flyAppear(index) = flyAppearData.identity;
            speed(index) = curSpeed;
            score(index) = calculateFliesScore(curSpeed, flyDisappearData, flyAppearData, totalErrorFrames, OverlappingFrames, param);
            time(index) = curTime;
            distance(index) = curDistance;
            decisionInfo{index} = [abs(flyAppearData.frame - flyDisappearData.frame) - 1, totalErrorFrames, OverlappingFrames];
        end
    end
end
scores = dataset(flyDisappear, flyAppear, speed, score, time, distance, decisionInfo);
scores(scores.flyDisappear == -1, :) = [];
if ~isempty(scores)
    scores = sortrows(scores, [4 3]);
end
end

% Returns the flies' non Overlapping data.
% If the fly that appear and the fly that disappear has Overlapping frames,
% returns their data from the first and last frame they're not Overlapping.
% Overlapping frames are usually defective and reduces the algorithm performance.
function [flyDisappearData, flyAppearData, overlappingFrames] = getNonOverlappingData(info, flyDisappearData, flyAppearData, param)
overlappingFrames = 0;
disappearFrame = flyDisappearData.frame;
appearFrame = flyAppearData.frame;
if appearFrame <= disappearFrame
    overlappingFrames = disappearFrame - appearFrame + 1;
    disappearSpeed = flyDisappearData.speed;
    appearSpeed = flyAppearData.speed;
    flyDisappearData = info.trackingData(info.trackingData.frame == appearFrame - 1 & info.trackingData.identity == flyDisappearData.identity, :);
    flyAppearData = info.trackingData(info.trackingData.frame == disappearFrame + 1 & info.trackingData.identity == flyAppearData.identity, :);
    if isempty(flyDisappearData) || isempty(flyAppearData)
        overlappingFrames = param.noOverlappingFrames;
        return;
    end
    flyDisappearData.count = [];
    flyAppearData.count = [];
    flyDisappearData.speed = disappearSpeed;
    flyAppearData.speed = appearSpeed;
end
end

% Calculates a score for the given pair of flies.
% The score is calculated according to the approximated speed between the
% disappear frame and the appear frame, and the flies' known behavior.
% There are penalties for long disappearance time and frame's overlapping.
function [score] = calculateFliesScore(speed, flyDisappearData, flyAppearData, totalErrorFrames, OverlappingFrames, param)
score = speed;
% Adds a penalty if the disappear fly isn't moving in the video.
if flyDisappearData.speed < param.flyMinWalkingSpeed
   score = score * param.notWalkingPenalty;
end
% Adds a penalty if the appear fly isn't moving in the video.
if flyAppearData.speed < param.flyMinWalkingSpeed
   score = score * param.notWalkingPenalty;
end
% Adds a penalty according to the error's length.
framesBetweenFlies = abs(flyAppearData.frame - flyDisappearData.frame) - 1;
framesFraction = framesBetweenFlies / totalErrorFrames;
numberOfFramesPenalty = 1 + param.framesPenalty * framesFraction;
score = score * numberOfFramesPenalty;
% Adds a penalty according to the flies' overlapping frames' number.
OverlappingPenalty = 1 + (OverlappingFrames / param.oneErrorThreshold);
score = score * OverlappingPenalty;
end

% Connects the flies disappear with the flies appear according to the
% scores table until the table is empty.
% The pair of flies that has the lowest score will be connected first.
function [info, changed] = connectAccordingToScores(info, scores, fliesAppear, fliesDisappear, param)
changed = false;
while ~isempty(scores)
    flyDisappearData = fliesDisappear(fliesDisappear.identity == scores.flyDisappear(1), :);
    flyAppearData = fliesAppear(fliesAppear.identity == scores.flyAppear(1), :);
    info = connectFlies(info, flyDisappearData, flyAppearData, param);
    scores(scores.flyDisappear == flyDisappearData.identity, :) = [];
    scores(scores.flyAppear == flyAppearData.identity, :) = [];
    scores.flyDisappear(scores.flyDisappear == flyAppearData.identity) = flyDisappearData.identity;
    changed = true;
end
end

% Connects the given flies. Deletes the overlapping frames, changes the  
% fly appear's identity to the fly disappear's identity, and fills the  
% missing frames with the fly's approximate location.
function [info] = connectFlies(info, flyDisappearData, flyAppearData, param)
[flyDisappearData, flyAppearData, ~] = getNonOverlappingData(info, flyDisappearData, flyAppearData, param);
indexs = (info.trackingData.frame <= flyAppearData.frame & info.trackingData.identity == flyAppearData.identity) | (info.trackingData.frame >= flyDisappearData.frame & info.trackingData.identity == flyDisappearData.identity);
framesChanged = info.trackingData.frame(indexs);
if ~isempty(framesChanged)
    info = updateChangesPerFrame(info, framesChanged, 'delete');
end
info.trackingData = info.trackingData(~indexs, :);
info.trackingData.identity(info.trackingData.identity == flyAppearData.identity) = flyDisappearData.identity;
info = connectFliesPaths(info, flyDisappearData, flyAppearData);
end

% Connects all the remaining flies. Sets the 'sameFlySpeed' to a high 
% threshold and connects all the flies that disappear in the tracking data 
% with all the flies that appear according to their scores.
% Deletes all the extra flies, the flies with identity higher than the
% number of flies - 1 (correct identities are 0 - numberOfFlies-1).
function [info] = connectRemainingTracks(info, param)
changed = true;
while param.endTimeLimit < param.maxTimeLimit && param.endDistanceLimit < param.maxDistanceLimit
    while changed
        [info, changed] = handleFliesConnection(info, info.trackingData.frame(1) + 1, param.numberOfFrames - 1, param);
    end
    changed = true;
    param.endTimeLimit = param.endTimeLimit * 2;
    param.endDistanceLimit = param.endDistanceLimit * 2;
end
framesChanged = info.trackingData.frame(info.trackingData.identity >= param.numberOfFlies);
if ~isempty(framesChanged)
    info = updateChangesPerFrame(info, framesChanged, 'delete');
end
info.trackingData(info.trackingData.identity >= param.numberOfFlies, :) = [];
end