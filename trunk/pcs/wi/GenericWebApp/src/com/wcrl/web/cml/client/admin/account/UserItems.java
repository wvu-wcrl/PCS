/*
 * File: UserItems.java

Purpose: Container class to store a collection of UserDto objects.
**********************************************************/

package com.wcrl.web.cml.client.admin.account;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.IsSerializable;
import com.wcrl.web.cml.client.account.User;

public class UserItems implements IsSerializable
{
	private ArrayList<User> userItems = new ArrayList<User>();
	
	public UserItems()
	{
		
	}	
		
	public ArrayList<User> getUserItems() 
	{
		return userItems;
	}

	public void setUserItems(ArrayList<User> userItems) 
	{
		this.userItems = userItems;
	}

	public User getUser(int userId)
	{
		User returnUser = null;
		for(int i = 0; i < userItems.size(); i++)
		{
			User user = userItems.get(i);
			if(user.getUserId() == userId)
			{
				returnUser = user;
			}
		}
		return returnUser;
	}
	
	//Set the user in the list - Used when a user is updated
	public void setUser(User user)
	{		
		for(int i = 0; i < userItems.size(); i++)
		{
			User currUser = userItems.get(i);
			if(currUser.getUserId() == user.getUserId())
			{
				currUser = user;
			}
		}		
	}
	
	public int getUserCount()
	{
		return userItems.size();
	}
	
	//Delete a user with a specific userId from the list of users
	public void deleteUser(int userId)
	{
		for(int i = 0; i < userItems.size(); i++)
		{
			User user = userItems.get(i);
			if(user.getUserId() == userId)
			{
				userItems.remove(user);
				break;
			}
		}				
	}
}