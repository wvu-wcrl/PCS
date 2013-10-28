package com.googlecode.mgwt.examples.showcase.server.job;

import java.io.File;
import java.util.ResourceBundle;

import com.allen_sauer.gwt.log.client.Log;

public class RandomProjection {
	
	public boolean getRandomProjection(String tempFilePath, String jobFilePath, String key) {
		 boolean fileGenerated = false;
		 ResourceBundle scriptsPathConstants = ResourceBundle.getBundle("Scripts");
		 
		 String scriptPath = scriptsPathConstants.getString("random_projection_path").trim() + File.separator + scriptsPathConstants.getString("random_projection").trim();
		 String matlabScriptPath = scriptsPathConstants.getString("matlab_script_path").trim();
		 String matlabScript = scriptsPathConstants.getString("matlab_script_rp").trim();
		 System.out.println("Working Directory of project script: " + scriptPath);
		 Log.info("Project creation script: " + scriptPath);
		 System.out.println("Project creation script: " + scriptPath);
		 int exitValue = -2;
	     try 
	     {
	    	 Log.info("getRandomProjection before executing script, parameters: " + tempFilePath + ", " + matlabScriptPath + ", " + matlabScript + ", " + key + ", " + jobFilePath);
	    	 System.out.println("getRandomProjection before executing script, parameters: " + tempFilePath + ", " + matlabScriptPath + ", " + matlabScript + ", " + key + ", " + jobFilePath);
	    	 ProcessBuilder processBuilder = new ProcessBuilder();
	    	 processBuilder.command(scriptPath, tempFilePath, matlabScriptPath, matlabScript, key, jobFilePath);	 
	    	 Process proc = processBuilder.start();
	    	 exitValue = proc.waitFor();    	 
	    	 Log.info("getRandomProjection after executing project creation script: " + scriptPath + " exitValue: " + exitValue);
	    	 System.out.println("getRandomProjection after executing project creation script: " + scriptPath + " exitValue: " + exitValue);
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
	     if(exitValue == 0)
	     {
	    	 fileGenerated = true;
	     }
		return fileGenerated;
	}
	
	public int changeOwnership(String user, String filePath) {
		int exitValue = -2;
	     try 
	     {
	    	 Log.info("In changeOwnership");
	    	 System.out.println("In changeOwnership");
	    	 String command = "sudo chown -R " + user + ":pcs " + filePath;
	    	 ProcessBuilder processBuilder = new ProcessBuilder(command);
	    	 //processBuilder.command(command);	 
	    	 Process proc = processBuilder.start();
	    	 exitValue = proc.waitFor();    	 
	    	 Log.info("changeOwnership after executing script, exitValue: " + exitValue);
	    	 System.out.println("changeOwnership after executing script, exitValue: " + exitValue);
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
		return exitValue;	
	}
}
