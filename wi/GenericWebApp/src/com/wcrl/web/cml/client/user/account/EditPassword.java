/*
 * File: EditPassword.java

Purpose: Java class to Edit Password
**********************************************************/
package com.wcrl.web.cml.client.user.account;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.PasswordTextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.user.accountService.EditPasswordService;
import com.wcrl.web.cml.client.user.accountService.EditPasswordServiceAsync;

public class EditPassword extends Composite implements ClickHandler
{
	private VerticalPanel changePasswordPanel = new VerticalPanel();
	private FlexTable table = new FlexTable();
	private final PasswordTextBox currentPassword = new PasswordTextBox();
	private final PasswordTextBox newPassword = new PasswordTextBox();
	private final PasswordTextBox confirmPassword = new PasswordTextBox();
	private Label lblWarnings = new Label();
	private Label lblMsg = new Label();
	private Label lblPageTitle = new Label();
	private Label lblDescription = new Label();
	private HorizontalPanel buttonPanel = new HorizontalPanel();
	private Button btnSave = new Button("Save");
	private Button btnCancel = new Button("Cancel");
	private ClientContext ctx;
	private User currentUser;
	
	//Get the current user context
	public EditPassword()
	{		
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{
			ctx = (ClientContext) RPCClientContext.get();	    
		    if(ctx != null)
		    {
		    	currentUser = ctx.getCurrentUser();  
		    }
		    else
		    {
		    	Log.info("Ctx null");
				Login login = new Login();
				login.displayLoginBox();
		    }

		    lblWarnings.addStyleName("warnings");
		    lblMsg.addStyleName("msg");
		    lblWarnings.setVisible(false);
			createComponent();
		}
		else
		{
			Login login = new Login();
			login.displayLoginBox();
		}				
	}

	//Display the components
	private void createComponent() {
		lblPageTitle.setText("Change Password");
		lblDescription.setText("To reset your password, provide your current password");
		
		currentPassword.setMaxLength(16);		
		newPassword.setMaxLength(16);
		confirmPassword.setMaxLength(16);
		HTML passwdInstructions = new HTML("1. At least 1 numeric. <br>  2. At least one lower case letter. <br> 3. At least one uppercase letter. <br> 4. Special character may or may not exist. <br> 5. Length should be minimum of 8 chars and maximum of 16 chars. <br> 6. Any order of characters is allowed in the password. <br> 7. Allowed special characters are @$=!:.#%");

		DisclosurePanel disclosurePanel = new DisclosurePanel("Password");
		disclosurePanel.add(passwdInstructions);

		buttonPanel.add(btnSave);
		buttonPanel.add(btnCancel);
		table.setWidget(0, 0, new HTML("<b>Current Password:</b>&nbsp;&nbsp;&nbsp;"));
		table.setWidget(0, 1, currentPassword);        
		table.setWidget(1, 0, new HTML("<b>New Password:</b>&nbsp;&nbsp;&nbsp;"));
		table.setWidget(1, 1, newPassword);
		table.setWidget(2, 0, disclosurePanel);
		table.setWidget(3, 0, new HTML("<b>Confirm Password:</b>&nbsp;&nbsp;&nbsp;"));
		table.setWidget(3, 1, confirmPassword);		
		table.setWidget(4, 0, buttonPanel);
				
		changePasswordPanel.add(lblWarnings);
		changePasswordPanel.add(lblMsg);
		changePasswordPanel.add(lblDescription);
		changePasswordPanel.add(table);
		
		btnSave.addClickHandler(this);
		btnCancel.addClickHandler(this);
		
		changePasswordPanel.setWidth("1000px");
		initWidget(changePasswordPanel);		
	}

