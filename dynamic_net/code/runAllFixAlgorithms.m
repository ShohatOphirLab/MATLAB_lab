%% Run all fix errors algotithms.

% Runs the fix errors algorithm.
% The algorithm receives CTRAX's tracking output, and removes\connects
% flies identities to generate a consistent tracking information.
% The tracking information is saved in a .mat file with the same format as
% the CTRAX's tracking output.
function [numberOfFrames] = runAllFixAlgorithms(paramFile)
load(paramFile);
param = getParameters(param, mmPerPixel, userFliesData, arenasPos, arenasType); %#ok<*NODEF>
[givenData, param, timestamps, startFrame] = createWorkingDatabase(fileName, param);
info = getWorkingInformation(givenData, userFliesData, param);
info = chooseBestAlgorithm(info, param);
[info, param] = handleEndAccuracy(info, param, showOptions);
changesGraph = generateChangesGraph(info, param, fileName);
generateMatFile(info, param, timestamps, startFrame, fixedFileName, changesGraph);
numberOfFrames = param.numberOfFrames;
end

%% Parameters values.

% Creates a struct with all the needed parameters.
function [param] = getParameters(param, mmPerPixel, userFliesData, arenasPos, arenasType)
param.currentSpeedLimit = param.sameFlySpeed;
param.mmPerPixel = mmPerPixel;
param.numberOfFlies = length(userFliesData);
param.arenasPos = arenasPos;
param.arenasType = arenasType;
end

%% Get the information needed to start fixing.

% Creates a struct with all the needed working information.
% The struct contains vectors with the number of flies removed and added in
% each frame that will be updated in the algorithm, and the tracking data 
% after matching the start identities with the given start identities which 
% were marked by the user.
function [info] = getWorkingInformation(givenData, userFliesData, param)
info = struct();
info.trackingData = givenData;
info.addedFliesPerFrame = zeros(param.numberOfFrames, 1);
info.deletedFliesPerFrame = zeros(param.numberOfFrames, 1);
info = fixStartIdentities(info, param, userFliesData);
[accuracy, ~] = calculateAccuracy(info, param);
info.startAccuracy = accuracy;
end

% Fixes the first frame's identities. Receives the location of all the 
% first frame's flies from the user and matches them to the tracking data.
% If the first frame has extra flies, they will be deleted from the data.
% If there are missing user's flies, they will be added to the first frame.
function [info] = fixStartIdentities(info, param, userFliesData)
maxIdentity = max(info.trackingData.identity);
addToIdentity = (info.trackingData.identity < param.numberOfFlies) * (maxIdentity + 1);
info.trackingData.identity = info.trackingData.identity + addToIdentity;
userFliesData.identity = (0:param.numberOfFlies - 1).';
firstFrameFlies = info.trackingData(info.trackingData.frame == info.trackingData.frame(1), :);
match = getMatchTable(userFliesData, firstFrameFlies, param);
info = matchFlies(info, match);
info = deleteExtraFlies(info, param);
info = addMissingFlies(info, userFliesData);
info.trackingData = sortrows(info.trackingData, [7 6]);
info = countFlies(info);
end

% Creates a table to match the user's flies with the tracking data.
% Flies with the smallest distance will be higher in the table so they will
% be matched. Flies with distance higher then 'flyMaxLength' will not be 
% added to the table.
function [match] = getMatchTable(userFliesData, firstFrameFlies, param)
userFly = repmat(-1, length(userFliesData) * length(firstFrameFlies), 1);
firstFrameFly = repmat(-1, length(userFliesData) * length(firstFrameFlies), 1);
distance = repmat(-1, length(userFliesData) * length(firstFrameFlies), 1);
match = dataset(userFly, firstFrameFly, distance);
for i = 1:length(userFliesData)
    for j = 1:length(firstFrameFlies)
        index = sub2ind([length(firstFrameFlies), length(userFliesData)], j, i);
        startX = userFliesData.x_pos(i);
        startY = userFliesData.y_pos(i);
        endX = firstFrameFlies.x_pos(j);
        endY = firstFrameFlies.y_pos(j);
        distance = sqrt(((startX - endX)^2) + ((startY - endY)^2)) * param.mmPerPixel;
        if distance <= param.flyMaxLength
            match.userFly(index) = userFliesData.identity(i);
            match.firstFrameFly(index) = firstFrameFlies.identity(j);
            match.distance(index) = distance;
        end
    end
