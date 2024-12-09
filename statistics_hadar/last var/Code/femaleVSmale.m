%% Personality Project Males vs.Females 
datacol = 6;
opt.nrmlzScope = 'day';
%%
addpath(genpath("D:\Fly_personality_Oren\"))
%%
load('D:\Hadar\femalesVSmalesPersonality\allDatainTbl.mat');

%% Organize data (get behavioral profile)
data = cellfun(@mean, allDatainTbl{:, datacol:end});
varNames = regexprep(regexprep(allDatainTbl.Properties.VariableNames, '.mat', ''), ' ', '_');
fly.table = [allDatainTbl(:, 1:datacol - 1), array2table(data)];
fly.table.Properties.VariableNames = varNames;

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
d = 1 - abs(corr(fly.nrmlz{:, datacol:end}));%strcmp(allDatainTbl.sex, 'Females')
[order, clusters] = Q.hiersort(d, opt.hiersort{:});
Q.hiersort(d, opt.hiersort{:});
varNames = fly.nrmlz.Properties.VariableNames(datacol:end);
set(gca, 'YTickLabel', regexprep(varNames(order), '_', ' '), 'YAxisLocation', 'right')
%% behavioral syndrome different order
figure;
opt.hiersort = {'cutoff', .75};
subplot(1,2,1)
dMales = 1 - abs(corr(fly.nrmlz{strcmp(allDatainTbl.sex, 'Males'), datacol:end}));%strcmp(allDatainTbl.sex, 'Females')
d4Order = 1 - abs(corr(fly.nrmlz{strcmp(allDatainTbl.sex, 'Females'), datacol:end}));
[order, clusters] = Q.hiersort(d4Order, opt.hiersort{:});
dMales = 1 - dMales(order, order);

dMales(eye(length(dMales)) == 1) = nan;
                Plot.Hinton(dMales, range=[0 max(dMales(:))], colormap=Colormaps.FromTo(Colors.PrettyRed, Colors.PrettyRed));
                set(gca, 'XTick', 1:length(dMales), 'XTickLabel', order)
                set(gca, 'YTick', 1:length(dMales), 'YTickLabel', order)
varNames = fly.nrmlz.Properties.VariableNames(datacol:end);
set(gca, 'YTickLabel', regexprep(varNames(order), '_', ' '), 'YAxisLocation', 'right')
title('Behavioral Syndrome Males ')
subplot(1,2,2)
dFemales = 1 - abs(corr(fly.nrmlz{strcmp(allDatainTbl.sex, 'Females'), datacol:end}));%strcmp(allDatainTbl.sex, 'Females')
d4Order = 1 - abs(corr(fly.nrmlz{strcmp(allDatainTbl.sex, 'Females'), datacol:end}));
[order, clusters] = Q.hiersort(d4Order, opt.hiersort{:});
dFemales = 1 - dFemales(order, order);

dFemales(eye(length(dFemales)) == 1) = nan;
                Plot.Hinton(dFemales, range=[0 max(dFemales(:))], colormap=Colormaps.FromTo(Colors.PrettyRed, Colors.PrettyRed));
                set(gca, 'XTick', 1:length(dFemales), 'XTickLabel', order)
                set(gca, 'YTick', 1:length(dFemales), 'YTickLabel', order)
varNames = fly.nrmlz.Properties.VariableNames(datacol:end);
set(gca, 'YTickLabel', regexprep(varNames(order), '_', ' '), 'YAxisLocation', 'right','XTickLabel', regexprep(varNames(order), '_', ' '))
title('Behavioral Syndrome Females ')
%%

figure;
opt.hiersort = {'cutoff', .75};
dMalesandFemale = triu(dMales)+tril(dFemales);
                Plot.Hinton(dMalesandFemale, range=[0 max(dMalesandFemale(:))], colormap=Colormaps.FromTo(Colors.PrettyRed, Colors.PrettyRed));
                set(gca, 'XTick', 1:length(dMalesandFemale), 'XTickLabel', order)
                set(gca, 'YTick', 1:length(dMalesandFemale), 'YTickLabel', order)
varNames = fly.nrmlz.Properties.VariableNames(datacol:end);
set(gca, 'YTickLabel', regexprep(varNames(order), '_', ' '), 'YAxisLocation', 'left','XTickLabel', regexprep(varNames(order), '_', ' '))
title('Behavioral Syndrome Males and Females ')

hadar = dMales-dFemales; % or: abs(dMales)-abs(dFemales);
rectangleSize=0.8;
for i = 1:39
    for j = 1:39
        
        if hadar(i, j)>0.2
            if i<j;
                hold on;
                rectangle('Position', [j-rectangleSize/2, i-rectangleSize/2, rectangleSize, rectangleSize], 'EdgeColor', 'b', 'LineWidth', 1.5);
            end
        elseif hadar(i, j)<-0.2
            if i>j;
                hold on;
                rectangle('Position', [j-rectangleSize/2, i-rectangleSize/2, rectangleSize, rectangleSize], 'EdgeColor', 'y', 'LineWidth', 1.5);
            end
        end
    end
end
%%
figure
%hold on
hadar = absdMales-absdFemales;
hadar(eye(length(hadar)) == 1) = nan;
                Plot.Hinton(hadar, range=[0 max(hadar(:))], colormap=Colormaps.FromTo(Colors.PrettyRed, Colors.PrettyRed));
                set(gca, 'XTick', 1:length(hadar), 'XTickLabel', order)
                set(gca, 'YTick', 1:length(hadar), 'YTickLabel', order)
varNames = fly.nrmlz.Properties.VariableNames(datacol:end);
set(gca, 'YTickLabel', regexprep(varNames(order), '_', ' '), 'YAxisLocation', 'right')
title('Behavioral Syndrome Males - Females ')

%%
fotGalit = triu(hadar);
forGalit=fotGalit(:);
colNames = order;
rowNames = colNames;
[rowNamesVector, colNamesVector] = ndgrid(varNames(order), varNames(order));
rowColNamesVector = strcat([rowNamesVector(:)+ " VS "], colNamesVector(:));
final4Galit={};
counter=1;
for ii= 1:length(forGalit)
    if forGalit(ii)==0
        counter=counter;
    elseif abs(forGalit(ii)) <0.2;
        counter=counter;
    elseif isnan(forGalit(ii));
        counter=counter;

    else
        final4Galit{counter,1} = rowColNamesVector{ii};
        final4Galit{counter,2}= forGalit(ii);
        counter=counter+1;
    end
end
filename = "output1.csv"
writecell(final4Galit, filename);
 

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
%%

for i = 1:opt.maxNPCs
    [p,tbl,stats] = anova1([score(conditionIdx == 1, i), score(conditionIdx == 2, i), score(conditionIdx == 3, i), score(conditionIdx == 4, i), score(conditionIdx == 5, i), score(conditionIdx == 6, i)]);
    %[h, p] = ttest2(score(conditionIdx == 1, i), score(conditionIdx == 2, i));
    if p<0.05
        fprintf('PC %d: sig diff (p=%.2g) \n', i, p);
        tosave = sprintf('PC %d: sig diff (p=%.2g) \n', i, p);
        
    else
        fprintf('PC %d: no sig diff (p=%.2g) \n', i, p);
   
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% histogram of PCA projections of different conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I need to add FDR for multiple comparison
% check which behavior has the most affect on the ID
% check whic ID is siggnificant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
figure
sexlessCondition = regexprep(fly.nrmlz.condition, '.*_', '');

data = fly.nrmlz{:, datacol:end};
dataColNames = fly.nrmlz.Properties.VariableNames(datacol:end);
[conditionNames, ~, conditionIdx] = unique(fly.nrmlz.condition);
[~, ~, flyidx] = unique([fly.nrmlz.fly, fly.nrmlz.movie_number], 'rows');
[W, e,s] = DimReduction.LDA(data, flyidx, 5);
% W([1:], :) = 0;
Y = data * W;
y = Q.accumrows(flyidx, Y, @mean);
condition = Q.accumrows(flyidx, conditionIdx, @mode);
movie_number = Q.accumrows(flyidx, fly.nrmlz.movie_number, @mode);
% [batch,~,batchidx] = unique(regexprep(regexprep(fly.nrmlz.name_of_the_file, '.*_', ''), 'T.*', ''));
% batchidx = Q.accumrows(flyidx, batchidx, @mode);
sex = Q.accumrows(flyidx, strcmp(fly.nrmlz.sex, 'Males') + 1, @mode);
idx = [1, 2 ,3 ,4 , 5];
%cmap = Colormaps.Retro;
colors = ['#FF6666';'#FFCCCC';'#990000';'#3399FF';'#99CCFF';'#0000CC'];
% batch = Q.accumrows(flyidx, batch, @(x) x{1});
shapes = {'o', 's'};
for i = 1:max(conditionIdx)
    map = condition == i;
    groups = unique(movie_number(map));
    first = true;
    for g = groups(:)'
        currSex = mode(sex(map & movie_number == g));
        if first
            plot(y(map & movie_number == g, idx(1)), y(map & movie_number == g, idx(3)), shapes{currSex}, 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', 'none')
            first = false;
        else
            plot(y(map & movie_number == g, idx(1)), y(map & movie_number == g, idx(3)), shapes{currSex}, 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', 'none','HandleVisibility','off')
        end
        title('ID1 VS ID3');
        hold on
        % xlim([-.3 .2])
        % ylim([-.3 .2])
        % waitforbuttonpress
    end
end
hold off

Fig.Labels('ID1', 'ID3');
fly.ids = Y;
score = y;

fly.lda = struct();
fly.lda.table = [];
for currfly = 1:max(flyidx)
    idx = find(flyidx == currfly, 1);
    fly.lda.table = [fly.lda.table; fly.nrmlz(idx, :)];
end
fly.lda.ids = y;
legend(regexprep(conditionNames, '_', ' '));

%%
for idxCon = 1:6
    figure
    title(conditionNames(idxCon))
    Identity.PlotID2BehaviorNewer(Y(conditionIdx==idxCon, 1:5), fly.nrmlz(conditionIdx==idxCon, datacol:end));
    conditionNames(idxCon)
    %waitforbuttonpress 


end
%%
idxCon =[1,2];
[sexName, ~, sexIdx] = unique(fly.nrmlz.sex);

for idNum=1:5
    figure;
    idxCon =1;
    subplot(1,2,idxCon)
    Identity.PlotID2BehaviorNewer(Y(sexIdx==idxCon, idNum), fly.nrmlz(sexIdx==idxCon, datacol:end));
    title([sprintf('ID %d',idNum), sexName{idxCon}])
    %sexName(idxCon)
    idxCon =2;
    subplot(1,2,idxCon)
    Identity.PlotID2BehaviorNewer(Y(sexIdx==idxCon, idNum), fly.nrmlz(sexIdx==idxCon, datacol:end));
    title([sprintf('ID %d',idNum), sexName{idxCon}])
    %sexName(idxCon)
    %textTitle = sprintf('ID%d', i);
end

%%


score = y;
sexlessCondition = regexprep(fly.nrmlz.condition, '.*_', '');
[sexlessConditionNames, ~, sexlessConditionIdx] = unique(sexlessCondition);
sexlessConditionIdx = Q.accumrows(flyidx, sexlessConditionIdx, @mode);
sex = Q.accumrows(flyidx, strcmp(fly.nrmlz.sex, 'Males') + 1, @mode);

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
        histogram(score(currSex & sexlessConditionIdx == i, idx),'Normalization', 'probability')
        
        hold on
        
        if s==1;
            femaleHist = score(currSex & sexlessConditionIdx == i, idx);
        elseif s==2
            maleHist = score(currSex & sexlessConditionIdx == i, idx);
        end
    end
    %ptest = PermutationIDs(femaleHist,maleHist);
    ptestU = PermutationUIDs(femaleHist,maleHist);
    title({sexlessConditionNames{i},ptestU })
    
    legend(sexes, 'Box', 'off');
    % xlim([-.3 .3])
    hold off
    
end

Fig.Suptitle(sprintf('ID %d', idx))
hadard = sprintf('ID %d', idx);
tosaved = "D:/Hadar/"+hadard+".svg";
%saveas(gcf,tosaved)

end
%% females vs males overall

idxCon =[1,2];
[sexName, ~, sexIdx] = unique(fly.nrmlz.sex);

score = y;
sexlessCondition = regexprep(fly.nrmlz.condition, '.*_', '');
[sexlessConditionNames, ~, sexlessConditionIdx] = unique(sexlessCondition);
sexlessConditionIdx = Q.accumrows(flyidx, sexlessConditionIdx, @mode);
sex = Q.accumrows(flyidx, strcmp(fly.nrmlz.sex, 'Males') + 1, @mode);

sexes = {'Females', 'Males'};
idxn = [1,3,5];
for idx =1:5;
    idNum = idx;
    figure
    for i = 1:max(sex)
       % subplot(1, 3, 3)
        stat = {};
        %for s = 1:2
            currSex = sex == i;
           % stat{s} = std(score(currSex & sexlessConditionIdx == i, idx));
           % histogram(score(currSex , idx),'Normalization', 'probability')
          %  title(sprintf('ID %d', idx))
            hold on
         %   legend(sexes, 'Box', 'off');
            if i==1;
                idxCon =1;
                femaleHist = score(currSex, idx);
                subplot(1,2,idxCon)
                Identity.PlotID2BehaviorNewer(Y(sexIdx==idxCon, idNum), fly.nrmlz(sexIdx==idxCon, datacol:end));
                title(sexName{idxCon})
            elseif i==2
                maleHist = score(currSex, idx);
                idxCon =2;
                subplot(1,2,idxCon)
                Identity.PlotID2BehaviorNewer(Y(sexIdx==idxCon, idNum), fly.nrmlz(sexIdx==idxCon, datacol:end));
                title(sexName{idxCon})
            end
    end
        ptestU = PermutationUIDs(femaleHist,maleHist);
        sgtitle({sprintf('ID %d', idx),ptestU})
        
       % legend(sexes, 'Box', 'off');
    fig=gcf; 
    fig.Position = [100, 100, 800, 400];
    %Fig.Suptitle(sprintf('ID %d', idx))
    hadard = sprintf('ID %d all FemalVSMale', idx);
    tosaved = "D:/Hadar/"+hadard+".svg";
    %saveas(fig,tosaved)

end
