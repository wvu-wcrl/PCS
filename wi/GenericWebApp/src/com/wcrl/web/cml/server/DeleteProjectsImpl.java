/*
 * File: DeleteProjectsImpl.java

Purpose: Java class to Delete projects from Database.
**********************************************************/
package com.wcrl.web.cml.server;

import java.util.ArrayList;

import javax.servlet.http.HttpSession;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.admin.projectService.DeleteProjectsService;

public class DeleteProjectsImpl extends RemoteServiceServlet implements DeleteProjectsService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
			
	public ArrayList<Integer> deleteProjects(ArrayList<Integer> projectIds) 
	{
		ArrayList<Integer> deletedProjectsList = new ArrayList<Integer>();
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
			for(int i = 0; i < projectIds.size(); i++)
			{					
				//cs = connection.getConnection().prepareCall("{ call DELETEPROJECT(?, ?) }");
				int projectId = projectIds.get(i);
				Log.info("DeleteProjectsImpl: Deleting project: " + projectId);
				DeleteProjectImpl delete = new DeleteProjectImpl();
				int flag = delete.deleteProject(projectId);				
				if(flag == 0)
				{
					deletedProjectsList.add(projectId);
				}											
			}
		}     
    	return deletedProjectsList;
    }     	    
}
