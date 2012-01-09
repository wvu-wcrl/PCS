/* file: Bicmid_decode.c
 *
 * Description: Decode a block code using the message passing algorithm.
 *
 *        [output1,errors] = Bicmid_decode(symbol_likelihood, row_one, col_one, ...
 *           bicm_interleaver, max_iter, data0);
 *
 */

#include <math.h>
#include <mex.h>
#include <matrix.h>
#include <stdlib.h>
#include "maxstar.h"


/* Input Arguments */
#define INPUT       prhs[0]
#define ROWONE		prhs[1]
#define COLONE		prhs[2]
#define INTLV       prhs[3]
#define MAXITER     prhs[4]
#define DATA        prhs[5]
#define FLAG        prhs[6]

/* Output Arguments */
#define OUTPUT      plhs[0]
#define	ERRORS      plhs[1]
struct v_node {
    int degree;
    float initial_value;
    int *index;  /* the index of a c_node it is connected to */
    int *socket; /* socket number at the c_node */
    float *message;
    int *sign;
};

struct c_node {
    int degree;
    int *index;
    float *message;
    int *socket; /* socket number at the v_node */
};

/* Phi function */
static float phi0(
        float x ) {
    float z;
    
    if (x>10)
        return( 0 );
    else if (x< 9.08e-5 )
        return( 10 );
    else if (x > 9)
        return( 1.6881e-4 );
    /* return( 1.4970e-004 ); */
    else if (x > 8)
        return( 4.5887e-4 );
    /* return( 4.0694e-004 ); */
    else if (x > 7)
        return( 1.2473e-3 );
    /* return( 1.1062e-003 ); */
    else if (x > 6)
        return( 3.3906e-3 );
    /* return( 3.0069e-003 ); */
    else if (x > 5)
        return( 9.2168e-3 );
    /* return( 8.1736e-003 ); */
    else {
        z = (float) exp(x);
        return( (float) log( (z+1)/(z-1) ) );
    }
}


float (*max_star[])(float, float) = {
    max_star0, max_star1, max_star2, max_star3, max_star4
};

static void interleave(double *data_in, double *intlv_pattern, int data_length, double *data_out) {
    int i;
    int index;
    
    for(i=0;i<data_length;i++) {
        index = (int) intlv_pattern[i];
        data_out[i] = data_in[index];
    }
    
}

static void deinterleave(double *data_in, double *intlv_pattern, int data_length, double *data_out) {
    int i;
    int index;
    
    for(i=0;i<data_length;i++) {
        index = (int) intlv_pattern[i];
        data_out[index] = data_in[i];
    }
    
}



static void somap(double *symllr, double *extrllr, double *bitllr, int M, int NumberSymbols, int extr_length)

{
    int i, j, k, n, mask;
    float metric;
    float *den, *num;
    int temp_int;
    int m = 0;
    int Code_length;
    
    
    temp_int = M;
    while (temp_int>1) {
        temp_int = temp_int/2;
        m++;
    }
    
    if (temp_int < 1)
        mexErrMsgTxt("Number of symbols M must be a power of 2");
    
    Code_length = m*NumberSymbols; /* total number of bits */
    
    if ( extr_length > Code_length )
        mexErrMsgTxt("Too many a prior LLR inputs");
    
    den = calloc( m, sizeof(float) );
    num = calloc( m, sizeof(float) );
    
    for (n=0;n<NumberSymbols;n++) { /* loop over symbols */
        for (k=0;k<m;k++) {
            /* initialize */
            num[k] = -1000000;
            den[k] = -1000000;
        }
        
        for (i=0;i<M;i++) {
            metric = symllr[n*M+i]; /* channel metric for this symbol */
            mask = 1 << m - 1;
            for (j=0;j<m;j++) {		/* incorporate extrinsic info */
                if (mask&i) {
                    metric += extrllr[n*m+j];
                }
                mask = mask >> 1;
            }
            
            mask = 1 << m - 1;
            for (k=0;k<m;k++) {	/* loop over bits */
                if (mask&i) {
                    /* this bit is a one */
                    num[k] = ( *max_star[0] )( num[k], metric - extrllr[n*m+k] );
                } else {
                    /* this bit is a zero */
                    den[k] = ( *max_star[0] )( den[k], metric );
                }
                mask = mask >> 1;
            }
        }
        
        for (k=0;k<m;k++) {
            bitllr[m*n+k] = num[k] - den[k];
        }
    }
    free(den);
    free(num);
    
}