end
match(match.userFly == -1, :) = [];
if ~isempty(match)
    match = sortrows(match, 3);
end
end

% Matches the flies according to the 'match' table.
% Changes the tracking data's fly's identity to the user's fly's identity.
function [info] = matchFlies(info, match)
while ~isempty(match)
    currentUserFly = match.userFly(1);
    currentFirstFrameFly = match.firstFrameFly(1);
    info.trackingData.identity(info.trackingData.identity == currentFirstFrameFly) = currentUserFly;
    match(match.firstFrameFly == currentFirstFrameFly, :) = [];
    match(match.userFly == currentUserFly, :) = [];
end
end

% Deletes the first frame's flies that were not matched to the user's flies.
% Updates the changes vector with the number of flies deleted from each frame.
function [info] = deleteExtraFlies(info, param)
falseFlies = info.trackingData.identity(info.trackingData.frame == info.trackingData.frame(1) & info.trackingData.identity >= param.numberOfFlies);
framesChanged = info.trackingData.frame(ismember(info.trackingData.identity, falseFlies));
if ~isempty(framesChanged)
    info = updateChangesPerFrame(info, framesChanged, 'delete');
end
info.trackingData(ismember(info.trackingData.identity, falseFlies), :) = [];
end

% Adds the user's flies that were not matched to the first frame's flies.
% Updates the changes vector with the number of flies added to the frame.
function [info] = addMissingFlies(info, userFliesData)
missingFlies = userFliesData.identity(~ismember(userFliesData.identity, info.trackingData.identity));
if ~isempty(missingFlies)
    x_pos = userFliesData.x_pos(ismember(userFliesData.identity, missingFlies));
    y_pos = userFliesData.y_pos(ismember(userFliesData.identity, missingFlies));
    angle = zeros(length(x_pos), 1);
    avgMaj = mean(info.trackingData.maj_ax(info.trackingData.frame == info.trackingData.frame(1)));
    avgMin = mean(info.trackingData.min_ax(info.trackingData.frame == info.trackingData.frame(1)));
    maj_ax = repmat(avgMaj, length(x_pos), 1);
    min_ax = repmat(avgMin, length(x_pos), 1);
    identity = missingFlies;
    frame = repmat(info.trackingData.frame(1), length(x_pos), 1);
    count = zeros(length(x_pos), 1);
    newData = dataset(x_pos, y_pos, angle, maj_ax, min_ax, identity, frame, count);
    info.trackingData = [info.trackingData ; newData];
    info = updateChangesPerFrame(info, frame, 'add');
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

% Calculates the tracking data's accuracy percent.
% Identities larger than 'numberOfFlies' - 1 is deleted (only the start
% identities will be taken into account when calculating the accuracy percent).
% The accuracy is calculated according to the number of missing flies in each frame. 
function [accuracy, lastOccurrences] = calculateAccuracy(info, param)
info.trackingData(info.trackingData.identity >= param.numberOfFlies, :) = [];
[~,ia,~] = unique(info.trackingData.identity, 'last');
lastOccurrences = info.trackingData(ia, :);
errors = param.numberOfFrames * param.numberOfFlies - sum(lastOccurrences.frame);
accuracy = 100 - (errors * 100) / (param.numberOfFrames * param.numberOfFlies);
end

%% Choose the best algorithm to fix current file

function [resultInfo] = chooseBestAlgorithm(info, param)
if param.runScoreBaseAlgorithm
    scoreBaseInfo = scoreBaseFixAlgorithm(info, param);
    scoreBaseChanges = sum(scoreBaseInfo.deletedFliesPerFrame) + sum(scoreBaseInfo.addedFliesPerFrame);
    resultInfo = scoreBaseInfo;
end
if param.runMinorChangesAlgorithm
    minorChangesInfo = minorChangesFixAlgorithm(info, param);
    minorChangesChanges = sum(minorChangesInfo.deletedFliesPerFrame) + sum(minorChangesInfo.addedFliesPerFrame);
    resultInfo = minorChangesInfo;
end
if param.runScoreBaseAlgorithm && param.runMinorChangesAlgorithm 
    if scoreBaseChanges < minorChangesChanges
        resultInfo = scoreBaseInfo;
    else
        resultInfo = minorChangesInfo;
    end
end
end

%% Handle tracking accuracy after fixing.

