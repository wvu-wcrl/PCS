/*
 * File: DeleteUsersImpl.java

Purpose: Java class to Delete users from Database.
**********************************************************/
package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.ArrayList;

import javax.servlet.http.HttpSession;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.admin.accountService.DeleteUsersService;

public class DeleteUsersImpl extends RemoteServiceServlet implements DeleteUsersService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
			
	public ArrayList<Integer> deleteUsers(ArrayList<Integer> userIds) 
	{
		ArrayList<Integer> deletedUsersList = new ArrayList<Integer>();
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
	    	DBConnection connection = new DBConnection();
	    	CallableStatement cs = null;
	    	try 
	    	{    		
				connection.openConnection();			
				for(int i = 0; i < userIds.size(); i++)
				{					
					cs = connection.getConnection().prepareCall("{ call DELETEUSER(?, ?) }");
					int userId = userIds.get(i);
					Log.info("DeleteUsersImpl: Deleting user: " + userId);
					cs.setInt(1, userId);
					cs.registerOutParameter(2, java.sql.Types.INTEGER);				
					cs.execute();
					int flag = cs.getInt(2);
					cs.close();
					if(flag == 0)
					{
						deletedUsersList.add(userId);
					}											
				}					
				connection.closeConnection();
			}
	    	catch (SQLException e) 
	        {
	        	e.printStackTrace();
	        }
		}        
    	return deletedUsersList;
    }     	    
}
