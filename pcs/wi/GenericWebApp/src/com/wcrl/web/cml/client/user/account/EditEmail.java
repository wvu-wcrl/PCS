/*
 * File: EditEmail.java

Purpose: Java class to Edit email address
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
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.user.accountService.EditEmailService;
import com.wcrl.web.cml.client.user.accountService.EditEmailServiceAsync;

public class EditEmail extends Composite implements ClickHandler
{
	private VerticalPanel emailPanel = new VerticalPanel();	
	private final Label lblEmail = new Label();
	private final TextBox txtAddEmail = new TextBox(); //("Add an additional email address", "alternateEmail");	
	private Label lblWarnings = new Label();
	private Label lblMsg = new Label();
	private Label lblPageTitle = new Label();
	private Label lblDescription = new Label();
	private FlexTable emailTable = new FlexTable();
	private HorizontalPanel buttonPanel = new HorizontalPanel();
	private Button btnSave = new Button("Save");
	private Button btnCancel = new Button("Cancel");
	
	private ClientContext ctx;
	private User currentUser;
	private String alternateEmail;
	
	public EditEmail()
	{		
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{
			ctx = (ClientContext) RPCClientContext.get();		    
		    if(ctx != null)
		    {	    
		    	currentUser = ctx.getCurrentUser();
		    	lblWarnings.addStyleName("warnings");
				lblMsg.addStyleName("msg");
			    lblWarnings.setVisible(false);
				createComponent(currentUser.getPrimaryemail(), currentUser.getPrimaryemail());
		    }
		    else
		    {
		    	Log.info("Ctx null");
				Login login = new Login();
				login.displayLoginBox();
		    }
		}
		else
		{
			Login login = new Login();
			login.displayLoginBox();
		}
	}

	//Display components
	private void createComponent(String primaryEmail, String secondaryEmail) 
	{
		lblPageTitle.setText("Update email");
		lblDescription.setText("Update email address");
		//txtAddEmail.setVtype(VType.EMAIL);
		txtAddEmail.setSize("250px", "25px");
		txtAddEmail.setValue(secondaryEmail);
		
		lblEmail.setText(primaryEmail);
		emailTable.setWidget(0, 0, lblEmail);
		emailTable.setText(0, 1, "(Primary email)");
		emailTable.setText(1, 0, "Update email address:");
		emailTable.setWidget(1, 1, txtAddEmail);				
		buttonPanel.add(btnSave);
		buttonPanel.add(btnCancel);
		emailTable.setWidget(2, 1, new HTML("<br>"));
		emailTable.setWidget(3, 1, buttonPanel);
		
		
		emailPanel.add(lblWarnings);
		emailPanel.add(lblMsg);
		//emailPanel.add(new HTML("<br>"));
		//emailPanel.add(lblPageTitle);
		emailPanel.add(lblDescription);
		//emailPanel.add(new HTML("<br>"));
		emailPanel.add(emailTable);
		
		emailPanel.setSpacing(5);
		
		btnSave.addClickHandler(this);
		btnCancel.addClickHandler(this);
		
		emailPanel.setSize("1000px", "500px");				
		initWidget(emailPanel);		
	}

	public void onClick(ClickEvent event) {
		Widget source = (Widget) event.getSource();
		
		if(source == btnSave)
		{		
			btnCancel.setEnabled(false);
			alternateEmail = txtAddEmail.getText().trim();
			//check if the entered email address is valid
			if((alternateEmail.length()) > 0 && (alternateEmail.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$")))
			{
				lblWarnings.setVisible(false);
				//Send a request to the server to save the email address in the database
				EditEmailServiceAsync service = EditEmailService.Util.getInstance();   		
	    		service.editEmail(currentUser.getUserId(), alternateEmail, editEmailCallback);
			}				
			else
			{
				lblWarnings.setText("Please enter a valid email address");
				lblWarnings.setVisible(true);
			}
		}		
		if(source == btnCancel)
		{			
			if(ctx != null)
			{
				currentUser = ctx.getCurrentUser();
				if(currentUser != null)
				{
					/*RootPanel.get("content").clear();
					RootPanel.get("content").add(new AccountSettings());	*/
					History.newItem("settings");
				}
			}						
		}		
	}
	
	AsyncCallback<Boolean> editEmailCallback = new AsyncCallback<Boolean>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info("EditEmail editEmailCallback error: " + caught.toString());			
		}
		public void onSuccess(Boolean result) 
		{			
			boolean editEmail = result;
			if(editEmail)
			{
				//System.out.println("EditEmail: " + editEmail);
				if(ctx != null)
				{
					lblMsg.setText("Your account information has been updated and saved.");
					currentUser = ctx.getCurrentUser();
					if(currentUser != null)
					{
						currentUser.setPrimaryemail(alternateEmail);
						ctx.setCurrentUser(currentUser);
						/*RootPanel.get("content").clear();
						RootPanel.get("content").add(new AccountSettings());*/
						History.newItem("settings");
					}										
				}				
			}	
		}	
	};	
}

