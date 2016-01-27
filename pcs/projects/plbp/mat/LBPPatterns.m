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
    % ClassID from subject directory
    ID = fliplr(strtok(fliplr(SubjectDirPath),filesep ));
    Filenames = dir(SubjectDirPath);
    FileCount = numel(Filenames);
    for k = 3:FileCount % Save last image file for testing.
        cnt = cnt + 1;
        Filename = fullfile(SubjectDirPath, Filenames(k).name);
        img = imread(Filename);
        img = ViolaJonesCropping(img);
        GrayImage = im2double(img);
        % GrayImage = imread(Filename);
        % GrayImage = im2double(GrayImage);
        GrayImage = (GrayImage - mean(GrayImage(:)))/std(GrayImage(:))* 20 + 128; % image normalization, to remove global intensity.
        LbpPattern = lbp(GrayImage, R, P, Mapping, 'h');
        LBP_Pattern(cnt,:) = RandomProjection * LbpPattern' + B;
        % Index = strfind(Filename,filesep);
        % l = numel(Index);
        % ClassID(cnt,:) = str2num(Filename(Index(l-1)+1 : Index(l)-1));
        ClassID(cnt,:) = {ID};
        File(cnt,:) = {Filename};
    end
end
OutputParam.LBP_Pattern = LBP_Pattern;
OutputParam.TrainClassID = ClassID;
OutputParam.Filenames = File;
end