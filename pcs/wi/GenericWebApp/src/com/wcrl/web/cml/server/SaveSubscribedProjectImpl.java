/*
 * File: SaveSubscribedProjectImpl.java

Purpose: Java handler class to get a list of projects.
**********************************************************/
package com.wcrl.web.cml.server;

import java.io.File;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.ResourceBundle;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.admin.accountService.SaveSubscribedProjectService;

public class SaveSubscribedProjectImpl extends RemoteServiceServlet implements SaveSubscribedProjectService {
	
	private static final long serialVersionUID = 1L;	
	
	public int saveProject(int projectId, int userId, int addProjectDirectory, String login, String projectName, int preferredProject)
	{			
		int project = -1;
		CallableStatement cs;			
		DBConnection connection = new DBConnection();
		try
		{
			connection.openConnection();
			cs = connection.getConnection().prepareCall("{ call SaveUserProject(?, ?, ?) }");
			cs.setInt(1, userId);
			cs.setInt(2, projectId);
			cs.setInt(3, preferredProject);
			cs.execute();
			cs.close();
			project = projectId;
			System.out.println("Save project: " + userId + " " + projectId + " " + preferredProject + " project: " + project);	
			if(addProjectDirectory == 0)
			{
				if(File.separator.equals("/"))
				{
					createProjectDirectories(login, projectName);
				}
			}
		}
		catch(SQLException e)
		{
			e.printStackTrace();
		}		
		return project;
	}
	
	
	public void createProjectDirectories(String username, String project) 
	{
		 ResourceBundle scriptsPathConstants = ResourceBundle.getBundle("Scripts");
		 ResourceBundle pathConstants = ResourceBundle.getBundle("Paths");
		 String usersRootPath = pathConstants.getString("path");
		 
		 //File wd = new File(scriptsPathConstants.getString("project"));
		 String path = scriptsPathConstants.getString("project").trim() + File.separator + scriptsPathConstants.getString("create_proj").trim();
		 System.out.println("Working Directory of project script: " + path);
		 Log.info("Project creation script: " + path);	     
	   
	     try 
	     {
	    	 String homeDir = usersRootPath + username;
	    	 ProcessBuilder processBuilder = new ProcessBuilder();
	    	 processBuilder.command(path, homeDir, username, project);	 
	    	 Process proc = processBuilder.start();
	    	 int exitValue = proc.waitFor();    	 
	    	 Log.info("CreateProjectDirectories after executing project creation script: " + path + " exitValue: " + exitValue);
	    	 Log.info("CreateProjectDirectories after executing project creation script parameters: " + homeDir + ", " + username + ", " + project);
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
	}	
}