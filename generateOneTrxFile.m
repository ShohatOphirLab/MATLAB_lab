function isSuccess = generateOneTrxFile(data, fileToUse, annName, fixedFileName, paramsName, movieName, currentPath)
isSuccess = 0;
args = [{'intrxfile', 'annfile'}; {fileToUse, annName}];
load(fixedFileName, 'middleX', 'middleY', 'timestamps');
secPerFrame = timestamps(2) - timestamps(1);
load(paramsName, 'arenasType', 'arenasPos', 'mmPerPixel');
radius = 123;
width = 123;
height = 123;
switch arenasType
    case 'imellipse'
        type = 'Circle';
        radius = max(arenasPos(3) / 2, arenasPos(4) / 2);
    case 'imrect'
        type = 'Rectangle';
        width = arenasPos(3);
        height = arenasPos(4);
    otherwise
        type = 'None';
end
try
    [~, ~] = Convert2JAABAWrapper('Ctrax',...
        'inmoviefile',movieName,...
        args{:},...
        'expdir',currentPath,...
        'moviefilestr',data.movieFileName,...
        'trxfilestr',data.jaabaFileName,...
        'perframedirstr',data.perframeDirName,...
        'overridefps',0,...
        'overridearena',0,...
        'dosoftlink',0,...
        'fliplr',0,...
        'flipud',0,...
        'dotransposeimage',0,...
        'fps',(1 / secPerFrame),...
        'pxpermm',(1 / mmPerPixel),...
        'arenatype',type,...
        'arenacenterx',middleX,...
        'arenacentery',middleY,...
        'arenaradius',radius,...
        'arenawidth',width,...
        'arenaheight',height,...
        'roi2',[],...
        'frameinterval',[1,inf]);
catch 
    isSuccess = 1;
    return;
end
end