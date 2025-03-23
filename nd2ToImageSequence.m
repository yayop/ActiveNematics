clear, close all
%Root = "\\Actnem\all_protocols_and_methods\XA_Reports_DataAnalysis_Literature\1_RAW_VIDEOS\CONFOCAL\20cSt_OIL_DEFINITIVE_VIDEOS";
%Root = '/Volumes/ALL_PROTOCOLS_AND_METHODS/XA_Reports_DataAnalysis_Literature/1_RAW_VIDEOS/CONFOCAL/20cSt_OIL_DEFINITIVE_VIDEOS';
Root = '/Users/edgardorosas/Desktop/K';
nd2PathNames = func_FindInDirectory(Root,'.nd2');
NVideos = length(nd2PathNames);
for j = 1:NVideos
    nd2PathName = nd2PathNames{j};
    FolderPathName = regexprep(nd2PathName,'.nd2','','ignorecase');
    ImageSequencePathName = strcat(FolderPathName,filesep,'ImageSequence');
    if ~exist(ImageSequencePathName, 'dir') || isempty(ImageSequencePathName)
        try
            I = bfopen(char(nd2PathName)); N = size(I{1},1); 
            I = reshape(cell2mat(I{1}(1:N)),[size(I{1}{1}),N]);
            nd2reader = [];
        catch
            nd2reader = bfGetReader(char(nd2PathName)); 
            N = nd2reader.getImageCount();
            I = [];
        end
        
        VideoBGFolderPathName = MakeFolder(FolderPathName, 'VideoBackground (average)');
        TIF_bgPathName_16bits = strcat(VideoBGFolderPathName, filesep, 'TIF_bg_16bits.tif');
        TIF_bgPathName_08bits = strcat(VideoBGFolderPathName, filesep, 'TIF_bg_08bits.tif');
        MAT_bgPathName = strcat(VideoBGFolderPathName, filesep, 'MAT_bg.mat');
        if ~exist(TIF_bgPathName_16bits, 'file') 
            if ~isempty(I)
                bg16bits = mean(I,3,'native');
                bg_double = double(bg16bits);
            else
                [bg_double, bg16bits] = ND2mean(nd2reader);
            end
            bg08bits = uint8(rescale(bg_double,0,2^8 -1));
            imwrite(bg08bits, TIF_bgPathName_08bits);
            imwrite(bg16bits, TIF_bgPathName_16bits);
            save(MAT_bgPathName, 'bg_double');
            close all
        else
            load(MAT_bgPathName, 'bg_double')
        end
        MakeFolder(FolderPathName,'ImageSequence');
        if ~isempty(I)
            parfor i = 1:N
                ImgClean = uint16(rescale(double(I(:,:,i))./bg_double,0,2^(16)-1));
                ImgFileName = fullfile(ImageSequencePathName, sprintf('Frame_%04d.tif',i));
                imwrite(ImgClean, ImgFileName);
            end
        else
             
             for i = 1:N
                ImgClean = imadjust(uint16(rescale(double(bfGetPlane(nd2reader,i))./bg_double,0,2^(16)-1)));
                ImgFileName = fullfile(ImageSequencePathName, sprintf('Frame_%04d.tif',i));
                imwrite(ImgClean, ImgFileName);
             end

        end
    end
end