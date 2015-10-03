/*
 * Copyright 2010 Daniel Kurka
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.googlecode.mgwt.examples.showcase.client.activities.elements;

import java.util.Date;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.Label;
import com.googlecode.mgwt.dom.client.event.tap.TapEvent;
import com.googlecode.mgwt.dom.client.event.tap.TapHandler;
import com.googlecode.mgwt.examples.showcase.client.ChromeWorkaround;
import com.googlecode.mgwt.examples.showcase.client.ClientFactory;
import com.googlecode.mgwt.examples.showcase.client.DetailViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.ClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.RPCClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.User;
import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.service.UserValidationService;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.service.UserValidationServiceAsync;
import com.googlecode.mgwt.ui.client.MGWT;
import com.googlecode.mgwt.ui.client.MGWTStyle;
import com.googlecode.mgwt.ui.client.widget.Button;
import com.googlecode.mgwt.ui.client.widget.MPasswordTextBox;
import com.googlecode.mgwt.ui.client.widget.MTextBox;
import com.googlecode.mgwt.ui.client.widget.WidgetList;

/**
 * @author Daniel Kurka
 * 
 */
public class ElementsViewImpl extends DetailViewGwtImpl implements ElementsView {
	
   private ClientContext ctx;
   private ClientFactory clientFactory;
   private Label lblWarning;
		
   public ElementsViewImpl(ClientFactory clientFactory) {
	//public ElementsViewImpl() {
	   this.clientFactory = clientFactory;  
	 String sessionID = Cookies.getCookie("sid");
   	 System.out.println("Session: " + sessionID);
   	 Log.info("Session: " + sessionID);
 	 if ( sessionID != null )
 	 {
 		 System.out.println("***SessionID sending for checking: " + sessionID);
		 UserValidationServiceAsync service = UserValidationService.Util.getInstance();
		 service.validateSession("Username", validateSessionCallback);
	 }
	 else
	 {
		 displayLogin();
	 }	   
  }
   
  private void displayLogin()
  {
	  	lblWarning = new Label();
		headerBackButton.removeFromParent();
		hPanel.removeFromParent();
	    scrollPanel.setScrollingEnabledX(false);
	    final FlowPanel container = new FlowPanel();

	    WidgetList widgetList = new WidgetList();
	    widgetList.setRound(true);
	    HTML header = new HTML("Login");
	    header.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
	    container.add(header);
	    container.add(widgetList);

	    scrollPanel.setWidget(container);
	    // workaround for android formfields jumping around when using
	    // -webkit-transform
	    scrollPanel.setUsePos(MGWT.getOsDetection().isAndroid());

	    ChromeWorkaround.maybeUpdateScroller(scrollPanel);

	    widgetList.add(lblWarning);
	    
	    final MTextBox mTextBox = new MTextBox();
	    mTextBox.setPlaceHolder("Username");
	    widgetList.add(mTextBox);
	    
	    mTextBox.setText("");

	    final MPasswordTextBox mPasswordTextBox = new MPasswordTextBox();
	    mPasswordTextBox.setPlaceHolder("Password");
	    widgetList.add(mPasswordTextBox);
	    
	    mPasswordTextBox.setText("");
	            
	    WidgetList widgetList1 = new WidgetList();
	    widgetList1.setRound(true);
	    
	    Button loginButton = new Button("Sign in");
	    Anchor forgotPassword = new Anchor("Forgot Password?");
	        
	    widgetList1.add(loginButton);
	    //widgetList1.add(forgotPassword);
	    
	    forgotPassword.addClickHandler(new ClickHandler(){

			@Override
			public void onClick(ClickEvent event) {
				// TODO Auto-generated method stub
				
			}
	    	
	    });
	    
	    
	    loginButton.addTapHandler(new TapHandler() {
	        @Override
	        public void onTap(TapEvent event) { 
	        	String usernameRegex = "^[a-z][-a-z0-9_]*$";
				String passwordRegex = "^.*(?=.{8,})(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(^[a-zA-Z0-9@$=!:.#%]+$)";
	        	//String regex = "^[A-Za-z@._][A-Za-z0-9._@]+";
	        	String username = mTextBox.getValue().trim();
	        	String password = mPasswordTextBox.getValue().trim();
	        	Log.info("Username: " + username + " Password: " + password);
	        	System.out.println("Username: " + username + " Password: " + password);
	        	System.out.println((username.matches(usernameRegex))  + " " +  (password.matches(passwordRegex)));
	        	if((username.matches(usernameRegex)) && (password.matches(passwordRegex)))
				{
	        		RPCClientContext.set(null);
	        		lblWarning.setText("");
	        		UserValidationServiceAsync service = UserValidationService.Util.getInstance();			
					service.validateUser(username, password, loginCallback);
				}
	        	else
	        	{
	        		lblWarning.setText("");
	     		    lblWarning.setText("Please enter valid username and password.");
	        	}
	        }                   
	    });    
	    container.add(widgetList1);
  }
   
