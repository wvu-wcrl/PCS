classdef Mapping < handle

    
    properties
        NoBitsPerSymb       % Number of bits per symbol (There are M=2^(NoBitsPerSymb) symbols.)
        Data                % Data row vector to be mapped to an M-ary symbol (The length of Data has to be an integer multiple (N) of NoBitsPerSymb.)
        DataIndex           % 1-by-N vector of M-ary symbols corresponding to N groups of bits in the Data vector.
        SymbolLLR           % M-by-N matrix of symbol LLR to be demapped to BitLLR.
        BitLLR              % 1-by-N*LOG2(M) vector of demapped bit LLR.
    end
    
    methods
        
        function obj = Mapping( NoBitsPerSymb )
            obj.NoBitsPerSymb = NoBitsPerSymb;
        end
        
        function DataIndex = Map( obj, Data )
            obj.Data = Data;
            % The Map function maps obj.Data to a vector of M-ary symbols.
            DataIndex = Map( obj.Data, obj.NoBitsPerSymb );
            obj.DataIndex = DataIndex;
        end
        
        function BitLLR = Demap( obj, SymbolLLR, DemodType, varargin )
            obj.SymbolLLR = SymbolLLR;
            
            if (length(varargin)>=1)
                ExtrinsicInfo = varargin{1};
            else
                ExtrinsicInfo = zeros( 1, size(obj.SymbolLLR,2)*log2(size(obj.SymbolLLR,1)) );
            end
            
            % Demap is a soft demapper of M-ary symbol LLR to bit LLR.
            BitLLR = Demap( obj.SymbolLLR, DemodType, ExtrinsicInfo );
            obj.BitLLR = BitLLR;
        end
        
    end
end