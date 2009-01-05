package com.iterativesolutions.cml.modulator;

import com.iterativesolutions.cml.util.Complex;

/**
 * Implementation of a BPSK modulator, inherited from base class "Modulator"
 * @author Terry
 *
 */

public class QPSK extends Modulator{

	private Complex S[];
	/**
	 *	This is a Javadoc comment.
	 *  Only constructor 
	 *  
	 */
	public QPSK(){

		/* Create the S-matrix */
		S = new Complex[4];
		S[0] = new Complex(1,0);
		S[1] = new Complex(0,1);
		S[2] = new Complex(0,-1);
		S[3] = new Complex(-1,0);


		/* Set modulator properties */
		setK(1);
		setbps(2);
		setS(S);

	}
}
