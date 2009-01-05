/**
 * 
 */
package com.iterativesolutions.cml.jobServer;

/**
 * Definition of running job state.  A CML job can be in one of four states:
 * 1. Pending - job not yet launched
 * 2. Running - the job has been launched, and the server is waiting for results
 * 3. Finished - job is complete, and results have been returned.
 * 4. Failed - the job failed for some reason
 * 
 * No exception handling right now.
 * 
 * DEFINE THE STATES USING STRINGS IN THIS INTERFACE
 * 
 * @author Terry
 * @version 1.0 - 12/16/2008
 *
 */
@SuppressWarnings("serial")
public class JobState implements java.io.Serializable{
	
	/* Fields */
	private byte state;			/* Stores job state */	
	private boolean updated; 	/* Tracks whether job state has changed since last access by GUI */
	private int jobId;			/* unique job identifier for the server */
	
	/**
	 * Constructor
	 * @param state
	 * @param updated
	 * @param jobId
	 */
	public JobState(int jobId){
		state = 1; // Job is pending.
		this.updated = false; 
		this.jobId = jobId; // Latest iteration of server job counter.
	}
	
	/* Accessors */

	/**
	 * @param state
	 */
	public void setState(byte state){
		this.state = state;
	}
	
	/**
	 * 
	 * @param updated
	 */
	public void setUpdated(boolean updated){
		this.updated = updated;
	}
	
	/**
	 * 
	 * @param jobId
	 */
	public void setJobId(int jobId){
		this.jobId = jobId;
	}
	
	/**
	 * 
	 * @return
	 */
	public byte getState(){
		return state;
	}

	/**
	 * 
	 * @return
	 */
	public boolean getUpdated(){
		return updated;
	}
	
	/**
	 * 
	 * @return
	 */
	public int getJobId(){
		return jobId;
	}
		
	
}
