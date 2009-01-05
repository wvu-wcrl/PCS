package com.iterativesolutions.cml.jobServer;

/**
 * Implementation of WebCML job state.  Initially the simulation parameters are hard coded.
 * Eventually they will be written and read from XML files.
 * 
 * No input checking.
 * 
 * @author Terry
 * @version 1.0 - 12/16/2008
 * 
 */

@SuppressWarnings("serial")
public class JobData implements java.io.Serializable {

	/* Job data */
	private String username;		/* CML username */
	private int jobNum;				/* Job Number */
	
	
	/* Simulation input parameters */	
	private double[] EbNo;			/* EbNo values in dB */
	private long maxTrials;			/* Maximum number of trials to simulate */
	private double errorFloor;		/* Simulate down to this EbNo value */
	
	
	/* Simulation result values */
	private double[] BER;			/* Computed BER */
	private long numTrials[];		/* Number of completed trials */
	private long errors[];			/* Recorded errors */
		
	
	/* Accessors */
	
	/* setters */
	/**
	 * @param errorFloor
	 */
	public void setBER(double BER[]){
		this.BER = BER;
	}
	
	/**
	 * @param errorFloor
	 */
	public void setErrorFloor(double errorFloor){
		this.errorFloor = errorFloor;
	}
	
	/**
	 * @param EbNo
	 */
	public void setEbNo(double[] EbNo){
		this.EbNo = EbNo;
	}
	
	/**
	 * @param username
	 */
	public void setUsername(String username){
		this.username = username;
	}

	/**
	 * 
	 * @param maxTrials
	 */
	public void setMaxTrials(int maxTrials){
		this.maxTrials = maxTrials;
	}
	
	/**
	 * 
	 * @param jobNum
	 */
	public void setjobNum(int jobNum){
		this.jobNum = jobNum;
	}

	/**
	 * 
	 * @param numTrials
	 */
	public void setnumTrials(long[] numTrials){
		this.numTrials = numTrials;
	}
	
	/**
	 * 
	 * @param errors
	 */
	public void setErrors(long[] errors){
		this.errors = errors;
	}


	/* getters */
	
	
	/**
	 * @param EbNo
	 */
	public double[] getEbNo(){
		return EbNo;
	}

	/**
	 * @param username
	 */
	public String getUsername(){
		return username;
	}

	/**
	 * 
	 * @param maxTrials
	 */
	public long getMaxTrials(){
		return maxTrials;
	}
	
	/**
	 * 
	 * @param jobNum
	 */
	public int getjobNum(){
		return jobNum;
	}

	/**
	 * 
	 * @param numTrials
	 */
	public long[] getnumTrials(){
		return numTrials;
	}
	
	/**
	 * 
	 * @param errors
	 */
	public long[] getErrors(){
		return errors;
	}
	
	/**
	 * @param errorFloor
	 */
	public double getErrorFloor(){
		return errorFloor;
	}
	
	/**
	 * @param errorFloor
	 */
	public double[] getBER(){
		return BER;
	}

	
	
}
