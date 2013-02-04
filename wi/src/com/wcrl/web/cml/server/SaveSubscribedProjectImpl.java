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
	
	public int saveProject(int projectId, int userId, int preferredProject, String login, String projectName)
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
			if(preferredProject == 0)
			{
				/*ProjectDirectories projectDirectories = new ProjectDirectories();
				projectDirectories.createUserProjectDirectories(login, projectName);
				projectDirectories.copyProjectConfigFile(projectName, login);*/
				if(File.separator.equals("/"))
				{
					createProjectDirectories(projectName, login);
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
		 File wd = new File(scriptsPathConstants.getString("project"));
		 String path = wd + File.separator;
		 System.out.println("Working Directory of project script: " + path);
		 Log.info("Working Directory of project script: " + path);	     
	     @SuppressWarnings("unused")
	     Process proc = null;
	     try 
	     {
	    	 proc = Runtime.getRuntime().exec(path + scriptsPathConstants.getString("create_proj") + " " + project + " " + username, null);
	    	 Log.info("After executing project script." + path);
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