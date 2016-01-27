package com.wcrl.web.cml.server;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.ResourceBundle;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.admin.accountService.ClusterStatusService;

public class ClusterStatusImpl extends RemoteServiceServlet implements ClusterStatusService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
		
	public String getClusterStatus(String queue)
	{
		String scriptOutput = "";
		 ResourceBundle scriptsPathConstants = ResourceBundle.getBundle("Scripts");
		 String path = scriptsPathConstants.getString("cluster_status_path").trim() + File.separator + scriptsPathConstants.getString("cluster_status").trim();
		 Log.info("Cluster status path: " + path);	   
		 int exitValue = -1;
	     try 
	     {
	    	 ProcessBuilder processBuilder = new ProcessBuilder();
	    	 processBuilder.command(path, queue);
	    	 Process proc = processBuilder.start();	  
	    	 BufferedReader input = new BufferedReader(new InputStreamReader(proc.getInputStream()));
	    	 String line = null;
	    	 //StringBuffer s = new StringBuffer();
	    	 while((line = input.readLine()) != null)
	    	 {
	    		 scriptOutput = scriptOutput + line + "\n";
	    		 //s.append(line + "\n");
	    	 }
	    	 
	    	 exitValue = proc.waitFor();    
	    	 Log.info("Cluster status after executing script: " + path + " exitValue: " + exitValue);
	    	 /*Log.info("Cluster status after executing script parameters: " + queue);
	    	 Log.info("Cluster status after executing script output buffer: " + s);*/
	    	 Log.info("Cluster status after executing script output: " + scriptOutput);
	     }	    
		 catch (Exception e)
		 {
			 System.out.println(e.getClass().getName() + ": " + e.getMessage());
			 Log.info(e.getClass().getName() + ": " + e.getMessage());
			 StackTraceElement[] trace = e.getStackTrace();			
			 for(int i = 0; i < trace.length; i++)
			 {
				 System.out.println("\t" + trace[i].toString());
				 Log.info("\n\t" + trace[i].toString());
			 }
			 e.printStackTrace();
		 }
		return scriptOutput;		
	}    	    
}