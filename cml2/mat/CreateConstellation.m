function [S, mapping] = CreateConstellation(mod_type, varargin)
% CreateConstellation function creates a K-dimensional signal constellation with M points. K is dimensionality and M is the number of symbols.
%
% The calling syntax of this function is as follows:
%     [S, mapping] = CreateConstellation(mod_type [, M] [, label_type] [, h])
%
%     S:        K by M complex signal constellation.
%
%     mod_type: Modulation type (as a string)
%               'BPSK', 'QPSK', 'PSK', 'QAM', 'APSK', 'HEX', 'HSDPA' or 'FSK'
%	  [M]:      Number of points in the constellation which must be a power of 2.
%               It is not needed for 'BPSK' (M=2), 'QPSK' (M=4), or 'HEX' (M=16). Default for 'FSK' is M=2.
%     [label_type]: Labelling type which may be a string or a vector.
%                   strings must be 'gray', 'Antigray', 'SP', 'SSP', 'MSEW', 'huangITNr1', 'huangITNr2', 'huangLetterNr1', or 'huangLetterNr2'
%                   It is not needed for BPSK, QPSK, HSDPA, HEX, APSK, or orthogonal FSK (h=1).
%     [h]:          FSK modulation index which is used only for FSK modulation. (Default h=1)

% Default values for M, mapping, lable_type and h
M = 2;
mapping = 0:M-1;
label_type = mapping;
h=1;

if (length(varargin)>=1)
    M = varargin{1};
    % Making sure that M is a power of 2.
    if (nargin > 1)
        if ( rem( log(M)/log(2),1 ) )
            error('Input M MUST be a power of 2.');
        end
    end
    
    if (length(varargin)>=2)
        label_type = varargin{2};
        if ~ischar(label_type)
            if (length( label_type ) ~= M)
                error('Length of label_type must be EQUALL to M.');
            elseif (sum( sort(label_type) ~= [0:M-1] ) > 0)
                error( 'Label_type must contain integers 0 through M-1.' );
            else
                mapping=label_type;
            end
        end
        
        if (length(varargin)>=3)
            h = varargin{3};
        end
        
    else
        mapping = 0:M-1;
        label_type = mapping;
    end
    
end


if ( strcmpi(mod_type, 'HSDPA') ) % HSDPA modulation
    if (M==4) % QPSK
        Temp = [1 1;1 -1;-1 1;-1 -1]';
        S = (Temp(1,:) + sqrt(-1)*Temp(2,:))/sqrt(2);
        mapping = [0:3];
    elseif (M==16) % 16-QAM
        for Point=0:15
            T = Point;
            for i=4:-1:1
                bit_vector(4-i+1) = fix( T/(2^(i-1)) );
                T = T - bit_vector(4-i+1)*2^(i-1);
            end
            iq = (-1).^bit_vector;
            % S(1,Point+1) = ( iq(1)*(2-iq(3)) + sqrt(-1)*iq(2)*(2-iq(4)) )/sqrt(5);
            S(1,Point+1) = ( iq(1)*(2-iq(3)) + sqrt(-1)*iq(2)*(2-iq(4)) )/sqrt(10);
        end
    else
        error( 'For HSDPA, modulation order must be either 4 or 16.' );
    end
elseif ( strcmpi(mod_type, 'BPSK') ) % BPSK modulation
    S = [1 -1];
    mapping = 0:1;
elseif ( strcmpi(mod_type, 'QPSK') ) % QPSK modulation
    S = [1 +j -j -1];  
    mapping = 0:3;
elseif  ( strcmpi(mod_type, 'PSK') ) % PSK modulation
    Temp = exp(j*2*pi*[0:M-1]/M);
    if ischar(label_type)
        switch label_type
            case 'gray'
                mapping = [0,1];
                for m = 2:log2(M)
                    mapping = [mapping, 2^(m-1) + fliplr(mapping)];
                end
            case 'SP'
                if (M == 8)
                    mapping = [0,1,2,3,4,5,6,7];
                elseif (M == 4)
                    mapping = [0,1,2,3];
                else
                    error('SP coded PSK is only supported for M=4 or 8.');
                end
            case 'SSP'
                if M == 8
                    mapping = [0,5,2,7,4,1,6,3];
                else
                    error( 'SSP coded PSK is only supported for M=8.' );
                end
            case 'MSEW'
                if M == 8
                    mapping = [0,3,5,6,1,2,4,7];
                else
                    error( 'MSEW coded PSK is only supported for M=8.' );
                end
            otherwise
                error('Labeling or symbol set size is not supported for PSK.');
        end
    end
    S(mapping+1) = Temp;
   
