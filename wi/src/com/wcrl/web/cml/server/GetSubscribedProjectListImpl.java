/*
 * File: ProjectListServiceImpl.java

Purpose: Java handler class to get a list of projects.
**********************************************************/
package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import javax.servlet.http.HttpSession;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.jobService.GetSubscribedProjectListService;
import com.wcrl.web.cml.client.projects.ProjectItem;
import com.wcrl.web.cml.client.projects.ProjectItems;

public class GetSubscribedProjectListImpl extends RemoteServiceServlet implements GetSubscribedProjectListService {
	
	private static final long serialVersionUID = 1L;	
			
	public ArrayList<ProjectItem> getSubscribedProjectList(int userId)
	{	
		ProjectItems projectItems = new ProjectItems();
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
			projectItems = getProjects(userId);
		}			
		return projectItems.getItems();		
	}	
	
	public ProjectItems getProjects(int userId)
	{
		CallableStatement cs;
		boolean hasResults;
		ResultSet rs;
		ProjectItems projectItems = new ProjectItems();
		DBConnection connection = new DBConnection();		
		try
		{
			connection.openConnection();
			cs = connection.getConnection().prepareCall("{ call GetUserProjects(?) }");
			cs.setInt(1, userId);
			hasResults = cs.execute();
			System.out.println("Getting projectlist: " + hasResults);			
			if(hasResults)
			{
				rs = cs.getResultSet();				
				while(rs.next())
				{
					ProjectItem projectItem = new ProjectItem();
					int projectId = rs.getInt("projectId");
					String projectName = rs.getString("projectname");
					System.out.println("Getting projectlist: " + projectId + " Name: " +  projectName);
					Log.info("Getting projectlist: " + projectId + " Name: " +  projectName);
					projectItem.setProjectId(projectId);
					projectItem.setProjectName(projectName);
					projectItem.setDescription(rs.getString("description"));
					projectItems.addProjectItem(projectItem);
				}									
				rs.close();
				connection.closeConnection();				
			}	
			else
			{
				Log.info("Projects file - No projects");			
			}						
		}
		catch(SQLException e)
		{
			e.printStackTrace();
		}		
		return projectItems;
	}
}