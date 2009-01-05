/**
 * 
 */
package com.iterativesolutions.cml.jobServer;

import java.net.*;
import java.io.*;

/**
 * This is the thread class spawned by the listener on incoming connections.
 * 
 * It takes the following actions:
 * 
 * 1. Receive processed job data from the grid node.
 * 2. Update the job state and status in ServerState, the shared memory object.
 * 
 * 
 * 
 * MAY HAVE TO COME BACK AND TEST THIS SEPARATELY
 * 
 * @author Terry 12/18/2008
 *
 */
public class ListenerAcceptThread implements Runnable{

	private Socket socketIn;			/* Incoming socket connection */
	private ServerState serverStateIn;	/* Server data and job state. */
	
	/**
	 * Constructor.  Accepts the incoming socket and server state.
	 * 
	 * @param socketIn
	 * @param stateIn
	 */
	public ListenerAcceptThread(Socket socketIn, ServerState stateIn){
		this.socketIn = socketIn;
		this.serverStateIn = stateIn;
	}
	
	/**
	 * Run method for this thread.
	 * 
	 */
	public void run(){
		try {
			// Read object using ObjectInputStream
		    ObjectInputStream objIn = 
		    	new ObjectInputStream (socketIn.getInputStream());
		    
		    // Read the data object, then the state object.
		    JobData dataIn;
		    JobState stateIn;
			
		    // Interface to the server state using the serverIface interface.
		    serverIface serverPlug = serverStateIn;
		
		    	// Read the data from the TCP socket.
		      	stateIn = (JobState)objIn.readObject();
		      	dataIn = (JobData)objIn.readObject();
		    	
		    	// Close the streams.
		    	objIn.close();
				socketIn.close();
		    	
				// Set the job state to completed.
		    	stateIn.setState((byte)3);
		    	// Update the data and job state in the server.
		    	serverPlug.updateJobState(dataIn, stateIn);
		    	
		} catch (IOException e) {
			System.out.println("The connection handler failed.");
		    e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}	
}
