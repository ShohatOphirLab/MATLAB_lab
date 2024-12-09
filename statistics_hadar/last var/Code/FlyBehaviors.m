datacol = 6;
opt.nrmlzScope = 'all';
opt.removeCols = {'timestamps', 'dt', 'arena_r', 'a_mm', 'b_mm', 'area', 'darea', 'da', 'db', 'decc', 'ecc'};
%%
load('../Data/cyp6a20/cellBehavior_cyp6a20.mat');
load('../Data/cyp6a20/allDatainTbl_cyp6a20.mat');
fly.validBehaviors = readtable('behaviors');

%% Organize data (get behavioral profile)
data = cellfun(@mean, allDatainTbl{:, datacol:end});
varNames = regexprep(regexprep(allDatainTbl.Properties.VariableNames, '.mat', ''), ' ', '_');
fly.table = [allDatainTbl(:, 1:datacol - 1), array2table(data)];
fly.table.Properties.VariableNames = varNames;
fly.table(:, opt.removeCols) = [];

%% Organize data into segments
opt.nSegs = 3;
fly.segs = struct();
for seg = 1:opt.nSegs
    data = cellfun(@(x) meanOnSeg(x, opt.nSegs, seg), allDatainTbl{:, datacol:end});
    data = Q.nwarp(data);
    t = [allDatainTbl(:, 1:datacol-1), array2table(data)];
    t.Properties.VariableNames = varNames;
    t(:, opt.removeCols) = [];
    fly.segs(seg).table = t;
end

%% Normalize behaviors to follow a normal distribution (warping)
movieNumbers = unique(fly.table.movie_number);
fly.nrmlz = fly.table;
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
else
    error
end

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

%% Plot the relation between the traits and the behaviors
Identity.PlotID2BehaviorNewer(fly.pcs, fly.nrmlz(:, datacol:end));

%% Compute IDs
fullTable = cat(1, fly.segs.table);
removeMovies = [7 8 9 32 33 34]; % which movies to remove (due to batch effects)
fly.dict = dictionary(fly.validBehaviors.Var1, fly.validBehaviors.Var2);
fullTable(:, fly.dict(fullTable.Properties.VariableNames) == 0) = [];

fullTable(ismember(fullTable.movie_number, removeMovies), :) = [];

data = fullTable{:, datacol:end};
dataColNames = fullTable.Properties.VariableNames(datacol:end);
[conditionNames, ~, conditionIdx] = unique(fullTable.condition);
[~, ~, flyidx] = unique([fullTable.fly, fullTable.movie_number], 'rows');
[W, e] = DimReduction.LDA(data, flyidx, 5);
% W([1:], :) = 0;
Y = data * W;
y = Q.accumrows(flyidx, Y, @mean);
condition = Q.accumrows(flyidx, conditionIdx, @mode);
idx = [1, 2];
plot(y(condition == 1, idx(1)), y(condition == 1, idx(2)), 'o')
hold on
plot(y(condition == 2, idx(1)), y(condition == 2, idx(2)), 'o')
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

%%
Identity.PlotID2BehaviorNewer(fly.lda.ids, fly.lda.table(:, datacol:end));


%%
movieNumbers = unique(fly.table.movie_number);
cmap = lines;
clf
for currmovie = movieNumbers(:)'
    plot(fly.lda.ids(fly.lda.table.movie_number == currmovie, 1), fly.lda.ids(fly.lda.table.movie_number == currmovie, 2), 'o', 'MarkerFaceColor', cmap(currmovie, :), 'MarkerEdgeColor', 'none');
    hold on
    xlim([-.5 .2])
    ylim([-.4 .3])
    title(currmovie)
    fullTable(find(fullTable.movie_number == currmovie, 1), :)
    input('press any key...')
end
hold off


%%
Identity.PlotID2BehaviorNewer(fly.ids(:, 1), fullTable(:, datacol:end));
