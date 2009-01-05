

package com.iterativesolutions.cml.modulator;

/**
 * Use only 1d arrays.
 * http://www.roseindia.net/javatutorials/java_multi_dimensions_array.shtml
 * 
 */

import com.iterativesolutions.cml.util.Complex;

/**
 *	This is a Javadoc comment.
 *  Base class for modulation. 
 *  
 */

public abstract class Modulator {

	/** I can add Javadoc comments for variables. */
	private int K; // S-matrix dimensions.
	private int bits_per_symbol;
	private Complex[] S_matrix; // Always 1d for speed.


	/** And methods.
	 *  Default constructor. */
	public Modulator(){}

	/**
	 * Performs modulation
	 * @param data
	 * @return symbols
	 */
	public Complex[] modulate(int[] data)
	{
		/* Iterators */
		int i, j, index;

		/* number of symbols and bits */
		int number_symbols, number_bits;
		
		/* Get the number of data bits. */
		number_bits = data.length;

		/* bits per symbol calculation moved to subclass */

		/* get the number of symbols */
		/* how are excess bits handled? */
		/* zero pad */
		number_symbols = number_bits/bits_per_symbol;

		/* Create the output matrix */
		Complex output[] = new Complex[K*number_symbols];

		/* Set output values */
		for(i = 0; i<number_symbols; i++){
			index = 0;
			/* loop through every bit in this symbol */
			for(j = 0; j < bits_per_symbol; j++){
				index = index << 1; /* left shift (multiply by 2) */
				index += data[i*bits_per_symbol + j];
			}
			/* assign the K-dimensional output symbol */
			for (j=0;j<K;j++) {
				output[K*i+j] = new Complex(S_matrix[K*index+j].getReal(),
						S_matrix[K*index+j].getImaginary());				
			}
		}

		return output;
	}

	/**
	 *  Setter for K */
	protected void setK(int KIn){
		K = KIn;
	}
	
	/**
	 *  Setter for bits per second */
	protected void setbps(int bpsIn){
		bits_per_symbol = bpsIn;
	}
	
	/**
	 *  Setter for S-matrix */
	protected void setS(Complex[] S_matrixIn){
		S_matrix = S_matrixIn;
	}
	
}