   AsyncCallback<User> loginCallback = new AsyncCallback<User>()
   {
	   public void onFailure(Throwable arg0)
	   {
		   System.out.println("Login loginCallback error: " + arg0.toString());
		   Log.info("Login loginCallback error: " + arg0.toString());
		   lblWarning.setText("");
		   lblWarning.setText("Error in setting user session.");
	   }		
	   public void onSuccess(User user)
	   {
		   if(user == null)
		   {
			   System.out.println("In Login in user is not set.");
		   }
		   else
		   {
			   if(user.getUsername() == null)
			   {
				   lblWarning.setText("");
				   lblWarning.setText("Invalid username/password.");
			   }
			   else
			   {
				   lblWarning.setText("");
				   System.out.println("User: " + user.getUsername() + " logged in at: " + new Date());
				   				   
				   Cookies.removeCookie("sid");
				   RPCClientContext.set(new ClientContext());
				   String sessionID = user.getSessionID();
				   if(sessionID.length() > 0)
				   {
					   final long DURATION = 1000 * 60 * 60 * 24 * 14; //duration remembering login for 2 weeks
					   Date expires = new Date(System.currentTimeMillis() + DURATION);
					   Cookies.setCookie("sid", sessionID, expires);
				   }
				   setUser(user);
			   }
		   }
		}
   };
   
   AsyncCallback<String> validateSessionCallback = new AsyncCallback<String>()
   {
	   public void onFailure(Throwable arg0)
	   {
		   Log.info("Login validateSessionCallback error: " +arg0.toString());
	   }
	   public void onSuccess(String sessionID)
	   {
		   String serverSessionID = Cookies.getCookie("sid");
  		   System.out.println("SessionID: " + sessionID + " ServerSessionID: " + serverSessionID);
		   Log.info("SessionID: " + sessionID + " ServerSessionID: " + serverSessionID);
		   //System.out.println("SessionID: " + sessionID.length());
		   if(sessionID != null)
		   {
			   if(sessionID.length() > 0)
			   {
				   if(serverSessionID.equalsIgnoreCase(sessionID))
				   {
					   UserValidationServiceAsync service = UserValidationService.Util.getInstance();			
					   service.ckLogin(serverSessionID, " ", reLoginCallback);
			 	   }
			   }
		   }
		   else
		   {
			   //clientFactory.getPlaceController().goTo(new ElementsPlace());
			   displayLogin();
		   }
	   }
   };
   
   AsyncCallback<User> reLoginCallback = new AsyncCallback<User>()
   {
	   public void onFailure(Throwable arg0) {
		   Log.info("Login loginCallback error: " + arg0.toString());
		   lblWarning.setText("");
  		   lblWarning.setText("Error in setting user session.");
  	   }
	   public void onSuccess(User user) {
		   if(user == null)
		   {
			   Log.debug("In Login in user is not set.");
		   }
		   else
		   {
			   RPCClientContext.set(new ClientContext());
			   setUser(user);	
		   }
	   }
	};
   
   public void setUser(User user)
   {
	   ctx = (ClientContext)RPCClientContext.get();
	   ctx.setCurrentUser(user);
	   clientFactory.getPlaceController().goTo(new BCFunctionButtonPlace());
   }
}
