function [interactions, noInteractions, spaces, frames] = computeTwoFliesInteractions(flyIdentity, fileName, param, showSingleGraphs)
load(fileName);
% classifier is a list of per frame data of each fly of distance and angle
% to other fly
classifier = [(1:length(pairtrx(flyIdentity).distnose2ell))', pairtrx(flyIdentity).distnose2ell' , pairtrx(flyIdentity).anglesub'];
% remove data of all frames which are not interactions
classifier(classifier(:, 1) < param.startFrame, :) = [];
classifier(classifier(:, 1) > param.endFrame, :) = [];
%removed to check if the angle made problems in aggregation
%classifier(classifier(:, 3) == param.interactionsAnglesub, :) = [];
classifier(classifier(:, 2) > param.interactionsDistance, :) = [];
toDelete = repmat(-1, 1, length(classifier(:, 1)));
iDelete = 1;
interactions = repmat(-1, 1, length(classifier(:, 1)));
iInter = 1; % interaction counter
noInteractions = repmat(-1, 1, length(classifier(:, 1)));
iNo = 1;
spaces = repmat(-1, 1, length(classifier(:, 1)));
iSpaces = 1;
% check thresholds for length of interaction and length between
% interactions
firstFrame = 1;
for i = 2:length(classifier(:, 1))
    % look for the time frame difference between interaction and the previous one.
    %if you are bigger than the threshold this is a new iinteraction 
    if (classifier(i, 1) - classifier(i - 1, 1) > param.oneInteractionThreshold) % if this is not the same interaction
        if (i - firstFrame < param.interactionsNumberOfFrames) % if this is the same interaction delete these frames
            newDelete = firstFrame:i - 1;
            toDelete(iDelete:length(newDelete) + iDelete - 1) = newDelete;
            iDelete = length(newDelete) + iDelete;
            noInteractions(iNo) = i - firstFrame;
            iNo = iNo + 1;
        else
            % if this is a new interaction
            interactions(iInter) = i - firstFrame;
            iInter = iInter + 1;
        end
        firstFrame = i;
    elseif (classifier(i, 1) - classifier(i - 1, 1) > 1) % if it is not the same interaction and not interaction at all
        spaces(iSpaces) = classifier(i, 1) - classifier(i - 1, 1);
        iSpaces = iSpaces + 1;
    end
end
if (length(classifier(:, 1)) - firstFrame < param.interactionsNumberOfFrames)
    classifier(firstFrame:end, :) = [];
    noInteractions(iNo) = length(classifier) - firstFrame + 1;
else
    interactions(iInter) = length(classifier) - firstFrame + 1;
end 
toDelete(toDelete == -1) = [];
interactions(interactions == -1) = [];
noInteractions(noInteractions == -1) = [];
classifier(toDelete, :) = [];
frames = classifier(:, 1) + pairtrx(1).firstframe - 1;

if strcmp(showSingleGraphs, 'on')
    figure;
    hold on;
    
    yyaxis left
    plot(pairtrx(flyIdentity).distnose2ell);
    ylabel('Distance (mm)');
    
    if ~isempty(classifier)
        plot(classifier(:, 1), ones(length(classifier(:, 1))), '.k');
    end
    
    yyaxis right
    plot(pairtrx(flyIdentity).anglesub);
    ylabel('Angle Subtended (rad)');
    xlabel('Frames');
    axis tight;
end