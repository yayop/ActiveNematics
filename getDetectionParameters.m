clear, close all
try 
    addpath(genpath('H:\My Drive\PhD ESPCI'))
    Root = '\\Actnem\all_protocols_and_methods\XA_Reports_DataAnalysis_Literature\1_RAW_VIDEOS\CONFOCAL\20cSt_OIL_DEFINITIVE_VIDEOS';
catch
    addpath(genpath('H:\My Drive\PhD ESPCI'))
    Root = '/Volumes/ALL_PROTOCOLS_AND_METHODS/XA_Reports_DataAnalysis_Literature/1_RAW_VIDEOS/CONFOCAL/20cSt_OIL_DEFINITIVE_VIDEOS';
end
nd2PathNames = func_FindInDirectory(Root, '.nd2');
NVideos = length(nd2PathNames);
%%
for j = 1:NVideos

    nd2PathName = nd2PathNames{j};
    nd2reader = bfGetReader(char(nd2PathName));
    NFrames = nd2reader.getImageCount();

    FolderPathName = regexprep(nd2PathName, '.nd2', '', 'ignorecase');
    ImageSequencePathName = strcat(FolderPathName, filesep, ...
        'ImageSequence');
    % Count existing image files to verify if processing is needed
    NImages = numel(dir(fullfile(ImageSequencePathName, '*.tif')));
    

    [~, ImageSequenceFileNames] = func_SortFileNames( ...
        ImageSequencePathName, '*.tif');
    DetectionFolderPathName = strcat(fileparts(ImageSequencePathName), ...
        filesep,'Detection');

    func_MakeFolder(DetectionFolderPathName);

    ParametersFilePathName = strcat(DetectionFolderPathName,filesep, ...
        'DetectionParameters.mat');
    I = imread(strcat(ImageSequencePathName,filesep, ...
        ImageSequenceFileNames{1}));
    if ~exist(ParametersFilePathName, 'file')
        J = imcrop(I);
        DetectionParameters = func_getParameters(J);
        [C, R] = FindFilteredCircles(I,[DetectionParameters.RMin, ...
            DetectionParameters.RMax], ...
            DetectionParameters.sensitivity,DetectionParameters.polarity);
        imshow(I)
        viscircles(C,R,'EnhanceVisibility',0,'Color','g')
        pause
        save(ParametersFilePathName, 'DetectionParameters');
    end
    close all
    
end