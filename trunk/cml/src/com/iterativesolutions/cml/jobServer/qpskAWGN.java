package com.iterativesolutions.cml.jobServer;

/* File: qpskAWGN.java
 * Author: Terry R. Ferrett
 * Date: 5/8/2007
 * 
 * This is a test simulation of quadriphase shift keying (QPSK) in additive white gaussian noise (AWGN).  
 * The purpose of the program is to compare execution time between a stand-alone machine and the Global Grid 
 * Exchange.
 * 
 */

import java.util.Random;
import java.lang.Math;
//import java.io.*;


public class qpskAWGN {
	
	private JobData dataIn;
	
	public qpskAWGN(){
	// Read: EbNo values, maxTrials		 
	}

	
	public void setJob(JobData dataIn){
		this.dataIn = dataIn;
	}
	
	public  JobData runSim(){ 
		int n;								// Number of values of EbNo to simulate.

		// Inputs: ebnos, error floor, max trials, max errors hard coded for now.
		long maxTrials = dataIn.getMaxTrials(); // = Math.pow(10,9);		// Maximum number of trials per value of EbNo.
		double EbNo[] = dataIn.getEbNo(); // = new double[n];  		// Values of EbNo to simulate.
		double errorFloor = dataIn.getErrorFloor(); // = Math.pow(10,-20);	// Error rate down which to simulate.
		long maxErrors = 500;				// Maximum errors per value of EbNo.
		
		// Get the number of EbNos
		n = EbNo.length;
		// Return values: errors at each ebno, trials at each ebno
		long bitErrors[] = new long[n];		// Bit errors per trial.
		long trials[] = new long[n];		// Trials per value EbNo.
		double BER[]  = new double[n];   		// Bit error rates.
		
		int dataSize = 100;						// Size of data block.
		double data[] = new double[2];			// Array to store data block.
		double symbol[] = new double[2];		// Received symbol.
		double noise[] = new double[2];			// Noise vectors.
		double var;								// Noise variance.
		
		
		Random dataGen = new Random();			// Random data generator.
		Random noiseGen = new Random();			// Random noise generator.

	//	FileOutputStream resultsFile; 			// File output
	//	PrintStream textStream; 				// Stream for character data. 


//		long startTime;						// Start of measured execution time.
//		long totalSeconds;					// Total seconds of execution time.
//		long executionTimeHrs;				// Whole hours elapsed.
//		long executionTimeMins;				// Whole minutes elapsed.
//		long executionTimeSeconds;			// Whole seconds elapsed.

		
		// Load EbNo with SNR values. 
//		int i;
//		for(i = 0; i < n; i++){
//			EbNo[i] = i;
//		}

		// Begin looping through the EbNo values.
		int j = 0;
		do{
			// Initialize the number of trials and bit errors to zero.
			trials[j] = 0;
			bitErrors[j] = 0;
			
			// Compute variance of AWGN process.
			var = 1/(4*(Math.pow(10,EbNo[j]/10)));
			
			// Begin measuring execution time for this value of EbNo.
			//startTime = System.nanoTime();
			

			// Generate data points, corrupt them with noise, and perform detection.
			while( (bitErrors[j]<maxErrors)&&(trials[j] < maxTrials) ){
				for(int i = 0; i < dataSize; i++) {
					//Uncorrupted symbols.
					data[0] = (1/Math.sqrt(2))*(2*Math.round(dataGen.nextDouble()) - 1);
					data[1] = (1/Math.sqrt(2))*(2*Math.round(dataGen.nextDouble()) - 1);


					//Samples of AWGN process.
					noise[0] = Math.sqrt(var)*noiseGen.nextGaussian();
					noise[1] = Math.sqrt(var)*noiseGen.nextGaussian();


					// Symbols corrupted by noise.
					symbol[0] = data[0] + noise[0];
					symbol[1] = data[1] + noise[1];


					// Test for errors.
					if(Math.signum(symbol[0]) != Math.signum(data[0])){
						bitErrors[j] = bitErrors[j] + 1;
					}
					if(Math.signum(symbol[1]) != Math.signum(data[1])){
						bitErrors[j] = bitErrors[j] + 1;
					}

				}

				// Update number of trials.
				trials[j] = trials[j] + 2*dataSize;

			}
			// Compute the bit error rate at this value of EbNo.
			BER[j] = (double)bitErrors[j]/(double)trials[j];

			// Print results.
//			try{
//				// Open the text file and set the access mode to append.
//				boolean append = true;
//				resultsFile = new FileOutputStream("results.txt", append);
//				textStream = new PrintStream( resultsFile );
//
//				
//				textStream.println();
//				
//				// Write the bit error rate to the text file.
//				textStream.println("EbNo: " + EbNo[j] + " BER: " + BER[j]);
//				
//				// Calculate execution time.
//				totalSeconds = Math.round((System.nanoTime() - startTime)/Math.pow(10, 9));
//				executionTimeSeconds = totalSeconds%60;
//				executionTimeMins = ((totalSeconds - executionTimeSeconds)/60)%60;
//				executionTimeHrs = (totalSeconds - executionTimeSeconds - executionTimeMins*60)/(60*60);
//							
//				// Print execution time to file.
//				textStream.println("Execution time: " + executionTimeHrs + " hours, " 
//						+ executionTimeMins + " minutes, " + executionTimeSeconds + " seconds.");
//								
//				textStream.close();
//			}
//			catch(Exception e){
//				System.err.println ("Error writing to file");
//			}
			// Proceed to the next value of EbNo.
			j++;
		}while( (j < n)&&(BER[j-1] > errorFloor) );
		dataIn.setErrors(bitErrors);
		dataIn.setnumTrials(trials);
		dataIn.setBER(BER);
		
		return dataIn;
		// Communicate back.
	}
}
