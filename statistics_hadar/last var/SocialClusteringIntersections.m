% Intersections
addpath(genpath("D:\MATLAB\statistics_hadar"))
[allBehaviors,~] = extractingNames();
[conditionNames, conditionName] = extractConditionName();
hadarDATA = zeros(length(allBehaviors),length(conditionNames));
%%
for condi=1:length(conditionNames);
    cd(conditionName{condi})
    %...................
    %............
    expGroups = uipickfiles('Prompt', 'Select experiment groups folders');
    for behave = 1:length(allBehaviors)
        tmp = 0;   
        for movieNum = 1:length(expGroups)
            cd(expGroups{1,movieNum})
            SocialClusteringScores = load("scores_Social_Clustering.mat");
            SC = SocialClusteringScores.allScores.postprocessed;
            load(cell2mat(allBehaviors(behave)))
            behaviorScore = allScores.postprocessed;
            for ii = 1:length(SC)
                if sum(SC{1,ii}&behaviorScore{1,ii}) ~= 0
                    tmp = tmp + sum(SC{1,ii}&behaviorScore{1,ii})/sum(SC{1,ii});
                else
                    tmp = tmp;
                end
            end   
        end
        hadarDATA(behave,condi) = tmp/(ii*movieNum);
    end
end
%% organize the DATA
allBehaviors = strrep(allBehaviors,"scores_",'');
allBehaviors = strrep(allBehaviors,"_"," ");
allBehaviors = strrep(allBehaviors,".mat",'');
%%
position = strfind(allBehaviors, "Social Clustering");
foundLogical = cellfun(@(x) ~isempty(x), position);
indices = find(foundLogical);

hadarDATA(indices,:)=[];
allBehaviors(indices)=[];
%%
position = strfind(allBehaviors, "Grooming");
foundLogical = cellfun(@(x) ~isempty(x), position);
indices = find(foundLogical);

hadarDATA(indices,:)=[];
allBehaviors(indices)=[];
%%
position = strfind(allBehaviors, "Long Distance Approach");
foundLogical = cellfun(@(x) ~isempty(x), position);
indices = find(foundLogical);

hadarDATA(indices,:)=[];
allBehaviors(indices)=[];
%%
position = strfind(allBehaviors, "Jump");
foundLogical = cellfun(@(x) ~isempty(x), position);
indices = find(foundLogical);

hadarDATA(indices,:)=[];
allBehaviors(indices)=[];
%%
position = strfind(allBehaviors, "Turn");
foundLogical = cellfun(@(x) ~isempty(x), position);
indices = find(foundLogical);

hadarDATA(indices,:)=[];
allBehaviors(indices)=[];
%%
GroupsNames = strrep(conditionNames, '_', ' ');
numGroups = length(GroupsNames);
ylabels = allBehaviors;
numBehaviors = length(ylabels);
data = hadarDATA;

labels = ylabels;

normalizedData = data ./ sum(data, 1);
data = normalizedData;

    figure;
    imagesc(data);
    %heatmap(data);
    a = gray;

    colormap(flipud(a(5:3:240,:)));
    %colormap(gray);
    colorbar;

    title('Heatmap for Behaviors(%) from social clustering');

    xticks(1:numGroups);
    yticks(1:length(ylabels))
    xticklabels(GroupsNames);
    yticklabels(ylabels);

    axis equal tight;

%%
figure
for ii=1:length(GroupsNames)
subplot(2,1,ii)
piechart(data([1 3 5 7 2 4 6 8],ii),labels([1 3 5 7 2 4 6 8]));

title(GroupsNames(ii))
end
