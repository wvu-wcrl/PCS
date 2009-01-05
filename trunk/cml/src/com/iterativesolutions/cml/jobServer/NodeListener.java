/**
 * 
 */
package com.iterativesolutions.cml.jobServer;
import java.net.*;
import java.io.*;


/**
 * This class is executed on the client and listens for jobs from the server.
 * In the initial implementation, only one thread of execution is used.  Spawning
 * multiple threads is a straightforward extension.
 * 
 * 1. Wait for connection from server.
 * 2. Get simulation parameters.
 * 3. Execute simulation
 * 4. Return results.
 * 
 * @author Terry 12/19/2008
 *
 */
public class NodeListener {


	public static void main(String[] args){
		// Start lisening.

		ServerSocket serverSocket = null;
		boolean listening = true;

		try {
			// Hard-coded server port.
			serverSocket = new ServerSocket(4445);
		} catch (IOException e) {
			System.err.println("Could not listen on port: 4444.");
			System.exit(-1);
		}

		// Listen for connection.
		Socket clientSocket = null;
		Socket sockOut = null;
		JobData dataIn = null;
		JobState stateIn = null;
		qpskAWGN sim = new qpskAWGN();
		ObjectOutputStream objOut;	/* Output stream for the serialized objects. */
		ObjectInputStream objIn;

		while (listening){
			try {
				System.out.println();
				System.out.println("Listening for new connection...");
				clientSocket = serverSocket.accept();
				System.out.println("New connection accepted.");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			// Read the simulation parameters.
			try {
				objIn = new ObjectInputStream(clientSocket.getInputStream());

				stateIn = (JobState)objIn.readObject();
				dataIn = (JobData)objIn.readObject();
				objIn.close();
				clientSocket.close();

				// Run the simulation.
				System.out.println("Running new simulation with job ID: " + stateIn.getJobId());
				sim.setJob(dataIn);  // Set up the parameters.
				dataIn = sim.runSim();
				System.out.println("Simulation complete.");
				
				// Simulation done.  Send everything back.
				sockOut = new Socket("127.0.0.1", 4444);
				// Get the output socket and cast it to an object stream.
				objOut = new ObjectOutputStream(sockOut.getOutputStream());
				// Send the job state first, then the data.
				objOut.writeObject(stateIn);
				objOut.writeObject(dataIn);
			

				objOut.close();
				sockOut.close();				
				System.out.println("Simulation results sent back to server.");
				

			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			} catch (ClassNotFoundException e){
				e.printStackTrace();
			}
		}
		// Close the connection to the server.
		try {
			clientSocket.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}




	}

}
