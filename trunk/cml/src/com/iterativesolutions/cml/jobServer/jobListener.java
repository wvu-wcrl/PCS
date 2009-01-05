/**
 * 
 */
package com.iterativesolutions.cml.jobServer;

import java.net.*;
import java.io.*;
/**
 * This class listens for incoming connections for the grid nodes and updates server state
 * accordingly.
 * 
 * Example:
 * 1. Node returns job state with completed status
 * 2. jobListener updates shared server state in ServerState class.
 * 
 * For now, this class handles all state updates from the network itself.  The class
 * might eventually have to spawn subthreads to handle multiple simultaneous connections,
 * but this is probably not necessary unless a large number of grid nodes are in use.
 * 
 * Funkiness with try/catch blocks in here.
 * 
 * Server port is hard-coded to 4444.  Make this configurable.
 * @author Terry 12/18/2008
 *
 */
public class jobListener implements Runnable{
	private ServerState runningState;
	
	public jobListener(ServerState runningState){
		this.runningState = runningState;
	}
	
	public void run(){
		
		
		ServerSocket serverSocket = null;
		boolean listening = true;

		try {
			// Hard-coded server port.
			serverSocket = new ServerSocket(4444);
		} catch (IOException e) {
			System.err.println("Could not listen on port: 4444.");
			System.exit(-1);
		}

		// Listen for connections.
		while (listening)
			try {
				new Thread(new ListenerAcceptThread(serverSocket.accept(), runningState)).start();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		try {
			serverSocket.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}


// Accept call

// Update server state


