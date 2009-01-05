/**
 * 
 */
package com.iterativesolutions.cml.jobServer;

import java.util.List;
import java.util.ArrayList;

/**
 * Object which stores the running job data and job state, and passes it between the GUI and the
 * job server.
 * 
 * For now, the job state and job data are stored as two separate objects.  This necessitates passing
 * more than one object at a time between the server thread and shared data object.  This should
 * probably eventually be changed so that the server object extends the data coming in from the client,
 * using inheritance.
 * 
 * @author Terry 12/16/2008
 *
 */
public class ServerState implements serverIface, clientIface {

	//private boolean jobFinished;	/* A job returned from the client node */
	//private boolean newJob;			/* A new job was added by the GUI. */
	private int jobId;				/* Unique identifier for submitted jobs */
	private int completedJobs;		/* Count of completed jobs in the queue */

	private List<JobState> jobStateList;		/* Storage list for states */
	private List<JobData> jobDataList;			/* Storage list for data */


	/**
	 * Default constructor.  Create the lists and initialize server state parameters.
	 */
	public ServerState(){
		// Server status flags and job counter.
		//jobFinished = false;
		//newJob = false;
		jobId = 0;
		completedJobs = 0; // Counts finished jobs.

		// Initialize the job data structures.
		jobStateList = new ArrayList<JobState>();
		jobDataList = new ArrayList<JobData>();
		
		// Construct dispatcher thread.
		new Thread(new JobDispatcher(this)).start();
		
		// Construct listener thread.
		new Thread(new jobListener(this)).start();
	}

	
	/**
	 * Add a new job to the job lists
	 * Part of GUI's interface.
	 */
	public synchronized void addJob(JobData jobIn){
		// Add the job to the end of the list.  Type checking?
		jobDataList.add(jobIn);		

		// Create a new job state object and increment the job counter.
		JobState stateTemp = new JobState(jobId);
		jobId++;

		// Add the job to the queue.
		jobStateList.add(stateTemp);
	}

	/**
	 * Method to return completed jobs to GUI.
	 * Part of GUI's interface.
	 * @return
	 */
	public synchronized JobData[] reportJobs(){

		// If no jobs are complete, return null.
		if(completedJobs == 0){
			return null;
		}

		// Pick off the completed jobs.
		JobData[] DataTemp = new JobData[completedJobs];

		JobState jobStateTemp;
		int j; // List index variable.

		//Iterate over the list as many times as there are completed jobs.
		for(int i = 0; i < completedJobs; i++){

			// Iterate until the next job in the list is found.
			j = 0;
			jobStateTemp = jobStateList.get(j);
			while(jobStateTemp.getState() != 3 &&
					jobStateTemp.getState() != 4){
				j++;
				jobStateTemp = jobStateList.get(j);
			}

			// Pick off the data item.
			DataTemp[i] = jobDataList.get(j);

			// Remove this data item from the server list, it's going to the GUI.
			jobDataList.remove(j);
			jobStateList.remove(j);
		}

		// Reset completed job counter.
		completedJobs = 0;
		//jobFinished = false;
		
		// Return pointer to completed data objects.
		return DataTemp;
	}

	/**
	 * Pull out the next pending job.  For now, this method simply iterates over the
	 * whole job list every time it is invoked.  This is inefficient and should be changed
	 * eventually, such as by maintaining a state variable which tracks whether pending jobs exist.
	 * 
	 * @return
	 */
	public synchronized JobState getNextJobState(){

		// No jobs in the list.  Just return a null pointer.
		if(jobStateList.size() == 0)
			return null;


		JobState jobStateTemp;  // Temporary variable for job state.

		// Loop over the list and check for a pending job.
		for(int i = 0; i < jobStateList.size(); i++){
			jobStateTemp = jobStateList.get(i);

			// Pull out the first pending job.
			if(jobStateTemp.getState() == 1){
				return jobStateTemp;
			}
		}

		// No pending jobs found. Return null.
		return null;
	}


	/**
	 * Pull out the data corresponding to the pending job.  This call always
	 * comes after a call to getNextJobState.  Probably a better way to implement
	 * this.
	 * 
	 * @param jobId job ID number.
	 * @return job data.
	 */
	public synchronized JobData getNextJobData(int jobId){
		JobState jobStateTemp;  // Temporary variable for job state.

		// Loop over the list and check for a pending job.
		for(int i = 0; i < jobStateList.size(); i++){
			jobStateTemp = jobStateList.get(i);

			// Pull out the first pending job.
			if(jobStateTemp.getJobId() == jobId){
				return jobDataList.get(i);
			}
		}
		
		// This just keeps the compiler happy for now, it should never be reached.
		return null;
	}
	
	
	/**
	 * Method to update job states from the server.  The server must set all
	 * this info before it returns it.
	 */
	public synchronized void updateJobState(JobData dataIn, JobState stateIn){
		
		// Match the job ID to a job in the queue, and update the info.
		int j = 0;
		JobState jobStateTemp = jobStateList.get(j);
		while(jobStateTemp.getJobId() != stateIn.getJobId()){
			j++;
			jobStateTemp = jobStateList.get(j);
		}		
		
		// We've picked off the matching job. Update its state.
		jobStateList.set(j, stateIn);
		jobDataList.set(j, dataIn);

		
		completedJobs++;
		//jobFinished = true;
	}
}