elseif ( strcmpi(mod_type, 'HEX') ) % (only 16-)HEX modulation
    if (nargin>1)
        if (M ~= 16)
            error( 'HEX modulation is only supported for M=16.' )
        end
    end

    % Fixed mapping
    S = transpose([0
        -2
        2
        4
        (-1 +j*sqrt(3))
        (-3 +j*sqrt(3))
        ( 1 +j*sqrt(3))
        ( 3 +j*sqrt(3))
        ( 1 -j*sqrt(3))
        (-1 -j*sqrt(3))
        ( 3 -j*sqrt(3))
        (-3 -j*sqrt(3))
        (-2 +j*2*sqrt(3))
        (   -j*2*sqrt(3))
        (   +j*2*sqrt(3))
        (-2 -j*2*sqrt(3))]);

    Temp = S/sqrt( mean(abs(S).^2) ); % Normalization
    
    % Fix mapping
    S(mapping+1) = Temp;   
  
elseif ( strcmpi(mod_type, 'APSK') )% APSK modulation 
    Temp = [+1 +j -1 -j]; % Inner ring is QPSK.

    % Mapping is fixed.
    if (M==16)
        rho = 2.85; % This value could be varied.
        Temp(5:16) = rho*exp(j*2*pi*[0:11]'/12); % Outer ring is 12-PSK w/ radius rho.
        % mapping = [3 11 9 1 6 2 10 14 15 13 12 8 0 4 5 7];
    elseif (M==32)
        rho1 = 2.84; % These values could be varied.
        rho2 = 5.27;
        % Middle and outer rings
        Temp(5:16) = rho1*exp(j*2*pi*[0:11]'/12);
        Temp(17:32) = rho2*exp(j*2*pi*[0:15]'/16);
        mapping = [24 8 0 16 29 28 12 13 9 1 5 4 20 21 17 25 ...
            26 30 14 10 15 11 3 7 2 6 22 18 23 19 27 31];
    else
        error('APSK modulation requires M=16 or 32.');
    end

    % Mapping is fixed.
    S(mapping+1) = Temp;

    S = S/sqrt( mean(abs(S).^2) ); % Normalization
    
elseif ( strcmpi(mod_type, 'QAM') ) % QAM modulation
    if (M == 32)
        % The mapping is not right here (just CM capacity).
        S(1:4) = [ ((-3:2:3)'+j*5) ];
        S(5:10) = [ ((-5:2:5)'+j*3) ];
        S(11:16) = [ ((-5:2:5)'+j*1) ];
        S(17:32) = conj(S(1:16));
        
        Temp = S/sqrt( mean(abs(S).^2) ); % Normalization
         
        % Mapping is fixed.
        S(mapping+1) = Temp;   
        return;
    end

    t = (- sqrt(M) +1) :2: (sqrt(M) - 1);
    Temp = ones(sqrt(M), 1) * t;
    Temp = Temp - j*Temp';
    Temp = reshape( Temp.', 1, M);
    % fprintf('Energy of the QAM signal = %f\n', mean( abs(Temp/2).^2 ));
    
    if (isstr(label_type)&(nargin>=3))
        switch label_type
            case 'gray'
                if M == 16
                    mapping = [15,11,3,7,14,10,2,6,12,8,0,4,13,9,1,5];
                elseif M == 64
                    submapping = [0,1,3,2,6,7,5,4];
                    tempmapping = ones(sqrt(M),1) * submapping;
                    tempmapping = sqrt(M)*tempmapping + flipud(tempmapping.');

                    mapping = reshape(tempmapping.', 1, M);
                elseif M == 256
                    submapping = [ [0,1,3,2,6,7,5,4] , 8+[0,1,3,2,6,7,5,4] ];
                    tempmapping = ones(sqrt(M), 1) * submapping;
                    tempmapping = sqrt(M)*tempmapping + flipud(tempmapping.');

                    mapping = reshape( tempmapping.', 1, M);
                else
                    error('Gray mapping for QAM modulation is only supported for M=16, 64, or 256.');
                end
            case 'SP'
                if M==16
                    mapping = [8,13,12,9,15,10,11,14,4,1,0,5,3,6,7,2];
                else
                    error( 'SP mapping for QAM modulation is only supported for M=16.' );
                end
            case 'MSP'
                if M == 16
                    mapping = [8,11,12,15,1,2,5,6,4,7,0,3,13,14,9,10];
                else
                    error( 'MSP mapping for QAM modulation is only supported for M=16.' );
                end
            case 'MSEW'
                if M == 16
                    mapping = [2,1,7,4,8,11,13,14,5,6,0,3,15,12,10,9];
                else
                    error( 'MSEW mapping for QAM modulation is only supported for M=16.' );
                end
            case 'Antigray'
                if M == 16
                    mapping = [2,14,6,10,1,13,5,9,3,15,7,11,0,12,4,8];
                else
                    error( 'Antigray mapping for QAM modulation is only supported for M=16.' );
                end
            case  'huangITNr1'
                if M == 16
                    mapping = [7,14,1,11,13,4,8,2,10,3,15,5,0,9,6,12];
                else
                    error( 'huangITNr1 mapping for QAM modulation is only supported for M=16.' );
                end
            case 'huangITNr2'
                if M == 16
                    mapping = [12,10,5,6,15,9,3,0,2,4,14,13,1,7,8,11];
                else
                    error( 'huangITNr2 mapping for QAM modulation is only supported for M=16.' );
                end
            case  'huangLetterNr1'
                if M == 16
                    mapping = [13,7,1,11,14,4,2,8,3,9,15,5,0,10,12,6];
                else
                    error( 'huangLetterNr1 mapping for QAM modulation is only supported for M=16.' );
                end
            case 'huangLetterNr2'
                if M == 16
                    mapping = [12,15,10,9,5,6,3,0,11,8,13,14,2,1,4,7];
                else
                    error( 'huangLetterNr2 mapping for QAM modulation is only supported for M=16.' );
                end
            otherwise
                error('Labeling or symbol set size not supported for QAM.');
        end
    end
    
    S(mapping+1) = Temp;
    S = S/sqrt( mean(abs(S).^2) );  % Normalization
    
elseif ( strcmpi(mod_type, 'FSK') )
    if h==1
        Temp = eye(M); % Orthogonal FSK
    else % Nonorthogonal FSK
        for m=1:M
            for n=1:M
                Temp(n,m) = sinc((m-n)*h) * exp(-j*pi*(m-n)*h);
            end
        end
    end

    if isstr(label_type)
        if ( strcmpi(label_type, 'gray') )
            mapping = [0,1];
            for m=2:log2(M)
                mapping = [mapping, 2^(m-1) + fliplr(mapping)];
            end
        elseif ( strcmpi(label_type, 'mv') )
            if M == 8
                mapping = [6 1 0 3 2 5 4 7];
            elseif M == 16
                mapping = [0 2 14 12 11 9 5 7 6 4 8 10 13 15 3 1];
            else
                error('mv mapping for FSK modulation is only supported for M=8 or 16.');
            end
        elseif ( strcmpi(label_type, 'dt') )
            if M == 8
                % mapping = [6 1 0 3 2 5 4 7];
                mapping = [2 1 4 3 6 5 0 7];
            elseif M == 16
                % mapping = [0 2 14 12 11 9 5 7 6 4 8 10 13 15 3 1];
                mapping = [0 15 1 14 9 6 8 7 10 5 11 4 3 12 2 13];
            else
                error('dt mapping for FSK modulation is only supported for M=8 or 16.');
            end
        elseif ( strcmpi(label_type, 'gray2') )
            if M ~= 8
                error('gray2 mapping for FSK modulation is only supported for M=8.');
            else
                mapping = [0 1 5 7 3 2 6 4];
            end
        elseif ( strcmpi(label_type, 'gray3') )
            if M ~= 8
                error('gray3 mapping for FSK modulation is only supported for M=8.');
            else
                mapping = [0 1 5 4 6 7 3 2];
            end
        elseif ( strcmpi(label_type, 'gray4') )
            if M ~= 8
                error('gray4 mapping for FSK modulation is only supported for M=8.');
            else
                mapping = [0 1 5 4 6 2 3 7];
            end
        elseif ( strcmpi(label_type, 'gray5') )
            if M ~= 8
                error('gray5 mapping for FSK modulation is only supported for M=8.');
            else
                mapping = [0 1 3 7 5 4 6 2];
            end
        elseif ( strcmpi(label_type, 'gray6') )
            if M ~= 8
                error( 'gray6 mapping for FSK modulation is only supported for M=8.' );
            else
                mapping = [0 1 3 2 6 4 5 7];
            end
        elseif (strcmpi(label_type, 'reversegray'))
            if M==8
                mapping = [0 1 3 2 7 6 4 5];
            elseif M==16
                mapping = [0 1 3 2 7 6 4 5 15 14 12 13 8 9 11 10]
            else
                error( 'reversegray mapping for FSK modulation is only supported for M=8 or 16.' );
            end
        else
            mapping = 0:M-1; % Natural mapping
        end
    end

    S(:,mapping+1) = Temp; % Mapping: Rearrange rows

else
    error('Modulation and/or labeling is not supported.');
end