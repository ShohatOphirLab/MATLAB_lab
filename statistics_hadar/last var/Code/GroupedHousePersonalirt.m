%% Personality Project Grouped House
datacol = 6;
opt.nrmlzScope = 'day';

%%
load('F:\hadar\GH\PERSONALITY OUTPUT\allDatainTbl.mat');

%% Organize data (get behavioral profile)
data = cellfun(@mean, allDatainTbl{:, datacol:end});
varNames = regexprep(regexprep(allDatainTbl.Properties.VariableNames, '.mat', ''), ' ', '_');
fly.table = [allDatainTbl(:, 1:datacol - 1), array2table(data)];
fly.table.Properties.VariableNames = varNames;

%% Organize data into segments
opt.nSegs = 3;
fly.segs = struct();
for seg = 1:opt.nSegs
    data = cellfun(@(x) meanOnSeg(x, opt.nSegs, seg), allDatainTbl{:, datacol:end});
    data = Q.nwarp(data);
    t = [allDatainTbl(:, 1:datacol-1), array2table(data)];
    t.Properties.VariableNames = varNames;
    fly.segs(seg).table = t;
end

%% Normalize behaviors to follow a normal distribution (warping)
movieNumbers = unique(fly.table.movie_number);
days = regexprep(fly.table.name_of_the_file, '.*_(\d*)T\d*', '$1');
[uniqueDay, ~, dayIdx] = unique(days);
fly.nrmlz = fly.table;
opt.nrmlzScope = 'day';
if strcmpi(opt.nrmlzScope, 'none')
    fly.nrmlz{:, datacol:end} = fly.table{:, datacol:end};
elseif strcmpi(opt.nrmlzScope, 'all')
    fly.nrmlz{:, datacol:end} = Q.nwarp(fly.table{:, datacol:end});
elseif strcmpi(opt.nrmlzScope, 'movie')
    for movieNumber = movieNumbers(:)'
        map = fly.table.movie_number == movieNumber;
        curr = fly.table(map, datacol:end);
        data = Q.nwarp(table2array(curr));
        fly.nrmlz{map, datacol:end} = data;
    end
elseif strcmpi(opt.nrmlzScope, 'day')
    for day = 1:max(dayIdx)
        map = dayIdx == day;
        curr = fly.table(map, datacol:end);
        data = Q.nwarp(table2array(curr));
        fly.nrmlz{map, datacol:end} = data;
    end
else
    error
end

%% Behavioral syndromes ?
figure;
opt.hiersort = {'cutoff', .75};
d = 1 - abs(corr(fly.nrmlz{:, datacol:end}));
[order, clusters] = Q.hiersort(d, opt.hiersort{:});
Q.hiersort(d, opt.hiersort{:});
varNames = fly.nrmlz.Properties.VariableNames(datacol:end);
set(gca, 'YTickLabel', regexprep(varNames(order), '_', ' '), 'YAxisLocation', 'right')

%% Find PCS (using PCA)
opt.maxNPCs = 5;
data = fly.nrmlz{:, datacol:end};
[conditionNames, ~, conditionIdx] = unique(fly.nrmlz.condition);
[coeff,score,latent,tsquared,explained,mu] = pca(data, 'NumComponents', opt.maxNPCs);
% plot(cumsum(explained) / sum(explained));
fly.pcs = score;
plot(score(conditionIdx == 1, 1), score(conditionIdx == 1, 2), 'o')
hold on
plot(score(conditionIdx == 2, 1), score(conditionIdx == 2, 2), 'o')
hold off
for i = 1:opt.maxNPCs
    [h, p] = ttest2(score(conditionIdx == 1, i), score(conditionIdx == 2, i));
    if h
        fprintf('PC %d: sig diff (p=%.2g) \n', i, p);
    else
        fprintf('PC %d: no sig diff (p=%.2g) \n', i, p);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% histogram of PCA projections of different conditions
figure
ConditionsGH = regexprep(fly.nrmlz.condition, '.*_', '');
[ConditionNamesGH, ~, ConditionGHIdx] = unique(ConditionsGH);
Groups = {'GroupedHouse1', 'GroupedHouse3','GroupedHouse5','GroupedHouse10','GroupedHouse20'};
idx = 5;
for i = 1:max(ConditionGHIdx)
    %subplot(max(ConditionGHIdx), 1, i)
    for s = 1:5
        currSex = strcmp(fly.nrmlz.condition, ConditionNamesGH{s});
        histogram(score(currSex & ConditionGHIdx == i, idx), 'Normalization', 'probability')
        %Groups(s) = ConditionNamesGH{s}
        hold on
    end
    title(ConditionNamesGH{i})
    legend(ConditionNamesGH, 'Box', 'off');
    %hold off
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Compute IDs
figure
ConditionsGH = regexprep(fly.nrmlz.condition, '.*_', '');

data = fly.nrmlz{:, datacol:end};
dataColNames = fly.nrmlz.Properties.VariableNames(datacol:end);
[conditionNames, ~, conditionIdx] = unique(fly.nrmlz.condition);
[~, ~, flyidx] = unique([fly.nrmlz.fly, fly.nrmlz.movie_number], 'rows');
[W, e] = DimReduction.LDA(data, flyidx, 5);
% W([1:], :) = 0;
Y = data * W;
y = Q.accumrows(flyidx, Y, @mean);
condition = Q.accumrows(flyidx, conditionIdx, @mode);
movie_number = Q.accumrows(flyidx, fly.nrmlz.movie_number, @mode);
[batch,~,batchidx] = unique(regexprep(regexprep(fly.nrmlz.name_of_the_file, '.*_', ''), 'T.*', ''));
batchidx = Q.accumrows(flyidx, batchidx, @mode);
sex = Q.accumrows(flyidx, strcmp(fly.nrmlz.sex, 'Males') + 1, @mode);
idx = [1, 2, 3, 4, 5];
cmap = Colormaps.Retro;
colors = [0.75 0.84 1;0 0.22 1;0 0.17 0.52;0.47 0.65 1;0.24 0.49 1];
statistics1 = {};
statistics2 = {};
statistics3 = {};
statistics4 = {};


