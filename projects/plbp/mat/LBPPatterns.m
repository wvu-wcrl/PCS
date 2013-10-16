function OutputParam = LBPPatterns(InputParam)

% OutputParam.InputParam = InputParam;
SubjectDirPaths = InputParam.SubjectDirPaths;
Count = numel(SubjectDirPaths);
Mapping = InputParam.Mapping;
% N = InputParam.N;
RandomProjection = InputParam.RandomProjection;
B = InputParam.B;
R = InputParam.R;
P = InputParam.P;
cnt = 0;
for i = 1:Count
    SubjectDirPath = char(SubjectDirPaths(i));
    % Filenames = dir(fullfile(SubjectDirPath, '*.ppm'));
    Filenames = dir(SubjectDirPath);
    FileCount = numel(Filenames);
    % for k = 1:FileCount-1 % Save last image file for testing.
    for k = 3:FileCount % Save last image file for testing.
        cnt = cnt + 1;
        Filename = fullfile(SubjectDirPath, Filenames(k).name);
        GrayImage = imread(Filename);
        GrayImage = im2double(GrayImage);
        GrayImage = (GrayImage - mean(GrayImage(:)))/std(GrayImage(:))* 20 + 128; % image normalization, to remove global intensity.
        LbpPattern = lbp(GrayImage, R, P, Mapping, 'h');
        LBP_Pattern(cnt,:) = RandomProjection * LbpPattern' + B;
        % Index = strfind(Filename,'\');
        Index = strfind(Filename,filesep);
        l = numel(Index);
        ClassID(cnt,:) = str2num(Filename(Index(l-1)+1 : Index(l)-1));
        File(cnt,:) = {Filename};
    end
end
OutputParam.LBP_Pattern = LBP_Pattern;
OutputParam.TrainClassID = ClassID;
OutputParam.Filenames = File;
end