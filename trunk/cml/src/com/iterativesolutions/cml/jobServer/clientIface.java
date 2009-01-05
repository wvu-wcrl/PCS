/**
 * 
 */
package com.iterativesolutions.cml.jobServer;

/**
 * This is the interface that a client, such as Chandana's GUI, uses to interact
 * with the CML job scheduler.
 * 
 * @author Terry 12-17-2008
 *
 */
public interface clientIface {

	/**
	 * Add a job to the queue.
	 * @param jobIn
	 */
	void addJob(JobData jobIn);
	
	/**
	 * Get a reference to all completed jobs.  This also removes them from the queue.
	 * @return
	 */
	JobData[] reportJobs();	
}
