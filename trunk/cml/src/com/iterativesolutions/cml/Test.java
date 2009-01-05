package com.iterativesolutions.cml;

import com.iterativesolutions.cml.modulator.*;
import com.iterativesolutions.cml.util.Complex;
import java.util.Random;

/**
 * Test program for BPSK and QPSK.
 * @author Terry
 *
 */
public class Test {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		/* Modulators */
		BPSK bpskMod = new BPSK();
		QPSK qpskMod = new QPSK();
		Modulator mod; //ijhguhj
		
		/* Random number generators */
		Random rand = new Random();
		
		Complex symbols[];
		
		
		
		/* Generate ten random bits */
		int data[] = new int[10];
		for(int k = 0; k < 10; k++){
		data[k] = rand.nextInt(2);	
		}
				
		/****************/
		/* First use the BPSK modulator */
		mod = bpskMod;
		symbols = mod.modulate(data);
		/****************/
		
		for(int k = 0; k < 10; k++){
			System.out.print(data[k]);
			System.out.print("    ");
			}
		System.out.println();
		
		for(int k = 0; k < symbols.length; k++){
			System.out.print(symbols[k].getReal());
			if(symbols[k].getImaginary() >= 0)
				System.out.print("+");
			
			System.out.print(symbols[k].getImaginary());
			System.out.print("i" + "   ");
			}
		
		System.out.println();
		System.out.println();
		
		/****************/
		/* Now use the QPSK modulator */
		mod = qpskMod;
		symbols = mod.modulate(data); //Polymorphistic function call 
	    /****************/
		
		for(int k = 0; k < 10; k++){
			System.out.print(data[k]);
			System.out.print("    ");
			}
		System.out.println();
		
		for(int k = 0; k < symbols.length; k++){
		System.out.print(symbols[k].getReal());
		if(symbols[k].getImaginary() >= 0)
			System.out.print("+");
		
		System.out.print(symbols[k].getImaginary());
		System.out.print("i" + "   ");
		}
		
		

	}

}
