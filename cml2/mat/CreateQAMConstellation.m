function [Constellation, MappingVector] = CreateQAMConstellation( Order, MappingType )

if Order == 32
    % The mapping is NOT right here (just for CM capacity simulation).
    Constellation(1:4) = [ ((-3:2:3)' + j*5) ];
    Constellation(5:10) = [ ((-5:2:5)' + j*3) ];
    Constellation(11:16) = [ ((-5:2:5)' + j*1) ];
    Constellation(17:32) = conj( Constellation(1:16) );

%   Temp = Constellation/sqrt( mean(abs(Constellation).^2) ); % Normalization
    Temp = Constellation;

    % Mapping is fixed.
    MappingVector = 0:Order-1;
    Constellation( MappingVector+1 ) = Temp;
    return;
end

t = (-sqrt(Order) +1) :2: (sqrt(Order) - 1);
Temp = ones(sqrt(Order), 1) * t;
Temp = Temp - j*Temp';
Temp = reshape( Temp.', 1, Order);
% fprintf( 'Energy of the QAM signal = %f\n', mean( abs(Temp/2).^2 ) );

if ischar( MappingType )
    switch MappingType
        case 'gray'
            if Order == 16
                MappingVector = [15,11,3,7,14,10,2,6,12,8,0,4,13,9,1,5];
            elseif Order == 64
                SubMappingVec = [0,1,3,2,6,7,5,4];
                TempMappingVec = ones( sqrt(Order),1 ) * SubMappingVec;
                TempMappingVec = sqrt(Order)*TempMappingVec + flipud(TempMappingVec.');
                MappingVector = reshape( TempMappingVec.', 1, Order );
            elseif Order == 256
                SubMappingVec = [ [0,1,3,2,6,7,5,4] , 8+[0,1,3,2,6,7,5,4] ];
                TempMappingVec = ones( sqrt(Order),1 ) * SubMappingVec;
                TempMappingVec = sqrt(Order)*TempMappingVec + flipud(TempMappingVec.');
                MappingVector = reshape( TempMappingVec.', 1, Order );
            else
                error( 'QAM:InvMappingType', 'Gray mapping for QAM modulation is ONLY supported for Order=16, 64, or 256.' );
            end
        case 'SP'
            if Order == 16
                MappingVector = [8,13,12,9,15,10,11,14,4,1,0,5,3,6,7,2];
            else
                error( 'QAM:InvMappingType', 'SP mapping for QAM modulation is ONLY supported for Order=16.' );
            end
        case 'MSP'
            if Order == 16
                MappingVector = [8,11,12,15,1,2,5,6,4,7,0,3,13,14,9,10];
            else
                error( 'QAM:InvMappingType', 'MSP mapping for QAM modulation is ONLY supported for Order=16.' );
            end
        case 'MSEW'
            if Order == 16
                MappingVector = [2,1,7,4,8,11,13,14,5,6,0,3,15,12,10,9];
            else
                error( 'QAM:InvMappingType', 'MSEW mapping for QAM modulation is ONLY supported for Order=16.' );
            end
        case 'Antigray'
            if Order == 16
                MappingVector = [2,14,6,10,1,13,5,9,3,15,7,11,0,12,4,8];
            else
                error( 'QAM:InvMappingType', 'Antigray mapping for QAM modulation is ONLY supported for Order=16.' );
            end
        case  'huangITNr1'
            if Order == 16
                MappingVector = [7,14,1,11,13,4,8,2,10,3,15,5,0,9,6,12];
            else
                error( 'QAM:InvMappingType', 'huangITNr1 mapping for QAM modulation is ONLY supported for Order=16.' );
            end
        case 'huangITNr2'
            if Order == 16
                MappingVector = [12,10,5,6,15,9,3,0,2,4,14,13,1,7,8,11];
            else
                error( 'QAM:InvMappingType', 'huangITNr2 mapping for QAM modulation is ONLY supported for Order=16.' );
            end
        case  'huangLetterNr1'
            if Order == 16
                MappingVector = [13,7,1,11,14,4,2,8,3,9,15,5,0,10,12,6];
            else
                error( 'QAM:InvMappingType', 'huangLetterNr1 mapping for QAM modulation is ONLY supported for Order=16.' );
            end
        case 'huangLetterNr2'
            if Order == 16
                MappingVector = [12,15,10,9,5,6,3,0,11,8,13,14,2,1,4,7];
            else
                error( 'QAM:InvMappingType', 'huangLetterNr2 mapping for QAM modulation is ONLY supported for Order=16.' );
            end
        otherwise
            error( 'QAM:InvMappingType', 'Labeling (MappingType) or symbol set size is NOT supported for QAM modulation.' );
    end
elseif ( ~ischar(MappingType) && length(MappingType)==Order )
    MappingVector = MappingType;
else
    MappingVector = 0:Order-1;
end

Constellation( MappingVector+1 ) = Temp;
% Constellation = Constellation/sqrt( mean(abs(Constellation).^2) );  % Normalization
end