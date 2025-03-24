%% -  --  --  --  --  --  --  --  ---  --  --  --  --  --  --  --  --  - %%
% --------------------- function getBackground_nd2 ---------------------- %
% -------------------------- by Edgardo Rosas --------------------------- %
% ----------------------------------------------------------------------- %
%% Inputs                                                                 %
% - nd2PathName: Path to the ND2 file                                     %
%% Outputs                                                                %
% - bg16bits: Background image calculated as mean of frames (16-bit)      %
% - bg_double: Background image converted to double precision             %
% - I: 3D array of image frames if successfully loaded, empty otherwise   %
%% --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -- %
function [bg16bits, bg_double, I] = func_getBackground_nd2(nd2PathName)
    % Attempt to open the ND2 file and load all frames into an array
    [I, nd2reader] = func_load_nd2(nd2PathName);
    % Calculate background as mean image if I is not empty
    if ~isempty(I)
        bg16bits = mean(I, 3, 'native');
        bg_double = double(bg16bits);
    else
    % If I is empty, calculate background using alternate method
        bg16bits = func_getMean_nd2(nd2reader);
        bg_double = double(bg16bits);
    end
end