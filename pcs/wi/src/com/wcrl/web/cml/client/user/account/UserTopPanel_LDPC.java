/*
 * File: TopPanel.java

Purpose: Display the 'user name' and the 'sign out' link on the top of the application page.
**********************************************************/

package com.wcrl.web.cml.client.user.account;

import java.util.ArrayList;
import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DockPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Hyperlink;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.PopupPanel;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.account.AdminPage;
import com.wcrl.web.cml.client.admin.account.UserItems;
import com.wcrl.web.cml.client.admin.accountService.GetUsersService;
import com.wcrl.web.cml.client.admin.accountService.GetUsersServiceAsync;
import com.wcrl.web.cml.client.login.Login;

/**
 * The top panel, which contains the username and various links.
 */
@SuppressWarnings("deprecation")
public class UserTopPanel_LDPC extends Composite implements ClickHandler 
{	
	private Hyperlink hlSignout;
	private Hyperlink hlSettings;
	private User currentUser;	
	private ClientContext ctx;
	private HorizontalPanel outer;
	
	public UserTopPanel_LDPC() 
	{
		outer = new HorizontalPanel();
		initWidget(outer);
		ctx = (ClientContext) RPCClientContext.get();
		if(ctx != null)
		{		
			currentUser = ctx.getCurrentUser();
			if(currentUser != null)
			{				
				hlSettings = new Hyperlink("Settings", "settings");
				hlSignout = new Hyperlink("Sign out", "signout");				
				
				final PopupPanel popup = new PopupPanel(true);
				Label lblHelp = new Label("This is a help label.");
				lblHelp.addStyleName("normalText");
				popup.add(lblHelp);
				popup.removeStyleName("gwt-PopupPanel");
				popup.removeStyleName("gwt-PopupPanel .popupContent");
								
			    HorizontalPanel inner = new HorizontalPanel();
			   			    
			    inner.setHorizontalAlignment(HorizontalPanel.ALIGN_RIGHT);
			    inner.setVerticalAlignment(VerticalPanel.ALIGN_MIDDLE);
		    
			    HTML login = new HTML();
			    login.setText(currentUser.getUsername());
			    login.setStyleName("normalTextFont");
			    HorizontalPanel links = new HorizontalPanel();
			    links.setSpacing(4);			        
			    links.add(getSeparator());
			    links.add(hlSettings);
			    links.add(getSeparator());
			    links.add(hlSignout);
			    			    
			    outer.add(inner);
			    inner.add(login);
			    inner.add(links);
			    		    
			    outer.setCellHorizontalAlignment(inner, HorizontalPanel.ALIGN_RIGHT);

			    hlSettings.addClickHandler(this);
			    hlSignout.addClickHandler(this);   
    
			    setStyleName("mail-TopPanel");
			    inner.setStyleName("mail-TopPanelLinks");			    
			}
		}
		else
		{
			Log.info("Ctx null UserTopPanel");
			@SuppressWarnings("unused")
			Login login = new Login();
		}   
  }

  public void onClick(ClickEvent event) 
  {
    Object sender = event.getSource();

    //Stop all the timers, clear the context and show up the login page when a user sign's off
    if(sender == hlSignout)
    {   	
    	if(ctx != null)
    	{
    		User currentUser = ctx.getCurrentUser();
    		if(currentUser != null)
    		{			
    			User adminUser = currentUser.getAdminUser();
    			//If the user assumed the role of a user and is signing off the assumed user, then set the current context to the 'Administrator' user and show the Admin Page
    			if(adminUser != null)
    			{
    				currentUser.setAdminUser(null);
    				RPCClientContext.set(new ClientContext());
    				ctx = (ClientContext)RPCClientContext.get();
    				ctx.setCurrentUser(adminUser);    			
    				RootPanel.get("header").clear();
    				RootPanel.get("leftnav").clear();
    				RootPanel.get("footer").clear();
    				RootPanel.get("content").clear();
    		    	UserTopPanel topPanel = new UserTopPanel();
    				UserBottomPanel bottomPanel = new UserBottomPanel();
    				RootPanel.get("header").add(topPanel);					
    				RootPanel.get("footer").add(bottomPanel);
    				GetUsersServiceAsync service = GetUsersService.Util.getInstance();			
    				service.getUsers(usersCallback);
    			}
    			else
    			{
    				resetContext();
    				@SuppressWarnings("unused")
    		    	Login login = new Login();
    			}
    		}
    	}    	    	
    }
    
    if(sender == hlSettings)
    {   	
    	if(ctx != null)
		{
			currentUser = ctx.getCurrentUser();		
			//AccountSettings accountSettings = new AccountSettings();
			//Navigate to AccountSettings Page when clicked on 'My Settings'
			if(currentUser != null)
			{
				DockPanel outer = new DockPanel();
		    	//outer.add(accountSettings, DockPanel.WEST);
		    	outer.setWidth("100%");
		    	//outer.setCellWidth(accountSettings, "100%");		    	
		   
		    	RootPanel.get("content").clear();
		    	RootPanel.get("content").add(outer);					
			}
		}    	
    }
  }
  
  private Widget getSeparator() 
  {
		Label barLabel = new Label();
		barLabel.setText("|");
		barLabel.addStyleName("normalTextFont");
		return barLabel;
  }
  
  AsyncCallback<Boolean> logOutCallback = new AsyncCallback<Boolean>()
  {
	  public void onFailure(Throwable caught)
	  {
		  System.out.println("UserTopPanel Logout Error: " + caught.toString());
	  }
	  public void onSuccess(Boolean result)
	  {
		  @SuppressWarnings("unused")
		  Login login = new Login();
	  }
  };
  
  private void resetContext() 
  {
	  RPCClientContext.set(new ClientContext());
  }	
  
  //Sets the registered users for a Administrator (When Administrator sign's off the role of assumed user to admin's identity)
  AsyncCallback<ArrayList<User>> usersCallback = new AsyncCallback<ArrayList<User>>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("UserTopPanel usersCallback error: " +arg0.toString());			
		}		
		public void onSuccess(ArrayList<User> users)
		{			
			ClientContext adminCtx = (ClientContext) RPCClientContext.get();
			if(adminCtx != null)
			{			
				User currentUser = adminCtx.getCurrentUser();
				if(users != null)
				{
					UserItems userItems = new UserItems();
					userItems.setUserItems(users);
					currentUser.setUserItems(userItems);
									
					adminCtx.setCurrentUser(currentUser);
				}
				AdminPage adminPage = new AdminPage(4, "", "", "");
				VerticalPanel contentPanel = new VerticalPanel();
				DockPanel outer = new DockPanel();		        	
				outer.add(adminPage, DockPanel.CENTER);
	        	outer.setWidth("100%");
	        	outer.setCellWidth(adminPage, "100%");
	        	contentPanel.add(outer);
				RootPanel.get("content").add(adminPage);
			}			
		}
	};	
}