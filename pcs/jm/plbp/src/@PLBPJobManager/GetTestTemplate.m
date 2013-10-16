function TestTemplate = GetTestTemplate(obj, Filename, RandomProjection, B, Mapping, R, P, UserCodeRoot)

GrayImage = imread(Filename);
GrayImage = im2double(GrayImage);
GrayImage = (GrayImage - mean(GrayImage(:)))/std(GrayImage(:))* 20 + 128; % image normalization, to remove global intensity.
CurrPath = pwd;

if ismac
    DirPath = UserCodeRoot;
else
    len = size(UserCodeRoot, 2);
    DirPath = ['/' UserCodeRoot(3:len)];
end

cd(DirPath);
LbpPattern = lbp(GrayImage, R, P, Mapping, 'h');
cd(CurrPath);

TestTemplate(1,:) = RandomProjection * LbpPattern' + B;
end