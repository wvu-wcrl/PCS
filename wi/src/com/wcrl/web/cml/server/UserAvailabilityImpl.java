package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.loginService.UserAvailabilityService;

public class UserAvailabilityImpl extends RemoteServiceServlet implements UserAvailabilityService {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
			
	public int checkUserAvailability(String username) 
	{
		DBConnection connection = new DBConnection();	
		ResultSet rs = null;
		int userId = 0;
		try
		{
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call ValidateUser(?) }");
		    cs.setString(1, username);
		    boolean hasResults = cs.execute();
		    if(hasResults)
			{
		    	rs = cs.getResultSet();
				while(rs.next())
				{
					userId = rs.getInt("userId");
				}
			}
		}
		catch(SQLException e)
		{
			e.printStackTrace();    				
		}	
		return userId;		
	} 
	
	public int checkUserEmail(String email)
	{
		int cnt = -1;
		DBConnection connection = new DBConnection();
    	CallableStatement cs = null;
    	connection.openConnection();
		try 
		{
			cs = connection.getConnection().prepareCall("{ call VALIDATEUSEREMAIL(?, ?) }");
			cs.setString(1, email);
			cs.registerOutParameter(2, java.sql.Types.INTEGER);
			cs.execute();
			cnt = cs.getInt(2);
		} 
		catch (SQLException e) 
		{
			e.printStackTrace();
		}		
		return cnt;		
	}
}