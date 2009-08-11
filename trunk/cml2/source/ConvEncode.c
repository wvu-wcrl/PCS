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

   Last updated on Aug. 10, 2009

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
#include "./include/convolutional.h"

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
	double	*input, *g_array;
	double	*output_p;

	/* local variables determined from input */
	int		this_nn, this_KK, this_g_row;
	int		this_DataLength, this_CodeLength;
	int		this_code_type;

	/* other local variables */
	int      i, j, index;
	int      subs[] = {1,1};
	int		 max_states;
	double   elm;
    
    /* static variables */
	static int		nn = -1;
    static int      KK = -1;
	static int		DataLength = -1;
	static int      CodeLength = -1;
	static int      code_type = 0;  /* default is RSC code */

	/* static arrays */
	static int     *g_encoder;
	static int     *out0, *out1, *state0, *state1, *tail;
	static int		*input_int, *output_int;

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
	this_DataLength = mxGetN(INPUT); /* number of data bits */

    /* if new input length, then need new array */
	if ( this_DataLength!=DataLength ) {
        /* this code runs if not initialized, since default DataLength == -1 */
		/* need to destroy old input array */
        free( input_int );
		
		/* create new input array */
        #ifdef DEBUG
        mexPrintf( "Creating new input array\n" );
        #endif        
        DataLength = this_DataLength;
		input_int = calloc( DataLength, sizeof(int) );        
	}

	/* cast the input into an array of integers */
	for (i=0;i<DataLength;i++)
		input_int[i] = (int) input[i];
	
	/* if there is a second argument, then get the code polynomial */
	if (nrhs >= 2) {        
		/* second input specifies the code polynomial */
		g_array = mxGetPr(GENENCODER);
		this_nn = mxGetM(GENENCODER);
		this_KK = mxGetN(GENENCODER);

        /* determine if g has changed */
        /* the code below runs if not initialized, since default nn = -1 */
        if ( (this_nn!=nn)||(this_KK!=KK) ) {
            changed_code = 1;  /* dimensions changed */
            #ifdef DEBUG
            mexPrintf( "Dimensions of g have changed\n" );
            #endif
        } else {
            /* test each row of the g_array */
            for (i = 0;i<nn;i++) {
                subs[0] = i;
                this_g_row = 0;
                for (j=0;j<KK;j++) {
                    subs[1] = j;
                    index = mxCalcSingleSubscript(GENENCODER, 2, subs);
                    elm = g_array[index];
                    if (elm != 0) {
                        this_g_row = this_g_row + (int) pow(2,(KK-j-1));
                    }
                }
                /* compare */
                if ( this_g_row != g_encoder[i] ) {
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
        }
		
		nn = this_nn;
		KK = this_KK;

		/* create new g */
		if ( changed_code ) {
			#ifdef DEBUG
            mexPrintf( "Creating g_encoder\n" );
            #endif
			max_states = 1 << (KK-1);        									
			
            /* create the arrays */
			g_encoder = calloc(nn, sizeof(int) );		
			out0 = calloc( max_states, sizeof(int) );
			out1 = calloc( max_states, sizeof(int) );
			state0 = calloc( max_states, sizeof(int) );
			state1 = calloc( max_states, sizeof(int) );
			tail = calloc( max_states, sizeof(int) );
			
			/* Convert code polynomial to binary */
            for (i = 0;i<nn;i++) {
				subs[0] = i;
				for (j=0;j<KK;j++) {
					subs[1] = j;
					index = mxCalcSingleSubscript(GENENCODER, 2, subs);
					elm = g_array[index];
					if (elm != 0) {
						g_encoder[i] = g_encoder[i] + (int) pow(2,(KK-j-1)); 
					}
				}
				#ifdef DEBUG
                mexPrintf("   g_encoder[%d] = %o\n", i, g_encoder[i] );
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
		}		
	}		

	/* Calculate the length of the output */
	if (code_type < 2)
		this_CodeLength = nn*(DataLength+KK-1);
	else
		this_CodeLength = nn*DataLength;	
    
    /* if new output length, need to create new array */
	if ( this_CodeLength!=CodeLength ) {
        /* this code runs if not initialized, since default CodeLength == -1 */
		/* need to destroy old output array */
        free( output_int );
		
		/* create new ouput array */
        #ifdef DEBUG
        mexPrintf( "Creating new output array\n" );
        #endif
        CodeLength = this_CodeLength;
		output_int = calloc( CodeLength, sizeof(int) );
	}	
	
	/* create the output vector */		
	OUTPUT = mxCreateDoubleMatrix(1, CodeLength, mxREAL );
	output_p = mxGetPr(OUTPUT);	

	/* Encode */
	conv_encode( output_int, input_int, out0, state0, out1, state1, tail, KK, DataLength, nn );	

	/* cast to output */
    for (i=0;i<CodeLength;i++) 			
		output_p[i] = output_int[i];

    /* function is now initialized and can allow a single input argument */
    initialized = 1;
    
    /* all done */
	return;
}
