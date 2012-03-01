%
%
% function in order to compute the outage probability
% where the input is a single structure  
%
%

function output_struct=outage(input_struct)

IndicesDir =  input_struct.IndicesPath;
NetworksDir = input_struct.NetworksPath;
     
%load Network
NetworkFile = input_struct.NetworkFileName;


try
    msg = sprintf( 'Loading Network file\n' );
    fprintf( msg );
    
    load( [NetworksDir NetworkFile], 'Omega' );
    success = 1;
catch
    % file was bad, kick out of loop
    msg = sprintf( 'Error: Network File could not be loaded\n' );
    fprintf( msg );
    success = 0;
end

          
% try to compute the outage probability
if (success)
    try
        msg = sprintf( 'Computing outage probabilty\n' );
        fprintf( msg );
        
        % Adjust Omega by the processing gain
        if  isfield( input_struct, 'PG' )
            Omega = Omega/input_struct.PG;
        end
        
        % Create the OutageNakagami object
        b = OutageNakagami( Omega, input_struct.m, input_struct.m_i, IndicesDir );
        
        % determine if adjacent channel interference is considered
        Splatter = 0;
        if isfield( input_struct, 'Fibp' );
            if ( input_struct.Fibp < 1 )
                Splatter = 1;
            end
        end
        
        % determine if there is shadowing
        if isfield( input_struct, 'ShadowStd' )
            if (input_struct.ShadowStd > 0)
                b.SetShadowing( input_struct.ShadowStd );
            end
        end
        
        ComputeCDF = false;
        if isfield( input_struct, 'ComputeCDF' )
            if input_struct.ComputeCDF
                ComputeCDF = true;
            end
        end
        
        
        % Compute the outage
        if Splatter
            msg = sprintf( 'Considering Spectral Splatter\n' );
            fprintf( msg );
            if ComputeCDF
                epsilon = b.ComputeSingleOutageSplatter( input_struct.Gamma, input_struct.Beta(1), input_struct.p(1), input_struct.Fibp(1) );
            else
                epsilon = b.ComputeOutage( input_struct.Gamma, input_struct.Beta, input_struct.p, input_struct.Fibp );
            end
        else
            if ComputeCDF
                epsilon = b.ComputeSingleOutage( input_struct.Gamma, input_struct.Beta(1), input_struct.p(1) );
            else
                epsilon = b.ComputeOutage( input_struct.Gamma, input_struct.Beta, input_struct.p );
            end
        end
        
        msg = sprintf( 'Done computing outage probabilty\n' );
        fprintf( msg );
        success = 1;
    catch exception
        % file was bad, kick out of loop
        msg = sprintf( '\nError: Could not compute outage probability\n\n' );
        fprintf( msg );
       fprintf(exception.message);
        success = 0;
    end
end  
  
  % try to create the output structure
  if (success)
      try
          msg = sprintf( 'Create output structure\n' );
          fprintf( msg );
          
          % create output structure
          output_struct.input_struct=input_struct;
          output_struct.epsilon=epsilon;

      catch
          msg = sprintf( 'Error: Output Structure could not be created\n' );
          fprintf( msg );
      end
  end


        

        



        
    


    
