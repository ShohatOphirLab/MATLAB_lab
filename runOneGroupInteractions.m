function [maxGroupInteractions, foldersNames] = runOneGroupInteractions(param, allFolders, csvFileName, groupName)
interactions = [];
noInteractions = [];
maxGroupInteractions = -1;

foldersNames = cell(length(allFolders) + 1, 2);
foldersNames{1, 1} = [groupName, ' length of interacions file names'];
foldersNames{1, 2} = [groupName, ' number of interacions file names'];

 
for i = 1:length(allFolders)
    folderPath = allFolders{i};
    fileName = fullfile(folderPath, param.jaabaFileName);
    [COMPUTERPERFRAMESTATSSOCIAL_SUCCEEDED,savenames] = compute_perframe_stats_social_f('matname', fileName);
    [newInteractions, newNoInteractions, txtFileNameLength, txtFileNameNumber, maxInteractionNumber] = computeAllMovieInteractions(savenames, param);
    interactions = [interactions, newInteractions];
    noInteractions = [noInteractions, newNoInteractions];
    foldersNames{i + 1, 1} = txtFileNameLength;
    foldersNames{i + 1, 2} = txtFileNameNumber;
    maxGroupInteractions = max(maxInteractionNumber, maxGroupInteractions);
end


%% plot graphs

graph = figure;
all = [noInteractions, interactions];
histogram(all, 1:4:max(all));
xlabel('Frames');
ylabel('Number of Interactions');
xlim([0 300]);%150
ylim([0 900]);%500
line([param.interactionsNumberOfFrames param.interactionsNumberOfFrames], get(gca,'YLim'),'Color', 'k');
[filepath,~,~] = fileparts(allFolders{i});
graphName = fullfile(filepath, 'interactions_graph.jpg');
saveas(graph, graphName);

end