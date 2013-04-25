#include <math.h>
#include "mex.h"
#include "time.h"

/*
    generic Discrete Pdf Random numbers generator
    powered by Gianluca Dorini
    
    g.dorini@ex.ac.uk
    
    for compiling type 
    
    mex gDiscrPdfRnd.c
    
*/

//  Y = gDiscrPdfRnd(pdf,n,m)

void gDiscrPdfRnd(double *,int ,  double *, double* ,int, int);

void mexFunction( int nlhs, mxArray *plhs[] , int nrhs, const mxArray *prhs[] )
{
	double *Y, *pdf, *nd, *cdf, sum;
	int N, n, m, i;
	const int  *dims;
		
	if(nrhs == 0) mexErrMsgTxt("syntax:\n\nY = gDiscrPdfRnd(pdf)\nY = gDiscrPdfRnd(pdf,n)\nY = gDiscrPdfRnd(pdf,n,m)");

	
	
	pdf = mxGetPr(prhs[0]);
	dims = mxGetDimensions(prhs[0]);
	
	N = dims[0] > dims[1]? dims[0] : dims[1];
    if(N==0) mexErrMsgTxt("pdf cannot be empty");
    for(i = 0; i<N; i++) if(pdf[i] < 0) mexErrMsgTxt("elements of pdf must be nonnegative");
    
    sum = 0;
    for(i = 0; i<N; i++) sum += pdf[i];
    if(sum == 0) mexErrMsgTxt("the sum of elements of pdf must be strictly positive");
	
	if(nrhs == 1)
	{
	    n = m = 1;
	}
	
    if(nrhs == 2)
	{
	    nd = mxGetPr(prhs[1]);
	    n = m = (int)*nd;

	}
	
	if(nrhs == 3)
	{
	    nd = mxGetPr(prhs[1]);
	    n = (int)*nd;
	    nd = mxGetPr(prhs[2]);
	    m = (int)*nd;
	}

    if(n <= 0 || m <= 0) mexErrMsgTxt("n and m must be > 0");
    
    


	/* ----- output ----- */

	plhs[0]    = mxCreateDoubleMatrix(n , m ,  mxREAL);
	Y          = mxGetPr(plhs[0]);
	
	cdf = (double *)mxMalloc(N*sizeof(double));
	
	/* main call */
	gDiscrPdfRnd(Y, N , pdf, cdf, n, m);
	
	mxFree(cdf);

}


void gDiscrPdfRnd(double * Y,int N ,  double * pdf, double* cdf,int n, int m)
{
       


        int i,j,k;
        double p;
        
        cdf[0] = pdf[0];
        for(i = 1; i<N; i++) cdf[i] = 0;
        
        for(i = 1; i < N; i++)
        {   
            cdf[i] = cdf[i-1] + pdf[i];
        }

        for(i = 0; i < n; i++)
        {
            for(j = 0; j < m; j++)
            {
            
                // randomize
                p = (double)rand()/32767*cdf[N-1];
                
                k = 0;
                while( p > cdf[k] && k<N)  k++;
                
                            
                Y[i + j*n] = k+1;
       
            }
            
         }

        
}