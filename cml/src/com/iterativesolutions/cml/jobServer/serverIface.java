package com.iterativesolutions.cml.jobServer;

/**
 * This is the interface that a job dispatcher uses to interact with the shared
 * server state.
 * 
 * @author Terry 12-17-2008
 *
 */

public interface serverIface {

	/**
	 * Return the next pending job state.
	 * @return
	 */
	JobState getNextJobState();
	
	/**
	 * Return the job data with the specified job ID.
	 * @param jobId
	 * @return
	 */
	JobData getNextJobData(int jobId);
	void updateJobState(JobData dataIn, JobState stateIn);	
}
