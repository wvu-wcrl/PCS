function X = randp(P,varargin)
% RANDP - Pick random values with relative probability.
%
%     X = RANDP(PROB,VARARGIN) returns integers in the range from 1 to
%     NUMEL(PROB) with a relative probability, so that the value M is
%     present approximately (PROB(M)./sum(PROB)) times in the matrix X.
%
%     All values of PROB should be equal to or larger than 0.
%
%     RANDP(PROB,N) is an N-by-N matrix.
%     RANDP(PROB,M,N) and RANDP(PROB,[M,N]) are M-by-N matrices.
%     RANDP(PROB, M1,M2,M3,...) or RANDP(PROB,[M1,M2,M3,...]) generate random arrays.
%     RANDP(PROB,SIZE(A)) is the same size as A.
%
%     Example:
%       R = randp([1 3 2],1,10000)  % It returns a row vector with 10000 values with about 16650 two.
%       histc(R,1:3) ./ numel(R)
%
%       R = randp([1 1 0 0 1],10,1) % It returns 10 samples evenly drawn from [1 2 5].
%
%     Also see RAND, RANDPERM
%              RANDPERMBREAK, RANDINTERVAL, RANDSWAP, DISCRETERND, gDiscrPdfRnd.

% Created for Matlab R13+ version 2.0 (Feb. 2009) By Jos van der Geest (email: jos@jasen.nl)
%
% File history:
% 1.0 (Nov 2005) - created
% 1.1 (Nov 2005) - modified slightly to check input arguments to RAND first.
% 1.2 (Aug 2006) - fixed bug when called with scalar argument P.
% 2.0 (Feb 2009) - use HISTC for creating the integers (faster and simplier than
%                  previous algorithm)

error(nargchk(1,Inf,nargin));

try
    X = rand(varargin{:});
catch
    E = lasterror;
    E.message = strrep(E.message,'rand','randp');
    rethrow(E);
end

P = P(:);

if any(P<0)
    error('All (relative) probabilities should be 0 or larger.');
end

if isempty(P) || sum(P)==0
    warning([mfilename ':ZeroProbabilities'],'All zero probabilities.');
    X(:) = 0;
else
    [Junk,X] = histc( X, [0 ; cumsum(P(:))]./sum(P) );
end

% Method used before version 2:
%     X = rand(varargin{:});
%     sz = size(X);
%     P = reshape(P,1,[]);  % row vector.
%     P = cumsum(P) ./ sum(P);
%     X = repmat(X(:),1,numel(P)) < repmat(P,numel(X),1);
%     X = numel(P) - sum(X,2) + 1;
%     X = reshape(X,sz);