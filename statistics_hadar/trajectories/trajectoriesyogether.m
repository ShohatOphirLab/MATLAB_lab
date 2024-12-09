function trajectoriesyogether(x, y, opt)
  
    arguments
        x
        y
        opt.colors = [
            0, 0.4470, 0.7410, 0.3; % Blue
            0.8500, 0.3250, 0.0980, 0.3; % Red
            0.9290, 0.6940, 0.1250, 0.3; % Yellow
            0.4940, 0.1840, 0.5560, 0.3; % Purple
            0.4660, 0.6740, 0.1880, 0.3; % Green
            0.3010, 0.7450, 0.9330, 0.3; % Cyan
            0.6350, 0.0780, 0.1840, 0.3; % Magenta
            0.8500, 0.3250, 0.0980, 0.3; % Orange
            0.8580, 0.4390, 0.5780, 0.3; % Pink
            0.5, 0.5, 0.5, 0.3; % Gray
        ];
    end


% Preallocate arrays for better performance
xx = zeros(length(x), length(x{1,1}));
yy = zeros(length(y), length(y{1,1}));

% Extract data from cell arrays
%figure
for ii = 1:length(x)
    xx(ii,:) = x{1,ii};
    yy(ii,:) = y{1,ii};
    plot(x{1,ii}, y{1,ii},'Color', opt.colors(ii, :));
    hold on 
end
end
