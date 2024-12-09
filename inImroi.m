function [in] = inImroi(x, y, pos, type) 
switch type
    case 'imellipse', [in] = checkEllipse(x, y, pos);
    case 'imrect', [in] = checkRectangle(x, y, pos);
    otherwise, [in] = checkPolygon(x, y, pos);
end
end

function [in] = checkEllipse(x, y, pos)
middleX = pos(1) + (pos(3) / 2);
middleY = pos(2) + (pos(4) / 2);
distance = sqrt(((x - middleX).^2) + ((y - middleY).^2));
r = max(pos(3) / 2, pos(4) / 2);
in = distance <= r;
end

function [in] = checkRectangle(x, y, pos)
roiX = [pos(1), pos(1), pos(1) + pos(3), pos(1) + pos(3)].';
roiY = [pos(2), pos(2) + pos(4), pos(2) + pos(4), pos(2)].';
in = inpolygon(x, y, roiX, roiY);
end

function [in] = checkPolygon(x, y, pos)
roiX = pos(:, 1);
roiY = pos(:, 2);
in = inpolygon(x, y, roiX, roiY);
end