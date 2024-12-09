% Handles a certain fly's jump.
% Deletes the jump's frames and update the changes vector with the deleted frames.
% If the jump is at the middle of the fly's track, fills the frames before 
% and after the jump to connect the fly's track.
function [info] = handleJump(info, firstJumpFrame, lastJumpFrame, flyIdentity)
framesChanged = (firstJumpFrame:lastJumpFrame).';
info = updateChangesPerFrame(info, framesChanged, 'delete');
indexs = info.trackingData.frame >= firstJumpFrame & info.trackingData.frame <= lastJumpFrame & info.trackingData.identity == flyIdentity;
info.trackingData(indexs, :) = [];
flyDisappearData = info.trackingData(info.trackingData.identity == flyIdentity & info.trackingData.frame == firstJumpFrame - 1, :);
flyAppearData = info.trackingData(info.trackingData.identity == flyIdentity & info.trackingData.frame == lastJumpFrame + 1, :);
if ~isempty(flyDisappearData) && ~isempty(flyAppearData)
    info.trackingData(info.trackingData.identity == flyIdentity & (info.trackingData.frame == firstJumpFrame - 1 | info.trackingData.frame == lastJumpFrame + 1), :) = [];
    info = connectFliesPaths(info, flyDisappearData, flyAppearData);
end
end