	public void onClick(ClickEvent event) {
		Widget source = (Widget) event.getSource();
		
		if(source == btnSave)
		{		
			String currentPwd = currentPassword.getText().trim();
			String newPwd = newPassword.getText().trim();
			String confirmPwd = confirmPassword.getText().trim();
			String regex = "^.*(?=.{8,})(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(^[a-zA-Z0-9@$=!:.#%]+$)";
						
			//Check if the entered current and the new password are valid and send a request to the server to update in the database
			if((newPwd.length() >= 8 && newPwd.length() <= 16) && (newPwd.matches(regex)))
			{
				System.out.println("New Password: " + newPwd + " Confirm Password: " + confirmPwd + " current passwordd: " + currentUser.getPassword());
				if(newPwd.equals(confirmPwd))
				{
					lblWarnings.setVisible(false);
					//btnCancel.setEnabled(false);
					EditPasswordServiceAsync service = EditPasswordService.Util.getInstance();   		
		    		service.editPassword(currentUser.getUserId(), newPassword.getText().trim(), currentPwd, currentUser.getPassword(), editPasswordCallback);				
				}
				else
				{							
					newPassword.setValue("");
					confirmPassword.setValue("");
					lblWarnings.setVisible(true);
					lblWarnings.setText("Password doesn't match.");										
				}
			}
			else
			{					
				newPassword.setValue("");
				confirmPassword.setValue("");
				lblWarnings.setVisible(true);
				lblWarnings.setText("Please enter a valid password.");
			}
			/*if((currentPwd.length() >= 8 && currentPwd.length() <= 16) && (currentPwd.matches(regex)))
			{
				if((newPwd.length() >= 8 && newPwd.length() <= 16) && (newPwd.matches(regex)))
				{
					//System.out.println("New Password: " + newPwd + " Confirm Password: " + confirmPwd);
					if(newPwd.equals(confirmPwd))
					{
						lblWarnings.setVisible(false);
						btnCancel.setEnabled(false);
						EditPasswordServiceAsync service = EditPasswordService.Util.getInstance();   		
			    		service.editPassword(currentUser.getUserId(), newPassword.getText().trim(), currentPwd, currentUser.getPassword(), editPasswordCallback);				
					}
					else
					{							
						newPassword.setValue("");
						confirmPassword.setValue("");
						lblWarnings.setVisible(true);
						lblWarnings.setText("Password doesn't match.");										
					}
				}
				else
				{					
					newPassword.setValue("");
					confirmPassword.setValue("");
					lblWarnings.setVisible(true);
					lblWarnings.setText("Please enter a valid password.");
				}
			}
			else
			{
				currentPassword.setValue("");
				newPassword.setValue("");
				confirmPassword.setValue("");
				lblWarnings.setVisible(true);								
				lblWarnings.setText("Current Password doesn't match.");
			}*/									
		}		
		if(source == btnCancel)
		{			
			if(ctx != null)
			{
				currentUser = ctx.getCurrentUser();
				if(currentUser != null)
				{
					/*RootPanel.get("content").clear();
					RootPanel.get("content").add(new AccountSettings());*/
					History.newItem("settings");
				}
			}			
		}		
	}
		
	//Inform user of the changed password
	AsyncCallback<String> editPasswordCallback = new AsyncCallback<String>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info("EditPassword editPasswordCallback error: " +  caught.toString());			
		}
		//public void onSuccess(Boolean result) 
		public void onSuccess(String newPasswdHash)
		{		
			if(newPasswdHash.length() > 0)
			{
				currentUser.setPassword(newPasswdHash);
				ctx.setCurrentUser(currentUser);
				lblMsg.setText("Password changed.");	
				//System.out.println("NewPasswordHash: " + newPasswdHash);
				/*RootPanel.get("content").clear();
				RootPanel.get("content").add(new AccountSettings());*/
				History.newItem("settings");
			}		
			else
			{
				currentPassword.setValue("");
				lblWarnings.setVisible(true);								
				lblWarnings.setText("Current Password doesn't match.");
			}
			/*boolean password = (Boolean)result;
			if(password)
			{
				currentUser.setPassword(newPassword.getText().trim());
				ctx.setCurrentUser(currentUser);
				lblMsg.setText("Password changed.");	
				RootPanel.get("content").clear();
				RootPanel.get("content").add(new AccountSettings());
				History.newItem("settings");
			}
			else
			{
				currentPassword.setValue("");
				lblWarnings.setVisible(true);								
				lblWarnings.setText("Current Password doesn't match.");
			}*/
		}	
	};	
}

