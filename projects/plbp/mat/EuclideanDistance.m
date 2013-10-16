function OutputParam = EuclideanDistance(InputParam)
X = InputParam.TrainModel;
Y = InputParam.TestTemplate;
m = size(X,1);
n = size(Y,1);
XX = sum(X.*X, 2);
YY = sum(Y'.*Y', 1);
A = XX(:,ones(1,n));
B = YY(ones(1,m),:);
C = 2*X*Y';
OutputParam.Distance = XX(:,ones(1,n)) + YY(ones(1,m),:) - 2*X*Y';
OutputParam.InputParam = InputParam;
end