/* File: Demap.c

   Description: Soft demapper (M-ary to binary LLR conversion)

   The calling syntax is:
      [output] = Demap( input, [demod_type], [extrinsic_info] )

   Where:
      output     = Length N*log2(M) stream of LLR values (float)

      input      = M by N matrix of symbol likelihoods (float) 
	  demod_type = The type of max_star algorithm that is used 
	             = 0 For linear approximation to log-MAP (DEFAULT)
                 = 1 For max-log-MAP algorithm (i.e. max*(x,y) = max(x,y) )
                 = 2 For Constant-log-MAP algorithm
	             = 3 For log-MAP, correction factor from small nonuniform table and interpolation
                 = 4 For log-MAP, correction factor uses C function calls

	  extrinsic_info = 1 by N*log2(M) vector of extrinsic info (float)

   Copyright (C) 2005-2009, Matthew C. Valenti

   Last updated on Aug. 30, 2009

   Function Somap is part of the Iterative Solutions 
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
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/
#include <math.h>
#include <mex.h>
#include <matrix.h>
#include <stdlib.h>
#include "./include/maxstar.h"

/* Input Arguments
prhs[0] is input
prhs[1] is demod_type
prhs[2] is ex_info

/* Output Arguments
plhs[0] is output

/* main function that interfaces with MATLAB */
void mexFunction(
				 int            nlhs,
				 mxArray       *plhs[],
				 int            nrhs,
				 const mxArray *prhs[] )
{
    /* input and output arrays */
	float *input;
	float *llr_in;	
	float *output_p;
	
	int demod_type = 0;
	int M, m, DataLength; 
	int i, j, k, n, mask;
	int NumberSymbols;
	float metric;
	
    float den, num;	
	int Number_LLR_bits;
    int temp_int;
    
	/* put the different max_star functions into array so easy to call */
	float (*max_star[])(float, float) =
	{ 
		max_star0, max_star1, max_star2, max_star3, max_star4
	};

	/* Check for proper number of arguments */
	if (nrhs ==  0) {
		mexErrMsgTxt("Usage: [output] = Somap( input, [demod_type], [extrinsic_info] )");
	} 

    /* first (and only required) input is M-ary symbols for conversion */
    input = mxGetPr(prhs[0]);
	
	if (nrhs > 1) {
		/* second (optional) input is the demodulator type */
		demod_type = (int) *mxGetPr(prhs[1]);
		if ( (demod_type < 0)||(demod_type > 4) )
			mexErrMsgTxt("demod_type must be be 0 through 4");
	}
	
	/* idetermine the number of symbols */
	NumberSymbols = mxGetN(prhs[0]);
	M = mxGetM(prhs[0]);

	/* determine number of bits per symbol */
	m = 0;
	temp_int = M;
	while (temp_int>1) {
		temp_int = temp_int/2;
		m++;
	}
    #ifdef DEBUG
	printf( "%d bits per symbol\n", m );
    #endif
    
	if (temp_int < 1)
		mexErrMsgTxt("Number of symbols M must be a power of 2");

	DataLength = m*NumberSymbols; /* total number of bits */

    /* the bit-wise LLRs (for output) */
	plhs[0] = mxCreateNumericMatrix(1, DataLength, mxSINGLE_CLASS, mxREAL );
	output_p = mxGetPr(plhs[0]);

	if (nrhs > 2) {
		/* third (optional) input is the extrinsic llr */
        Number_LLR_bits = mxGetN(prhs[2]);
        if ( Number_LLR_bits > DataLength )
            mexErrMsgTxt("Too many a prior LLR inputs");
        llr_in = mxGetPr(prhs[2]);
        
        /* process using the extrinsic llr input */
        for (n=0;n<NumberSymbols;n++) { /* loop over symbols */
            
            /* add a priori likelihood to symbol likelihoods */
            for (i=1;i<M;i++) {
                mask = 1 << m - 1;
                for (j=0;j<m;j++) {		/* incorporate extrinsic info */
                    if (mask&i)
                        input[n*M+i] = input[n*M+i] + llr_in[n*m+j];
                    mask = mask >> 1;
                }
            } 
            
            mask = 1 << m-1;
            for (k=0;k<m;k++) {
                /* initialize */
                den = input[ n*M ]; /* all-zeros */
                num = input[ n*M + (M-1) ] - llr_in[n*m+k]; /* all-ones */
                
                /* loop over all symbols except for all-zeros and all-ones */
                for (i=1;i<(M-1);i++) {             
                    if (mask&i) /* this bit is a one */
                        num = ( *max_star[demod_type] )( num, input[n*M+i] - llr_in[n*m+ k]);
                    else  /* this bit is a zero */
                        den = ( *max_star[demod_type] )( den, input[n*M+i] );          
                }
                mask = mask >> 1;
            
                output_p[m*n+k] = num - den;
            }    
        }
	} else {
        /* process without using the extrinsic llr input */
        for (n=0;n<NumberSymbols;n++) { /* loop over symbols */
            
            mask = 1 << m-1;
            for (k=0;k<m;k++) {
                /* initialize */
                den = input[ n*M ]; /* all-zeros */
                num = input[ n*M + (M-1) ]; /* all-ones */
                
                /* loop over all symbols except for all-zeros and all-ones */
                for (i=1;i<(M-1);i++) {             
                    if (mask&i) /* this bit is a one */
                        num = ( *max_star[demod_type] )( num, input[n*M+i] );
                    else  /* this bit is a zero */
                        den = ( *max_star[demod_type] )( den, input[n*M+i] );          
                }
                mask = mask >> 1;
            
                output_p[m*n+k] = num - den;
            }                        
        }
    }

	return;
}

