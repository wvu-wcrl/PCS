/*
 * File: DBConnection.java

Purpose: Java class to open and close Database connection
**********************************************************/
package com.wcrl.web.cml.server;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import java.util.ResourceBundle;


public class DBConnection
{	
	private ResourceBundle constants = ResourceBundle.getBundle("DBConnectionConstants"); 
	private Connection connection;

	public DBConnection()
	{
		
	}	

	public Connection getConnection() 
	{		
		return connection;
	}
	
	public void openConnection() 
	{
		try 
		{						
			Class.forName(constants.getString("driverclassname")).newInstance();			
			connection = DriverManager.getConnection(getConnectionUrl(), constants.getString("username"), constants.getString("password"));
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}
	}
	
	private String getConnectionUrl()
    {		         
		return constants.getString("url")
        + constants.getString("servername")
        + ":"
        + constants.getString("portnumber")
        + "/"
        + constants.getString("databasename");
    }
	
	public boolean isOpenConnection()
	{
		if(connection != null)
			return true;
		else
			return false;
	}

	public void closeConnection() 
	{
		try 
		{
			if(this.connection != null)
				this.connection.close();
		} 
		catch (SQLException e) 
		{			
			e.printStackTrace();
		}
	}
}
