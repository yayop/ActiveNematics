function TrackingAppUnified()
%% Main window and layout
    
    f = figure('Name', 'Tracking GUI', ...
           'MenuBar', 'none', ...
           'ToolBar', 'none', ...
           'NumberTitle', 'off', ...
           'WindowState', 'fullscreen');

%% Left panel for tab controls (40% width)
    tgroup = uitabgroup(f, 'Units', 'normalized', ...
        'Position', [0 0 0.4 1]);

%% Tabs 
    tabImport = uitab(tgroup, 'Title', 'Import');
    tabDetect = uitab(tgroup, 'Title', 'Detection');
    tabTrack = uitab(tgroup, 'Title', 'Tracking');
    tabPlot = uitab(tgroup, 'Title', 'Plot');
    tabValidate = uitab(tgroup, 'Title', 'Validation');

%% Right panel for image display (60% width)
    panelRight = uipanel(f, 'Units', 'normalized', ...
        'Position', [0.4 0 0.6 1]);

    ax = axes('Parent', panelRight, 'Units', 'normalized', ...
        'Position', [0.05 0.15 0.9 0.8]);

%% Frame number (above the image)
    lblFrameNum = uicontrol(panelRight, 'Style', 'text', ...
        'String', '', ...
        'Units', 'normalized', ...
        'Position', [0.05 0.96 0.9 0.03], ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 12);

%% Slider (below the image) %%
    slider = uicontrol(panelRight, 'Style', 'slider', ...
        'Units', 'normalized', ...
        'Position', [0.05 0.08 0.9 0.03], ...
        'Min', 1, 'Max', 2, 'Value', 1, ...
        'SliderStep', [1 1], ...
        'Callback', @(src, event) showImage());

%%  Contrast: original
    rbOriginal = uicontrol(panelRight, 'Style', 'radiobutton', ...
        'String', 'original', ...
        'Units', 'normalized', ...
        'Position',[0.05 0.01 0.9 0.03],'Value', 1,...
        'Callback',@contrastCallback);

%% Contrast: imadjust
    rbImadjust = uicontrol(panelRight, 'Style', 'radiobutton', ...
        'String', 'imadjust', ...
        'Units', 'normalized', ...
        'Position', [0.2 0.01 0.9 0.03],'Callback',@contrastCallback);

%% Contrast: histeq
    rbHisteq = uicontrol(panelRight, 'Style', 'radiobutton', ...
        'String', 'histeq', ...
        'Units', 'normalized', ...
        'Position', [0.35 0.01 0.9 0.03],'Callback',@contrastCallback);

%% Contrast: adapthisteq
    rbAdapthisteq = uicontrol(panelRight, 'Style', 'radiobutton', ...
        'String', 'adapthisteq', ...
        'Units', 'normalized', ...
        'Position', [0.5 0.01 0.9 0.03],'Callback',@contrastCallback);

%% Global storage struct: appData
    appData.CurrentFrame = [];
    appData.Detection = [];
    appData.contrastMode = 'original';
    appData.VideoIndex = 0;
    appData.Dparam = struct();