% Calculates the tracking data's accuracy percent after fixing the errors.
% If the accuracy percent is lower than 100, display a list dialog with 
% options for the user to decide what to do with the incomplete data.
function [info, param] = handleEndAccuracy(info, param, showOptions)
[accuracy, lastOccurrences] = calculateAccuracy(info, param);
[info, param] = uniteGaps(info, param);
info.endAccuracy = accuracy;
message = strcat('Tracking is', {' '}, num2str(accuracy), '% complete.');
if accuracy < 100
    if strcmp(showOptions, 'on')
        [options, recommendedOption] = getOptions(param, lastOccurrences);
        message = strcat(message, ' Decide what to do:');
        [Selection, ~] = listdlg('SelectionMode', 'single', 'PromptString', message, 'ListString', options, 'ListSize', [300, 130], 'Name', 'Performances', 'CancelString', 'Do as recommended');
        if isempty(Selection)
            Selection(1) = recommendedOption;
        end
        if Selection(1) == 1
            info = deleteIncorrectFrames(info, min(lastOccurrences.frame));
        elseif Selection(1) == 2
            [info, param] = deleteFliesTracks(info, param, lastOccurrences);
        else
            info = addMissingFrames(info, param);
        end
    else
        info = addMissingFrames(info, param);
    end
end
end

function [info, param] = uniteGaps(info, param)
for flyIdentity = 0:max(info.trackingData.identity)
    flyFrames = info.trackingData.frame(info.trackingData.identity == flyIdentity);
    if isempty(flyFrames)
        return;
    end
    allFrames = (flyFrames(1):flyFrames(end)).';
    
    if ~isequal(flyFrames, allFrames)
        missingFrames = setdiff(allFrames, flyFrames);
        [info, param] = addGapFrames(info, param, missingFrames, flyIdentity);
    end
end
end

function [info, param] = addGapFrames(info, param, missingFrames, flyIdentity)
firstErrorFrame = missingFrames(1);
for i = 2:length(missingFrames)
    if missingFrames(i) - missingFrames(i - 1) > 1
        lastErrorFrame = missingFrames(i - 1);
        flyDisappearData = info.trackingData(info.trackingData.frame == firstErrorFrame - 1 & info.trackingData.identity == flyIdentity, :);
        flyAppearData = info.trackingData(info.trackingData.frame == lastErrorFrame + 1 & info.trackingData.identity == flyIdentity, :);
        info.trackingData(info.trackingData.identity == flyIdentity & (info.trackingData.frame == firstErrorFrame - 1 | info.trackingData.frame == lastErrorFrame + 1), :) = [];
        [info] = connectFliesPaths(info, flyDisappearData, flyAppearData);
        firstErrorFrame = missingFrames(i);
    end
end
if missingFrames(end) < param.numberOfFrames
    flyDisappearData = info.trackingData(info.trackingData.frame == firstErrorFrame - 1 & info.trackingData.identity == flyIdentity, :);
    flyAppearData = info.trackingData(info.trackingData.frame == missingFrames(end) + 1 & info.trackingData.identity == flyIdentity, :);
    info.trackingData(info.trackingData.identity == flyIdentity & (info.trackingData.frame == firstErrorFrame - 1 | info.trackingData.frame == missingFrames(end) + 1), :) = [];
    [info] = connectFliesPaths(info, flyDisappearData, flyAppearData);
end
info = countFlies(info);
end

% Returns the list of options for the list dialog.
% The options lets the user decide what to do with the incomplete data.
% A recommendation is calculated according to the characteristics of the
% remaining errors in the tracking data, and added to the options.
function [options, recommendedOption] = getOptions(param, lastOccurrences)
incorrectTime = (param.numberOfFrames - min(lastOccurrences.frame)) * param.secPerFrame;
units = 'second/s)';
if incorrectTime >= 60
    incorrectTime = incorrectTime / 60;
    units = 'minute/s)';
end
fliesDisappear = length(lastOccurrences(lastOccurrences.frame < param.numberOfFrames, :));
option1 = strjoin({'Delete incorrect frames (about', num2str(incorrectTime), units});
option2 = strjoin({'Delete incomplete tracks (delete', num2str(fliesDisappear), 'fly/ies)'});
option3 = 'Fill missing values with flies'' last known locations';
recommended = '- recommended';
if param.numberOfFrames - min(lastOccurrences.frame) <= param.numberOfFrames * param.framesPercentToDelete
    option1 = strjoin({option1, recommended});
    recommendedOption = 1;
elseif fliesDisappear <= param.numberOfFlies * param.fliesPercentToDelete
    option2 = strjoin({option2, recommended});
    recommendedOption = 2;
