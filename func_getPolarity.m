%% -  --  --  --  --  --  --  --  ---  --  --  --  --  --  --  --  --  - %%
% ------------------------ function getPolarity ------------------------- %
% -------------------------- by Edgardo Rosas --------------------------- %
% ----------------------------------------------------------------------- %
%% Inputs                                                                 %
% - None                                                                  %
%% Outputs                                                                %
% - polarity: User-selected polarity ('bright' or 'dark')                 %
%% --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -- %
function polarity = func_getPolarity()

    % Define polarity options
    polarityOptions = {'bright', 'dark'};

    % Prompt user to choose polarity
    polarityChoice = questdlg('Choose polarity:', 'Polarity Selection', polarityOptions{:}, 'bright');

    % Assign the user's choice to output
    polarity = polarityChoice;

end