/* function for doing the LDPC decoding */
static void SumProduct(
        int	  BitErrors[],
        int      DecodedBits[],
        struct c_node c_nodes[],
        struct v_node v_nodes[],
        int	  CodeLength,
        int	  NumberParityBits,
        int	  max_iter,
        int      data[] ) {
    int i, j, iter;
    float phi_sum;
    int sign;
    float temp_sum;
    float Qi;
    
    for (iter=0;iter<max_iter;iter++) {
        /* update r */
        for (j=0;j<NumberParityBits;j++) {
            sign = v_nodes[ c_nodes[j].index[0] ].sign[ c_nodes[j].socket[0] ];
            phi_sum = v_nodes[ c_nodes[j].index[0] ].message[ c_nodes[j].socket[0] ];
            
            for (i=1;i<c_nodes[j].degree;i++) {
                phi_sum += v_nodes[ c_nodes[j].index[i] ].message[ c_nodes[j].socket[i] ];
                sign ^= v_nodes[ c_nodes[j].index[i] ].sign[ c_nodes[j].socket[i] ];
            }
            
            for (i=0;i<c_nodes[j].degree;i++) {
                if ( sign^v_nodes[ c_nodes[j].index[i] ].sign[ c_nodes[j].socket[i] ] ) {
                    c_nodes[j].message[i] = -phi0( phi_sum - v_nodes[ c_nodes[j].index[i] ].message[ c_nodes[j].socket[i] ] );
                } else
                    c_nodes[j].message[i] = phi0( phi_sum - v_nodes[ c_nodes[j].index[i] ].message[ c_nodes[j].socket[i] ] );
            }
        }
        
        /* update q */
        for (i=0;i<CodeLength;i++) {
            
            /* first compute the LLR */
            Qi = v_nodes[i].initial_value;
            for (j=0;j<v_nodes[i].degree;j++) {
                Qi += c_nodes[ v_nodes[i].index[j] ].message[ v_nodes[i].socket[j] ];
            }
            
            /* make hard decision */
            if (Qi < 0) {
                DecodedBits[i] = 1;
            }
            
            /* now subtract to get the extrinsic information */
            for (j=0;j<v_nodes[i].degree;j++) {
                temp_sum = Qi - c_nodes[ v_nodes[i].index[j] ].message[ v_nodes[i].socket[j] ];
                
                v_nodes[i].message[j] = phi0( fabs( temp_sum ) );
                if (temp_sum > 0)
                    v_nodes[i].sign[j] = 0;
                else
                    v_nodes[i].sign[j] = 1;
            }
        }
        
        /* count data bit errors, assuming that it is systematic */
        for (i=0;i<CodeLength-NumberParityBits;i++)
            if ( DecodedBits[i] != data[i] )
                BitErrors[iter]++;
        
        /* Halt if zero errors */
        if (BitErrors[iter] == 0)
            break;
        
    }
}