else
    option3 = strjoin({option3, recommended});
    recommendedOption = 3;
end
options = {option1, option2, option3};
end

% Deletes the frames with the incomplete tracking data.
% Updates the changes vector with the number of flies deleted from each frame.
function [info] = deleteIncorrectFrames(info, lastCorrectFrame)
framesChanged = info.trackingData.frame(info.trackingData.frame > lastCorrectFrame);
info = updateChangesPerFrame(info, framesChanged, 'delete');
info.trackingData(info.trackingData.frame > lastCorrectFrame, :) = [];
end

% Deletes the flies with the incomplete track.
% Updates the changes vector with the number of flies deleted from each frame.
function [info, param] = deleteFliesTracks(info, param, lastOccurrences)
fliesToDelete = lastOccurrences.identity(lastOccurrences.frame < param.numberOfFrames, :);
framesChanged = info.trackingData.frame(ismember(info.trackingData.identity, fliesToDelete));
info = updateChangesPerFrame(info, framesChanged, 'delete');
info.trackingData(ismember(info.trackingData.identity, fliesToDelete), :) = [];
param.numberOfFlies = param.numberOfFlies - length(fliesToDelete);
end

% Adds the missing frames to the tracking data.
% The missing frames will be filled with the flies' last known locations.
% Updates the changes vector with the number of flies added to each frame.
function [info] = addMissingFrames(info, param)
[~,ia,~] = unique(info.trackingData.identity, 'last');
lastOccurrences = info.trackingData(ia, :);
s = 1;
for i = 1:param.numberOfFlies
    flyData = lastOccurrences(i, :);
    length = param.numberOfFrames - flyData.frame;
    if length == 0
        continue;
    end
    s = s + 1;
    x_pos = repmat(flyData.x_pos, length, 1);
    y_pos = repmat(flyData.y_pos, length, 1);
    angle = repmat(flyData.angle, length, 1);
    maj_ax = repmat(flyData.maj_ax, length, 1);
    min_ax = repmat(flyData.min_ax, length, 1);
    identity = repmat(flyData.identity, length, 1);
    frame = ((flyData.frame + 1):param.numberOfFrames).';
    count = repmat(flyData.count, length, 1);
    newData = dataset(x_pos, y_pos, angle, maj_ax, min_ax, identity, frame, count);
    info.trackingData = [info.trackingData ; newData];
    info = updateChangesPerFrame(info, frame, 'add');
end
info.trackingData = sortrows(info.trackingData, [7 6]);
end

%% Create and display changes graph.

% Generates the graph with the number of flies added and deleted in each frame.
% The graph displays the number of flies with the approximate addition and 
% the number of extra flies as a function of frame number.
function [graph] = generateChangesGraph(info, param, fileName)
changesGraph = figure('Visible', 'off', 'Name', 'Changes Graph', 'Position', [60, 300, 1200, 300]);
graph = bar([info.deletedFliesPerFrame info.addedFliesPerFrame]);
set(graph(1), 'FaceColor',[0.667, 0.333, 0.345]);
set(graph(2), 'FaceColor',[0.3, 0.7, 0.7]);
axis([0 param.numberOfFrames 0 param.numberOfFlies]);
title('Number Of Flies Changed Per Frame');
xlabel('Frame Number');
ylabel('Flies Changed');
legend('Flies Deleted', 'Flies Added');
graphName = strcat(fileName(1:end - 4), '_changes_graph.jpg');
saveas(changesGraph, graphName);
end

%% Save fixed tracking data.

% Generates a .mat file with the fixed tracking information.
% The .mat file format is the same as the the .mat file received from CTRAX.
function generateMatFile(info, param, timestamps, startframe, fileName, changesGraph)
ntargets = repmat(param.numberOfFlies, param.numberOfFrames, 1);
x_pos = info.trackingData.x_pos;
y_pos = info.trackingData.y_pos;
angle = info.trackingData.angle;
maj_ax = info.trackingData.maj_ax;
min_ax = info.trackingData.min_ax;
identity = info.trackingData.identity;
[middleX, middleY] = middleImroi(param.arenasPos, param.arenasType); %#ok<*ASGLU>
mmPerPixel = param.mmPerPixel;
save(fileName, 'x_pos', 'y_pos', 'angle', 'maj_ax', 'min_ax', 'identity', 'timestamps', 'startframe', 'ntargets', 'middleX', 'middleY', 'changesGraph', 'mmPerPixel');
end
