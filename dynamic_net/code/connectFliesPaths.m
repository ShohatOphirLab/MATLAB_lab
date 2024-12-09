% Receives the data of the fly's disappear and appear occurrences.
% Fills the missing frames with the fly's approximate location according 
% to its disappear and appear location.
function [info] = connectFliesPaths(info, flyDisappearData, flyAppearData)
length = flyAppearData.frame - flyDisappearData.frame + 1;
x_pos = linspace(flyDisappearData.x_pos, flyAppearData.x_pos, length).';
y_pos = linspace(flyDisappearData.y_pos, flyAppearData.y_pos, length).';
angle = linspace(flyDisappearData.angle, flyAppearData.angle, length).';
maj_ax = linspace(flyDisappearData.maj_ax, flyAppearData.maj_ax, length).';
min_ax = linspace(flyDisappearData.min_ax, flyAppearData.min_ax, length).';
identity = repmat(flyDisappearData.identity, length, 1);
frame = linspace(flyDisappearData.frame, flyAppearData.frame, length).';
count = zeros(length, 1);
newData = dataset(x_pos, y_pos, angle, maj_ax, min_ax, identity, frame, count);
info.trackingData = [info.trackingData ; newData];
info.trackingData = sortrows(info.trackingData, [7 6]);
info = updateChangesPerFrame(info, frame, 'add');
end