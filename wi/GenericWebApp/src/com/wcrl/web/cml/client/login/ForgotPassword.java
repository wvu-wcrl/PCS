/*
 * File: ForgotPassword.java

Purpose: Java class to handle the 'Forgot Password' 
**********************************************************/
package com.wcrl.web.cml.client.login;

import java.util.HashMap;
import java.util.Map;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.PopupPanel;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.widgetideas.client.GlassPanel;
import com.wcrl.web.cml.client.loginService.ForgotPasswordService;
import com.wcrl.web.cml.client.loginService.ForgotPasswordServiceAsync;

public class ForgotPassword
{
	private FlexTable table;
	private VerticalPanel vPanel;
	private Label lblWarning;
	private PopupPanel popup;
	private GlassPanel glassPanel;
	
	//Initialize the components
	public ForgotPassword()
	{		
		Log.info("In ForgotPassword");
		glassPanel = new GlassPanel(true);
		popup = new PopupPanel();
		lblWarning = new Label();
		table = new FlexTable();
		vPanel = new VerticalPanel();
		//customWidgets = new CustomWidgets();
		createComponents();
	}
	
	private void createComponents()
	{				
		lblWarning.setStyleName("warnings");
		HTML msg = new HTML("If you're a registered user, submit your Username and we'll send you a new, temporary password and instructions within 15 minutes. <br> Please enter the username and click 'Submit'.");
		final TextBox txtUsername = new TextBox();
				
		table.getCellFormatter().setHorizontalAlignment(0, 0, HasHorizontalAlignment.ALIGN_RIGHT);
		table.getCellFormatter().setVerticalAlignment(0, 0, HasVerticalAlignment.ALIGN_TOP);
		table.getCellFormatter().setHorizontalAlignment(0, 1, HasHorizontalAlignment.ALIGN_LEFT);
		table.getCellFormatter().setVerticalAlignment(0, 1, HasVerticalAlignment.ALIGN_TOP);
		table.getCellFormatter().setHorizontalAlignment(1, 0, HasHorizontalAlignment.ALIGN_RIGHT);
		table.getCellFormatter().setVerticalAlignment(1, 0, HasVerticalAlignment.ALIGN_TOP);
		
		HorizontalPanel buttonPanel = new HorizontalPanel();
		buttonPanel.setSpacing(10);
						
		Button btnSubmit = new Button("Submit");
		Button btnCancel = new Button("Cancel");
				
		vPanel.setWidth("200px");
		vPanel.add(lblWarning);
		vPanel.add(msg);
		table.setWidget(0, 0, new HTML("<b>Username:</b>&nbsp;&nbsp;&nbsp;"));
		table.setWidget(0, 1, txtUsername);        
		table.setWidget(1, 0, buttonPanel);
		vPanel.add(table);
		
		//Send the username to the sever - Server sends an email of a reset (random) password to the user 
		btnSubmit.addClickHandler(new ClickHandler()
		{		
			public void onClick(ClickEvent event) 
			{
				String username = txtUsername.getText().trim();
				String usernameRegex = "^[A-Za-z][A-Za-z0-9._]+";
				//Check the username and send a request to the server
				if(username.matches(usernameRegex) && username.length() > 0)
				{
					lblWarning.setVisible(false);
					hideFolderPopup();
					ForgotPasswordServiceAsync service = ForgotPasswordService.Util.getInstance();
					Map<String, String> formData = new HashMap<String, String>();
					formData.put("username", username);
					service.sendEmail(formData, forgotPasswordCallback);
				}				
				else
				{
					lblWarning.setVisible(true);
					lblWarning.setText("Please enter a valid username.");
					//customWidgets.alertWidget("Username validation failed", "Please enter a valid username.");					
				}
			}			
		});
		
		//Close the 'Forgot Password' pop up
		btnCancel.addClickHandler(new ClickHandler()
		{			 
			public void onClick(ClickEvent event) 
			{
				hideFolderPopup();
			}
		});		
		
		buttonPanel.add(btnSubmit);
		buttonPanel.add(btnCancel);
				
		popup.add(vPanel);		
		popup.setAnimationEnabled(true);		
	}
	
	public void showFolderPopup()
	{
		RootPanel.get().add(glassPanel, 0, 0);
		popup.center();		
	}
	
	public void hideFolderPopup()
	{
		if (glassPanel != null) 
		{
			glassPanel.removeFromParent();			
		}
		popup.hide();
	}
	
	
	AsyncCallback<Integer> forgotPasswordCallback = new AsyncCallback<Integer>()
	{
		public void onFailure(Throwable error) 
		{
			Log.info("ForgotPassword forgotPasswordCallback error: " +  "Error in sending Email.");			
		}

		public void onSuccess(Integer flag) 
		{				
			hideFolderPopup();		
		}
	};	
}
