/*
 * File: UnSubscribeUserProjectImpl.java

Purpose: Java handler class to get a list of projects.
**********************************************************/
package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.SQLException;

import javax.servlet.http.HttpSession;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.admin.accountService.UnSubscribeUserProjectService;

public class UnSubscribeUserProjectImpl extends RemoteServiceServlet implements UnSubscribeUserProjectService {
	
	private static final long serialVersionUID = 1L;	
	
	public int unSubscribeProject(int userId, int projectId)
	{			
		int project = -1;
		CallableStatement cs;			
		DBConnection connection = new DBConnection();
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
			try
			{
				connection.openConnection();
				cs = connection.getConnection().prepareCall("{ call UNSUBSCRIBEUSERPROJECT(?, ?) }");
				cs.setInt(1, userId);
				cs.setInt(2, projectId);
				cs.execute();
				cs.close();
				project = projectId;
				System.out.println("UNSUBSCRIBEUSERPROJECT: " + userId + " " + projectId  + " project: " + project);
			}
			catch(SQLException e)
			{
				e.printStackTrace();
			}
		}		
		return project;
	}
}