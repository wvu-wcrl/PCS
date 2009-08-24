/* file: ConvEncode.c

   Description: Encode one block of data using a convolutional code.

   The calling syntax is:

      [output] = ConvEncode(input, [g_encoder], [code_type] )

      output = code word

      Required inputs:
	  input  = data word
 
      Optional inputs:
 	  g_encoder = generator matrix for convolutional code
	              (If RSC, then feedback polynomial is first)
                  If not given, then use the previous g and code_type
	  
	  code_type = 0 for recursive systematic convolutional (RSC) code (default if not initialized)
	            = 1 for non-systematic convolutional (NSC) code
				= 2 for tail-biting NSC code               

   Copyright (C) 2005-2009, Matthew C. Valenti

   Last updated on Aug. 11, 2009

   Function ConvEncode is part of the Iterative Solutions 
   Coded Modulation Library. The Iterative Solutions Coded Modulation 
   Library is free software; you can redistribute it and/or modify it 
   under the terms of the GNU Lesser General Public License as published 
   by the Free Software Foundation; either version 2.1 of the License, 
   or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
  
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/
        
#include <math.h>
#include <mex.h>
#include <matrix.h>
#include <stdlib.h>

/* library of local functions */
#include "./include/convolutionalnew.h"

/* Input Arguments */
#define INPUT       prhs[0]
#define GENENCODER  prhs[1]
#define CODETYPE    prhs[2]

/* Output Arguments */
#define OUTPUT      plhs[0]

/* main function that interfaces with MATLAB */
void mexFunction(
				 int            nlhs,
				 mxArray       *plhs[],
				 int            nrhs,
				 const mxArray *prhs[] )
{
	/* input and output arrays */
	int     *g_input;
    unsigned char *input;
    unsigned char *output;

	/* local variables determined from input */
	int		this_code_type, this_nn;

	/* other local variables */
	int      i, j, k;
	int		 max_states, g_temp;
    int      DataLength, CodeLength; 
    
    /* static variables */
    static int		nn, KK;
	static int      code_type = 0;  /* default is RSC code */

	/* static arrays */
	static int     *g_encoder;
	static int     *out0, *out1, *state0, *state1, *tail;

	/* flag indicating a change in the code specificiation */
	int		changed_code = 0;
   
    /* flag indicating if it has been initialized */
    static int initialized = 0;

	/* Check for proper number of arguments */
	if ((nrhs < 1 )||(nlhs  > 1)) 
		mexErrMsgTxt("Usage: [output] = ConvEncode(input, [g_encoder], [code_type] )");
	 		
	/* A check for 1 argument before it is initialized */
	if ( (nrhs < 2 )&&(!initialized) ) 
		mexErrMsgTxt("Function not initialized, need at least two input arguments" );
	
	/* first input is the data word */
	input = mxGetPr(INPUT);	
	DataLength = mxGetN(INPUT); /* number of data bits */
	
	/* if there is a second argument, then get the code polynomial */
	if (nrhs >= 2) {        
		/* second input specifies the code polynomial */
		g_input = mxGetPr(GENENCODER);
		this_nn = mxGetM(GENENCODER);

        /* determine if g has changed */
        /* the code below runs if not initialized, since default nn = -1 */
        if (this_nn!=nn) {
            changed_code = 1;  /* dimensions changed */
            #ifdef DEBUG
            mexPrintf( "Number rows of g has changed\n" );
            #endif
            nn = this_nn;
        } else {
            /* test each row of the g_array */
            for (i = 0;i<nn;i++) {
                /* compare */
                if ( g_input[i] != g_encoder[i] ) {
                    changed_code = 1;
                    #ifdef DEBUG
                    mexPrintf( "Row %d of g has changed\n", i );
                    #endif
                    break;
                }
            }
        }
        
        /* if new g, need to destroy old arrays */
        if (changed_code) {
            #ifdef DEBUG
            mexPrintf( "Destroying old arrays\n" );
            #endif
            /* "free" is ignored if not yet initialized */
            free( g_encoder );
            free( out0 );
            free( out1 );
            free( state0 );
            free( state1 );
            free( tail );            		            
            
		    /* create new g */
			#ifdef DEBUG
            mexPrintf( "Creating g_encoder\n" );
            #endif
            /* determine the constraint length */
            KK = 0;
            for (i = 0;i<nn;i++) {
                g_temp = g_input[i];
                for ( k = 1;k<32;k++ ) {
                    g_temp = g_temp/2;
                    if (!g_temp)
                        break;
                }
                if (k > KK) 
                    KK = k;
            }
            
            #ifdef DEBUG
            mexPrintf("Constraint Length = %d\n", KK );
            #endif     
			max_states = 1 << (KK-1);             
			
            /* create the arrays */
			g_encoder = calloc(nn, sizeof(int) );		
			out0 = calloc( max_states, sizeof(int) );
			out1 = calloc( max_states, sizeof(int) );
			state0 = calloc( max_states, sizeof(int) );
			state1 = calloc( max_states, sizeof(int) );
			tail = calloc( max_states, sizeof(int) );
			
			/* Update the code polynomial */
            for (i = 0;i<nn;i++) {
                g_encoder[i] = g_input[i];
				#ifdef DEBUG
                mexPrintf("   g_encoder[%d] = %o octal = %d decimal\n", i, g_encoder[i], g_encoder[i] );
                #endif
			}            
		}

		/* optional third input indicates if outer is RSC, NSC or tail-biting NSC */
		if ( nrhs == 3 ) { 					
			this_code_type   = (int) *mxGetPr(CODETYPE);
		 
			/* see if code type has changed */
			if (this_code_type != code_type ) {
				changed_code = 1;
				code_type = this_code_type;
                #ifdef DEBUG
				mexPrintf( "New code type is %d\n", code_type );
                #endif
			}
		}
			
		if ( changed_code )  { 
			#ifdef DEBUG
            mexPrintf( "Creating transition matrices\n" );
            #endif

			/* create appropriate transition matrices */		
			if ( code_type ) {
				nsc_transit( out0, state0, 0, g_encoder, KK, nn );
				nsc_transit( out1, state1, 1, g_encoder, KK, nn );
				if (code_type == 2)
					tail[0] = -1;
			} else {
				max_states = 1 << (KK-1); 
				rsc_transit( out0, state0, 0, g_encoder, KK, nn );
				rsc_transit( out1, state1, 1, g_encoder, KK, nn );
				rsc_tail( tail, g_encoder, max_states, KK-1 );
			}
            #ifdef DEBUG
            for (i = 0;i<max_states;i++) 
                mexPrintf( "out0[%d] = %d, state0[%d] = %d, out1[%d] = %d, state1[%d] = %d\n", 
                   i, out0[i], i, state0[i], i, out1[i], i, state1[i] );
            #endif               
		}		
	}		

	/* Calculate the length of the output */
	if (code_type < 2)
		CodeLength = nn*(DataLength+KK-1);
	else
		CodeLength = nn*DataLength;	    
	
	/* create the output vector */		    
    OUTPUT = mxCreateNumericMatrix( 1, CodeLength, mxUINT8_CLASS, mxREAL );
	/* OUTPUT = mxCreateDoubleMatrix(1, CodeLength, mxREAL ); */
	output = mxGetPr(OUTPUT);	

	/* Encode */
	conv_encode( output, input, out0, state0, out1, state1, tail, KK, DataLength, nn );	

    /* function is now initialized and can allow a single input argument */
    initialized = 1;
    
    /* all done, return */
	return;
}
