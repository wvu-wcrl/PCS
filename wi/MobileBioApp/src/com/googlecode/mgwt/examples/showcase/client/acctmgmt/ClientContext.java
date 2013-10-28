/*
 * File: ClientContext.java

Purpose: RPC context object managed by the client.
**********************************************************/

package com.googlecode.mgwt.examples.showcase.client.acctmgmt;

import com.google.gwt.user.client.rpc.IsSerializable;

public class ClientContext implements IsSerializable
{
	private User currentUser;
	
	public User getCurrentUser() 
	{
		return currentUser;
	}

	public void setCurrentUser(User user) 
	{
		this.currentUser = user;
	}
}
