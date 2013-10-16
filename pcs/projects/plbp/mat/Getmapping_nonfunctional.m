%GETMAPPING returns a structure containing a mapping table for LBP codes.
%  MAPPING = GETMAPPING(SAMPLES,MAPPINGTYPE)
%  Returns a  structure containing a mapping table for LBP codes in a
%  neighbourhood of SAMPLES sampling points.
%  Possible values for MAPPINGTYPE are
%       'u2'   for uniform LBP
%       'ri'   for rotation-invariant LBP
%       'riu2' for uniform rotation-invariant LBP.
%
%  Example:
%       I=imread('rice.tif');
%       MAPPING=Getmapping(16,'riu2');
%       LBPHIST=lbp(I,2,16,MAPPING,'hist');
%  Now LBPHIST contains a rotation-invariant uniform LBP histogram in a (16,2) neighbourhood.
%
%  Version 0.1.1
%  Authors: Marko Heikkilä and Timo Ahonen

%  Changelog
%       0.1.1 Changed output to be a structure.
%       Fixed a bug causing out of memory errors when generating rotation
%       invariant mappings with high number of sampling points.
%       Lauge Sorensen is acknowledged for spotting this problem.


function Mapping = Getmapping(Samples, MappingType)

V       = 2^Samples-1;
Table   = 0:V;
newMax  = 0; %number of patterns in the resulting LBP code.
index   = 0;

if strcmp(MappingType,'u2') %Uniform 2.
    newMax       = Samples*(Samples-1) + 3;
    vect_samples = (1:Samples);
    for i = 0:V
        j    = bitset(bitshift(i,1,Samples),1,bitget(i,Samples)); %rotate left.
        % number of 1->0 and 0->1 transitions in binary string x is equal to
        % the number of 1-bits in XOR(x,Rotate left(x)).
        numt = sum(bitget(bitxor(i,j),vect_samples));
        if numt <= 2
            Table(i+1) = index;
            index      = index + 1;
        else
            Table(i+1) = newMax - 1;
        end
    end
end

if strcmp(MappingType,'ri') %Rotation invariant.
    tmpMap = zeros(V+1,1) - 1;
    for i = 0:V
        rm = i;
        r  = i;
        for j = 1:Samples-1
            r = bitset(bitshift(r,1,Samples),1,bitget(r,Samples)); %rotate left.
            if r < rm
                rm = r;
            end
        end
        if tmpMap(rm+1) < 0
            tmpMap(rm+1) = newMax;
            newMax       = newMax + 1;
        end
        Table(i+1)       = tmpMap(rm+1);
    end
end

if strcmp(MappingType,'riu2') %Uniform and Rotation invariant.
    newMax       = Samples + 2;
    vect_samples = (1:Samples);
    
    for i = 0:V
        j = bitset(bitshift(i,1,Samples),1,bitget(i,Samples)); %rotate left.
        numt = sum(bitget(bitxor(i,j),vect_samples));
        if numt <= 2
            Table(i+1) = sum(bitget(i,vect_samples));
        else
            Table(i+1) = Samples+1;
        end
    end
end

Mapping.table   = Table;
Mapping.samples = Samples;
Mapping.num     = newMax;