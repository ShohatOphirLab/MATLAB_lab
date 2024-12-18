% main trajectories
expGroups = uipickfiles('Prompt', 'Select experiment groups folders');
[suggestedPath, ~, ~] = fileparts(expGroups{1});
savePath =suggestedPath;
numOfGroups = length(expGroups);
groupNameDir = [];
groupNameDir = expGroups';
NumberofMovie = {1:numOfGroups}';
condition = {};
for j = 1:numOfGroups;
    fileNamePath = groupNameDir(j); % all path file name
    findStr = strfind(fileNamePath,"\"); % search for a specific str to extract conditionName
    findStr = cell2mat(findStr);
    vecLen = length(findStr);
    char_fileNamePath = char(fileNamePath);
    condition{j} = char_fileNamePath(findStr(vecLen-1)+1:findStr(vecLen)-1);
    if strfind(char_fileNamePath,"Male");
        sex{j} = "Males";
    elseif strfind(char_fileNamePath,"Female");
        sex{j} = "Females";
    else
        sex{j} = [];
    end

    NumberofMovie{j} = j;
end

condition = condition';
sex = sex';
NumberofMovie = NumberofMovie';

TMPtables=table(groupNameDir,NumberofMovie,condition,sex);

%%
figure(1)
for numberMovie = 1:numOfGroups;
    %figure(numberMovie)
    name_of_the_file = char(TMPtables{numberMovie,1});
    name_of_the_condition = TMPtables{numberMovie,3};
    number_of_movie = TMPtables{numberMovie,2};
    cd(name_of_the_file)
    cd("perframe")
        xdata = load('x.mat').data;
        ydata = load('y.mat').data;
        % subplot(2,3,numberMovie)
         ylim([100,1000]);
    xlim([200,1100]);
       % trajectoriesyogether(xdata, ydata);
       title (strrep(name_of_the_condition,"_"," "));
       txt = strrep(name_of_the_condition,"_"," ");
       trajectoriesmoves(xdata, ydata,"title",txt);
end

%%
function trajectoriesmoves(x, y, opt)
    arguments
        x
        y
        opt.colors = [
            0, 0.4470, 0.7410, 0.2; % Blue
            0.8500, 0.3250, 0.0980, 0.2; % Red
            0.9290, 0.6940, 0.1250, 0.2; % Yellow
            0.4940, 0.1840, 0.5560, 0.2; % Purple
            0.4660, 0.6740, 0.1880, 0.2; % Green
            0.3010, 0.7450, 0.9330, 0.2; % Cyan
            0.6350, 0.0780, 0.1840, 0.2; % Magenta
            0.8500, 0.3250, 0.0980, 0.2; % Orange
            0.8580, 0.4390, 0.5780, 0.2; % Pink
            0.5, 0.5, 0.5, 0.2; % Gray
        ];
        opt.marker = 'o'; % Marker style (default: 'o' for circle)
        opt.markerSize = 25; % Marker size (default: 8)
        opt.lineAlpha = 0.5; % Line opacity (default: 0.7)
        opt.markerAlpha = 1.0; % Marker opacity (default: 1.0)
        opt.title = []
    end

    % Determine the number of trajectories
    numTrajectories = length(x);

    % Create a new figure
    % figure;
    ylim([100,1000]);
    xlim([200,1100]);
    hold on;

    % Initialize lines and markers
    h = gobjects(numTrajectories, 1);
    for ii = 1:numTrajectories
        colorIndex = mod(ii-1, size(opt.colors, 1)) + 1; % Cycle through colors if needed
        h(ii) = plot(NaN, NaN, 'Color', [opt.colors(colorIndex, 1:3), opt.lineAlpha], 'LineWidth', 1.5);
    end

    % Initialize markers for current position
    markers = gobjects(numTrajectories, 1);
    for ii = 1:numTrajectories
        colorIndex = mod(ii-1, size(opt.colors, 1)) + 1; % Cycle through colors if needed
        markers(ii) = scatter(x{ii}(1), y{ii}(1), opt.markerSize, opt.colors(colorIndex, 1:3), opt.marker, 'filled', 'MarkerFaceAlpha', opt.markerAlpha, 'MarkerEdgeAlpha', opt.markerAlpha);
    end

    % Get the maximum length of the trajectories
    maxLength = max(cellfun(@length, x));

    % Animate the trajectories
    for jj = 1:maxLength
        for ii = 1:numTrajectories
            if jj <= length(x{ii})
                % Update the line data
                h(ii).XData = [h(ii).XData, x{ii}(jj)];
                h(ii).YData = [h(ii).YData, y{ii}(jj)];
                
                % Update the marker position
                markers(ii).XData = x{ii}(jj);
                markers(ii).YData = y{ii}(jj);
            end
        end
        drawnow;
        
        % Update title with current frame number
        titletxt = sprintf('%0.2f sec', jj/30);
        title([titletxt opt.title]);
        
    end

    hold off;
end

%%
% function trajectoriesmove(x, y, opt)
%     arguments
%         x
%         y
%         opt.colors = [
%             0, 0.4470, 0.7410, 0.2; % Blue
%             0.8500, 0.3250, 0.0980, 0.2; % Red
%             0.9290, 0.6940, 0.1250, 0.2; % Yellow
%             0.4940, 0.1840, 0.5560, 0.2; % Purple
%             0.4660, 0.6740, 0.1880, 0.2; % Green
%             0.3010, 0.7450, 0.9330, 0.2; % Cyan
%             0.6350, 0.0780, 0.1840, 0.2; % Magenta
%             0.8500, 0.3250, 0.0980, 0.2; % Orange
%             0.8580, 0.4390, 0.5780, 0.2; % Pink
%             0.5, 0.5, 0.5, 0.2; % Gray
%         ];
%     end
% 
%     % Determine the number of trajectories
%     numTrajectories = length(x);
% 
%     % Create a new figure
%     %figure;
%     hold on;
% 
%     % Initialize lines
%     h = gobjects(numTrajectories, 1);
%     for ii = 1:numTrajectories
%         colorIndex = mod(ii-1, size(opt.colors, 1)) + 1; % Cycle through colors if needed
%         h(ii) = plot(NaN, NaN, 'Color', opt.colors(colorIndex, 1:4), 'LineWidth', 1.5);
%     end
% 
%     % Get the maximum length of the trajectories
%     maxLength = max(cellfun(@length, x));
% 
%     % Animate the trajectories
%     for jj = 1:maxLength
%         for ii = 1:numTrajectories
%             if jj <= length(x{ii})
%                 % Update the line data
%                 h(ii).XData = [h(ii).XData, x{ii}(jj)];
%                 h(ii).YData = [h(ii).YData, y{ii}(jj)];
%             end
%         end
%         drawnow;
%         %pause(0.01 / 100000); % Adjust pause to speed up animation by 3 times
%     end
% 
%      hold off;
% end

% %%
% function trajectoriesmove(x, y, opt)
%     arguments
%         x
%         y
%         opt.colors = [
%             0, 0.4470, 0.7410, 0.5; % Blue
%             0.8500, 0.3250, 0.0980, 0.7; % Red
%             0.9290, 0.6940, 0.1250, 0.7; % Yellow
%             0.4940, 0.1840, 0.5560, 0.7; % Purple
%             0.4660, 0.6740, 0.1880, 0.7; % Green
%             0.3010, 0.7450, 0.9330, 0.7; % Cyan
%             0.6350, 0.0780, 0.1840, 0.7; % Magenta
%             0.8500, 0.3250, 0.0980, 0.7; % Orange
%             0.8580, 0.4390, 0.5780, 0.7; % Pink
%             0.5, 0.5, 0.5, 0.7; % Gray
%         ];
%     end
% 
%     % Determine the number of trajectories
%     numTrajectories = length(x);
% 
%     % Create a new figure
%    % figure;
%     hold on;
% 
%     % Initialize animated lines
%     h = gobjects(numTrajectories, 1);
%     for ii = 1:numTrajectories
%         colorIndex = mod(ii-1, size(opt.colors, 1)) + 1; % Cycle through colors if needed
%         h(ii) = animatedline('Color', opt.colors(colorIndex, 1:4), 'LineWidth', 1.5, 'LineStyle', '-');
%     end
% 
%     % Get the maximum length of the trajectories
%     maxLength = max(cellfun(@length, x));
% 
%     % Animate the trajectories
%     for jj = 1:maxLength
%         for ii = 1:numTrajectories
%             if jj <= length(x{ii})
%                 addpoints(h(ii), x{ii}(jj), y{ii}(jj));
%             end
%         end
%         drawnow;
%     end
%     hold off;
% end
