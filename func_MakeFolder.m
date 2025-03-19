%% -  --  --  --  --  --  --  --  ---  --  --  --  --  --  --  --  --  - %%
% ------------------------- function MakeFolder ------------------------- %
% -------------------------- by Edgardo Rosas --------------------------- %
% ----------------------------------------------------------------------- %
%% Inputs                                                                 %
% - varargin: Variable-length input arguments representing folder names   %
%% Outputs                                                                %
% - Folder: Full path name of the created folder                          %                 %
%% --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -- %
function Folder = func_MakeFolder(varargin)

    % Combine input arguments into a single valid folder path
    Folder = fullfile(varargin{:});

    % Create the folder (including subfolders) if it does not exist
    if ~isfolder(Folder)
        mkdir(Folder);
    end

end