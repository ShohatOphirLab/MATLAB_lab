function [interactions, noInteractions, txtFileName] = computeAllMovieInteractions_old(savenames, param)
load(savenames{1});
maxNumberOfInteractions = sum([pairtrx.nframes]);
load(savenames{2});
maxNumberOfInteractions = maxNumberOfInteractions + pairtrx(1).nframes;
maxNumberOfInteractions = maxNumberOfInteractions * length(pairtrx);
interactions = repmat(-1, 1, maxNumberOfInteractions);
iInter = 1;
noInteractions = repmat(-1, 1, maxNumberOfInteractions);
iNo = 1;
spaces = repmat(-1, 1, maxNumberOfInteractions);
iSpaces = 1;
[filepath,~,~] = fileparts(savenames{1});
if param.interactionLength
    type = '_interaction_length';
else
    type = '_interaction_number';
end
txtFileName = fullfile(filepath, ['interactionMatrix_frame_', num2str(param.startFrame), '_to_', num2str(param.endFrame), '_gap_', num2str(param.oneInteractionThreshold), type, '.txt']);
interactionMatrix = zeros(length(savenames), length(savenames));
undirectedInteractionMatrix = zeros(length(savenames), length(savenames));
interactionFrameMatrix = cell(length(savenames), length(savenames));

for i = 1:length(savenames)
    cur = ['fly ', num2str(i)];
    disp(cur);
    for j = 1:length(savenames)
        if i ~= j
            [newInteractions, newNoInteractions, newSpaces, frames] = computeTwoFliesInteractions(j, savenames{i}, param, 'off');
            if param.interactionLength
                interactionMatrix(i, j) = sum(newInteractions) / pairtrx(1).nframes;
            else     
                interactionMatrix(i, j) = length(newInteractions);
            end
            interactionFrameMatrix{i, j} = frames;
            interactions(iInter:length(newInteractions) + iInter - 1) = newInteractions;
            iInter = length(newInteractions) + iInter;
            noInteractions(iNo:length(newNoInteractions) + iNo - 1) = newNoInteractions;
            iNo = length(newNoInteractions) + iNo;
            spaces(iSpaces:length(newSpaces) + iSpaces - 1) = newSpaces;
            iSpaces = length(newSpaces) + iSpaces;
        end
    end
end

interactions(interactions == -1) = [];
noInteractions(noInteractions == -1) = [];
spaces(spaces == -1) = [];


%% save interaction matrix according to the directed value

if (~param.directed)
    for i = 1:length(savenames)
        for j = (i + 1):length(savenames)
            if param.interactionLength
                allFrames = unique([interactionFrameMatrix{i, j}; interactionFrameMatrix{j, i}]);
                undirectedInteractionMatrix(i, j) = length(allFrames) / pairtrx(1).nframes;
                undirectedInteractionMatrix(j, i) = length(allFrames) / pairtrx(1).nframes;
            else
                allFrames = unique([interactionFrameMatrix{i, j}; interactionFrameMatrix{j, i}]);
                if isempty(allFrames)
                    groups = 0;
                else
                    diffFrames = diff(allFrames);
                    groups = length(diffFrames(diffFrames > param.oneInteractionThreshold)) + 1;
                end
                undirectedInteractionMatrix(i, j) = groups;
                undirectedInteractionMatrix(j, i) = groups;
            end
        end
    end
    save(txtFileName, 'undirectedInteractionMatrix', '-ascii', '-double', '-tabs')
else
    save(txtFileName, 'interactionMatrix', '-ascii', '-double', '-tabs')
end


%% plot graphs

graph = figure;
all = [noInteractions, interactions];
histogram(all, 1:4:max(all));
xlabel('Frames');
ylabel('Number of Interactions');
xlim([0 150]);%150
ylim([0 500]);%500
line([param.interactionsNumberOfFrames param.interactionsNumberOfFrames], get(gca,'YLim'),'Color', 'k');
[filepath,~,~] = fileparts(savenames{1});
graphName = fullfile(filepath, 'interactions_graph.jpg');
saveas(graph, graphName);


%% plot correlation

k = 1;
for i = 1:length(savenames)
    for j = (i + 1):length(savenames)
        x(k) = interactionMatrix(i, j);
        y(k) = interactionMatrix(j, i);
        k = k + 1;
    end
end
x = x';
y = y';
graph = figure;
format long;
b1 = x\y;
yCalc1 = b1 * x;
scatter(x,y);
hold on;
plot(x,yCalc1);
xlabel('Length of Interaction - Fly x With Fly y');
ylabel('Length of Interaction - Fly y With Fly x');
graphName = fullfile(filepath, 'correlation_graph.jpg');
saveas(graph, graphName);
end