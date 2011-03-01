classdef Mapping < handle

    
    properties
        NoBitsPerSymb       % Number of bits per symbol (There are M=2^(NoBitsPerSymb) symbols.)
        Data                % Data row vector as UINT8 to be mapped to an M-ary symbol (The length of Data has to be an integer multiple (N) of NoBitsPerSymb.)
        DataIndex           % 1-by-N vector of M-ary symbols as INT32 corresponding to N groups of bits in the Data vector.
        SymbolLLR           % M-by-N matrix of symbol LLR to be demapped to BitLLR.
        BitLLR              % 1-by-N*LOG2(M) vector of demapped bit LLR.
        DemodType=0         % Demodulater type indicating how the max_star function is implemented within the Demapper.
                            % =0 For linear-log-MAP algorithm (Correction function is a straght line.) (DEFAULT).
                            % =1 For max-log-MAP algorithm FASTEST (max*(x,y) = max(x,y) and correction function = 0).
                            % =2 For Constant-log-MAP algorithm (Correction function is a constant.)
                            % =3 For log-MAP (Correction factor from small nonuniform table and interpolation.)
                            % =4 For log-MAP (Correction factor uses C function calls.)
    end
    
    methods
        
        function obj = Mapping( NoBitsPerSymb, DemodType )
            obj.NoBitsPerSymb = NoBitsPerSymb;
            if ( nargin>=2 && ~isempty(DemodType) )
                obj.DemodType = DemodType;
            end
        end
        
        function DataIndex = Map( obj, Data )
        % Map method maps a vector of bits to a vector of M-ary symbols.
            obj.Data = Data;
            % The Map function maps obj.Data to a vector of M-ary symbols.
            DataIndex = Map( obj.Data, obj.NoBitsPerSymb );
            obj.DataIndex = DataIndex;
        end
        
        function BitLLR = Demap( obj, SymbolLLR, ExtrinsicInfo, DemodType )
        % Demap method is a SOFT demapper of M-ary to binary LLR conversion.
            obj.SymbolLLR = SymbolLLR;
            if ( nargin<3 || isempty(ExtrinsicInfo) )
                ExtrinsicInfo = zeros( 1, size(obj.SymbolLLR,2)*log2(size(obj.SymbolLLR,1)) );
            end
            if ( nargin>=4 && ~isempty(DemodType) )
                obj.DemodType = DemodType;
            end
            
            % Demap is a soft demapper of M-ary symbol LLR to bit LLR.
            BitLLR = Demap( obj.SymbolLLR, obj.DemodType, ExtrinsicInfo );
            obj.BitLLR = BitLLR;
        end
        
    end
end