/* function for doing the BICMID decoding */
static void SumProduct1(
        
        
        int	  BitErrors[],
        int   DecodedBits[],
        double input[],
        struct c_node c_nodes[],
        struct v_node v_nodes[],
        int	  CodeLength,
        int	  NumberParityBits,
        double intlv_pattern[],
        int	  max_iter,
        int      data[],
        int m,
        int M,
        int NumberSymbols   ) {
    int i, j, iter;
    float phi_sum;
    int sign;
    float temp_sum;
    float Qi;
    float metric;
    int mask;
    int n, k;
    double  *out_soft;
    double *out_soft_i;
    double *input_p1, *input_i1;
    
    
    out_soft = calloc(CodeLength  , sizeof(double));
    out_soft_i = calloc(CodeLength  , sizeof(double));
    input_p1 = calloc(CodeLength  , sizeof(double));
    input_i1 = calloc(CodeLength  , sizeof(double));
    
    
    /*  mexPrintf("\n");
     * for (i=0;i<CodeLength;i++) {
     * mexPrintf("\t%f",v_nodes[i].initial_value);
     * }
     * mexPrintf("\n");   */
    
    
    for (iter=0;iter<max_iter;iter++) {
        /* update r */
        for (j=0;j<NumberParityBits;j++) {
            sign = v_nodes[ c_nodes[j].index[0] ].sign[ c_nodes[j].socket[0] ];
            phi_sum = v_nodes[ c_nodes[j].index[0] ].message[ c_nodes[j].socket[0] ];
            
            for (i=1;i<c_nodes[j].degree;i++) {
                phi_sum += v_nodes[ c_nodes[j].index[i] ].message[ c_nodes[j].socket[i] ];
                sign ^= v_nodes[ c_nodes[j].index[i] ].sign[ c_nodes[j].socket[i] ];
            }
            
            for (i=0;i<c_nodes[j].degree;i++) {
                if ( sign^v_nodes[ c_nodes[j].index[i] ].sign[ c_nodes[j].socket[i] ] ) {
                    c_nodes[j].message[i] = -phi0( phi_sum - v_nodes[ c_nodes[j].index[i] ].message[ c_nodes[j].socket[i] ] );
                } else
                    c_nodes[j].message[i] = phi0( phi_sum - v_nodes[ c_nodes[j].index[i] ].message[ c_nodes[j].socket[i] ] );
            }
        }
        
        /* update q */
        for (i=0;i<CodeLength;i++) {
            
            /* first compute the LLR */
            Qi = 0;
            for (j=0;j<v_nodes[i].degree;j++) {
                Qi += c_nodes[ v_nodes[i].index[j] ].message[ v_nodes[i].socket[j] ];
            }
            
            out_soft_i[i] = -Qi ;
            
            
            
            
            /* now subtract to get the extrinsic information
             * for (j=0;j<v_nodes[i].degree;j++) {
             * temp_sum = Qi - c_nodes[ v_nodes[i].index[j] ].message[ v_nodes[i].socket[j] ];
             * /*  	out_soft[iter+max_iter*i] = temp_sum;
             *
             * v_nodes[i].message[j] = phi0( fabs( temp_sum ) );
             *
             * if (temp_sum > 0)
             * v_nodes[i].sign[j] = 0;
             * else
             * v_nodes[i].sign[j] = 1;
             * }*/
            
        }
        
        interleave(out_soft_i, intlv_pattern, CodeLength, out_soft);
        
        somap(input, out_soft, input_i1, M, NumberSymbols, CodeLength);
        
        deinterleave(input_i1, intlv_pattern, CodeLength, input_p1);
        
        for (i=0;i<CodeLength;i++) {
            v_nodes[i].initial_value = -input_p1[i];
            input_p1[i] = input_p1[i] + out_soft_i[i];
            
            /* make hard decision */
            if (input_p1[i] > 0)
                DecodedBits[i] = 1;
            else
                DecodedBits[i] = 0;
            
            
        }
        
        
        /* count data bit errors, assuming that it is systematic */
        for (i=0;i<CodeLength-NumberParityBits;i++)
            if ( DecodedBits[i] != data[i] )
                BitErrors[iter]++;
        
        /* Halt if zero errors */
        if (BitErrors[iter] == 0){
            break;
        }
        
        
        for (i=0;i<CodeLength;i++) {
            
            
            for (j=0;j<v_nodes[i].degree;j++) {
                temp_sum = -input_p1[i]  - c_nodes[ v_nodes[i].index[j] ].message[ v_nodes[i].socket[j] ];
                /*  	out_soft[iter+max_iter*i] = temp_sum;  */
                
                v_nodes[i].message[j] = phi0( fabs( temp_sum ) );
                
                if (temp_sum > 0)
                    v_nodes[i].sign[j] = 0;
                else
                    v_nodes[i].sign[j] = 1;
            }
            
            
            
        }
    }
    free(out_soft);
    free(out_soft_i);
    free(input_p1);
    free(input_i1);
}

/* main function that interfaces with MATLAB */
void mexFunction(
        int            nlhs,
        mxArray       *plhs[],
        int            nrhs,
        const mxArray *prhs[] )
        
