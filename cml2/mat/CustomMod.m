classdef CustomMod < Modulation
    
    properties
    end
    
    methods
        
        function obj = CustomMod( SignalSet, MappingVector )
        % SignalSet is a K-by-Order REAL Signal Constellation (K is the dimensionality of the signal space. There are Order points in the signal space.)
            Order = size(SignalSet, 2);
            
            if ischar(MappingVector)
                error('The second input argument for the CUSTOM modulation should be Mapping Vector as a vector of length Order of modulation.');
            elseif (length(MappingVector) ~= Order)
                error('Length of MappingVector must be EQUALL to the Order of modulation.');
            elseif (sum( sort(MappingVector) ~= [0:Order-1] ) > 0)
                error( 'MappingVector must contain ALL integers from 0 through Order-1.' );
            end
            
            obj@Modulation(SignalSet);
            obj.Type = 'custom';
            obj.MappingVector = MappingVector;
        end
        
    end
end