/* file: SisoDecode.c
 
   Description: Soft-in/soft-out decoding algorithm for a convolutional code
 
   The calling syntax is:
 
      [output_u, output_c] = SisoDecode(input_c, {input_u}, {g_encoder}, [code_type], [dec_type] )
 
      output_u = LLR of the data bits
      output_c = LLR of the code bits
 
      Required inputs:
      input_c = APP of the code bits
 
      Static inputs:
      input_u = APP of the data bits
      g_encoder = generator matrix for convolutional code
                  (If RSC, then feedback polynomial is first)
 
      Optional inputs:
      code_type = 0 for RSC outer code (default)
                = 1 for NSC outer code
 
      dec_type = the decoder type:
            = 0 For linear approximation to log-MAP (DEFAULT)
            = 1 For max-log-MAP algorithm (i.e. max*(x,y) = max(x,y) )
            = 2 For Constant-log-MAP algorithm
            = 3 For log-MAP, correction factor from small nonuniform table and interpolation
            = 4 For log-MAP, correction factor uses C function calls (slow)
 
   Copyright (C) 2005-2009, Matthew C. Valenti
 
   Last updated on Aug. 17, 2009
 
   Function SisoDecode is part of the Iterative Solutions
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

/* library of functions */
#include "./include/maxstar.h"
#include "./include/convolutional.h"
#include "./include/siso.h"

/* Input Arguments */
#define INPUT_C     prhs[0]
#define INPUT_U     prhs[1]
#define GENENCODER  prhs[2]
#define CODETYPE    prhs[3]
#define DECTYPE     prhs[4]

/* Output Arguments */
#define OUTPUT_U    plhs[0]
#define OUTPUT_C    plhs[1]

/* main function that interfaces with MATLAB */
void mexFunction(
int            nlhs,
mxArray       *plhs[],
int            nrhs,
const mxArray *prhs[] )
{
    /* input and output arrays */
    double	*input_u, *input_c, *g_array;
    double  *output_u_p, *output_c_p;
    
    /* local variables determined from input */
    int		this_nn, this_KK;
    int		this_DataLength, this_CodeLength;
    int		this_code_type = 0;
    int     this_dec_type = 0;
    
    /* other local variables */
    int      i, j, index, max_states, this_g_row;
    int      subs[] = {1,1};
    double   elm;
    
    /* static variables */
    static int		nn = -1;
    static int      KK = -1;
    static int		DataLength = -1;
    static int      CodeLength = -1;
    static int      code_type = 0;  /* default is RSC code */
    static int      dec_type = 0;
    
    /* static arrays */
    static int     *g_encoder;
    static int     *out0, *out1, *state0, *state1;
    static float   *input_u_float, *input_c_float;
    static float   *output_u_float, *output_c_float;
    
    /* flag indicating a change in the code specificiation */
    int		changed_code = 0;
    
    /* flag indicating if it has been initialized */
    static int initialized = 0;
    
    /* Check for proper number of arguments */
    if ((nrhs < 1 )||(nlhs  > 1))
        mexErrMsgTxt("Usage: [output_u, output_c] = SisoDecode(input_c, {input_u}, {g_encoder}, [code_type], [dec_type] )");
    
    /* A check for 1 or 2 arguments before it is initialized */
    if ( (nrhs < 3 )&&(!initialized) )
        mexErrMsgTxt("Function not initialized, need at least three input arguments" );
    
    /* first input is the LLRs of the code bits */
    input_c = mxGetPr(INPUT_C);
    this_CodeLength = mxGetN(INPUT_C); /* number of code bits */
    
    /* if new input length, then need new arrays */
    if ( this_CodeLength != CodeLength ) {
        /* need to destroy old input arrays (if they exist) */
        free( input_c_float );
        free( output_c_float );
        
        CodeLength = this_CodeLength;        
        /* create new input array */
        #ifdef DEBUG
        mexPrintf( "Creating new input_c and output_c arrays of length %d\n", CodeLength );
        #endif
        input_c_float = calloc( CodeLength, sizeof(float) );
        output_c_float = calloc( CodeLength, sizeof(float) );
    }
    
    /* cast input_c into array of floats */
    for (i=0;i<CodeLength;i++)
        input_c_float[i] = input_c[i];
    
    /* if there is a second argument, then get input_u */
    if (nrhs >= 2) {
        /* second input is the LLRs of the data bits */
        input_u = mxGetPr(INPUT_U);
        this_DataLength = mxGetN(INPUT_U); /* number of data bits */
        
        /* if new input length, then need new array */
        if ( this_DataLength != DataLength ) {
            /* need to destroy old input array (if there is one) */
            free( input_u_float );
            free( output_u_float );
            
            DataLength = this_DataLength;            
            /* create new input array */
            #ifdef DEBUG
            mexPrintf( "Creating new input_u and output_u arrays of length %d\n", DataLength );
            #endif
            input_u_float = calloc( DataLength, sizeof(float) );
            output_u_float = calloc( DataLength, sizeof(float) );
        }
        
        /* cast input_u into an array of float */
        for (i=0;i<DataLength;i++)
            input_u_float[i] = input_u[i];
    }
    
    /* if there is a third argument, then get the code polynomial */
    if (nrhs >= 3) {
        /* third input specifies the code polynomial */
        g_array = mxGetPr(GENENCODER);
        this_nn = mxGetM(GENENCODER);
        this_KK = mxGetN(GENENCODER);
        
        /* Make sure CodeLength is a multiple of nn */
        if ( CodeLength % this_nn > 0)
            mexErrMsgTxt("Length of input_c must be a multiple of n, the number of rows in g");
        
        /* determine if g has changed */
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
            mexPrintf( "   g_encoder[%d] = %o\n", i, g_encoder[i] );
            #endif
        }
        #ifdef DEBUG
        mexPrintf( "n = %d and K = %d\n", nn, KK );
        #endif
    }   
        
    /* make sure data and code lengths agree */    
    if ( CodeLength != nn*(DataLength+KK-1 ) )
        mexErrMsgTxt( "SisoDecode: Length of input_u and input_c don't agree" );
        
    /* optional fourth input indicates if outer is RSC or NSC code */
    if ( nrhs >= 4 ) {
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
    
    /* optional fifth input is type of decoder */
    if ( nrhs >= 5 ) {
        this_dec_type   = (int) *mxGetPr(DECTYPE);
        
        /* see if code type has changed */
        if (this_dec_type != dec_type ) {
            dec_type = this_dec_type;
            #ifdef DEBUG
            mexPrintf( "New decoder type is %d\n", dec_type );
            #endif
        }
    }           
   
    /* Run the SISO algorithm */
    siso( output_u_float, output_c_float, out0, state0, out1, state1,
          input_u_float, input_c_float, KK, nn, DataLength, dec_type );
    
    /* cast to outputs */
    if (nlhs >= 1) {
        OUTPUT_U = mxCreateDoubleMatrix(1, DataLength, mxREAL );
        output_u_p = mxGetPr(OUTPUT_U);       
        for (j=0;j<DataLength;j++) 
            output_u_p[j] = output_u_float[j];        
    }
    
    if (nlhs >= 2) {
        OUTPUT_C = mxCreateDoubleMatrix(1, CodeLength, mxREAL );
        output_c_p = mxGetPr(OUTPUT_C);
        for (j=0;j<CodeLength;j++) 
            output_c_p[j] = output_c_float[j];        
    }
    
    /* function is now initialized and can allow a single input argument */
    initialized = 1;
    
    /* all done */
	return;
}
