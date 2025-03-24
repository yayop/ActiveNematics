%% -  --  --  --  --  --  --  --  ---  --  --  --  --  --  --  --  --  - %%
% ----------------------- function getRadiusRange ----------------------- %
% -------------------------- by Edgardo Rosas --------------------------- %
% ----------------------------------------------------------------------- %
%% Inputs                                                                 %
% - I: Image to be displayed for radius selection                         %
%% Outputs                                                                %
% - RMin: Minimum radius defined by user                                  %
% - RMax: Maximum radius defined by user                                  %
%% --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -- %
function [RMin, RMax] = func_getRadiusRange(I) 
    
    % Display the image with 1500 magnification
    imshow(I, [], 'InitialMagnification', 1500)

    % Set the title of the displayed image
    title('Select the radius range of your particle')

    % Allow the user to interactively draw minimum radius
    RMin = customWait(drawcircle());

    % Allow the user to interactively draw maximum radius
    RMax = customWait(drawcircle());

    % Prompt user to confirm or adjust radius values
    Prompt = {'Enter minimum radius RMin', 'Enter maximum radius RMax'};
    Title = 'Radius Range Parameter';
    dims = [1 40];
    definput = [string(round(min([RMin, RMax]))), string(round(max([RMin, RMax])))];

    % Display input dialog for radius adjustment
    RadiusRange = inputdlg(Prompt, Title, dims, definput);

    % Convert string input to numerical values
    RMin = str2double(RadiusRange{1});
    RMax = str2double(RadiusRange{2});

    % Close all open figure windows
    close all

end
