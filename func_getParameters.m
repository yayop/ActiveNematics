%% -  --  --  --  --  --  --  --  ---  --  --  --  --  --  --  --  --  - %%
% --------------------------- Get Parameters ---------------------------- %
% -------------------------- by Edgardo Rosas --------------------------- %
% ----------------------------------------------------------------------- %
%% Inputs                                                                 %
% - I: Image for parameter selection                                      %
% - magnification: Magnification level for image visualization            %
% - P: Title displayed on the image figure                                %
%% Outputs                                                                %
% - parameters: Struct containing fields                                  %
%     - RMin: Minimum radius defined by user                              %
%     - RMax: Maximum radius defined by user                              %
%     - sensitivity: Numeric sensitivity parameter (default: 0.99)        %
%     - polarity: String ('bright' or 'dark')                             %
%% --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -- %
function parameters = func_getParameters(I, magnification, P)

    % Get radius range interactively from user
    [parameters.RMin, parameters.RMax] = RadiusRange(I, magnification, P);

    % Prompt user for sensitivity value (default 0.99)
    promptSens = {'Enter sensitivity parameter (0 to 1):'};
    titleSens = 'Sensitivity Parameter';
    defSens = {'0.99'};
    sensitivityInput = inputdlg(promptSens, titleSens, [1 40], defSens);
    parameters.sensitivity = str2double(sensitivityInput{1});

    % User selects polarity ('bright' or 'dark')
    polarityOptions = {'bright','dark'};
    polarityChoice = questdlg('Choose polarity:', 'Polarity Selection', polarityOptions{:}, 'bright');

    % Store polarity selection in parameters struct
    parameters.polarity = polarityChoice;

end