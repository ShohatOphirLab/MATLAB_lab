function movieName = getMovieName(filePath)
    % This function extracts the movie name (file name without the extension)
    % from a given file path.
    %
    % Input:
    % - filePath: The full path of the file including directory, name, and extension.
    %
    % Output:
    % - movieName: The name of the file (movie) without the directory path and file extension.

    % Use fileparts to split the file path into directory, name, and extension.
    [~, name, ~] = fileparts(filePath);
    
    % Assign the name (without extension) to movieName.
    movieName = name;
end
