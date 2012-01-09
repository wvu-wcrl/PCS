/* File: VectorDemod.c

   Description: Transforms received symbols into symbol log-likelihoods 

   The calling syntax is:
      [log_likelihood] = VectorDemod( input, S_matrix, snr )

   Where:
      log_likelihood = M by N matrix of symbol log-likelihoods (float)

      input     = K by N real matrix of matched filter outputs (float)
	  S_matrix  = K by M matrix of constellation points (float)
	  snr       = instantaneous SNR |a|^2/N_0. (float)
                  can be a scalar, vector, or matrix. 

   Copyright (C) 2005-2009, Matthew C. Valenti

   Last updated on Aug. 25, 2009

   Function VectorDemod is part of the Iterative Solutions 
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

/* Input Arguments
prhs[0] is input
prhs[1] is S_matrix
prhs[2] is snr

/* Output Arguments
plhs[0] is log_likelihood

/* main function that interfaces with MATLAB */
void mexFunction(
				 int            nlhs,
				 mxArray       *plhs[],
				 int            nrhs,
				 const mxArray *prhs[] )
{
    int    KK, MM, LL, snr_rows, snr_cols, i, j, k;
    double *input, *S_matrix, *snr; 
    float  *log_likelihood;
    double dist, partial_sum;
    
    /* make sure there are enough inputs */
    if (nrhs<3)
        mexErrMsgTxt("Usage: [log_likelihood] = VectorDemod( input, S_matrix, snr )");
    
    /* determine and verify properties */
    LL = mxGetN( prhs[0] );  /* length of the symbol sequence */
    KK = mxGetM( prhs[0] );  /* dimensionality of the signal set */
    MM = mxGetN( prhs[1] );  /* size of the signal set */
    
    if(mxGetM( prhs[1] ) != KK  )
        mexErrMsgTxt("S_matrix should have same number of rows as input");
    
    snr_rows = mxGetM( prhs[2] );  /* number of rows in the snr matrix */
    snr_cols = mxGetN( prhs[2] );  /* number of columns in the snr matrix */
    
    /* first input is the received signal vectors */
    input = mxGetPr( prhs[0] );
    S_matrix = mxGetPr( prhs[1] );
    snr = mxGetPr( prhs[2] );
    
    /* initialize the output */
    plhs[0] = mxCreateNumericMatrix( MM, LL, mxSINGLE_CLASS, mxREAL );
    log_likelihood = mxGetPr( plhs[0] );
    
    if ( ( snr_rows == 1 )&&( snr_cols == 1 ) ) {
        #ifdef DEBUG
        mexPrintf( "SNR is a scalar\n" );
        #endif
        /* loop over each received symbol */
        for (i=0;i<LL;i++) {
            /* loop over each postulated symbol */
            for (j=0;j<MM;j++) {
                partial_sum = 0;
                /* loop over each dimension */
                for (k=0;k<KK;k++) {
                    dist = input[i*KK+k] - S_matrix[j*KK+k];
                    partial_sum = partial_sum + dist*dist;
                }
                /* in this case th snr if fixed for whole packet */
                log_likelihood[i*MM+j] = (float) -snr[0]*partial_sum;
            }
        }
    } else if ( snr_cols == 1 ) {
        #ifdef DEBUG
        mexPrintf( "SNR is a row vector\n" );
        #endif
        /* loop over each received symbol */
        for (i=0;i<LL;i++) {
            /* loop over each postulated symbol */
            for (j=0;j<MM;j++) {
                partial_sum = 0;
                /* loop over each dimension */
                for (k=0;k<KK;k++) {
                    dist = input[i*KK+k] - S_matrix[j*KK+k];
                    partial_sum = partial_sum + dist*dist;
                }
                /* in this case, the SNR is time-varying */
                log_likelihood[i*MM+j] = (float) -snr[i]*partial_sum;
            }
        }    
    } else {
        /* for future expansion */
        mexErrMsgTxt("snr cannot have more than one row, at least not yet");
    }
}
