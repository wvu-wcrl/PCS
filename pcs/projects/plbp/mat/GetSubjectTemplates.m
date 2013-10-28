function [LBP_Pattern, ClassID, File] = GetSubjectTemplates(SubjectDirPath, Mapping, RandomProjection, B, R, P)    
    % ClassID from subject directory
    ID = fliplr(strtok(fliplr(SubjectDirPath),filesep ));
    Filenames = dir(SubjectDirPath);
    file_count = numel(Filenames);
    cnt = 0;
    for k = 3 : file_count
        cnt = cnt + 1;
        Filename = fullfile(SubjectDirPath, Filenames(k).name)
        img = imread(Filename);
        size(img)
        img = ViolaJonesCropping(img);
        GrayImage = im2double(img);
        GrayImage = (GrayImage - mean(GrayImage(:)))/std(GrayImage(:))* 20 + 128; % image normalization, to remove global intensity  
        lbp_pattern = lbp(GrayImage, R, P, Mapping, 'h');
        LBP_Pattern(cnt,:) = RandomProjection * lbp_pattern' + B;      
        ClassID(cnt,:) = {ID};         
        File(cnt,:) = {Filename};
    end     
end
