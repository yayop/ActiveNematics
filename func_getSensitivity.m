%% -  --  --  --  --  --  --  --  ---  --  --  --  --  --  --  --  --  - %%
% ----------------------- function getSensitivity ----------------------- %
% -------------------------- by Edgardo Rosas --------------------------- %
% ----------------------------------------------------------------------- %
%% Inputs                                                                 %
% - None                                                                  %
%% Outputs                                                                %
% - sensitivity: Numeric sensitivity parameter chosen by user             %
%% --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -- %
function sensitivity = func_getSensitivity()

    % Define prompt details for sensitivity input
    promptSens = {'Enter sensitivity parameter (0 to 1):'};
    titleSens = 'Sensitivity Parameter';
    defSens = {'0.99'};

    % Prompt user to enter sensitivity
    sensitivityInput = inputdlg(promptSens, titleSens, [1 40], defSens);

    % Convert user input to numeric value
    sensitivity = str2double(sensitivityInput{1});

end