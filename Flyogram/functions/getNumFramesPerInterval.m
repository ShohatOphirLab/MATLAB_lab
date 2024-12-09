function numFramesPerInterval = getNumFramesPerInterval(timeInterval)
    % This function returns the number of frames corresponding to a given time interval.
    % The time intervals can be specified as 'Frame', 'Second', or 'Minute'.
    %
    % Input:
    % - timeInterval: A string specifying the desired time interval ('Frame', 'Second', or 'Minute').
    %
    % Output:
    % - numFramesPerInterval: The number of frames that correspond to the specified time interval.
    %   - 'Frame': 1 frame per interval.
    %   - 'Second': 30 frames per second.
    %   - 'Minute': 30 frames per second * 60 seconds per minute.
    
    switch timeInterval
        case 'Frame'
            % 1 frame per interval for 'Frame'
            numFramesPerInterval = 1;
        case 'Second'
            % Assuming 30 frames per second
            numFramesPerInterval = 30;
        case 'Minute'
            % 30 frames per second multiplied by 60 seconds per minute
            numFramesPerInterval = 30 * 60;
        otherwise
            % Throw an error if the input is not a valid time interval
            error('Invalid time interval specified.');
    end
end
