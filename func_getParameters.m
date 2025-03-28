%% -  --  --  --  --  --  --  --  ---  --  --  --  --  --  --  --  --  - %%
% ----------------------- function getParameters ------------------------ %
% -------------------------- by Edgardo Rosas --------------------------- %
% ----------------------------------------------------------------------- %
%% Inputs                                                                 %
% - I: Image for parameter selection                                      %
%% Outputs                                                                %
% - parameters: Struct containing fields                                  %
%     - RMin: Minimum radius defined by user                              %
%     - RMax: Maximum radius defined by user                              %
%     - sensitivity: Numeric sensitivity parameter (default: 0.99)        %
%     - polarity: String ('bright' or 'dark')                             %
%% --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -- %
function parameters = func_getParameters(I)

    % Get radius range interactively from user
    [parameters.RMin, parameters.RMax] = func_getRadiusRange(I);

    % Prompt user for sensitivity value
    parameters.sensitivity = func_getSensitivity();

    % User selects polarity ('bright' or 'dark')
    parameters.polarity = func_getPolarity();

end