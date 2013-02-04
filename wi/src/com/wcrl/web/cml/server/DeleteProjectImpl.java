/*
 * File: DeleteProjectItemServiceImpl.java

Purpose: Java class to Delete a Job of an user from Database.
**********************************************************/
package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.SQLException;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.admin.projectService.DeleteProjectService;

public class DeleteProjectImpl extends RemoteServiceServlet implements DeleteProjectService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private DBConnection connection = new DBConnection();
	private CallableStatement cs = null;
		
	public int deleteProject(int projectId) 
	{
		int flag = -1;		
		connection.openConnection();
		try 
		{
			cs = connection.getConnection().prepareCall("{ call DELETEPROJECT(?, ?) }");
			Log.info("DeleteProjectsImpl: Deleting project: " + projectId);
			cs.setInt(1, projectId);
			cs.registerOutParameter(2, java.sql.Types.INTEGER);				
			cs.execute();
			flag = cs.getInt(2);
			cs.close();
		} 
		catch (SQLException e) 
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	
		return flag;
	}
}
