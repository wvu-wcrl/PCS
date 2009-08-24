/* File: BitPack.c

   Transform vector of bits into a vector of M-ary symbols.

   The calling syntax is:
      [output] = BitPack( input, bits_per_word )
 
      input is input bits as uint8
      output is output bits as int32

*/
#include <math.h>
#include <mex.h>
#include <matrix.h>
#include <stdlib.h>

/* Input Arguments
prhs[0] is input
prhs[1] is number of bits per word

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
    unsigned char *input_bits;
    int *output_symbols;    
    int bits_per_symbol; 
    int number_bits, number_symbols;
    int i, j, index;

    /* make sure there are enough inputs */
    if (nrhs<2)
        mexErrMsgTxt("[output] = BitPack( input, bits_per_word )");
    
    /* read in input bits */
    number_bits = mxGetN(prhs[0]);
    input_bits = mxGetPr(prhs[0]);
    
    /* second input is number of bits per word */
    bits_per_symbol = (int) *mxGetPr( prhs[1] );
    
    /* determine the number of output symbols */
    number_symbols = number_bits/bits_per_symbol + (number_bits%bits_per_symbol>0);
    
    #ifdef DEBUG
    mexPrintf( "(%d bits)/(%d symbols) = %d bits per symbol\n", number_bits, number_symbols, bits_per_symbol );
    #endif
    
    /* create the output matrix */
    plhs[0] = mxCreateNumericMatrix( 1, number_symbols, mxINT32_CLASS, mxREAL );
    // plhs[0] = mxCreateNumericMatrix( 1, number_symbols, mxDOUBLE_CLASS, mxREAL );
    output_symbols = mxGetPr( plhs[0] );

    /* determine output */
    for (i=0;i<number_symbols;i++) { /* create each modulated symbol */
        index = 0;
        for (j=0;j<bits_per_symbol;j++) { /* go through each associated bit */
            index = index << 1; /* shift to the left (multiply by 2) */
            index += (int) input_bits[i*bits_per_symbol+j];
        }
        output_symbols[i] = index+1;
    }

}

