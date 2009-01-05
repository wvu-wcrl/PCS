package com.iterativesolutions.cml.modulator;

import com.iterativesolutions.cml.util.Complex;

/**
 * Implementation of a BPSK modulator, inherited from base class "Modulator"
 * @author Terry
 *
 */


public class BPSK extends Modulator{

	private Complex S[];
	/* Only constructor */
	
	/**
	 *	This is a Javadoc comment.
	 *  Only constructor 
	 *  
	 */
	public BPSK(){
		
		/* Create the S-matrix */
	    S = new Complex[2];
	    S[0] = new Complex(1,0);
	    S[1] = new Complex(-1,0);
	    
	    /* Set modulator properties */
	    setK(1);
	    setbps(1);
	    setS(S);
	}
	
}
