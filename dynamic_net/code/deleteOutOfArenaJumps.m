% Deletes observations of flies that "jumps" out of the arena bounds.
% If the jump is at the end of the fly's track, delete the jump's frames.
% If the jump is at the middle of the fly's track, fills the frames with the
% fly's approximate location according to its location before and after the jump.
function [info] = deleteOutOfArenaJumps(info, param, flyIdentity)
indexs = info.trackingData.identity == flyIdentity & ~inImroi(info.trackingData.x_pos, info.trackingData.y_pos, param.arenasPos, param.arenasType);
jumpsFrames = info.trackingData.frame(indexs);
if isempty(jumpsFrames)
    return;
end
firstJumpFrame = jumpsFrames(1);
for j = 2:length(jumpsFrames)
    if jumpsFrames(j) - jumpsFrames(j - 1) > 1
        lastJumpFrame = jumpsFrames(j - 1);
        info = handleJump(info, firstJumpFrame, lastJumpFrame, flyIdentity);
        firstJumpFrame = jumpsFrames(j);
    end
end
info = handleJump(info, firstJumpFrame, jumpsFrames(end), flyIdentity);
end