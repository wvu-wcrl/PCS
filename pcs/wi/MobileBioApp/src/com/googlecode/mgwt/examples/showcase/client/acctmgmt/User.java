/*
 * File: UserDto.java

Purpose: Java Bean class to store the attributes of an user.
**********************************************************/
package com.googlecode.mgwt.examples.showcase.client.acctmgmt;

import com.google.gwt.user.client.rpc.IsSerializable;

public class User implements IsSerializable 
{
    
	private int userId;
    private String username;
    private String password; 
    private String usertype;
    private String email;  
    private String sessionID;
        
	public User()
    {
    	
    }
	
	public int getUserId() 
	{
		return userId;
	}

	public void setUserId(int userId) 
	{
		this.userId = userId;
	}

	public String getUsername() 
	{
		return username;
	}

	public void setUsername(String username) 
	{
		this.username = username;
	}

	public String getPassword() 
	{
		return password;
	}

	public void setPassword(String password) 
	{
		this.password = password;
	}

	public String getEmail() 
	{
		return email;
	}

	public void setEmail(String email) 
	{
		this.email = email;
	}
	
	public String getUsertype() 
	{
		return usertype;
	}

	public void setUsertype(String usertype) 
	{
		this.usertype = usertype;
	}	
		
	public String getSessionID() {
		return sessionID;
	}

	public void setSessionID(String sessionID) {
		this.sessionID = sessionID;
	}
}
