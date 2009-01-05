/**
 * 
 */
package com.iterativesolutions.cml.jobServer;
import java.net.*;
import java.io.*;

/**
 * The JobDispatcher class periodically polls the server state and launches
 * jobs on the grid.
 * 
 * 1. Sleep for x seconds.
 * 2. Wake up and poll the server state.
 * 3. If a job is found in the 'pending' state, attempt to launch it on the next
 * 		available grid node.
 * 4.  Update job state to 'running' on successful launch.
 * 
 * @author Terry 12/19/2008
 *
 */
public class JobDispatcher implements Runnable{

	private ServerState stateIn;			/* Shared server state variable */
	private serverIface serverPlug;			/* Interface into the server state */

	private JobData jobDataTemp;			/* Temporary pointers for job state and data objects */
	private JobState jobStateTemp;

	private Socket sockOut;					/* Outgoing socket for node communication */
	private ObjectOutputStream objOut;		/* Output stream for the serialized objects. */

	/**
	 * Constructor which takes the server state as its input.
	 * @param stateIn
	 */
	public JobDispatcher(ServerState stateIn){
		this.stateIn = stateIn;
		serverPlug = this.stateIn;
		jobDataTemp = null;
		jobStateTemp = null;
		sockOut = null;
		objOut = null;
	}

	/**
	 * Thread implementation.  Periodically checks for jobs and dispatches them.
	 */
	public void run(){

		// Main execution loop.
		while(true){
			// Go to sleep for five seconds.  Make this parameter tweakable later.
			try{
				Thread.sleep(5000);
				System.out.println("Looking for a job to dispatch...");
			}
			catch(InterruptedException e){
				e.printStackTrace();
			}

			// Wake up and check for a pending job.  The current implementation of this
			//  is kludgey as hell.  Make this more efficient.
			jobStateTemp = serverPlug.getNextJobState();

			if(jobStateTemp != null)
				jobDataTemp = serverPlug.getNextJobData(jobStateTemp.getJobId());
			else
				jobDataTemp = null;

			// If a job was found, launch it, otherwise go back to sleep.
			if(jobDataTemp != null){
				// Open a socket to the next available node.
				try{
					sockOut = new Socket("127.0.0.1", 4445);

					// Get the output socket and cast it to an object stream.
					objOut = new ObjectOutputStream(sockOut.getOutputStream());
					// Send the job state first, then the data.
					objOut.writeObject(jobStateTemp);
					objOut.writeObject(jobDataTemp);

					// Assuming no error occurred, change state to "running".
					jobStateTemp.setState((byte)2);

					// Write the state back to the server.  Inefficient, data doesn't
					//  need to go.  THIS STEP MAY NOT EVEN BE NECESSARY.
					//  This caused problems in the current implementation.  Need
					//  a different interface for dispatcher and listener.
					//serverPlug.updateJobState(jobDataTemp, jobStateTemp);

				}catch(UnknownHostException U){
					U.printStackTrace();
				}catch(IOException e){
					e.printStackTrace();
				}

			} 
		}

	}

}
