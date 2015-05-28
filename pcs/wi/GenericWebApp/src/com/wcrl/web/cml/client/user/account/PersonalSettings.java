/*
 * File: PersonalSettings.java

Purpose: Java class to handle user's Personal settings - Edit email and Change Password
**********************************************************/
package com.wcrl.web.cml.client.user.account;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.login.Login;

public class PersonalSettings implements ClickHandler 
{
	private ClientContext ctx;
	private User user;
	private VerticalPanel panel;
	private FlexTable table;
	private Anchor hlEditProfile;
	private Anchor hlChangePassword;
	private Anchor hlEditEmailAddress;
	private Label msgLabel;
	private EditPassword editPassword;
	private EditEmail editEmail;
	private EditUserProfile editProfile;
	
	public PersonalSettings() 
	{
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{

			ctx = (ClientContext) RPCClientContext.get();			
		    if(ctx != null)
		    {	    	
		       	user = ctx.getCurrentUser();
		    }
		}
		else
		{
			Login login = new Login();
			login.displayLoginBox();
		}
	}
	
	//Initialize and attach components
	public VerticalPanel getPersonalSettingsPanel()
	{			
		table = new FlexTable();
		panel = new VerticalPanel();
		msgLabel = new Label();
   		msgLabel.setStylePrimaryName("msg");
   		msgLabel.setVisible(false);
   		
		FlexTable profileTable = new FlexTable();
		FlexTable securityTable = new FlexTable();
		
		table.setCellSpacing(10);
		table.setCellPadding(10);
		table.setWidget(0, 0, profileTable);
		table.setWidget(0, 1, new HTML("&nbsp;&nbsp;&nbsp;"));
		table.setWidget(0, 2, new HTML("&nbsp;&nbsp;&nbsp;"));
		table.setWidget(0, 3, new HTML("&nbsp;&nbsp;&nbsp;"));
		table.setWidget(0, 4, new HTML("&nbsp;&nbsp;&nbsp;"));
		table.setWidget(0, 5, securityTable);
		
		System.out.println("Username : " + user.getFirstName() + " " + user.getLastName());
		String name = user.getFirstName() + " " + user.getLastName();
		hlEditProfile = new Anchor("Edit Profile");		
		profileTable.setText(0, 0, name);
		profileTable.setWidget(1, 0, hlEditProfile);
		
		securityTable.setText(0, 0, "Security:");
		VerticalPanel securityPanel = new VerticalPanel();
		hlChangePassword = new Anchor("Change password");		
		securityPanel.add(hlChangePassword);
		securityTable.setWidget(0, 1, new HTML("&nbsp;&nbsp;"));
		securityTable.setWidget(0, 2, securityPanel);
		securityTable.setWidget(1, 0, new HTML("<br>"));
		securityTable.setWidget(2, 0, new HTML("<br>"));
		securityTable.setText(3, 0, "Email Address:");
		VerticalPanel emailPanel = new VerticalPanel();
		Label lblEmail = new Label();
		lblEmail.setText(user.getPrimaryemail() + "(Primary Email)");
		hlEditEmailAddress = new Anchor("Edit");
		emailPanel.add(lblEmail);
		emailPanel.add(hlEditEmailAddress);
		securityTable.setWidget(3, 1, new HTML("&nbsp;&nbsp;"));
		securityTable.setWidget(3, 2, emailPanel);
		
		securityTable.getCellFormatter().setVerticalAlignment(0, 0, HasVerticalAlignment.ALIGN_TOP);
		securityTable.getCellFormatter().setHorizontalAlignment(0, 0, HasHorizontalAlignment.ALIGN_LEFT);
		securityTable.getCellFormatter().setVerticalAlignment(0, 2, HasVerticalAlignment.ALIGN_TOP);
		securityTable.getCellFormatter().setHorizontalAlignment(0, 2, HasHorizontalAlignment.ALIGN_LEFT);
		securityTable.getCellFormatter().setVerticalAlignment(3, 0, HasVerticalAlignment.ALIGN_TOP);
		securityTable.getCellFormatter().setHorizontalAlignment(3, 0, HasHorizontalAlignment.ALIGN_LEFT);
		securityTable.getCellFormatter().setVerticalAlignment(3, 2, HasVerticalAlignment.ALIGN_TOP);
		securityTable.getCellFormatter().setHorizontalAlignment(3, 2, HasHorizontalAlignment.ALIGN_LEFT);
						
		panel.add(msgLabel);
		panel.add(table);
		
		hlEditEmailAddress.addClickHandler(this);
		hlChangePassword.addClickHandler(this);
		hlEditProfile.addClickHandler(this);
		
		return panel;			
	}

	//Handle click events
	public void onClick(ClickEvent event) 
	{
		Widget source = (Widget) event.getSource();
		VerticalPanel outer = new VerticalPanel();
		outer.setSize("100%", "100%");
		outer.setHorizontalAlignment(HasHorizontalAlignment.ALIGN_CENTER);
		outer.setWidth("100%");
		if(source == hlEditEmailAddress)
		{		
			History.newItem("editMailAddress");
			editEmail = new EditEmail();			
	      	outer.add(editEmail);	      	
	      	outer.setCellWidth(editEmail, "100%");			
		}
		else if(source == hlChangePassword)
		{
			History.newItem("editPassword");
			editPassword = new EditPassword();
			outer.add(editPassword);	      	
	      	outer.setCellWidth(editPassword, "100%");			
		}		
		else if(source == hlEditProfile)
		{
			Log.info("Into user profile");
			History.newItem("editProfile");
			editProfile = new EditUserProfile();
			outer.add(editProfile);	      	
	      	outer.setCellWidth(editProfile, "100%");			
		}
		
		RootPanel.get("content").clear();
		RootPanel.get("content").add(outer);
	}
}