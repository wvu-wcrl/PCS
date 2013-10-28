function TestTemplate = GetTestTemplate(Filename, RandomProjection, B, Mapping, R, P, UserCodeRoot)

% addpath( fullfile( filesep, 'rhome', 'pcs', 'projects', 'plbp', 'mat' ) );
% addpath( fullfile( filesep,  'home', 'pcs', 'projects', 'plbp', 'mat' ) );

CurImg = imread(Filename);
CurImg = ViolaJonesCropping(CurImg);
% error('CurImgR:%d CurImgC:%d',size(CurImg,1),size(CurImg,2))
GrayImage = im2double(CurImg);
% GrayImage = imread(Filename);
% GrayImage = im2double(GrayImage);
GrayImage = (GrayImage - mean(GrayImage(:)))/std(GrayImage(:))* 20 + 128; % image normalization, to remove global intensity.
% CurrPath = pwd;

% try
%     if ismac
%         DirPath = UserCodeRoot;
%     else
%         len = size(UserCodeRoot, 2);
%         DirPath = ['/' UserCodeRoot(3:len)];
%     end
%     cd(DirPath);
% catch
%     DirPath = UserCodeRoot;
%     cd(DirPath);
% end

LbpPattern = lbp(GrayImage, R, P, Mapping, 'h');
% cd(CurrPath);

TestTemplate(1,:) = RandomProjection * LbpPattern' + B;
end