package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.SQLException;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.admin.accountService.GetUserStatusService;

public class GetUserStatusImpl extends RemoteServiceServlet implements GetUserStatusService {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
			
	public int getUserStatus(int userId) 
	{
		DBConnection connection = new DBConnection();	
		int status = 0;
		try
		{
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call GETUSERSTATUS(?, ?) }");
		    cs.setInt(1, userId);
		    cs.registerOutParameter(2, java.sql.Types.INTEGER);
		    cs.execute();
		    status = cs.getInt(2);
		    cs.close();
		}
		catch(SQLException e)
		{
			e.printStackTrace();    				
		}	
		return status;		
	}
}