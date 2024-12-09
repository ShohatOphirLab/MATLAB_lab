%% Personality Project Males vs.Females 
datacol = 6;

opt.nrmlzScope = 'day';
%opt.removeCols = {'timestamps', 'dt', 'arena_r', 'a_mm', 'b_mm', 'area', 'darea', 'da', 'db', 'decc', 'ecc'};

%%
%load('../Data/allDatainTbl_females_mated_gs.mat');
load('D:\Hadar\allDatainTbl.mat');
%%
%fly.validBehaviors = readtable('behaviors_females');

%% Organize data (get behavioral profile)
data = cellfun(@mean, allDatainTbl{:, datacol:end});
varNames = regexprep(regexprep(allDatainTbl.Properties.VariableNames, '.mat', ''), ' ', '_');
fly.table = [allDatainTbl(:, 1:datacol - 1), array2table(data)];
fly.table.Properties.VariableNames = varNames;
%fly.table(:, opt.removeCols) = [];

%% Organize data into segments
opt.nSegs = 3;
fly.segs = struct();
for seg = 1:opt.nSegs
    data = cellfun(@(x) meanOnSeg(x, opt.nSegs, seg), allDatainTbl{:, datacol:end});
    data = Q.nwarp(data);
    t = [allDatainTbl(:, 1:datacol-1), array2table(data)];
    t.Properties.VariableNames = varNames;
   % t(:, opt.removeCols) = [];
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
% %% extract only valid behaviors
% fullTable = cat(1, fly.segs.table);
% removeMovies = [];
% fly.dict = dictionary(fly.validBehaviors.Var1, fly.validBehaviors.Var2);
% fullTable(:, fly.dict(fullTable.Properties.VariableNames) == 0) = [];
% 
% fullTable(ismember(fullTable.movie_number, removeMovies), :) = [];
%% Behavioral syndromes ?
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
sexlessCondition = regexprep(fly.nrmlz.condition, '.*_', '');
[sexlessConditionNames, ~, sexlessConditionIdx] = unique(sexlessCondition);
sexes = {'Females', 'Males'};
idx = 3;
for i = 1:max(sexlessConditionIdx)
    subplot(max(sexlessConditionIdx), 1, i)
    for s = 1:2
        currSex = strcmp(fly.nrmlz.sex, sexes{s});
        histogram(score(currSex & sexlessConditionIdx == i, idx), 'Normalization', 'probability')
        hold on
    end
    title(sexlessConditionNames{i})
    legend(sexes, 'Box', 'off');
    hold off
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Compute IDs

sexlessCondition = regexprep(fly.nrmlz.condition, '.*_', '');
fullTable = cat(1, fly.segs.table);
% removeMovies = [7 8 9 32 33 34]; % which movies to remove (due to batch effects)
fly.dict = dictionary(lower(fly.validBehaviors.Var1), fly.validBehaviors.Var2);
fullTable(:, fly.dict(lower(fullTable.Properties.VariableNames)) == 0) = [];
month = regexprep(fullTable.name_of_the_file, '^.*_(\d*)\d\dT\d*.*', '$1');
[umonth, ~, monthidx] = unique(month);
% monthidx = Q.accumrows(flyidx, monthidx, @mode);
% fullTable = fullTable(monthidx == 2, :);
fullTable(monthidx == 1, :) = [];
warning('removing batch #1!')
% subplot(2,1,1)
% fullTable(ismember(fullTable.movie_number, removeMovies), :) = [];

