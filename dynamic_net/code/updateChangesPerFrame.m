% Updates the changes done on each frame in the info's vectors.
% 'framesChanged' represents the frames that were changed, and the 'type'
% string represent the type of change: 'add' or 'remove'.
function [info] = updateChangesPerFrame(info, framesChanged, type)
if isempty(framesChanged)
    return;
end
framesChanged = tabulate(framesChanged);
FliesPerFrame = zeros(length(info.deletedFliesPerFrame), 1);
FliesPerFrame(framesChanged(:, 1)) = framesChanged(:, 2);
if strcmp(type, 'add')
    info.addedFliesPerFrame = info.addedFliesPerFrame + FliesPerFrame;
else
    info.deletedFliesPerFrame = info.deletedFliesPerFrame + FliesPerFrame;
end
end