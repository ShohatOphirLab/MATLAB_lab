
%jaabaFileName = 'registered_trx.mat';
%jaabaFileName = 'ctrax_results - Copy.mat';


param = struct();
param.interactionsNumberOfFrames = 45;
param.interactionsDistance = 8;
param.interactionsAnglesub = 0;
param.oneInteractionThreshold = 120;
param.startFrame = 0;
param.endFrame = 27001;
param.directed = true;
param.interactionLength = true;

interactions = [];
noInteractions = [];

handles.allFolders = uipickfiles('Prompt', 'Select movies to run inteactions');
for i = 1:length(handles.allFolders)
    folderPath = handles.allFolders{i};
    fileName = fullfile(folderPath, jaabaFileName);
    [COMPUTERPERFRAMESTATSSOCIAL_SUCCEEDED,savenames] = compute_perframe_stats_social_f('matname', fileName);
    [newInteractions, newNoInteractions, txtFileName] = computeAllMovieInteractions(savenames, param);
    interactions = [interactions, newInteractions];
    noInteractions = [noInteractions, newNoInteractions];
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
[filepath,~,~] = fileparts(savenames{1});
graphName = fullfile(filepath, 'interactions_graph.jpg');



