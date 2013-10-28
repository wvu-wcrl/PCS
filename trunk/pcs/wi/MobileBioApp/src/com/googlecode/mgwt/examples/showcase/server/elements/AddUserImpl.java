package com.googlecode.mgwt.examples.showcase.server.elements;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.googlecode.mgwt.examples.showcase.server.db.BCrypt;
import com.googlecode.mgwt.examples.showcase.server.db.DBConnection;
import com.googlecode.mgwt.examples.showcase.server.enroll.ResetPassword;

public class AddUserImpl {
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
	
	public String addUser(String username, String email, String usertype) {
		DBConnection connection = new DBConnection();
	  	CallableStatement cs = null;    	 
	  	int flag = -5;
	  	connection.openConnection();
	  	ResetPassword resetPassword = new ResetPassword();
	  	
	  	String password = resetPassword.generateRandomPassword();
  		String hash = BCrypt.hashpw(password, BCrypt.gensalt(12));
  		try 
  		{
  			cs = connection.getConnection().prepareCall("{ call ADDUSER(?, ?, ?, ?, ?) }");
  			cs.setString(1, username);
  			cs.setString(2, hash);
  			cs.setString(3, email);
  			cs.setString(4, usertype);
  			cs.registerOutParameter(5, java.sql.Types.INTEGER);
  			cs.execute();
  			flag = cs.getInt(5);			
  			cs.execute();
  			cs.close();
  			connection.closeConnection();
  		} 
  		catch (SQLException e) 
  		{
  			e.printStackTrace();
  		} 			
  		if(flag > 0)
  			return hash;
  		else
  			return "";
	}
}