for i = 1:max(conditionIdx)
    map = condition == i;
    groups = unique(movie_number(map));
    statistics1{i} = y(condition == i, idx(1));
    statistics2{i} = y(condition == i, idx(2));
    statistics3{i} = y(condition == i, idx(3));
    statistics4{i} = y(condition == i, idx(4));
    % first = true;
    for g = groups(:)'
        currSex = mode(sex(map & movie_number == g));
        plot(y(map & movie_number == g, idx(1)), y(map & movie_number == g, idx(2)), 'o', 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', 'none');
        hold on      
    end
    
end
hold off
legend(regexprep(conditionNames, '_', ' '));
Fig.Labels('ID1', 'ID2');

fly.ids = Y;
score = y;
%%
fly.lda = struct();
fly.lda.table = [];
for currfly = 1:max(flyidx)
    idx = find(flyidx == currfly, 1);
    fly.lda.table = [fly.lda.table; fly.nrmlz(idx, :)];
end
fly.lda.ids = y;
%legend(regexprep(conditionNames, '_', ' '));
%%
figure
subplot(1,4,1)
aaa = Plot.Statistics(statistics1([1,4,5,2,3]));
conditionOrder = [1,4,5,2,3];
conditionNamesOrdered = conditionNames(conditionOrder);

% Set the X-axis labels using xticklabels
xticklabels(conditionNamesOrdered);
title('ID1')
subplot(1,4,2)
aaa = Plot.Statistics(statistics2([1,4,5,2,3]));
xticklabels(conditionNamesOrdered);
title('ID2')
subplot(1,4,3)
aaa = Plot.Statistics(statistics3([1,4,5,2,3]));
xticklabels(conditionNamesOrdered);
title('ID3')
subplot(1,4,4)
aaa = Plot.Statistics(statistics4([1,4,5,2,3]));
xticklabels(conditionNamesOrdered);
title('ID4')

%%
figure
Identity.PlotID2BehaviorNewer(Y(:, 1:2), fly.nrmlz(:, datacol:end));

%%

score = y;
ConditionsGH = regexprep(fly.nrmlz.condition, '.*_', '');
[ConditionNamesGH, ~, ConditionGHIdx] = unique(ConditionsGH);
ConditionGHIdx = Q.accumrows(flyidx, ConditionGHIdx, @mode);
sex = Q.accumrows(flyidx, strcmp(fly.nrmlz.sex, 'Males') + 1, @mode);

Groups = {'Females', 'Males'};
idxn = [1,3,5];
for idx =1:5;
    figure
for i = 1:max(ConditionGHIdx)
    subplot(max(ConditionGHIdx), 1, i)
    stat = {};
    for s = 1:2
        currSex = sex == s;
       % stat{s} = std(score(currSex & sexlessConditionIdx == i, idx));
        histogram(score(currSex & ConditionGHIdx == i, idx), 'Normalization', 'probability')
        hold on
        
        if s==1;
            femaleHist = score(currSex & ConditionGHIdx == i, idx);
        elseif s==2
            maleHist = score(currSex & ConditionGHIdx == i, idx);
        end
    end
    ptest = PermutationIDs(femaleHist,maleHist);
    ptestU = PermutationUIDs(femaleHist,maleHist);
    title({ConditionNamesGH{i}, ptest,ptestU })
    
    legend(Groups, 'Box', 'off');
    % xlim([-.3 .3])
    hold off
    
end

Fig.Suptitle(sprintf('ID %d', idx))
hadard = sprintf('ID %d', idx);
tosaved = "D:/Fly_personality_Oren/"+hadard+".svg";
saveas(gcf,tosaved)

end

%% different visualization
idxn = [1,3,5];
for idx =1:5;
    figure
for i = 1:max(ConditionGHIdx)
    subplot(max(ConditionGHIdx), 1, i)
    stat = {};
    for s = 1:2
        currSex = sex == s;
       % stat{s} = std(score(currSex & sexlessConditionIdx == i, idx));
       data = score(currSex & ConditionGHIdx == i, idx);
        % Specify the number of bins and smoothing factor
numBins = 100;
smoothingFactor = 20; % Adjust this value to control the smoothing level

% Calculate the bin counts
[counts, edges] = histcounts(data, numBins);

% Calculate bin centers
binCenters = (edges(1:end-1) + edges(2:end)) / 2;

% Smooth the data
smoothedCounts = smoothdata(counts, 'movmean', smoothingFactor); % Use 'gaussian' for a Gaussian filter

% Plot the smoothed line
plot(binCenters, smoothedCounts);

        hold on
        
        if s==1;
            femaleHist = score(currSex & ConditionGHIdx == i, idx);
        elseif s==2
            maleHist = score(currSex & ConditionGHIdx == i, idx);
        end
    end
    ptest = PermutationIDs(femaleHist,maleHist);
    title({ConditionNamesGH{i}, ptest})
    
    legend(Groups, 'Box', 'off');
    % xlim([-.3 .3])
    hold off
    
end


end