package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.SQLException;

import javax.servlet.http.HttpSession;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.admin.projectService.UpdateProjectService;

public class UpdateProjectImpl extends RemoteServiceServlet implements UpdateProjectService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private DBConnection connection = new DBConnection();
		
	public int[] updateProjectName(int projectId, String newProjectName) 
	{
		int[] flag = new int[2];
		flag[0] = -1;
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
			try 
	    	{    		
				connection.openConnection();
				CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATEPROJECTNAME(?, ?, ?) }");
				cs.setInt(1, projectId);
				cs.setString(2, newProjectName);
				cs.registerOutParameter(3, java.sql.Types.INTEGER);
				cs.execute();			
				flag[0] = cs.getInt(3);
				flag[1] = projectId;
				cs.close();
				System.out.println("Password Flag:" + flag);
				Log.info("Password Flag:" + flag);
				
				connection.closeConnection();
			}
	    	catch (SQLException e) 
	        {
	        	e.printStackTrace();
	        }
		}  
		return flag;	
	}

	public int[] updateProjectDescription(int projectId, String description) 
	{
		int[] flag = new int[2];
		flag[0] = -1;
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
			try 
	    	{    		
				//System.out.println("Username server side:" + newUsername + " UserId: " + userId);
				connection.openConnection();
				CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATEPROJECTDESCRIPTION(?, ?) }");
				cs.setInt(1, projectId);
				cs.setString(2, description);
				
				cs.execute();
				flag[0] = 0;
				flag[1] = projectId;
				cs.close();			
				//System.out.println("Username Flag:" + flag[0]);
				Log.info("Username Flag:" + flag[0]);
				
				connection.closeConnection();
			}
	    	catch (SQLException e) 
	        {
	        	e.printStackTrace();
	        }
		}		  
		return flag;
	}
	
	public int[] updateProjectPath(int projectId, String path) 
	{
		int[] flag = new int[2];
		flag[0] = -1;
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
			try 
	    	{    		
				//System.out.println("Username server side:" + newUsername + " UserId: " + userId);
				connection.openConnection();
				CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATEPROJECTPATH(?, ?) }");
				cs.setInt(1, projectId);
				cs.setString(2, path);
				
				cs.execute();
				flag[0] = 0;
				flag[1] = projectId;
				cs.close();			
				//System.out.println("Username Flag:" + flag[0]);
				Log.info("Username Flag:" + flag[0]);
				
				connection.closeConnection();
			}
	    	catch (SQLException e) 
	        {
	        	e.printStackTrace();
	        }
		}  
		return flag;
	}

	public int[] updateDataFile(int projectId, int required) 
	{
		int[] flag = new int[2];
		flag[0] = -1;
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
			try 
	    	{    		
				connection.openConnection();
				CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATEPROJECTDATAFILE(?, ?) }");
				cs.setInt(1, projectId);
				cs.setInt(2, required);
				
				cs.execute();
				flag[0] = required;
				flag[1] = projectId;
				cs.close();
				Log.info("Username Flag:" + flag[0]);
				
				connection.closeConnection();
			}
	    	catch (SQLException e) 
	        {
	        	e.printStackTrace();
	        }
		}		  
		return flag;
	}
}