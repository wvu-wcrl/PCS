package com.googlecode.mgwt.examples.showcase.server.job;

import java.sql.CallableStatement;
import java.sql.SQLException;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.googlecode.mgwt.examples.showcase.client.custom.service.MasterKeyService;
import com.googlecode.mgwt.examples.showcase.server.db.BCrypt;
import com.googlecode.mgwt.examples.showcase.server.db.DBConnection;

public class MasterKeyImpl extends RemoteServiceServlet implements MasterKeyService{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public String getHashKey()
    {
   	 String hashKey = "";
   	 DBConnection connection = new DBConnection();
   	 try
   	 {
   		 connection.openConnection();
   		 CallableStatement  cs = connection.getConnection().prepareCall("{ call GETMASTERKEY(?) }"); 
   		 cs.registerOutParameter(1, java.sql.Types.VARCHAR);
   		 cs.execute();
   		 hashKey = cs.getString(1);
   	 }
   	 catch(SQLException e)
   	 {
   		 e.printStackTrace();
   	 }
		return hashKey;
    }
	
	 public boolean addHashKeyToDB(String hashKey, String username)
     {
    	 boolean flag = false;
    	 DBConnection connection = new DBConnection();
    	 try
    	 {
    		 connection.openConnection();
    		 CallableStatement  cs = connection.getConnection().prepareCall("{ call ADDMASTERKEY(?, ?) }"); 
    		 cs.setString(1, hashKey);
    		 cs.setString(2, username);
    		 cs.execute();
    	 }
    	 catch(SQLException e)
    	 {
    		 e.printStackTrace();
    	 }
		return flag;
     }
	 
	 public boolean verifyMasterKey(String adminProvidedExistingKey)
	 {
		 boolean match = false;
		 String existingHashMasterKey = getHashKey();
		 match = BCrypt.checkpw(adminProvidedExistingKey, existingHashMasterKey);
		 return match; 
	 }

}