data = fullTable{:, datacol:end};
dataColNames = fullTable.Properties.VariableNames(datacol:end);
[conditionNames, ~, conditionIdx] = unique(fullTable.condition);
[~, ~, flyidx] = unique([fullTable.fly, fullTable.movie_number], 'rows');
[W, e] = DimReduction.LDA(data, flyidx, 5);
% W([1:], :) = 0;
Y = data * W;
y = Q.accumrows(flyidx, Y, @mean);
condition = Q.accumrows(flyidx, conditionIdx, @mode);
movie_number = Q.accumrows(flyidx, fullTable.movie_number, @mode);
[batch,~,batchidx] = unique(regexprep(regexprep(fullTable.name_of_the_file, '.*_', ''), 'T.*', ''));
batchidx = Q.accumrows(flyidx, batchidx, @mode);
sex = Q.accumrows(flyidx, strcmp(fullTable.sex, 'Males') + 1, @mode);
idx = [1, 2];
cmap = Colormaps.Retro;
% batch = Q.accumrows(flyidx, batch, @(x) x{1});
shapes = {'o', 's'};
for i = 1:max(conditionIdx)
    map = condition == i;
    groups = unique(movie_number(map));
    first = true;
    for g = groups(:)'
        currSex = mode(sex(map & movie_number == g));
        if first
            plot(y(map & movie_number == g, idx(1)), y(map & movie_number == g, idx(2)), shapes{currSex}, 'MarkerFaceColor', cmap(i, :), 'MarkerEdgeColor', 'none')
            first = false;
        else
            plot(y(map & movie_number == g, idx(1)), y(map & movie_number == g, idx(2)), shapes{currSex}, 'MarkerFaceColor', cmap(i, :), 'MarkerEdgeColor', 'none','HandleVisibility','off')
        end
        title(sprintf('%s (%s), group %d', regexprep(conditionNames{i}, '_', ' '), batch{mode(batchidx(map & movie_number == g))}, g));
        hold on
        % xlim([-.3 .2])
        % ylim([-.3 .2])
        % waitforbuttonpress
    end
end
hold off
Fig.Labels('ID1', 'ID2');
fly.ids = Y;
score = y;

fly.lda = struct();
fly.lda.table = [];
for currfly = 1:max(flyidx)
    idx = find(flyidx == currfly, 1);
    fly.lda.table = [fly.lda.table; fullTable(idx, :)];
end
fly.lda.ids = y;
legend(regexprep(conditionNames, '_', ' '));

%%
Identity.PlotID2BehaviorNewer(Y(:, 1:2), fullTable(:, datacol:end));

%%

score = y;
sexlessCondition = regexprep(fullTable.condition, '.*_', '');
[sexlessConditionNames, ~, sexlessConditionIdx] = unique(sexlessCondition);
sexlessConditionIdx = Q.accumrows(flyidx, sexlessConditionIdx, @mode);
sex = Q.accumrows(flyidx, strcmp(fullTable.sex, 'Males') + 1, @mode);

sexes = {'Females', 'Males'};
idxn = [1,3,5];
for idx =1:5;
    figure
for i = 1:max(sexlessConditionIdx)
    subplot(max(sexlessConditionIdx), 1, i)
    stat = {};
    for s = 1:2
        currSex = sex == s;
       % stat{s} = std(score(currSex & sexlessConditionIdx == i, idx));
        histogram(score(currSex & sexlessConditionIdx == i, idx), 'Normalization', 'probability')
        hold on
        
        if s==1;
            femaleHist = score(currSex & sexlessConditionIdx == i, idx);
        elseif s==2
            maleHist = score(currSex & sexlessConditionIdx == i, idx);
        end
    end
    ptest = PermutationIDs(femaleHist,maleHist);
    title({sexlessConditionNames{i}, ptest})
    
    legend(sexes, 'Box', 'off');
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
for i = 1:max(sexlessConditionIdx)
    subplot(max(sexlessConditionIdx), 1, i)
    stat = {};
    for s = 1:2
        currSex = sex == s;
       % stat{s} = std(score(currSex & sexlessConditionIdx == i, idx));
       data = score(currSex & sexlessConditionIdx == i, idx);
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
            femaleHist = score(currSex & sexlessConditionIdx == i, idx);
        elseif s==2
            maleHist = score(currSex & sexlessConditionIdx == i, idx);
        end
    end
    ptest = PermutationIDs(femaleHist,maleHist);
    title({sexlessConditionNames{i}, ptest})
    
    legend(sexes, 'Box', 'off');
    % xlim([-.3 .3])
    hold off
    
end


end