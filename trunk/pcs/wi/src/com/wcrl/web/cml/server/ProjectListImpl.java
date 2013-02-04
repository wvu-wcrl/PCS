/*
 * File: ProjectListServiceImpl.java

Purpose: Java handler class to get a list of projects.
**********************************************************/
package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;

import org.apache.log4j.Logger;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.projectService.ProjectListService;
import com.wcrl.web.cml.client.projects.ProjectItem;
import com.wcrl.web.cml.client.projects.ProjectItems;

public class ProjectListImpl extends RemoteServiceServlet implements ProjectListService {
	
	private static final long serialVersionUID = 1L;	
	private static Logger logger = Logger.getLogger(ProjectListImpl.class);
			
	public ArrayList<ProjectItem> getProjectList()
	{	
		ProjectItems projectItems = getProjects();			
		return projectItems.getItems();		
	}	
	
	public ProjectItems getProjects()
	{
		CallableStatement cs;
		boolean hasResults;
		ResultSet rs;
		ProjectItems projectItems = new ProjectItems();
		DBConnection connection = new DBConnection();		
		try
		{
			connection.openConnection();
			cs = connection.getConnection().prepareCall("{ call GetProjects() }");
			hasResults = cs.execute();
			System.out.println("Getting projectlist: " + hasResults);
			logger.info("Getting projectlist: " + hasResults);
			if(hasResults)
			{
				rs = cs.getResultSet();
				
				while(rs.next())
				{
					ProjectItem projectItem = new ProjectItem();
					int projectId = rs.getInt("projectId");
					String projectName = rs.getString("projectname");
					Date lastUpdate = rs.getDate("UpdatedAt");
					long timeElapsed = lastUpdate.getTime();
					System.out.println("Getting projectlist: " + projectId + " Name: " +  projectName);
					logger.info("Getting projectlist: " + projectId + " Name: " +  projectName);
					projectItem.setProjectId(projectId);
					projectItem.setProjectName(projectName);
					projectItem.setLastUpdate(timeElapsed);
					projectItem.setDescription(rs.getString("description"));
					int dataFileRequired = rs.getInt("datafile");
					if(dataFileRequired == 0)
					{
						projectItem.setDataFile("Not Required");
					}
					else if(dataFileRequired == 1)
					{
						projectItem.setDataFile("Required");
					}
					else
					{
						projectItem.setDataFile("Possibly Required");
					}
					
					projectItem.setPath(rs.getString("path"));
					projectItems.addProjectItem(projectItem);
				}									
				rs.close();
				connection.closeConnection();				
			}	
			else
			{
				logger.info("Projects file - No projects");			
			}						
		}
		catch(SQLException e)
		{
			e.printStackTrace();
		}		
		return projectItems;
	}
}