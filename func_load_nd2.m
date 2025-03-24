%% -  --  --  --  --  --  --  --  ---  --  --  --  --  --  --  --  --  - %%
% ------------------------- function load_nd2 --------------------------- %
% -------------------------- by Edgardo Rosas --------------------------- %
% ----------------------------------------------------------------------- %
%% Inputs                                                                 %
% - nd2PathName: Full path to the ND2 file                                %
%% Outputs                                                                %
% - I: Loaded image array from ND2 file, empty if loading fails           %
% - nd2reader: Alternative ND2 file reader if primary loading fails       %
%% --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -- %
function [I, nd2reader] = func_load_nd2(nd2PathName)

    % Attempt to open and load the ND2 file using primary method
    try
        data = bfopen(char(nd2PathName));
        N = size(data{1}, 1);
        I = reshape(cell2mat(data{1}(1:N)), [size(data{1}{1}), N]);
        nd2reader = [];
    catch
        % If primary loading method fails, initialize alternate reader
        nd2reader = bfGetReader(char(nd2PathName));
        I = [];
    end
end