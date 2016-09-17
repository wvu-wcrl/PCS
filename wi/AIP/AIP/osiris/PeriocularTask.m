function OutputParam=PeriocularTask(InputParam,IrisCloudCodeRoot)
ImageOnePath=InputParam.ImageOnePath;
ImageTwoPath=InputParam.ImageTwoPath;
AlgorithmName=InputParam.AlgorithmParams.AlgorithmName;
AlgorithmPath=fullfile(IrisCloudCodeRoot,'algorithms',AlgorithmName);
oldFolder=cd(AlgorithmPath);
%addpath(genpath(AlgorithmPath));
MatchingScore=MICHE_Demo(ImageOnePath,ImageTwoPath);
cd(oldFolder);
OutputParam.MatchingScore=MatchingScore;

