/*
 * File: UpdateOnlyJobStatus.java

Purpose: Java class to update status of a Job.
**********************************************************/
package com.wcrl.web.cml.server;

import java.sql.CallableStatement;

import com.allen_sauer.gwt.log.client.Log;

public class UpdateOnlyJobStatus 
{
	public void updateStatus(int jobId, String status) 
	{		
		DBConnection connection = null;
		CallableStatement cs = null;		
		@SuppressWarnings("unused")
		boolean hasResults = false;		
	
		try 
    	{   
			    connection = new DBConnection();
    			connection.openConnection();
    			cs = connection.getConnection().prepareCall("{ call UpdateOnlyJobStatus(?, ?) }");
    			cs.setString(1, status);    			
    			cs.setInt(2, jobId);
    			hasResults = cs.execute();
    			Log.info("Job status updated. JobId: " + jobId + " Status: "+ status);    		    			
    			connection.closeConnection();
    	}
		catch (Exception e) 
    	{
    		e.printStackTrace();
    	}
		finally
		{			
			if(connection.isOpenConnection())
			{
				connection.closeConnection();
			}			
		}		
	}

}
