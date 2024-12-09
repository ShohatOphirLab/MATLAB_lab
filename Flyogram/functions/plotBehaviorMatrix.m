% TODO: fix the x-axis labels (starts at 0.5)
function plotBehaviorMatrix(colorPalette, matrix, behaviorLabels, x_label, plot_title)
    % This function plots a matrix of behaviors with a color-coded visualization.
    % The behavior labels are reordered based on a manually specified desired order.
    % The matrix values are color-coded according to the behavior indices, and the
    % color palette can be customized. 
    %
    % Inputs:
    % - colorPalette: A string specifying the color palette ('Happy' or 'Rainbow').
    % - matrix: The behavior matrix to be plotted (rows: behaviors, columns: frames/intervals).
    % - behaviorLabels: A cell array of strings containing the labels for each behavior.
    % - x_label: A string for labeling the x-axis.
    % - plot_title: A string for the plot title.

    % Define the desired order of behaviors
    desiredOrder = { 'Walk', 'Stop', 'Turn', 'Touch',...
        'Long Distance Approach', 'Short Distance Approach',...
        'Long Lasting Interaction', 'Social Clustering', ...
        'Grooming', 'Song', 'Chain', 'Chase', 'Jump'};

    % Filter desiredOrder to include only behaviors present in behaviorLabels
    filteredDesiredOrder = desiredOrder(ismember(desiredOrder, behaviorLabels));

    % Find indices of behaviors in filteredDesiredOrder
    [~, idx] = ismember(filteredDesiredOrder, behaviorLabels);
    existingOrder = idx(idx > 0);

    % Find indices of behaviors in behaviorLabels that are not in filteredDesiredOrder
    remainingIdx = setdiff(1:length(behaviorLabels), existingOrder);
    
    % Combine the indices to create the final order
    finalOrder = [existingOrder, remainingIdx];
    
    % Reorder the matrix and behavior labels according to the final order
    reorderedMatrix = matrix(finalOrder, :);
    reorderedBehaviorLabels = behaviorLabels(finalOrder);

    % Scale each row's values by its index if they are greater than or equal to the threshold
    for i = 1:size(reorderedMatrix, 1)
        reorderedMatrix(i, reorderedMatrix(i, :) == 1) = i;
    end

    % Create a figure for the behavior matrix plot
    figure;
    
    % Plot the matrix as an image
    imagesc(reorderedMatrix);
    
    % Define a custom color palette ('Happy' palette) for the plot
    happyColors = [
                255/255 255/255 255/255;  % White
                204/255 0/255   204/255;  % Medium Purple
                0/255   204/255 204/255;  % Cyan / Aqua
                255/255 102/255 0/255;    % Orange
                102/255 204/255 0/255;    % Lime Green
                204/255 0/255   0/255;    % Red
                102/255 0/255   204/255;  % Purple
                255/255 204/255 0/255;    % Yellow
                0/255   51/255  255/255;  % Bright Blue
                231/255 14/255  134/255;  % Hot Pink
                14/255  231/255 111/255;  % Mint Green
                231/255 111/255 14/255;   % Pumpkin Orange
                14/255  134/255 231/255;  % Light Blue
                79/255  44/255  27/255;   % Dark Brown
                ];

    % Ensure there are enough colors to cover all behaviors
    if strcmpi(colorPalette, 'Happy')
        % If there are more behaviors than colors, repeat the colors (skipping white)
        if size(reorderedMatrix, 1) > size(happyColors, 1)
            happyColors = [happyColors; happyColors(2:end, :)]; % Repeat colors if needed
        end
        % Set the colormap using the custom Happy palette
        colormap(happyColors(1:length(reorderedBehaviorLabels) + 1, :));
    elseif strcmpi(colorPalette, 'Rainbow')
        % Use the 'jet' colormap for the 'Rainbow' option
        cmap = [1 1 1; jet(size(reorderedMatrix, 1))];
        colormap(cmap);
    else
        % Default to 'jet' colormap if no valid palette is provided
        cmap = [1 1 1; jet(size(reorderedMatrix, 1))];
        colormap(cmap);
    end

    % Set the title of the plot
    title(plot_title);
    
    % Set the x-axis label
    xlabel(x_label);

    % Set the y-axis ticks to show the reordered behavior labels
    yticks(1:size(reorderedMatrix, 1));
    yticklabels(reorderedBehaviorLabels);

    % Display a success message
    disp("Successfully plotted the behavior matrix.");
end
