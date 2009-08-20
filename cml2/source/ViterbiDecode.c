/* file: ViterbiDecode.c

   Description: Soft-in/hard-out decoding of a convolutional code using the Viterbi algorithm

   The calling syntax is:

      [output_u] = ViterbiDecode( input_c, {g_encoder}, [code_type], [depth] )

      output_u = hard decisions on the data bits (0 or 1)

      Required inputs:
	  input_c = LLR of the code bits (based on channel observations)
 
 	  Static inputs:
 	  g_encoder = generator matrix for convolutional code
	              (If RSC, then feedback polynomial is first)
	  
      Optional inputs:
	  code_type = 0 for recursive systematic convolutional (RSC) code (default)
	            = 1 for non-systematic convolutional (NSC) code
				= 2 for tail-biting NSC code      
             
      depth = wrap depth used for tail-biting decoding
	          default is 6 times the constraint length

   Copyright (C) 2005-2009, Matthew C. Valenti

   Last updated on Aug. 17, 2009

   Function ViterbiDecode is part of the Iterative Solutions 
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
#define INPUT_C     prhs[0]
#define GENENCODER  prhs[1]
#define CODETYPE    prhs[2]
#define DEPTH       prhs[3]

/* Output Arguments */
#define OUTPUT_U    plhs[0]

/* main function that interfaces with MATLAB */
void mexFunction(
				 int            nlhs,
				 mxArray       *plhs[],
				 int            nrhs,
				 const mxArray *prhs[] )
{
    /* input and output arrays */
	double	*input_c, *g_array; 
	double  *output_u_p;     
   
    /* local variables determined from input */
    int		this_nn, this_KK;
    int		this_DataLength, this_CodeLength;
	int		this_code_type = 0;    
    int     this_depth_KK = 6;  
    
    /* other local variables */
    int      i, j, index, depth_states, max_states, this_g_row;
    int      subs[] = {1,1};
	double   elm;  
    
    /* static variables */
	static int		nn = -1;
    static int      KK = -1;
	static int		DataLength = -1;
	static int      CodeLength = -1;
	static int      code_type = 0;  /* default is RSC code */
    static int      depth_KK = 6;   /* default is 6x constraint lengths */
       
    /* static arrays */
    static int     *g_encoder;
    static int     *out0, *out1, *state0, *state1;
    static float   *input_c_float;
	static int     *output_u_int;      

    /* flag indicating a change in the code specificiation */
	int		changed_code = 0;
   
    /* flag indicating if it has been initialized */
    static int initialized = 0;

	/* Check for proper number of arguments */
    if ((nrhs < 1 )||(nlhs  > 1)) 
        mexErrMsgTxt("Usage: [output_u] = ViterbiDecode( input_c, {g_encoder}, [code_type], [depth] )");
    
    /* A check for 1 argument before it is initialized */
	if ( (nrhs < 2 )&&(!initialized) ) 
		mexErrMsgTxt("Function not initialized, need at least two input arguments" );
    
    /* first input is the LLRs of the code bits */
    input_c = mxGetPr(INPUT_C);
    this_CodeLength = mxGetN(INPUT_C); /* number of code bits */
    
    /* if new input length, then need new array */
    if ( this_CodeLength != CodeLength ) {
        /* need to destroy old input array (if it exists) */
        free( input_c_float );               
		
		/* create new input array */
        #ifdef DEBUG
        mexPrintf( "Creating new input array\n" );
        #endif
        CodeLength = this_CodeLength;
		input_c_float = calloc( CodeLength, sizeof(float) );
	}   
    
    /* cast the input into array of floats */
    for (i=0;i<CodeLength;i++)
        input_c_float[i] = input_c[i];  
    
    /* if there is a second argument, then get the code polynomial */
	if (nrhs >= 2) {        
        /* second input specifies the code polynomial */
        g_array = mxGetPr(GENENCODER);
        this_nn = mxGetM(GENENCODER);
        this_KK = mxGetN(GENENCODER);
        
        /* Make sure CodeLength is a multiple of nn */
        if ( CodeLength % this_nn > 0)
            mexErrMsgTxt("Length of input_c must be a multiple of n, the number of rows in g");

        /* determine if g has changed */
        /* the code below runs if not initialized, since default nn = -1 */
        if ( (this_nn!=nn)||(this_KK!=KK) ) {
            changed_code = 1;  /* dimensions changed */
            nn = this_nn;
            KK = this_KK;
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
                    break;
                    #ifdef DEBUG
                    mexPrintf( "Row %d of g has changed\n", i );
                    #endif
                }
            }
        }
        
        /* if new g, need to destroy old arrays and create new ones */
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
		if ( nrhs >= 3 ) { 					
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
			} else {
				rsc_transit( out0, state0, 0, g_encoder, KK, nn );
				rsc_transit( out1, state1, 1, g_encoder, KK, nn );
			}           
		}        	
	}	    
   
    /* Calculate the length of the output */
    if ( code_type < 2 ) {
        this_DataLength = (CodeLength/nn)-KK+1;
    } else {
        this_DataLength = CodeLength/nn;
        
        /* 4th input (optional) is the wrap depth */
        if (nrhs >= 4) {
            this_depth_KK = (int) *mxGetPr(DEPTH);
            if ( this_depth_KK != depth_KK ) {
                /* wrap depth has changed */
                depth_KK = this_depth_KK;
            }
        }
    }

    /* if new output length, need to create new array */
    if ( this_DataLength != DataLength ) {
        /* this code runs if not initialized, since default CodeLength == -1 */
		/* need to destroy old output array */
        free( output_u_int);
		
		/* create new ouput array */
        #ifdef DEBUG
        mexPrintf( "Creating new output array\n" );
        #endif
        DataLength = this_DataLength;
		output_u_int = calloc( DataLength, sizeof(int) );
	}          
    
    /* the outputs */
	OUTPUT_U = mxCreateDoubleMatrix(1, DataLength, mxREAL );
	output_u_p = mxGetPr(OUTPUT_U);	

	/* Run the Viterbi algorithm */
	if ( code_type < 2 ) {
		Viterbi( output_u_int, out0, state0, out1, state1,
			input_c_float, KK, nn, DataLength ); 
	} else {
        /* tailbiting code */
        depth_states = KK*depth_KK;
		ViterbiTb( output_u_int, out0, state0, out1, state1,
			input_c_float, KK, nn, DataLength, depth_states ); 
	}   

	/* cast to outputs */
	for (j=0;j<DataLength;j++) {
		output_u_p[j] = output_u_int[j];
	}
    
    /* function is now initialized and can allow a single input argument */
    initialized = 1;
    
    /* all done */
	return;
}
