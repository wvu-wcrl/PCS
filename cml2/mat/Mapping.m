classdef Mapping < handle
    
    properties
        NoBitsPerSymb       % Number of bits per symbol (There are M=2^(NoBitsPerSymb) symbols.)
        DemodType           % Type of max_star algorithm that is used.
                            % =0 For linear approximation to log-MAP (DEFAULT)
                            % =1 For max-log-MAP algorithm (i.e. max*(x,y) = max(x,y))
                            % =2 For Constant-log-MAP algorithm
                            % =3 For log-MAP, correction factor from small nonuniform table and interpolation.
                            % =4 For log-MAP, correction factor uses C function calls.
        Data                % Data row vector as UINT8 to be mapped to an M-ary symbol.
                            % The length of Data has to be an integer multiple (N) of NoBitsPerSymb.
        SymbolLL            % M-by-N matrix of symbol LLR to be demapped to BitLLR.
    end
    
    properties(SetAccess = protected)
        DataIndex           % 1-by-N vector of M-ary symbols as INT32 numbers between 1 and M corresponding to N groups of bits in the Data vector.
        BitLLR              % 1-by-N*LOG2(M) vector of demapped BITWISE LLR.
    end
    
    methods
        
        function obj = Mapping( NoBitsPerSymb, DemodType )
            obj.NoBitsPerSymb = NoBitsPerSymb;
            if(nargin<2 || isempty(DemodType)), DemodType = 0; end
            obj.DemodType = DemodType;
        end
        
        function DataIndex = Map( obj, Data )
        % Map method maps a vector of bits to a vector of M-ary symbols.
            obj.Data = Data;
            % The Map function maps obj.Data to a vector of M-ary symbols.
            DataIndex = Map( obj.Data, obj.NoBitsPerSymb );
            obj.DataIndex = DataIndex;
        end
        
        function BitLLR = Demap( obj, SymbolLL, ExtrinsicInfo )
        % Demap method is a SOFT demapper of M-ary to binary LLR conversion.
            obj.SymbolLL = SymbolLL;
            
            if(nargin<3 || isempty(ExtrinsicInfo))
                ExtrinsicInfo = zeros( 1, size(obj.SymbolLL,2)*log2(size(obj.SymbolLL,1)) );
            end
            
            % Demap is a soft demapper of M-ary symbol LLR to bit LLR.
            BitLLR = Demap( obj.SymbolLL, obj.DemodType, ExtrinsicInfo );
            obj.BitLLR = BitLLR;
        end
        
    end
end