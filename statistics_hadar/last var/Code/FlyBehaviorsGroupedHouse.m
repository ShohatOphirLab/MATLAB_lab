datacol = 6;
opt.nrmlzScope = 'all';
%%
load('../Data/GroupedHouse/allDatainTbl_GH.mat');

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
fly.nrmlz = cat(1, fly.segs.table);
remove = struct('fly', {10, 10}, 'movie_number', {3, 5});
for i = 1:length(remove)
    map = fly.nrmlz.fly == remove(i).fly & fly.nrmlz.movie_number == remove(i).movie_number;
    fly.nrmlz(map, :) = [];
end
for i=1:size(fly.nrmlz.condition, 1); curr=fly.nrmlz.condition{i}; curr = sprintf('%02d', str2double(regexprep(curr, 'GroupedHouse', '')));fly.nrmlz.condition{i}=curr;  end

warning('ensure the following two lines are needed (and not doing damage)');
fly.nrmlz.Properties.VariableNames{6} = 'scores_Chain_hadar';
fly.nrmlz.Properties.VariableNames{7} = 'scores_Chase_hadar';
% removeMovies = [7 8 9 32 33 34]; % which movies to remove (due to batch effects)

data = fly.nrmlz{:, datacol:end};
dataColNames = fly.nrmlz.Properties.VariableNames(datacol:end);
[conditionNames, ~, conditionIdx] = unique(fly.nrmlz.condition);
[~, ~, flyidx] = unique([fly.nrmlz.fly, fly.nrmlz.movie_number], 'rows');
[W, e] = DimReduction.LDA(data, flyidx, 5);
% W([1:], :) = 0;
Y = data * W;
y = Q.accumrows(flyidx, Y, @mean);
condition = Q.accumrows(flyidx, conditionIdx, @mode);
idx = [1, 2];
cmap = Colormaps.Retro;
statistics = {};
for conditionIdx = 1:length(conditionNames)
    subplot(3,1,1:2)
    plot(y(condition == conditionIdx, idx(1)), y(condition == conditionIdx, idx(2)), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', cmap(conditionIdx, :));
    hold on
    statistics{conditionIdx} = y(condition == conditionIdx, idx(1));
    % subplot(3,1,3)
    
end
legend(conditionNames)
fly.ids = Y;
score = y;

fly.lda = struct();
fly.lda.table = [];
for currfly = 1:max(flyidx)
    idx = find(flyidx == currfly, 1);
    fly.lda.table = [fly.lda.table; fly.nrmlz(idx, :)];
end
fly.lda.ids = y;
axis square
hold off
subplot(3,3,8)
Plot.Statistics(statistics);

%%
Identity.PlotID2BehaviorNewer(fly.lda.ids(:, 1:2), fly.lda.table(:, datacol:end));


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
    fly.nrmlz(find(fly.nrmlz.movie_number == currmovie, 1), :)
    input('press any key...')
end
hold off


%%
Identity.PlotID2BehaviorNewer(fly.ids(:, 1), fly.nrmlz(:, datacol:end));
