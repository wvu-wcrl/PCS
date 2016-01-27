/*
 * File: Comlnk.java

Purpose: COMLNK - module entry point class
**********************************************************/

package com.wcrl.web.cml.client.login;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.user.client.Command;
import com.google.gwt.user.client.DeferredCommand;

@SuppressWarnings("deprecation")
public class WebCML implements EntryPoint
{	
	public void onModuleLoad() 
	{		
		DeferredCommand.addCommand(new Command()
		{
			public void execute()
			{
				@SuppressWarnings("unused")				
				Login login = new Login();
			}
		});				
	}	
}