%% Tab Import
% --- Title ---
    uicontrol(tabImport, 'Style', 'text', ...
        'String', 'Single ImageSequence', ...
        'Units', 'normalized', ...
        'Position', [0.05 0.83 0.9 0.05], ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
    
% --- Button to select a single folder ---
    uicontrol(tabImport, 'Style', 'pushbutton', ...
        'String', 'Select Folder', ...
        'Units', 'normalized', ...
        'Position', [0.35 0.77 0.3 0.05], ...
        'Callback', @SelectFolderCallback);
    
% --- Path display ---
    txtPathImport = uicontrol(tabImport, 'Style', 'text', ...
        'String', 'No folder selected', ...
        'Units', 'normalized', ...
        'Position', [0.05 0.71 0.9 0.05], ...
        'HorizontalAlignment', 'center');

% --- Title ---
    uicontrol(tabImport, 'Style', 'text', ...
        'String', 'Batch ImageSequence Search', ...
        'Units', 'normalized', 'Position', [0.05 0.62 0.9 0.05], ...
        'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
% --- Button to browse root ---
    uicontrol(tabImport, 'Style', 'text', ...
        'String', 'Root:', ...
        'Units', 'normalized', 'Position', [0.05 0.56 0.1 0.04], ...
        'HorizontalAlignment', 'left');
    btnRootBrowse = uicontrol(tabImport, 'Style', 'pushbutton', ...
        'String', 'Browse...', ...
        'Units', 'normalized', 'Position', [0.15 0.56 0.15 0.05], ...
        'Callback', @browseRootCallback);

% --- Field for folder name pattern ---
    uicontrol(tabImport, 'Style', 'text', ...
        'String', 'Name:', ...
        'Units', 'normalized', 'Position', [0.32 0.56 0.1 0.04], ...
        'HorizontalAlignment', 'left');
    inputPattern = uicontrol(tabImport, 'Style', 'edit', ...
        'String', 'ImageSequence', ...
        'Units', 'normalized', 'Position', [0.42 0.56 0.3 0.05]);
    
% --- Search button ---
    btnSearch = uicontrol(tabImport, 'Style', 'pushbutton', ...
        'String', 'Search', ...
        'Units', 'normalized', 'Position', [0.75 0.56 0.15 0.05], ...
        'Callback', @searchFoldersCallback);
    
% --- Status display ---
    txtSearchResults = uicontrol(tabImport, 'Style', 'text', ...
        'String', 'No folders searched yet.', ...
        'Units', 'normalized', 'Position', [0.05 0.49 0.9 0.04], ...
        'HorizontalAlignment', 'center');
    % === Button: Save FilePaths ===
    uicontrol(tabImport, 'Style', 'pushbutton', ...
        'String', 'Save FilePaths', ...
        'Units', 'normalized', ...
        'Position', [0.1 0.1 0.35 0.05], ...
        'Callback', @saveISCallback);

    % === Button: Load FilePaths ===
    uicontrol(tabImport, 'Style', 'pushbutton', ...
        'String', 'Load FilePaths', ...
        'Units', 'normalized', ...
        'Position', [0.55 0.1 0.35 0.05], ...
        'Callback', @loadISCallback);
    % === Button: Previous Video ===
    uicontrol(tabImport, 'Style', 'pushbutton', ...
        'String', 'Previous Video', ...
        'Units', 'normalized', ...
        'Position', [0.05 0.02 0.4 0.05], ...
        'Callback', @prevVideoCallback);

    % === Button: Next Video ===
    uicontrol(tabImport, 'Style', 'pushbutton', ...
        'String', 'Next Video', ...
        'Units', 'normalized', ...
        'Position', [0.55 0.02 0.4 0.05], ...
        'Callback', @nextVideoCallback);

    % === Text: current video ===
    lblVideoImport = uicontrol(tabImport, 'Style', 'text', ...
        'String', '', ...
        'Units', 'normalized', ...
        'Position', [0.55 0.2 0.4 0.05], ...
        'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold');
    appData.lblVideoImport = lblVideoImport;

%% Tab Detection 

% --- Section "Radius Estimation" ---
    uicontrol(tabDetect, 'Style', 'text', ...
        'String', '-- radius estimation --', ...
        'Units', 'normalized', ...
        'Position', [0.2 0.92 0.6 0.05], ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');

% Buttons for Crop and Get Radius Range (now together, vertically centered)
    uicontrol(tabDetect, 'Style', 'pushbutton', ...
        'String', 'crop', ...
        'Units', 'normalized', ...
        'Position', [0.05 0.88 0.2 0.05], ...
        'Callback', @cropImageCallback);

    uicontrol(tabDetect, 'Style', 'pushbutton', ...
        'String', 'get radii', ...
        'Units', 'normalized', ...
        'Position', [0.3 0.88 0.2 0.05], ...
        'Callback', @getRadiusCallback);

% RMin and RMax fields, arranged side by side
    uicontrol(tabDetect, 'Style', 'text', 'String', 'RMin:', ...
        'Units', 'normalized', 'Position', [0.55 0.865 0.1 0.05], ...
        'HorizontalAlignment', 'right');

    inputRMin = uicontrol(tabDetect, 'Style', 'edit', ...
        'Units', 'normalized', 'Position', [0.65 0.89 0.1 0.03]);

    uicontrol(tabDetect, 'Style', 'text', 'String', 'RMax:', ...
        'Units', 'normalized', 'Position', [0.75 0.865 0.1 0.05], 'HorizontalAlignment', 'right');
    inputRMax = uicontrol(tabDetect, 'Style', 'edit', ...
        'Units', 'normalized', 'Position', [0.85 0.89 0.1 0.03]);

%%% --- Section "Sensitivity" ---
    uicontrol(tabDetect, 'Style', 'text', ...
        'String', '-- sensitivity --', ...
        'Units', 'normalized', ...
        'Position', [0.2 0.82 0.6 0.04], ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');

    sliderSensitivity = uicontrol(tabDetect, 'Style', 'slider', ...
        'Min', 0.5, 'Max', 1, 'Value', 0.99, ...
        'SliderStep', [0.001 0.01], ...
        'Units', 'normalized', ...
        'Position', [0.05 0.77 0.77 0.04], ...
        'Callback', @updateSensitivity);

    txtSensitivity = uicontrol(tabDetect, 'Style', 'edit', ...
        'String', '0.990', ...
        'Units', 'normalized', ...
        'Position', [0.85 0.785 0.1 0.03], ...
        'HorizontalAlignment', 'center', ...
        'Callback', @manualSensitivityUpdate);

% --- Section "Polarity" ---
    uicontrol(tabDetect, 'Style', 'text', ...
        'String', '-- polarity --', ...
        'Units', 'normalized', ...
        'Position', [0.2 0.73 0.6 0.04], ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');

% (Checkboxes remain with the label to the right)
    chkBright = uicontrol(tabDetect, 'Style', 'checkbox', ...
        'String', 'Bright', ...
        'Units', 'normalized', ...
        'Position', [0.3 0.7 0.2 0.04]);

    chkDark = uicontrol(tabDetect, 'Style', 'checkbox', ...
        'String', 'Dark', ...
        'Units', 'normalized', ...
        'Position', [0.6 0.7 0.2 0.04]);

    %% --- Section "Edge Threshold" ---
    uicontrol(tabDetect, 'Style', 'text', ...
        'String', '-- edge threshold --', ...
        'Units', 'normalized', ...
        'Position', [0.2 0.65 0.6 0.04], ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');

    sliderEdge = uicontrol(tabDetect, 'Style', 'slider', ...
        'Min', 0.01, 'Max', 1, 'Value', 0.1, ...
        'SliderStep', [0.01 0.1], ...
        'Units', 'normalized', ...
        'Position', [0.05 0.60 0.77 0.035], ...
        'Callback', @updateEdgeThreshold);

    txtEdge = uicontrol(tabDetect, 'Style', 'edit', ...
        'String', '0.1', ...
        'Units', 'normalized', ...
        'Position', [0.85 0.61 0.1 0.03], ...
        'HorizontalAlignment', 'center', ...
        'Callback', @manualEdgeThresholdUpdate);

    %% --- Section "Method" ---
    uicontrol(tabDetect, 'Style', 'text', ...
        'String', '-- method --', ...
        'Units', 'normalized', ...
        'Position', [0.2 0.55 0.6 0.04], ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');

    radioMethod1 = uicontrol(tabDetect, 'Style', 'radiobutton', ...
        'String', 'TwoStage', ...
        'Units', 'normalized', ...
        'Position', [0.27 0.52 0.2 0.03], ...
        'Callback', @(src, evt) setMethod('TwoStage'));

    radioMethod2 = uicontrol(tabDetect, 'Style', 'radiobutton', ...
        'String', 'PhaseCode', ...
        'Units', 'normalized', ...
        'Position', [0.6 0.52 0.2 0.03], ...
        'Callback', @(src, evt) setMethod('PhaseCode'));

    %% --- Section "Preprocess" ---
    uicontrol(tabDetect, 'Style', 'text', ...
        'String', '-- preprocessing --', ...
        'Units', 'normalized', ...
        'Position', [0.2 0.47 0.6 0.04], ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');

    radioPre1 = uicontrol(tabDetect, 'Style', 'radiobutton', ...
        'String', 'original', ...
        'Units', 'normalized', ...
        'Position', [0.05 0.435 0.2 0.03], ...
        'Callback', @(src, evt) setPreprocess('original'));

    radioPre2 = uicontrol(tabDetect, 'Style', 'radiobutton', ...
        'String', 'imadjust', ...
        'Units', 'normalized', ...
        'Position', [0.275 0.435 0.2 0.03], ...
        'Callback', @(src, evt) setPreprocess('imadjust'));

    radioPre3 = uicontrol(tabDetect, 'Style', 'radiobutton', ...
        'String', 'histeq', ...
        'Units', 'normalized', ...
        'Position', [0.5 0.435 0.2 0.03], ...
        'Callback', @(src, evt) setPreprocess('histeq'));

    radioPre4 = uicontrol(tabDetect, 'Style', 'radiobutton', ...
        'String', 'adapthisteq', ...
        'Units', 'normalized', ...
        'Position', [0.725 0.435 0.2 0.03], ...
        'Callback', @(src, evt) setPreprocess('adapthisteq'));


    % --- New buttons: Save / Load Parameters ---
    % Save Parameters button on the left
    uicontrol(tabDetect, 'Style', 'pushbutton', ...
        'String', 'Save Parameters', ...
        'Units', 'normalized', ...
        'Position', [0.1 0.35 0.35 0.05], ...
        'Callback', @saveParametersCallback);
    % Load Parameters button on the right
    uicontrol(tabDetect, 'Style', 'pushbutton', ...
        'String', 'Load Parameters', ...
        'Units', 'normalized', ...
        'Position', [0.55 0.35 0.35 0.05], ...
        'Callback', @loadParametersCallback);

    % Detect Frame button
    uicontrol(tabDetect, 'Style', 'pushbutton', ...
        'String', 'Detect', ...
        'Units', 'normalized', ...
        'Position', [0.1 0.15 0.2 0.05], ...
        'Callback', @detectFrameCallback);

    % Detect All Frames button
    uicontrol(tabDetect, 'Style', 'pushbutton', ...
        'String', 'Detect All', ...
        'Units', 'normalized', ...
        'Position', [0.4 0.15 0.2 0.05],...
        'Callback',@detectAllCallback);

    uicontrol(tabDetect, 'Style', 'pushbutton', ...
        'String', 'Load Detection', ...
        'Units', 'normalized', ...
        'Position', [0.7 0.15 0.2 0.05],'Callback',@loadDetectionCallback);

    % --- Section "ROI Filter" -------------------------------------
    uicontrol(tabDetect, 'Style', 'text', 'String', '-- ROI Filter --', ...
        'Units', 'normalized', 'Position', [0.2 0.31 0.6 0.03], ...
        'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    uicontrol(tabDetect, 'Style', 'pushbutton', 'String', 'Set ROI', ...
        'Units', 'normalized', 'Position', [0.1 0.26 0.2 0.04], ...
        'Callback', @setROICallback);
    uicontrol(tabDetect, 'Style', 'text', 'String', 'ROI size (a):', ...
        'Units', 'normalized', 'Position', [0.35 0.26 0.2 0.04], ...
        'HorizontalAlignment', 'left');
    inputROISize = uicontrol(tabDetect, 'Style', 'edit', 'String', '', ...
        'Units', 'normalized', 'Position', [0.55 0.26 0.15 0.04]);
    chkShowROI = uicontrol(tabDetect, 'Style', 'checkbox', 'String', 'Show ROI iterations', ...
        'Units', 'normalized', 'Position', [0.75 0.26 0.2 0.04], 'Value', 1);
    chkROI = uicontrol(tabDetect, 'Style', 'checkbox', 'String', 'ROI Filter on', ...
        'Units', 'normalized', 'Position', [0.35 0.22 0.3 0.04], 'Value', 0);
    


    % === Buttons in Detection tab ===
    uicontrol(tabDetect, 'Style', 'pushbutton', ...
        'String', 'Previous Video', ...
        'Units', 'normalized', ...
        'Position', [0.05 0.01 0.4 0.05], ...
        'Callback', @prevVideoCallback);

    uicontrol(tabDetect, 'Style', 'pushbutton', ...
        'String', 'Next Video', ...
        'Units', 'normalized', ...
        'Position', [0.55 0.01 0.4 0.05], ...
        'Callback', @nextVideoCallback);

    lblVideoDetection = uicontrol(tabDetect, 'Style', 'text', ...
        'String', '', ...
        'Units', 'normalized', ...
        'Position', [0.35 0.07 0.3 0.03], ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    appData.lblVideoDetection = lblVideoDetection;

%% Tab Tracking
    % Title
    uicontrol(tabTrack, 'Style', 'text', 'String', 'Tracking Parameters', ...
        'Units', 'normalized', 'Position', [0.1 0.85 0.8 0.05], ...
        'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    % memory
    uicontrol(tabTrack, 'Style', 'text', 'String', 'Memory (gap frames):', ...
        'Units', 'normalized', 'Position', [0.1 0.75 0.5 0.05], ...
        'HorizontalAlignment', 'left');
    inputMemory = uicontrol(tabTrack, 'Style', 'edit', 'String', '10', ...
        'Units', 'normalized', 'Position', [0.6 0.75 0.3 0.06]);
    
    % good
    uicontrol(tabTrack, 'Style', 'text', 'String', 'Min detections (good):', ...
        'Units', 'normalized', 'Position', [0.1 0.68 0.5 0.05], ...
        'HorizontalAlignment', 'left');
    inputGood = uicontrol(tabTrack, 'Style', 'edit', ...
        'String', 'num2str(max(round(appData.Video(appData.VideoIndex).NFrames/3),100))', ...
        'Units', 'normalized', 'Position', [0.6 0.68 0.3 0.06]);
    
    % dim
    uicontrol(tabTrack, 'Style', 'text', 'String', 'Trajectory dimensions (dim):', ...
        'Units', 'normalized', 'Position', [0.1 0.61 0.5 0.05], ...
        'HorizontalAlignment', 'left');
    inputDim = uicontrol(tabTrack, 'Style', 'edit', 'String', '2', ...
        'Units', 'normalized', 'Position', [0.6 0.61 0.3 0.06]);
    
    % quiet
    chkQuiet = uicontrol(tabTrack, 'Style', 'checkbox', ...
        'String', 'Quiet mode (no verbose output)', ...
        'Units', 'normalized', ...
        'Position', [0.1 0.54 0.8 0.05], ...
        'Value', 1);
    
    % maxdisp
    uicontrol(tabTrack, 'Style', 'text', 'String', 'Max displacement (px):', ...
        'Units', 'normalized', 'Position', [0.1 0.47 0.5 0.05], ...
        'HorizontalAlignment', 'left');
    % Compute robust default for maxdisp if Dparam.RMax missing
    if ~isfield(appData, 'Dparam') || ~isfield(appData.Dparam, 'RMax')
        defaultMaxdisp = 10;    % fallback value
    else
        defaultMaxdisp = appData.Dparam.RMax / 2;
    end
    inputMaxDisp = uicontrol(tabTrack, 'Style', 'edit', ...
        'String', num2str(defaultMaxdisp), ...
        'Units', 'normalized', 'Position', [0.6 0.47 0.3 0.06]);
    % === Buttons in Tracking tab ===
    uicontrol(tabTrack, 'Style', 'pushbutton', ...
        'String', 'Track All Frames', ...
        'Units', 'normalized', 'Position', [0.3 0.1 0.4 0.08], ...
        'FontSize', 11, 'FontWeight', 'bold', ...
        'Callback', @trackAllFramesCallback);
    uicontrol(tabTrack, 'Style', 'pushbutton', ...
        'String', 'Previous Video', ...
        'Units', 'normalized', ...
        'Position', [0.05 0.01 0.4 0.05], ...
        'Callback', @prevVideoCallback);

    uicontrol(tabTrack, 'Style', 'pushbutton', ...
        'String', 'Next Video', ...
        'Units', 'normalized', ...
        'Position', [0.55 0.01 0.4 0.05], ...
        'Callback', @nextVideoCallback);

    lblVideoTracking = uicontrol(tabTrack, 'Style', 'text', ...
        'String', '', ...
        'Units', 'normalized', ...
        'Position', [0.35 0.07 0.3 0.03], ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    appData.lblVideoTracking = lblVideoTracking;


%% Tab Plot
    % --- Section "Plot" ----------------------------------------
    uicontrol(tabPlot, 'Style', 'text', 'String', '-- plot --', ...
        'Units', 'normalized', 'Position', [0.2 0.9 0.6 0.05], ...
        'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

    % --- Plot controls in Plot tab ----------------------------------
    % Bright plot options
    chkPlotBrightContour    = uicontrol(tabPlot, 'Style', 'checkbox', 'String', 'Contour',    ...
        'Units', 'normalized', 'Position', [0.2 0.85 0.15 0.04], 'Value', 1, 'Callback', @(src,evt) showImage());
    chkPlotBrightCenterDot  = uicontrol(tabPlot, 'Style', 'checkbox', 'String', 'Center .',   ...
        'Units', 'normalized', 'Position', [0.35 0.85 0.15 0.04], 'Callback', @(src,evt) showImage());
    chkPlotBrightCenterPlus = uicontrol(tabPlot, 'Style', 'checkbox', 'String', 'Center +',   ...
        'Units', 'normalized', 'Position', [0.50 0.85 0.15 0.04], 'Value', 1, 'Callback', @(src,evt) showImage());
    chkPlotBrightRadius     = uicontrol(tabPlot, 'Style', 'checkbox', 'String', 'Radius',      ...
        'Units', 'normalized', 'Position', [0.65 0.85 0.15 0.04], 'Value', 1, 'Callback', @(src,evt) showImage());
    chkPlotBrightAllFrames  = uicontrol(tabPlot, 'Style', 'checkbox', 'String', 'All Frames',  ...
        'Units', 'normalized', 'Position', [0.80 0.85 0.15 0.04], 'Callback', @(src,evt) showImage());

    % Dark plot options
    chkPlotDarkContour      = uicontrol(tabPlot, 'Style', 'checkbox', 'String', 'Contour',    ...
        'Units', 'normalized', 'Position', [0.2 0.82 0.15 0.04], 'Value', 1, 'Callback', @(src,evt) showImage());
    chkPlotDarkCenterDot    = uicontrol(tabPlot, 'Style', 'checkbox', 'String', 'Center .',   ...
        'Units', 'normalized', 'Position', [0.35 0.82 0.15 0.04], 'Callback', @(src,evt) showImage());
    chkPlotDarkCenterPlus   = uicontrol(tabPlot, 'Style', 'checkbox', 'String', 'Center +',   ...
        'Units', 'normalized', 'Position', [0.50 0.82 0.15 0.04], 'Value', 1, 'Callback', @(src,evt) showImage());
    chkPlotDarkRadius       = uicontrol(tabPlot, 'Style', 'checkbox', 'String', 'Radius',      ...
        'Units', 'normalized', 'Position', [0.65 0.82 0.15 0.04], 'Value', 1, 'Callback', @(src,evt) showImage());
    chkPlotDarkAllFrames    = uicontrol(tabPlot, 'Style', 'checkbox', 'String', 'All Frames',  ...
        'Units', 'normalized', 'Position', [0.80 0.82 0.15 0.04], 'Callback', @(src,evt) showImage());


%% CALLBACK FUNCTIONS
 % ------------------------ Select Folder ------------------------- %%
    function SelectFolderCallback(~, ~)
        ImageSequencePathName = uigetdir;
        if ImageSequencePathName ~= 0
            set(txtPathImport, 'String', ImageSequencePathName);
            appData.Video(1).ImageSequence = ImageSequencePathName;

            [NImages,ImgFileNames] = func_SortFileNames(ImageSequencePathName,'*.tif');

            if isempty(ImgFileNames)
                msgbox('No .tif files found', 'Warning', 'warn');
                return;
            end
            appData.NFrames = NImages;
            appData.NVideos = 1;
            appData.VideoIndex = 1;

            appData.Video(1).FrameFiles = fullfile(ImageSequencePathName,ImgFileNames);
            appData.Video(1).NFrames = NImages;
            appData.Video(1).Container = fileparts(ImageSequencePathName);
            appData.Video(1).DetectionFolder = fullfile(appData.Video(1).Container,'Detection');
            appData.Video(1).DetectionFile = fullfile(appData.Video(1).DetectionFolder,'Detection.mat');
            appData.Video(1).TrackingFile = fullfile(appData.Video(1).DetectionFolder,'Tracking.mat');
            appData.Video(1).TrajectoriesFile = fullfile(appData.Video(1).DetectionFolder,'Trajectories.mat');
            appData.Video(1).DetectionParam = fullfile(appData.Video(1).DetectionFolder,'DetectionParameters.mat');
            appData.Video(1).TrackingParam = fullfile(appData.Video(1).DetectionFolder,'TrackingParameters.mat');

            slider.Min = 1;
            slider.Max = NImages;
            slider.Value = 1;
            slider.SliderStep = [1 1] / max(1, NImages-1);
            showImage();
        end
    end
%% ------------------------ show Image ------------------------- %%
    function showImage()
        % --- Ensure right‑panel is valid (some external functions may call clf/close) ---
        if ~ishandle(panelRight) || ~isgraphics(panelRight)
            panelRight = uipanel(f, 'Units', 'normalized', ...
                                 'Position', [0.4 0 0.6 1]);
        end
        % --- Ensure axes handle is still valid (some external functions
        % may call clf/close and delete it) ------------------------------
        if ~ishandle(ax) || ~isgraphics(ax)
            ax = axes('Parent', panelRight, 'Units', 'normalized', ...
                      'Position', [0.05 0.15 0.9 0.8]);
        end
        VideoIndex = appData.VideoIndex;
        if isempty(appData.Video(VideoIndex).FrameFiles)
            return;
        end

        idx = round(slider.Value);
        appData.idx = idx;
        img = imread(appData.Video(VideoIndex).FrameFiles{idx});

        switch lower(appData.contrastMode)
            case 'imadjust'
                img = imadjust(imread(appData.Video(VideoIndex).FrameFiles{idx}));
            case 'histeq'
                img = histeq(imread(appData.Video(VideoIndex).FrameFiles{idx}));
            case 'adapthisteq'
                img = adapthisteq(imread(appData.Video(VideoIndex).FrameFiles{idx}));
        end


        appData.CurrentFrame = img;
        cla(ax);
        imshow(img, 'Parent', ax);
        lblFrameNum.String = sprintf('%d / %d', idx, appData.Video(VideoIndex).NFrames);


        axis(ax, 'image');  % keep proportions
        hold(ax,'on');
        % Always overlay the initial ROI
        if isfield(appData, 'ROI0')
            rectangle(ax, 'Position', appData.ROI0, ...
                      'EdgeColor', 'g', 'LineStyle', '--', 'LineWidth', 1);
        end
        % If ROI Filter has computed a new ROI, overlay it too
        if isfield(appData, 'ROICurrent')
            rectangle(ax, 'Position', appData.ROICurrent, ...
                      'EdgeColor', 'r', 'LineStyle', '-', 'LineWidth', 1);
        end

        % --- Bright detections (with individual plot controls) ---
        if isfield(appData.Detection, 'Bright') && isfield(appData.Detection.Bright, 'Spots')
            spotsB = appData.Detection.Bright.Spots;
            % Ensure spotsB is a N×4 array
            if isempty(spotsB)
                spotsB = zeros(0,4);
            elseif size(spotsB,2) < 4
                spotsB = [spotsB, idx*ones(size(spotsB,1),1)];
            end
            % Select frames based on AllFrames checkbox
            if chkPlotBrightAllFrames.Value
                selB = true(size(spotsB,1),1);
            else
                selB = (spotsB(:,4) == idx);
            end
            centersB = spotsB(selB,1:2);
            radiiB   = spotsB(selB,3);
            if ~isempty(centersB)
                if chkPlotBrightContour.Value
                    viscircles(ax, centersB, radiiB, 'EdgeColor', '#8acbdd', 'LineWidth', 0.5, 'LineStyle', '--', 'EnhanceVisibility', false);
                end
                if chkPlotBrightCenterDot.Value
                    plot(ax, centersB(:,1), centersB(:,2), '.', 'MarkerSize', 10, 'Color', '#8acbdd');
                end
                if chkPlotBrightCenterPlus.Value
                    plot(ax, centersB(:,1), centersB(:,2), '+', 'MarkerSize', 10, 'Color', '#8acbdd');
                end
                if chkPlotBrightRadius.Value
                    for k = 1:numel(radiiB)
                        text(ax, centersB(k,1), centersB(k,2) - radiiB(k), ...
                             num2str(round(radiiB(k))), 'Color', '#8acbdd', ...
                             'FontSize', 12, 'HorizontalAlignment', 'center');
                    end
                end
            end
        end

        % --- Dark detections (with individual plot controls) ---
        if isfield(appData.Detection, 'Dark') && isfield(appData.Detection.Dark, 'Spots')
            spotsD = appData.Detection.Dark.Spots;
            % Ensure spotsD is a N×4 array
            if isempty(spotsD)
                spotsD = zeros(0,4);
            elseif size(spotsD,2) < 4
                spotsD = [spotsD, idx*ones(size(spotsD,1),1)];
            end
            if chkPlotDarkAllFrames.Value
                selD = true(size(spotsD,1),1);
            else
                selD = (spotsD(:,4) == idx);
            end
            centersD = spotsD(selD,1:2);
            radiiD   = spotsD(selD,3);
            if ~isempty(centersD)
                if chkPlotDarkContour.Value
                    viscircles(ax, centersD, radiiD, 'EdgeColor', '#8893d8', 'LineWidth', 0.5, 'LineStyle', '--', 'EnhanceVisibility', false);
                end
                if chkPlotDarkCenterDot.Value
                    plot(ax, centersD(:,1), centersD(:,2), '.', 'MarkerSize', 10, 'Color', '#8893d8');
                end
                if chkPlotDarkCenterPlus.Value
                    plot(ax, centersD(:,1), centersD(:,2), '+', 'MarkerSize', 10, 'Color', '#8893d8');
                end
                if chkPlotDarkRadius.Value
                    for k = 1:numel(radiiD)
                        text(ax, centersD(k,1), centersD(k,2) - radiiD(k), ...
                             num2str(round(radiiD(k))), 'Color', '#8893d8', ...
                             'FontSize', 12, 'HorizontalAlignment', 'center');
                    end
                end
            end
        end

    end
%% ------------------------ cropImage ------------------------- %%
    function cropImageCallback(~, ~)
        if isempty(appData.CurrentFrame)
            msgbox('No image loaded', 'Error', 'error');
            return;
        end
        rect = getrect(ax);
        cropped = imcrop(appData.CurrentFrame, rect);
        cla(ax);
        ax = axes('Parent', panelRight, 'Units', 'normalized', ...
        'Position', [0.05 0.15 0.9 0.8]);
        imshow(cropped, 'Parent', ax,'InitialMagnification','fit');
        appData.croppedImage = cropped;
    end
%% ------------------------ getRadius ------------------------- %%
    function getRadiusCallback(~, ~)
        if ~isfield(appData, 'croppedImage') || isempty(appData.croppedImage)
            msgbox('First crop the image', 'Error', 'error');
            return;
        end
        [RMin, RMax] = func_getRadiusRange(appData.croppedImage, ax);
        set(inputRMin, 'String', num2str(RMin));
        set(inputRMax, 'String', num2str(RMax));
    end
%% ------------------------ updateSensitivity ------------------------- %%
    function updateSensitivity(src, ~)
        val = src.Value;
        set(txtSensitivity, 'String', sprintf('%.3f', val));
    end
%% ------------------------ manualSensitivity ------------------------- %%
    function manualSensitivityUpdate(src, ~)
        val = str2double(get(src, 'String'));
        if isnan(val) || val < 0.5 || val > 1
            msgbox('Enter a value between 0.5 and 1', 'Invalid value', 'warn');
            set(src, 'String', sprintf('%.3f', sliderSensitivity.Value));
        else
            set(sliderSensitivity, 'Value', val);
        end
    end
%% ------------------------ save Detection Parameters ------------------------- %%
function saveParametersCallback(~, ~)
    % Recolectar RMin, RMax
    RMin = str2double(get(inputRMin, 'String'));
    RMax = str2double(get(inputRMax, 'String'));

    % Sensitivity
    sensitivity = str2double(get(txtSensitivity, 'String'));

    % --- Polarity ---
    polarity = {};  % default como cell vacía
    if get(chkBright, 'Value')
        polarity{end+1} = 'bright';
    end
    if get(chkDark, 'Value')
        polarity{end+1} = 'dark';
    end
    
    % Validación
    if isempty(polarity)
        msgbox('❌ You must select at least one option in Polarity (Bright or Dark).','Error','error');
        return;
    end
    
    % If only one, save as char
    % Convert polarity selection to saved format
    if numel(polarity) == 1
        polarity = polarity{1};      % 'bright' o 'dark'
    elseif numel(polarity) == 2
        polarity = 'both';           % se eligieron ambas opciones
    end
    % EdgeThreshold
    edgeThreshold = str2double(get(txtEdge, 'String'));

   % Obtener Method desde los radio buttons
    if get(radioMethod1, 'Value')
        method = 'TwoStage';
    elseif get(radioMethod2, 'Value')
        method = 'PhaseCode';
    else
        method = 'TwoStage';  % default de seguridad
    end

    % Obtener Preprocess desde los radio buttons
    if get(radioPre1, 'Value')
        preprocess = 'original';
    elseif get(radioPre2, 'Value')
        preprocess = 'imadjust';
    elseif get(radioPre3, 'Value')
        preprocess = 'histeq';
    elseif get(radioPre4, 'Value')
        preprocess = 'adapthisteq';
    else
        preprocess = 'original';  % default de seguridad
    end

    % Guardar todo en el struct
    Dparam = struct(...
        'RMin', RMin, ...
        'RMax', RMax, ...
        'Sensitivity', sensitivity, ...
        'Polarity', polarity, ...
        'EdgeThreshold', edgeThreshold, ...
        'Method', method, ...
        'Preprocess', preprocess ...
    );

    % Obtener carpeta raíz de la secuencia
    VideoIndex = appData.VideoIndex;
    func_MakeFolder(appData.Video(VideoIndex).DetectionFolder)
    % === Validación ===
    if isnan(RMin) || isnan(RMax)
        msgbox('❌ RMin and RMax cannot be empty or NaN.','Error','error');
        return;
    end

    if ~isfinite(RMin) || ~isfinite(RMax) || RMin <= 0 || RMax <= 0
        msgbox('❌ RMin and RMax must be positive and finite.','Error','error');
        return;
    end

    if mod(RMin,1) ~= 0 || mod(RMax,1) ~= 0
        msgbox('❌ RMin and RMax must be integers.','Error','error');
        return;
    end

    if RMin >= RMax
        msgbox('❌ RMin must be less than RMax.','Error','error');
        return;
    end

    if isempty(polarity)
        msgbox('❌ You must select at least one option in Polarity (Bright or Dark).','Error','error');
        return;
    end

    if isnan(sensitivity) || ~isnumeric(sensitivity) || sensitivity < 0.5 || sensitivity > 1
        msgbox('❌ Sensitivity must be between 0.5 and 1.','Error','error');
        return;
    end

    if isnan(edgeThreshold) || edgeThreshold < 0.01 || edgeThreshold > 1
        msgbox('❌ EdgeThreshold must be between 0.01 and 1.','Error','error');
        return;
    end

    if ~ischar(method) || ~ismember(method, {'TwoStage', 'PhaseCode'})
        msgbox('❌ Invalid detection method.','Error','error');
        return;
    end

    if ~ischar(preprocess) || ~ismember(preprocess, {'original','imadjust','histeq','adapthisteq'})
        msgbox('❌ Invalid preprocessing method.','Error','error');
        return;
    end

    save(appData.Video(VideoIndex).DetectionParam,'Dparam');
    msgbox('Parameters saved','Info');

    % Store in appData
    appData.Dparam = Dparam;
end
%% ------------------------ loadParameters ------------------------- %%
    function loadParametersCallback(~, ~)
        VideoIndex = appData.VideoIndex;
        
        if ~exist(appData.Video(VideoIndex).DetectionFolder, 'dir')
            msgbox('Detection folder does not exist','Error','error');
            return;
        end
        [file, path] = uigetfile(fullfile(appData.Video(VideoIndex).DetectionFolder, '*.mat'), 'Select Parameter File');
        if isequal(file,0)
            return;
        end
        s = load(fullfile(path, file));
        if ~isfield(s, 'Dparam')
            msgbox('File does not contain the struct "Dparam"','Error','error');
            return;
        end
        appData.Dparam = s.Dparam;
        set(inputRMin, 'String', num2str(appData.Dparam.RMin));
        set(inputRMax, 'String', num2str(appData.Dparam.RMax));
        set(txtSensitivity, 'String', num2str(appData.Dparam.Sensitivity));
        set(sliderSensitivity, 'Value', appData.Dparam.Sensitivity);
        switch lower(appData.Dparam.Polarity)
            case 'bright'
                set(chkBright, 'Value', 1);
                set(chkDark, 'Value', 0);
            case 'dark'
                set(chkBright, 'Value', 0);
                set(chkDark, 'Value', 1);
            case 'both'
                set(chkBright, 'Value', 1);
                set(chkDark, 'Value', 1);
            otherwise
                set(chkBright, 'Value', 0);
                set(chkDark, 'Value', 0);
        end
        % EdgeThreshold
        set(txtEdge, 'String', num2str(appData.Dparam.EdgeThreshold));
        set(sliderEdge, 'Value', appData.Dparam.EdgeThreshold);
        
        % Method
        switch lower(appData.Dparam.Method)
            case 'twostage'
                set(radioMethod1, 'Value', 1);
                set(radioMethod2, 'Value', 0);
            case 'phasecode'
                set(radioMethod1, 'Value', 0);
                set(radioMethod2, 'Value', 1);
        end
        
        % Preprocess
        set(radioPre1, 'Value', 0);
        set(radioPre2, 'Value', 0);
        set(radioPre3, 'Value', 0);
        set(radioPre4, 'Value', 0);
        
        switch lower(appData.Dparam.Preprocess)
            case 'original'
                set(radioPre1, 'Value', 1);
            case 'imadjust'
                set(radioPre2, 'Value', 1);
            case 'histeq'
                set(radioPre3, 'Value', 1);
            case 'adapthisteq'
                set(radioPre4, 'Value', 1);
        end
        msgbox('Parameters loaded','Info');
    end
%% ------------------------ DetectFrame ------------------------- %%
function detectFrameCallback(~, ~)
    if isempty(appData.CurrentFrame)
        msgbox('No image loaded','Error','error');
        return;
    end
    % If ROI Filter checkbox is on, attempt ROI-based detection on current frame
    if exist('chkROI','var') && get(chkROI, 'Value')
        if isfield(appData, 'ROI0') && ~isempty(appData.ROI0)
            roiDetectFrameCallback();
            return;
        else
            % ROI filter enabled but no ROI defined: ignore and proceed with normal detection
        end
    end

    idx = appData.idx;
    VideoIndex = appData.VideoIndex;

    % === Leer parámetros desde la GUI ===
    RMin = str2double(get(inputRMin, 'String'));
    RMax = str2double(get(inputRMax, 'String'));
    sensitivity = str2double(get(txtSensitivity, 'String'));
    edgeThreshold = str2double(get(txtEdge, 'String'));

    % Polarity
    if get(chkBright, 'Value') && get(chkDark, 'Value')
        polarity = {'bright','dark'};
    elseif get(chkBright, 'Value')
        polarity = 'bright';
    elseif get(chkDark, 'Value')
        polarity = 'dark';
    else
        polarity = [];
    end

    % Method
    if get(radioMethod1, 'Value')
        method = 'TwoStage';
    else
        method = 'PhaseCode';
    end

    % Preprocess
    if get(radioPre1, 'Value')
        preprocess = 'original';
    elseif get(radioPre2, 'Value')
        preprocess = 'imadjust';
    elseif get(radioPre3, 'Value')
        preprocess = 'histeq';
    elseif get(radioPre4, 'Value')
        preprocess = 'adapthisteq';
    else
        preprocess = 'original';
    end

    % === Construir el struct param ===
    param = struct( ...
        'RMin', RMin, ...
        'RMax', RMax, ...
        'Sensitivity', sensitivity, ...
        'EdgeThreshold', edgeThreshold, ...
        'Method', method, ...
        'Polarity', polarity, ...
        'Preprocess', preprocess ...
    );

    % === Preprocesar imagen y detectar ===
    ImagePath = appData.Video(VideoIndex).FrameFiles{idx};
    I = func_preprocess(ImagePath, preprocess);
    Detection = func_FindFilteredCircles(I, param);

    % Append current frame index to each spot set for unified plotting
    if isfield(Detection, 'Bright') && isfield(Detection.Bright, 'Spots')
        spotsB = Detection.Bright.Spots;
        Detection.Bright.Spots = [spotsB, idx*ones(size(spotsB,1),1)];
    end
    if isfield(Detection, 'Dark') && isfield(Detection.Dark, 'Spots')
        spotsD = Detection.Dark.Spots;
        Detection.Dark.Spots = [spotsD, idx*ones(size(spotsD,1),1)];
    end

    % Store updated detection struct
    appData.Detection = Detection;

    % Use showImage to handle all plotting consistently
    showImage();
end
%% ------------------------ detectAll ------------------------- %%
    function detectAllCallback(~, ~)
        % -----------------------------------------------------------
        % Detect circles in *all* frames with robustness against
        % external routines that might clear or close our GUI figure.
        % -----------------------------------------------------------

        % If ROI Filter is on, run adaptive ROI detection for all frames
        if exist('chkROI','var') && get(chkROI,'Value')
            % Run ROI-based detection across all frames
            roiFilterCallback();
            % Save detection results
            VideoIndex = appData.VideoIndex;
            func_MakeFolder(appData.Video(VideoIndex).DetectionFolder);
            Detection = appData.Detection;  %#ok<NASGU>
            save(appData.Video(VideoIndex).DetectionFile, 'Detection');
            % Refresh display and exit
            showImage();
            return;
        end

        % Guardar los parámetros actuales
        saveParametersCallback();

        VideoIndex = appData.VideoIndex;
        ImagePaths = appData.Video(VideoIndex).FrameFiles;

        % --- Backup GUI handles in case they get nuked -------------
        hFig   = gcf;          % Main GUI figure
        tmpFig = figure('Visible', 'off');   % Off‑screen fig to divert plotting

        try
            % Run the heavy detection routine
            Detection = func_DetectAllFrames(ImagePaths, appData.Dparam);
        catch ME
            % Clean up temp fig and re‑throw
            if isvalid(tmpFig), close(tmpFig); end
            rethrow(ME);
        end

        % Close the off‑screen figure
        if isvalid(tmpFig)
            close(tmpFig);
        end

        % Bring focus back to the GUI (it may have been lost)
        if isvalid(hFig)
            figure(hFig);
        end

        % Save detection results
        appData.Detection = Detection;
        func_MakeFolder(appData.Video(VideoIndex).DetectionFolder)
        save(appData.Video(VideoIndex).DetectionFile, 'Detection');

        % Refresh display
        showImage();
    end
 %% ------------------------ loadDetection ------------------------- %%   
    function loadDetectionCallback(~,~)
        idx = appData.idx;
        VideoIndex = appData.VideoIndex;
        DetectionFolder = appData.Video(VideoIndex).DetectionFolder;
        if ~exist(DetectionFolder, 'dir')
            msgbox('Detection folder does not exist','Error','error');
            return;
        end
        [file, path] = uigetfile(fullfile(DetectionFolder, '*.mat'), 'Select Detection File');
        if isequal(file,0)
            return;
        end
        s = load(fullfile(path, file));
        if ~isfield(s, 'Detection')
            msgbox('File does not contain the struct "Detection"','Error','error');
            return;
        end
        appData.Detection = s.Detection;
        showImage()
    end
%% ------------------------ ContrastCallback ------------------------- %%
    function contrastCallback(src,~)
    % Turn off all buttons
    set([rbOriginal, rbImadjust, rbHisteq, rbAdapthisteq], 'Value', 0);

    % Activate only the pressed one
    set(src, 'Value', 1);

    % Store contrast mode in appData
    appData.contrastMode = get(src, 'String');

    % Refresh image
    showImage();
    end
%% ------------------------ trackAllFrames ------------------------- %%
    function trackAllFramesCallback(~, ~)
        % ---------------------------------------------------
        % Track all frames using GUI parameters and save params
        % ---------------------------------------------------
        % Collect tracking parameters from GUI
        Tparam.mem     = str2double(get(inputMemory, 'String'));
        Tparam.good    = str2double(get(inputGood, 'String'));
        Tparam.dim     = str2double(get(inputDim, 'String'));
        Tparam.quiet   = get(chkQuiet, 'Value');
        Tparam.maxdisp = str2double(get(inputMaxDisp, 'String'));

        % Force 2D tracking (ignore radius)
        Tparam.dim = 2;

        % Store parameters globally
        VideoIndex = appData.VideoIndex;
        appData.Tparam = Tparam;

        % Ensure Tracking struct exists
        if ~isfield(appData, 'Tracking') || ~isstruct(appData.Tracking)
            appData.Tracking = struct();
        end
        if ~isfield(appData.Tracking, 'Bright') || ~isstruct(appData.Tracking.Bright)
            appData.Tracking.Bright = struct();
        end
        if ~isfield(appData.Tracking, 'Dark') || ~isstruct(appData.Tracking.Dark)
            appData.Tracking.Dark = struct();
        end

        % Prepare storage for per-polarity tracking
        appData.Video(VideoIndex).Tracking = struct();

        % Track Bright spots only if any detected
        if isfield(appData.Detection, 'Bright') && isfield(appData.Detection.Bright, 'Spots')
            SpotsB = appData.Detection.Bright.Spots;
            if ~isempty(SpotsB)
                TrajB = track(SpotsB, Tparam.maxdisp, Tparam);
            else
                TrajB = [];
            end
            appData.Tracking.Bright.Trajectories = TrajB;
        end
        
        % Track Dark spots only if any detected
        if isfield(appData.Detection, 'Dark') && isfield(appData.Detection.Dark, 'Spots')
            SpotsD = appData.Detection.Dark.Spots;
            if ~isempty(SpotsD)
                TrajD = track(SpotsD, Tparam.maxdisp, Tparam);
            else
                TrajD = [];
            end
            appData.Tracking.Dark.Trajectories = TrajD;
        end
        
            % … tras haber llenado appData.Tracking con Bright y Dark …

        % —––– Guardado de parámetros y resultados ––––––––––––––––––––
        % Asegúrate de que existe la carpeta de salida
        func_MakeFolder(appData.Video(VideoIndex).DetectionFolder);

        % Guardar Tparam (igual que Dparam)
        Tparam = appData.Tparam;  
        save(appData.Video(VideoIndex).TrackingParam, 'Tparam');

        % Guardar todo el struct Tracking
        Tracking = appData.Tracking;
        save(appData.Video(VideoIndex).TrackingFile, 'Tracking');

        % Finalmente la notificación
        msgbox('Tracking complete for available polarities', 'Info');
    end
%% ------------------------ browseRoot ------------------------- %%
    function browseRootCallback(~, ~)
        folder = uigetdir;
        if folder ~= 0
            appData.rootDir = folder;
        end
    end
%% ------------------------ searchFolders ------------------------- %%    
    function searchFoldersCallback(~, ~)
        if ~isfield(appData, 'rootDir') || ~isfolder(appData.rootDir)
            msgbox('Please select a valid root directory.', 'Error', 'error');
            return;
        end

        pattern = get(inputPattern, 'String');
        paths = func_FindInDirectory(appData.rootDir, pattern);

        if isempty(paths)
            set(txtSearchResults, 'String', 'No folders found.');
            return;
        end

        appData.VideoIndex = 1;

        % Count total images
        totalImages = 0;
        NVideos = numel(paths);
        appData.NVideos = NVideos;
        for i = 1:NVideos
            appData.Video(i).ImageSequence = paths{i};
            [NImages,ImgFileNames] = func_SortFileNames(paths{i},'*.tif');
            appData.Video(i).FrameFiles = fullfile(paths{i},ImgFileNames);
            appData.Video(i).Container = fileparts(paths{i});  
            appData.Video(i).DetectionFolder = fullfile(appData.Video(i).Container, 'Detection');
            appData.Video(i).DetectionFile = fullfile(appData.Video(i).DetectionFolder, 'Detection.mat');
            appData.Video(i).TrackingFile = fullfile(appData.Video(i).DetectionFolder, 'Tracking.mat');
            appData.Video(i).TrajectoriesFile = fullfile(appData.Video(i).DetectionFolder, 'Trajectories.mat');
            appData.Video(i).DetectionParam = fullfile(appData.Video(i).DetectionFolder, 'DetectionParameters.mat');
            appData.Video(i).TrackingParam = fullfile(appData.Video(i).DetectionFolder, 'TrackingParameters.mat');
            appData.Video(i).NFrames = NImages;
            totalImages = totalImages + NImages;
        end
        appData.NFrames = totalImages;

        % Update status
        set(txtSearchResults, 'String', ...
            sprintf('Found %d folders – %d total images', NVideos, totalImages));

        loadImageSequence(appData.Video(1).ImageSequence);
        showImage();
    end
%% ------------------------ loadIS ------------------------- %%
    function loadImageSequence(folderPath)
        VideoIndex = appData.VideoIndex;

        % Validate current video entry
        if ~isfield(appData, 'Video') || VideoIndex < 1 || VideoIndex > numel(appData.Video)
            msgbox('Invalid video index.','Error','error');
            return;
        end

        % Retrieve pre-stored frame file list
        FrameFiles = appData.Video(VideoIndex).FrameFiles;
        if isempty(FrameFiles)
            msgbox('No images found for this video.','Error','error');
            return;
        end

        % Update slider based on number of frames
        N = numel(FrameFiles);
        set(txtPathImport, 'String', appData.Video(VideoIndex).ImageSequence);
        set(slider, 'Min', 1, 'Max', N, 'Value', 1);
        if N > 1
            set(slider, 'SliderStep', [1 min(10, N-1)] / (N - 1));
        end

        % Calculate default edge threshold using Otsu's method on the first frame
        img0 = imread(FrameFiles{1});
        defaultEdge = graythresh(img0);
        set(sliderEdge, 'Value', defaultEdge);
        set(txtEdge, 'String', sprintf('%.3f', defaultEdge));
        appData.Dparam.EdgeThreshold = defaultEdge;

        % Initialize current frame index
        appData.idx = 1;
        appData.NFrames = N;

        % Clear previous detection and parameters
        appData.Detection = [];

        % Initialize tracking defaults
        appData.Tparam.mem     = 10;
        appData.Tparam.good    = max(round(appData.Video(VideoIndex).NFrames/3),100);
        appData.Tparam.dim     = 2;
        if isfield(appData.Dparam, 'RMax')
            appData.Tparam.maxdisp = appData.Dparam.RMax/2;
        else
            appData.Tparam.maxdisp = 10;  % fallback if no Dparam.RMax
        end
        % Update UI fields with these defaults
        set(inputMemory, 'String', num2str(appData.Tparam.mem));
        set(inputGood,   'String', num2str(appData.Tparam.good));
        set(inputDim,    'String', num2str(appData.Tparam.dim));
        set(inputMaxDisp,'String', num2str(appData.Tparam.maxdisp));

        % Auto-load detection parameters if available
        paramFile = appData.Video(VideoIndex).DetectionParam;
        if exist(paramFile, 'file')
            tmp = load(paramFile);
            if isfield(tmp, 'Dparam')
                appData.Dparam = tmp.Dparam;
                % Update GUI controls only if fields exist
                if isfield(appData.Dparam, 'RMin')
                    set(inputRMin, 'String', num2str(appData.Dparam.RMin));
                end
                if isfield(appData.Dparam, 'RMax')
                    set(inputRMax, 'String', num2str(appData.Dparam.RMax));
                end
                if isfield(appData.Dparam, 'Sensitivity')
                    sens = appData.Dparam.Sensitivity;
                    % Validation: [0, 1] instead of [0.5, 1]
                    if ~isnumeric(sens) || ~isscalar(sens) || sens < 0 || sens > 1
                        sens = 0.99;
                    end
                    set(sliderSensitivity, 'Value', sens);
                    set(txtSensitivity,   'String', num2str(sens));
                end
                if isfield(appData.Dparam, 'EdgeThreshold')
                    et = appData.Dparam.EdgeThreshold;
                    % Validation: [0, 1] instead of [0.01, 1]
                    if ~isnumeric(et) || ~isscalar(et) || et < 0 || et > 1
                        et = defaultEdge;
                    end
                    set(sliderEdge, 'Value', et);
                    set(txtEdge,    'String', num2str(et));
                end
                if isfield(appData.Dparam, 'Method')
                    % Ensure Method is a char vector
                    meth = appData.Dparam.Method;
                    if iscell(meth)
                        meth = meth{1};
                    end
                    if isstring(meth)
                        meth = char(meth);
                    end
                    if ischar(meth)
                        switch lower(meth)
                            case 'twostage'
                                set(radioMethod1, 'Value', 1); set(radioMethod2, 'Value', 0);
                            case 'phasecode'
                                set(radioMethod1, 'Value', 0); set(radioMethod2, 'Value', 1);
                        end
                    end
                end
                if isfield(appData.Dparam, 'Preprocess')
                    % Reset all preprocess radios
                    set(radioPre1, 'Value', 0); set(radioPre2, 'Value', 0);
                    set(radioPre3, 'Value', 0); set(radioPre4, 'Value', 0);
                    switch lower(appData.Dparam.Preprocess)
                        case 'original',    set(radioPre1, 'Value', 1);
                        case 'imadjust',    set(radioPre2, 'Value', 1);
                        case 'histeq',      set(radioPre3, 'Value', 1);
                        case 'adapthisteq', set(radioPre4, 'Value', 1);
                    end
                end
            end
        end
        % Set default ROI size based on RMax: 2*9/3 * RMax = 6 * RMax
        if isfield(appData.Dparam, 'RMax')
            defaultROI = 6 * appData.Dparam.RMax;
        else
            defaultROI = 100;  % fallback
        end
        set(inputROISize, 'String', num2str(defaultROI));
        appData.ROIdefaultSize = defaultROI;
        % Auto-load polarity setting if available
        if isfield(appData.Dparam, 'Polarity')
            switch lower(appData.Dparam.Polarity)
                case 'bright'
                    set(chkBright, 'Value', 1);
                    set(chkDark,   'Value', 0);
                case 'dark'
                    set(chkBright, 'Value', 0);
                    set(chkDark,   'Value', 1);
                case 'both'
                    set(chkBright, 'Value', 1);
                    set(chkDark,   'Value', 1);
                otherwise
                    set(chkBright, 'Value', 0);
                    set(chkDark,   'Value', 0);
            end
        end

        % Auto-load detection results if available
        detFile = appData.Video(VideoIndex).DetectionFile;
        if exist(detFile, 'file')
            tmp = load(detFile);
            if isfield(tmp, 'Detection')
                appData.Detection = tmp.Detection;
            end
        end

        % Auto-load tracking parameters if available
        tparamFile = appData.Video(VideoIndex).TrackingParam;
        if exist(tparamFile, 'file')
            tmpTP = load(tparamFile);
            if isfield(tmpTP, 'Tparam')
                appData.Tparam = tmpTP.Tparam;
                % Update UI fields
                set(inputMemory, 'String', num2str(appData.Tparam.mem));
                set(inputGood,   'String', num2str(appData.Tparam.good));
                set(inputDim,    'String', num2str(appData.Tparam.dim));
                set(inputMaxDisp,'String', num2str(appData.Tparam.maxdisp));
            end
        end

        % Auto-load tracking results if available
        trackFile = appData.Video(VideoIndex).TrackingFile;
        if exist(trackFile, 'file')
            tmpTr = load(trackFile);
            if isfield(tmpTr, 'Tracking')
                appData.Tracking = tmpTr.Tracking;
            end
        end

        % Display first image
        showImage();
    end
%%
    function updateVideoLabel()
        str = sprintf('Video %d of %d', appData.VideoIndex, appData.NVideos);
        set(appData.lblVideoImport, 'String', str);
        set(appData.lblVideoDetection, 'String', str);
        set(appData.lblVideoTracking, 'String', str);

    end
%%
    function prevVideoCallback(~, ~)
        if appData.VideoIndex > 1
            appData.VideoIndex = appData.VideoIndex - 1;
            loadImageSequence(appData.Video(appData.VideoIndex).ImageSequence);
            updateVideoLabel();
        else
            msgbox('Already at first video.', 'Info');
        end
    end
%%
    function nextVideoCallback(~, ~)
        if appData.VideoIndex < numel(appData.Video)
            appData.VideoIndex = appData.VideoIndex + 1;
            loadImageSequence(appData.Video(appData.VideoIndex).ImageSequence);
            updateVideoLabel();
        else
            msgbox('Already at last video.', 'Info');
        end
    end
%%
    function saveISCallback(~, ~)
        if ~isfield(appData, 'Video') || isempty(appData.Video)
            msgbox('No data to save.', 'Error', 'error');
            return;
        end
        Date = datetime('now');
        rootDir = appData.rootDir;
        % File paths
        savePath = fullfile(rootDir, 'filepaths.mat');
        csvPath  = fullfile(rootDir, 'filepaths.csv');
        txtPath  = fullfile(rootDir, 'filepaths.txt');
        % Save .mat containing the full Video struct
        Video = appData.Video;
        save(savePath, 'Video', 'Date');
        % Build CSV: one row per video
        NVideos = numel(Video);
        rows = cell(NVideos, 2);
        for i = 1:NVideos
            rows{i,1} = Video(i).ImageSequence; 
            rows{i,2} = Video(i).NFrames;
        end
        T = cell2table(rows, 'VariableNames', {'FolderPath','NFrames'});
        writetable(T, csvPath);
        % Write summary txt
        fid = fopen(txtPath, 'w');
        fprintf(fid, 'Date: %s\n\n', datestr(Date));
        total = 0;
        for i = 1:NVideos
            fprintf(fid, 'Video %d:\n  Folder: %s\n  Frames: %d\n\n', ...
                    i, Video(i).ImageSequence, Video(i).NFrames);
            total = total + Video(i).NFrames;
        end
        fprintf(fid, 'Total frames across all videos: %d\n', total);
        fclose(fid);
        % Inform user
        msgbox(['File paths saved to:' newline savePath newline csvPath newline txtPath], 'Success');
    end
%%
    function loadISCallback(~, ~)
        [file, path] = uigetfile('filepaths.mat', 'Select filepaths.mat');
        if isequal(file, 0)
            return;
        end
        data = load(fullfile(path, file));
        if ~isfield(data, 'Video')
            msgbox('Invalid file. Expected variable Video.', 'Error', 'error');
            return;
        end
        appData.Video  = data.Video;
        appData.NVideos = numel(appData.Video);
        appData.NFrames = sum([appData.Video.NFrames]);
        appData.VideoIndex = 1;
        if isfield(data, 'Date')
            msgbox(['✅ Loaded filepaths from: ' datestr(data.Date)], 'Loaded');
        else
            msgbox('✅ Filepaths loaded successfully', 'Loaded');
        end
        loadImageSequence(appData.Video(1).ImageSequence);
        updateVideoLabel();
    end
    function setMethod(value)
        appData.Dparam.Method = value;
        switch value
            case 'TwoStage'
                set(radioMethod1, 'Value', 1);
                set(radioMethod2, 'Value', 0);
            case 'PhaseCode'
                set(radioMethod1, 'Value', 0);
                set(radioMethod2, 'Value', 1);
        end
    end
    function updateEdgeThreshold(src, ~)
        val = get(src, 'Value');
        set(txtEdge, 'String', num2str(val, '%.3f'));
        appData.Dparam.EdgeThreshold = val;
    end
    function manualEdgeThresholdUpdate(src, ~)
        val = str2double(get(src, 'String'));
        if isnan(val)
            val = appData.Dparam.EdgeThreshold;  % volver al último valor si escribieron basura
        end
        val = min(max(val, 0.01), 1);  % clamp entre 0.01 y 1
        set(src, 'String', num2str(val, '%.3f'));
        set(sliderEdge, 'Value', val);
        appData.Dparam.EdgeThreshold = val;
    end
    function setPreprocess(value)
        if ~isfield(appData,'Dparam'), appData.Dparam = struct(); end
            appData.Dparam.Preprocess = value;
        % Reset todos los radios
        set(radioPre1, 'Value', 0);
        set(radioPre2, 'Value', 0);
        set(radioPre3, 'Value', 0);
        set(radioPre4, 'Value', 0);
    
        % Activar solo el seleccionado
        switch value
            case 'original'
                set(radioPre1, 'Value', 1);
            case 'imadjust'
                set(radioPre2, 'Value', 1);
            case 'histeq'
                set(radioPre3, 'Value', 1);
            case 'adapthisteq'
                set(radioPre4, 'Value', 1);
        end
    end
%% ------------------------ ROI Filter Callbacks ------------------------- %%
    function setROICallback(~, ~)
        % Let user draw initial ROI on current frame
        appData.ROI0 = getrect(ax);
        msgbox('ROI set','Info');
    end

    function roiFilterCallback(~, ~)
        % Adaptive ROI Filter across frames
        if ~isfield(appData, 'ROI0')
            msgbox('Define ROI first','Error','error');
            return;
        end
        a = str2double(get(inputROISize, 'String'));
        show = get(chkShowROI, 'Value');
        VideoIndex = appData.VideoIndex;
        N = appData.Video(VideoIndex).NFrames;
        % Start from the currently selected frame
        startFrame = appData.idx;
        ROI = appData.ROI0;
        for i = startFrame:N
            % Load and preprocess according to current detection preprocess setting
            img = func_preprocess(appData.Video(VideoIndex).FrameFiles{i}, appData.Dparam.Preprocess);
            % Crop to current ROI
            sub = imcrop(img, ROI);
            % Detect in sub-image
            D = func_FindFilteredCircles(sub, appData.Dparam);
            %disp(D)
            % Ensure D is a struct with Bright and Dark fields
            if ~isstruct(D) || (~isfield(D,'Bright') && ~isfield(D,'Dark'))
                D = struct('Bright', struct('Spots', []), 'Dark', struct('Spots', []));
            end
            % Bright spots: offset back to full-image coords
            if isfield(D, 'Bright') && ~isempty(D.Bright.Spots)
                sb = D.Bright.Spots;
                sb = [sb(:,1) + ROI(1), sb(:,2) + ROI(2), sb(:,3), i * ones(size(sb,1),1)];
                if ~isfield(appData.Detection, 'Bright') || ~isfield(appData.Detection.Bright, 'Spots') || isempty(appData.Detection.Bright.Spots)
                    appData.Detection.Bright.Spots = sb;
                else
                    appData.Detection.Bright.Spots = [appData.Detection.Bright.Spots; sb];
                end
            end
            % Dark spots
            if isfield(D, 'Dark') && ~isempty(D.Dark.Spots)
                sd = D.Dark.Spots;
                sd = [sd(:,1) + ROI(1), sd(:,2) + ROI(2), sd(:,3), i * ones(size(sd,1),1)];
                if ~isfield(appData.Detection, 'Dark') || ~isfield(appData.Detection.Dark, 'Spots') || isempty(appData.Detection.Dark.Spots)
                    appData.Detection.Dark.Spots = sd;
                else
                    appData.Detection.Dark.Spots = [appData.Detection.Dark.Spots; sd];
                end
            end
            % Optionally show ROI and adaptive circle on GUI
            if show
                cla(ax);
                % Display with viewer contrast setting
                raw = imread(appData.Video(VideoIndex).FrameFiles{i});
                switch lower(appData.contrastMode)
                    case 'imadjust'
                        raw = imadjust(raw);
                    case 'histeq'
                        raw = histeq(raw);
                    case 'adapthisteq'
                        raw = adapthisteq(raw);
                end
                imshow(raw, 'Parent', ax);
                hold(ax, 'on');
                % Draw ROI
                rectangle(ax, 'Position', ROI, 'EdgeColor', 'g', 'LineStyle', '--', 'LineWidth', 1);
                % Compute and draw circle at mean spot location
                allSpots = [D.Bright.Spots; D.Dark.Spots];
                if ~isempty(allSpots)
                    % Centroid in sub-image coords
                    ctrSub = mean(allSpots(:,1:2), 1);
                    % Convert to full-image coords
                    ctrFull = [ROI(1) + ctrSub(1), ROI(2) + ctrSub(2)];
                    % Circle radius = (10/3) * RMax
                    radius = (10/3) * appData.Dparam.RMax;
                    viscircles(ax, ctrFull, radius, ...
                        'EdgeColor', '#FF6600', ...
                        'LineStyle', '--', ...
                        'LineWidth', 0.5, ...
                        'EnhanceVisibility', false);
                end
                drawnow;
            end
            % Compute new ROI center from mean of detections in sub
            allSub = [D.Bright.Spots; D.Dark.Spots];
            if ~isempty(allSub)
                ctr = mean(allSub(:,1:2), 1);
                % Update ROI (centered square of side a)
                ROI = [ROI(1) + ctr(1) - a/2, ROI(2) + ctr(2) - a/2, a, a];
            end
            appData.ROICurrent = ROI;
            % Stop if ROI reaches image border
            [imgH, imgW, ~] = size(img);
            % ROI = [x, y, w, h]
            if ROI(1) <= 1 || ROI(2) <= 1 || (ROI(1) + ROI(3)) >= imgW || (ROI(2) + ROI(4)) >= imgH
                msgbox('ROI reached image boundary; stopping filter','Info');
                break;
            end
        end
        % Refresh display with final detections
        showImage();
        msgbox('Adaptive ROI Filter complete','Info');
    end
    function roiDetectFrameCallback(~, ~)
        % Detect circles in the current frame within the user-defined ROI
        if ~isfield(appData, 'ROI0')
            msgbox('Define ROI first','Error','error');
            return;
        end
        idx = appData.idx;
        VideoIndex = appData.VideoIndex;
        ROI = appData.ROI0;
        % Load and preprocess current frame before cropping
        img = func_preprocess(appData.Video(VideoIndex).FrameFiles{idx}, appData.Dparam.Preprocess);
        sub = imcrop(img, ROI);
        % Run detection on the sub-image
        Draw = func_FindFilteredCircles(sub, appData.Dparam);
        % Coerce to struct with Bright and Dark fields
        if ~isstruct(Draw) || (~isfield(Draw,'Bright') && ~isfield(Draw,'Dark'))
            Draw = struct('Bright', struct('Spots', []), 'Dark', struct('Spots', []));
        end
        % Bright spots: offset back to full-image coords
        if isfield(Draw, 'Bright') && ~isempty(Draw.Bright.Spots)
            sb = Draw.Bright.Spots;
            sb = [sb(:,1)+ROI(1), sb(:,2)+ROI(2), sb(:,3), idx*ones(size(sb,1),1)];
            if isfield(appData.Detection, 'Bright') && isfield(appData.Detection.Bright, 'Spots') && ~isempty(appData.Detection.Bright.Spots)
                appData.Detection.Bright.Spots = [appData.Detection.Bright.Spots; sb];
            else
                appData.Detection.Bright.Spots = sb;
            end
        end
        % Dark spots
        if isfield(Draw, 'Dark') && ~isempty(Draw.Dark.Spots)
            sd = Draw.Dark.Spots;
            sd = [sd(:,1)+ROI(1), sd(:,2)+ROI(2), sd(:,3), idx*ones(size(sd,1),1)];
            if isfield(appData.Detection, 'Dark') && isfield(appData.Detection.Dark, 'Spots') && ~isempty(appData.Detection.Dark.Spots)
                appData.Detection.Dark.Spots = [appData.Detection.Dark.Spots; sd];
            else
                appData.Detection.Dark.Spots = sd;
            end
        end
        % Refresh display, using viewer contrast setting
        cla(ax);
        % Display with viewer contrast setting
        raw = imread(appData.Video(VideoIndex).FrameFiles{idx});
        switch lower(appData.contrastMode)
            case 'imadjust'
                raw = imadjust(raw);
            case 'histeq'
                raw = histeq(raw);
            case 'adapthisteq'
                raw = adapthisteq(raw);
        end
        imshow(raw, 'Parent', ax);
        hold(ax, 'on');
        % Optionally, mark the ROI (optional, not required by instructions)
        %rectangle(ax, 'Position', ROI, 'EdgeColor', 'g', 'LineStyle', '--', 'LineWidth', 1);
        appData.ROICurrent = ROI;
    end
%% ------------------------ -end- ------------------------- %%
end