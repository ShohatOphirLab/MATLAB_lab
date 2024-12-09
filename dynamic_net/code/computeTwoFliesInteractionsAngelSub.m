function [interactions, noInteractions, spaces, frames] = computeTwoFliesInteractionsAngelSub(flyIdentity, fileName, param, showSingleGraphs)
load(fileName);
% classifier is a list of per frame data of each fly of distance and angle
% to other fly
%the logic is first we remove all the frames that is not anwering the
%thrshold of distance or angelsub or both

if(param.doAngelsub == true)
  classifier = [(1:length(pairtrx(flyIdentity).distnose2ell))', pairtrx(flyIdentity).distnose2ell' , pairtrx(flyIdentity).anglesub'];
  classifier(classifier(:, 3) == param.interactionsAnglesub, :) = [];

else
classifier = [(1:length(pairtrx(flyIdentity).distnose2ell))', pairtrx(flyIdentity).distnose2ell'];
end


% remove data of all frames which are not interactions
classifier(classifier(:, 1) < param.startFrame, :) = [];
classifier(classifier(:, 1) > param.endFrame, :) = [];
classifier(classifier(:, 2) > param.interactionsDistance, :) = [];
toDelete = repmat(-1, 1, length(classifier(:, 1)));
iDelete = 1;
interactions = repmat(-1, 1, length(classifier(:, 1)));
iInter = 1; % interaction counter
noInteractions = repmat(-1, 1, length(classifier(:, 1)));
iNo = 1;%i think this is number of intearction
spaces = repmat(-1, 1, length(classifier(:, 1)));
iSpaces = 1;
% check thresholds for length of interaction and length between
% interactions
firstFrame = 1;
for i = 2:length(classifier(:, 1))
    % look for the time frame difference between interaction and the previous one.
    %if you are bigger than the threshold this is a new iinteraction 
    %if the next frame is gap of more than the threshold of 120 
    if (classifier(i, 1) - classifier(i - 1, 1) > param.oneInteractionThreshold) % if this is not the same interaction
        if (i - firstFrame < param.interactionsNumberOfFrames) % if this is the same interaction delete these frames
            %the length of the continous interaction
            %so if the gap is over 120 and the length of the current
            %continous intearction is less than 60 so this is not an
            %interaction
            %first frame is updateing,it is the first frame of the current
            %intearction, i am checking if it is the same interaction
            newDelete = firstFrame:i - 1;
            toDelete(iDelete:length(newDelete) + iDelete - 1) = newDelete;
            iDelete = length(newDelete) + iDelete;
            noInteractions(iNo) = i - firstFrame;
            %next index of the interaction
            iNo = iNo + 1;
        else
            % if this is a new interaction (not continous to the previous
            % one) and the length of the interaction is bigger than 60 and
            % the gap is bigger than 120(independed interaction from her
            % prevoiuos)
            interactions(iInter) = i - firstFrame;
            iInter = iInter + 1;
        end
        firstFrame = i;
        %if the gap of the next interaction is not bigger than 120 but also
        %not continous by one frame 
        %anyway check this condition if the gap is bigger than 1 (not
        %continoius) from the prevoius 
    elseif (classifier(i, 1) - classifier(i - 1, 1) > 1) % if it is not the same interaction and not interaction at all
        spaces(iSpaces) = classifier(i, 1) - classifier(i - 1, 1);
        iSpaces = iSpaces + 1;
    end
end
%this part adressing the last inteartcions
%if the gap between the current end that we found to the actuall end is
%bigger than 60 add this to the interactions
if (length(classifier(:, 1)) - firstFrame < param.interactionsNumberOfFrames)
    classifier(firstFrame:end, :) = [];
    noInteractions(iNo) = length(classifier) - firstFrame + 1;
else
    interactions(iInter) = length(classifier) - firstFrame + 1;
end 
%todelete is the frames where there is not inetction as defined (gaps of
%120 and inetaction longer than 60)
toDelete(toDelete == -1) = [];
%iinteraction is the lengths of the inetactions as defined
interactions(interactions == -1) = [];
%nointeraction is the length of the inteaction that didn't follow as
%defined ,their length was less that 60
noInteractions(noInteractions == -1) = [];
%it is also delete the frames in between that is empty 
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