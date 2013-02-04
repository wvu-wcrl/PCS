package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.SQLException;

public class UserProcessDurationUsage 
{
	public double getUserUsage(int userId) 
	{
    	double usedUnits = 0;
		try 
    	{    
			DBConnection connection = new DBConnection();	
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call USERUSAGE(?, ?) }");
			cs.setInt(1, userId);
			cs.registerOutParameter(2, java.sql.Types.DOUBLE);			
			cs.execute();	
			
			usedUnits = cs.getDouble(2);
			usedUnits = usedUnits/60;
			cs.close();	
			connection.closeConnection();
		}
    	catch (SQLException e) 
        {
        	e.printStackTrace();
        }
		return usedUnits;
	}
}