{	int		max_iter;
    int		max_row_weight, max_col_weight;
    int		NumberParityBits, CodeLength;
    double  *Row_one, *Col_one;		/* Parity check matrix info */
    double  *input;
    double  *input_p, *input_i;
    double  *intlv_pattern;
    int     i, j, count, v_index, c_index;
    int		*DecodedBits;	/* Output of the decoder.  Is an array of size iter by CodeLength */
    
    float   *out_soft;
    
    int		*BitErrors;		/* Number of errors at each iteration */
    double  *errors_p, *output_p;
    struct c_node *c_nodes;
    struct v_node *v_nodes;
    double  *data;
    int     *data_int;
    int     DataLength;
    int     cnt;
    float metric;
    int     k, m, M, n;
    int     NumberCodeBits;
    int     NumberSymbols;
    float *den, *num;
    int temp_int, mask;
    int flag;
    /* default values */
    
    flag = 1;
    max_iter  = 30;
    
    /* Check for proper number of arguments */
    if ( (nrhs < 4 )|(nlhs  > 2) ) {
        mexErrMsgTxt("[output, errors ] = Bicmid_decode(input, row_one, col_one, bicm_interleaver, [max_iter], [data] )");
    } else {
        /* first input is the received data in LLR form */
        input = mxGetPr(INPUT);
        
        /* second input is H_rows matrix */
        Row_one = mxGetPr( ROWONE );
        
        /* third input is H_cols matrix */
        Col_one = mxGetPr( COLONE );
        intlv_pattern = mxGetPr(INTLV);
        /* derive some parameters */
        
        NumberSymbols = mxGetN(INPUT);
        M = mxGetM(INPUT);
        
        /* determine number of bits per symbol */
        m = 0;
        temp_int = M;
        while (temp_int>1) {
            temp_int = temp_int/2;
            m++;
        }
        
        if (temp_int < 1)
            mexErrMsgTxt("Number of symbols M must be a power of 2");
        
        CodeLength = m*NumberSymbols; /* total number of bits */
        den = calloc( m, sizeof(float) );
        num = calloc( m, sizeof(float) );
        input_p = calloc(CodeLength, sizeof(double));
        input_i = calloc(CodeLength, sizeof(double));
        
        
        for (n=0;n<NumberSymbols;n++) { /* loop over symbols */
            
            for (k=0;k<m;k++) {
                /* initialize */
                num[k] = -1000000;
                den[k] = -1000000;
            }
            
            for (i=0;i<M;i++) {
                metric = input[n*M+i]; /* channel metric for this symbol */
                mask = 1 << m - 1;
                for (k=0;k<m;k++) {	/* loop over bits */
                    if (mask&i) {
                        /* this bit is a one */
                        num[k] = ( *max_star[0] )( num[k], metric );
                    } else {
                        /* this bit is a zero */
                        den[k] = ( *max_star[0] )( den[k], metric );
                    }
                    mask = mask >> 1;
                }
            }
            
            for (k=0;k<m;k++) {
                input_i[m*n+k] = den[k] - num[k];
            }
        }
        
        deinterleave(input_i, intlv_pattern, CodeLength, input_p);
        
        NumberParityBits = mxGetM( ROWONE );
        NumberCodeBits = mxGetM( COLONE );
        if ( CodeLength != NumberCodeBits )
            mexErrMsgTxt("Error: Number of rows in H_cols must equal number of received bits or number of data bits");
        
        max_row_weight = mxGetN( ROWONE );
        
        max_col_weight = mxGetN( COLONE );
        
    }
    
    /* initialize c-node structures */
    c_nodes = calloc( NumberParityBits, sizeof( struct c_node ) );
    
    /* first determine the degree of each c-node */
    
    
    for (i=0;i<NumberParityBits;i++) {
        count = 0;
        for (j=0;j<max_row_weight;j++) {
            if ( Row_one[i+j*NumberParityBits] > -1 )
                count++;
            
        }
        c_nodes[i].degree = count;
        
    }
    
    
    
    for (i=0;i<NumberParityBits;i++) {
        /* now that we know the size, we can dynamically allocate memory */
        c_nodes[i].index =  calloc( c_nodes[i].degree, sizeof( int ) );
        c_nodes[i].message =calloc( c_nodes[i].degree, sizeof( float ) );
        c_nodes[i].socket = calloc( c_nodes[i].degree, sizeof( int ) );
        
        for (j=0;j<c_nodes[i].degree;j++){
            c_nodes[i].index[j] = (int) (Row_one[i+j*NumberParityBits]);
            
        }
    }
    
    
    /* initialize v-node structures */
    v_nodes = calloc( CodeLength, sizeof( struct v_node));
    
    /* determine degree of each v-node */
    for(i=0; i<CodeLength; i++){
        count=0;
        for (j=0;j<max_col_weight;j++) {
            if ( Col_one[i+j*NumberCodeBits] > -1 ) {
                count++;
            }
        }
        v_nodes[i].degree = count;
    }
    
    
    
    
    for (i=0;i<CodeLength;i++) {
        /* allocate memory according to the degree of the v-node */
        v_nodes[i].index = calloc( v_nodes[i].degree, sizeof( int ) );
        v_nodes[i].message = calloc( v_nodes[i].degree, sizeof( float ) );
        v_nodes[i].sign = calloc( v_nodes[i].degree, sizeof( int ) );
        v_nodes[i].socket = calloc( v_nodes[i].degree, sizeof( int ) );
        
        /* index tells which c-nodes this v-node is connected to */
        v_nodes[i].initial_value = input_p[i];
        count=0;
        
        for (j=0;j<v_nodes[i].degree;j++) {
            
            v_nodes[i].index[j]=(int) (Col_one[i+j*NumberCodeBits]);
            
            for (c_index=0;c_index<c_nodes[ v_nodes[i].index[j] ].degree;c_index++)
                if ( c_nodes[ v_nodes[i].index[j] ].index[c_index] == i ) {
                v_nodes[i].socket[j] = c_index;
                break;
                }
            
            /* initialize v-node with received LLR */
            
            v_nodes[i].message[j] = phi0( fabs(input_p[i]) );
            
            if (input_p[i] < 0)
                v_nodes[i].sign[j] = 1;
        }
        
    }
    
    
    /* now finish setting up the c_nodes */
    for (i=0;i<NumberParityBits;i++) {
        /* index tells which v-nodes this c-node is connected to */
        for (j=0;j<c_nodes[i].degree;j++) {
            /* search the connected v-node for the proper message value */
            for (v_index=0;v_index<v_nodes[ c_nodes[i].index[j] ].degree;v_index++)
                if (v_nodes[ c_nodes[i].index[j] ].index[v_index] == i ) {
                c_nodes[i].socket[j] = v_index;
                break;
                }
        }
    }
    
    
    
    if (nrhs > 3 ) {
        /* fourth input (optional) is maximum number of iterations */
        max_iter   = (int) *mxGetPr(MAXITER);
    }
    
    DataLength = CodeLength - NumberParityBits;
    data_int = calloc( DataLength, sizeof(int) );
    
    /*
     mexPrintf("%s\t%d\n", "nrhs: ", nrhs);
     mexPrintf("%s\t%d\n", "DataLength: ", DataLength);
     mexPrintf("%s\t%d\n", "mxGetPr(DATA): ", mxGetPr(DATA));
     */
    
    if (nrhs > 4 ) {
        /* next input is the data */
        data = mxGetPr(DATA);
        if ( DataLength != mxGetN(DATA) ) /* number of data bits */
            mexErrMsgTxt("Error: Incorrect number of data bits");
        
        /* cast the input into a vector of integers */
        for (i=0;i<DataLength;i++) {
            data_int[i] = (int) data[i];
        }
        
    }
    
    
    
    if (nrhs > 6 ) {
        /* sixth input (optional) is flag of BICM-ID or BICM */
        flag   = (int) *mxGetPr(FLAG);
    }
    else
        flag = 1;
    
    /* create matrices for the decoded data */
    OUTPUT = mxCreateDoubleMatrix(1, CodeLength, mxREAL );
    output_p = mxGetPr(OUTPUT);
    
    /* Decode */
    DecodedBits = calloc( CodeLength, sizeof( int ) );
    BitErrors = calloc( max_iter, sizeof(int) );
    
    /* Call function to do the actual decoding */
    
    
    if (flag) {
        SumProduct1( BitErrors, DecodedBits, input, c_nodes, v_nodes, CodeLength,
                NumberParityBits, intlv_pattern, max_iter,  data_int, m, M, NumberSymbols );
    }
    else {
        
        SumProduct( BitErrors, DecodedBits, c_nodes, v_nodes, CodeLength,
                NumberParityBits, max_iter, data_int );
    }
    /* cast to output */
    
    for (j=0;j<CodeLength;j++) {
        output_p[j] = DecodedBits[j];
        /*  output_p[i + j*max_iter] = out_soft[i+j*max_iter];*/
    }
    
    
    if (nlhs > 1 ) {
        /* second output is a count of the number of errors */
        ERRORS = mxCreateDoubleMatrix(max_iter, 1, mxREAL);
        errors_p = mxGetPr(ERRORS);
        
        /* cast to output */
        for (i=0;i<max_iter;i++) {
            errors_p[i] = BitErrors[i];
        }
    }
    
    /* Clean up memory */
    free( BitErrors );
    free( DecodedBits );
    free( data_int );
    free( input_p);
    free( input_i);
    free( den );
    free( num );
    /* printf( "Cleaning c-node elements\n" ); */
    for (i=0;i<NumberParityBits;i++) {
        free( c_nodes[i].index );
        free( c_nodes[i].message );
        free( c_nodes[i].socket );
    }
    
    /* printf( "Cleaning c-nodes \n" ); */
    free( c_nodes );
    
    /* printf( "Cleaning v-node elements\n" ); */
    for (i=0;i<CodeLength;i++) {
        free( v_nodes[i].index);
        free( v_nodes[i].sign );
        free( v_nodes[i].message );
        free( v_nodes[i].socket );
    }
    
    /* printf( "Cleaning v-nodes \n" ); */
    free( v_nodes );
    
    return;
}
