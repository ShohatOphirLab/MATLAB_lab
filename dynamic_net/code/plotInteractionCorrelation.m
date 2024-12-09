function plotInteractionCorrelation(savenames, interactionMatrix, filepath, title, graphName)
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
graph = figure('Visible', 'off');
format long;
b1 = x\y;
yCalc1 = b1 * x;
scatter(x,y);
hold on;
plot(x,yCalc1);
xlabel([title  ' - Fly x With Fly y']);
ylabel([title  ' - Fly y With Fly x']);
graphName = fullfile(filepath, [graphName '_correlation_graph.jpg']);
saveas(graph, graphName);
end