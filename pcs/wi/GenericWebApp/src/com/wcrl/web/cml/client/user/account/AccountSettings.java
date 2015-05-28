/*
 * File: AccountSettings.java

Purpose: Java class to handle user's Personal settings
**********************************************************/

package com.wcrl.web.cml.client.user.account;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.SelectionEvent;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.ui.*;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.login.Login;

public class AccountSettings extends Composite
{		
	private ClientContext ctx;
	private User currentUser;	
	private VerticalPanel panel;
	private DecoratedTabPanel tPanel;
	private PersonalSettings personalSettings;
	private ProjectSettings projectSettings;
	private Anchor hlHome;
	private boolean bool;
	private int idx = -1;

	public AccountSettings(int selectedIndex)
	{	 
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{
			ctx = (ClientContext) RPCClientContext.get();			
		    if(ctx != null)
		    {
		       	currentUser = ctx.getCurrentUser();
		       	if(currentUser != null)
		       	{
		       		Log.info("In AccountSettings username: " + currentUser.getUsername());
		       		System.out.println("In AccountSettings username: " + currentUser.getUsername());
		       		Log.info("Username : " + currentUser.getFirstName() + " " + currentUser.getLastName());
					panel = new VerticalPanel();
					hlHome = new Anchor("<<Home");
				    initWidget(panel);
		       			       			       		
		       		panel.setSize("1000px", "500px");
		       		
		       		tPanel = new DecoratedTabPanel();
		       		tPanel.setSize("1000px", "500px");
		       		tPanel.setAnimationEnabled(true);
		       			       		
		       		panel.add(hlHome);
		       		panel.add(new HTML("<br>"));
				    panel.add(tPanel);
				    
				    hlHome.addClickHandler(new ClickHandler()
				    {
						public void onClick(ClickEvent event) 
						{
							if(currentUser.getUsertype().equalsIgnoreCase("user"))
							{
								/*UserPage userPage = new UserPage(0);
								RootPanel.get("content").clear();
								RootPanel.get("content").add(userPage);*/
								History.newItem("userJobList");
							}
							else
							{
								History.newItem("jobList");
								/*AdminPage adminPage = new AdminPage(3);
								RootPanel.get("content").clear();
								RootPanel.get("content").add(adminPage);*/
							}
						}			    	
				    });
				    			
				    personalSettings = new PersonalSettings();
				    projectSettings = new ProjectSettings();
				    if(selectedIndex == 0)
			   		{
				    	//System.out.println("Before@@@");
				    	//personalSettings = new PersonalSettings();
				    	//System.out.println("After@@@");
			   			History.newItem("settings");		   			
			   		}
			   		else if(selectedIndex == 1)
			   		{
			   			//projectSettings = new ProjectSettings();
			   			History.newItem("projectSettings");		   			
			   		}
				    
				    tPanel.add(personalSettings.getPersonalSettingsPanel(),"General");
				    tPanel.add(projectSettings,"Project");

				    idx = selectedIndex;
				    tPanel.selectTab(selectedIndex);
		       	}
		    }
		}
		else
		{
			Login login = new Login();
			login.displayLoginBox();
		}			    
	}	
	
	public void onSelection(SelectionEvent<Integer> event)
	{
		int index = event.getSelectedItem();
		
		Log.info("Tab selected: " + index + " " + bool);
		
		if(index == 0)
		{			
			if(!(idx == index))
			{
				//StaticClass.stopJobListTimers();
				Log.info("Calling personalSettings");
				History.newItem("settings");	
				personalSettings = new PersonalSettings();				
				bool = true;
				tPanel.remove(index);
				tPanel.insert(personalSettings.getPersonalSettingsPanel(),"General", index);
				tPanel.selectTab(index);				
			}			
		}
		if(index == 1)
		{	
			if(!(idx == index))
			{
				//StaticClass.stopJobListTimers();
				Log.info("Calling projectSettings");
				History.newItem("projectSettings");
				projectSettings = new ProjectSettings();
				bool = false;
				tPanel.remove(index);
				tPanel.insert(projectSettings, "Project", index);
				tPanel.selectTab(index);				
			}			
		}		
	}
}