function [middleX, middleY] = middleImroi(pos, type)
switch type
    case 'imellipse', [middleX, middleY] = getMiddleEllipse(pos);
    case 'imrect', [middleX, middleY] = getMiddleRectangle(pos);
    otherwise, [middleX, middleY] = getMiddlePolygon(pos);
end
end

function [middleX, middleY] = getMiddleEllipse(pos)
middleX = pos(1) + (pos(3) / 2);
middleY = pos(2) + (pos(4) / 2);
end

function [middleX, middleY] = getMiddleRectangle(pos)
roiX = [pos(1), pos(1), pos(1) + pos(3), pos(1) + pos(3)].';
roiY = [pos(2), pos(2) + pos(4), pos(2) + pos(4), pos(2)].';
middleX = (max(roiX) + min(roiX)) / 2;
middleY = (max(roiY) + min(roiY)) / 2;
end

function [middleX, middleY] = getMiddlePolygon(pos)
roiX = pos(:, 1);
roiY = pos(:, 2);
middleX = (max(roiX) + min(roiX)) / 2;
middleY = (max(roiY) + min(roiY)) / 2;
end