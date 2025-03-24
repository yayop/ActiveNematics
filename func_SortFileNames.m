%% --------------------------------------------------------------------- %%
% ----------------------- function SortFileNames ------------------------ %
% -------------------------- by Edgardo Rosas --------------------------- %
% ----------------------------------------------------------------------- %
% This function sorts image filenames within a specified folder path      %
% according to natural numerical order. It is useful for ensuring that    %
% images are processed sequentially in the correct order, especially when %
% dealing with numbered image sequences.                                  %
%                                                                         %
% Inputs:                                                                 %
% - ImageSequencePathname: Path to the folder containing the image 
% sequence.
% - Format: Image file format (e.g., '*.tif', '*.jpg').                   %
%                                                                         %
% Outputs:                                                                %
% - n: Number of images found in the directory.                           %
% - ImgFilenames: Cell array containing sorted image filenames            %
%% ---------------------------------------------------------------------- %
function [n, ImgFilenames] = func_SortFileNames(ImageSequencePathname, Format)

    % Initialize an empty cell array for image filenames
    ImgFilenames = {};

    % Retrieve directory information for all files matching the format
    Info = dir([ImageSequencePathname, filesep, Format]);

    % Get the total number of images
    n = length(Info);

    % Store filenames in a cell array
    [ImgFilenames{1:n,1}] = deal(Info.name);

    % Sort filenames in natural numeric order (e.g., Frame_1, Frame_2, ...)
    ImgFilenames = sort_nat(ImgFilenames);
end