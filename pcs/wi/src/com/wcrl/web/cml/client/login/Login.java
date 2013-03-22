package com.wcrl.web.cml.client.login;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.dom.client.Document;
import com.google.gwt.dom.client.Element;
import com.google.gwt.dom.client.InputElement;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FormPanel;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.account.UserHistory;
import com.wcrl.web.cml.client.admin.account.UserItems;
import com.wcrl.web.cml.client.admin.accountService.GetUsersService;
import com.wcrl.web.cml.client.admin.accountService.GetUsersServiceAsync;
import com.wcrl.web.cml.client.loginService.UserValidationService;
import com.wcrl.web.cml.client.loginService.UserValidationServiceAsync;
import com.wcrl.web.cml.client.user.account.UserBottomPanel;
import com.wcrl.web.cml.client.user.account.UserTopPanel;


/**
 * Entry point classes define <code>onModuleLoad()</code>.
 */
public class Login extends Composite implements EntryPoint, ClickHandler 
{
	private static final String LOGINFORM_ID = "loginForm";
	private static final String LOGINBUTTON_ID = "loginSubmit";
    private static final String REMEMBERME_ID = "loginRememberMe";
    private static final String USERNAME_ID = "loginUsername";
    private static final String PASSWORD_ID = "loginPassword";
    private VerticalPanel mPanel;
    private Anchor requestAnchor;
    private Anchor accessAnchor;    
	private Label lblWarning;	
	private ClientContext ctx;
	private static Element formElement = DOM.getElementById("loginForm");
	private static Element usernameElement = DOM.getElementById("loginUsername");
	private FormPanel formPanel;    
	private boolean rememberMe;
	
	public Login()
	{
		
	}	
	
	/**
	 * This is the entry point method.
	 */
	public void onModuleLoad()
	{
		//System.out.println(BCrypt.hashpw("userJobList", BCrypt.gensalt(12)));
		String sessionID = Cookies.getCookie("sid");
		System.out.println("Session: " + sessionID);
		if ( sessionID != null )
		{
			System.out.println("***SessionID sending for checking: " + sessionID);
			UserValidationServiceAsync service = UserValidationService.Util.getInstance();
			service.validateSession("Username", validateSessionCallback);
		}
		else
		{
			displayLoginBox();
		}		
	}
	
	public void displayLoginBox()
	{	
		Element div = DOM.getElementById("loginDiv");		
		lblWarning = new Label();
		lblWarning.setStyleName("warnings");
		// Re-attaching the HTML form to <div>
		if(!formElement.getParentElement().equals(div))
		{
			div.appendChild(formElement);
		}
		
		setUsername("");
		setPassword("");
		setCheckValue(false);
		formPanel = FormPanel.wrap(formElement, false);
		formPanel.setAction("javascript:__gwt_login()");
		
        requestAnchor = new Anchor("Request Login");
        requestAnchor.addClickHandler(this);
        accessAnchor = new Anchor("Can't access account?");
        accessAnchor.addClickHandler(this);
        
        // Now, inject the jsni method for handling the form submit
        injectLoginFunction(this);
        

        // Add the form to the panel
        mPanel = new VerticalPanel();
        mPanel.add(lblWarning);
        mPanel.add(formPanel);
        mPanel.add(requestAnchor);
        mPanel.add(accessAnchor);
        mPanel.setCellHorizontalAlignment(requestAnchor, HasHorizontalAlignment.ALIGN_RIGHT);
        mPanel.setCellHorizontalAlignment(accessAnchor, HasHorizontalAlignment.ALIGN_RIGHT);
        
        RootPanel.get("header").clear();
		RootPanel.get("leftnav").clear();
		RootPanel.get("footer").clear();
		RootPanel.get("content").clear();
        RootPanel.get("content").add(mPanel);   
	}
	
    // This is the JSNI method that will be called on form submit
    private native void injectLoginFunction(Login view) 
    /*-{
        $wnd.__gwt_login = function(){     
        	view.@com.wcrl.web.cml.client.login.Login::doLogin()();   
        //view.@com.wcrl.comlnk.client.login.Login::doLogin()();
        }
    }-*/;
    
    // This is the internal method that is called from the JSNI method
    private void doLogin() 
    {
    	if(getUsername().equals("") && getPassword().equals(""))
		{
			lblWarning.setText("");
			lblWarning.setText("Please enter a valid username/password.");
		}
		else if(getUsername().equals("") && !(getPassword().equals("")))
		{
			lblWarning.setText("");
			lblWarning.setText("Please enter a valid username.");
		}
		else if((!getUsername().equals("")) && getPassword().equals(""))
		{
			lblWarning.setText("");
			lblWarning.setText("Please enter a valid password.");
		}
		else
		{
			String username = getUsername();
			String password = getPassword();
			//String usernameRegex = "^[A-Za-z][A-Za-z0-9._]+";
			String usernameRegex = "^[a-z][-a-z0-9_]*$";
			String passwordRegex = "^.*(?=.{8,})(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(^[a-zA-Z0-9@$=!:.#%]+$)";

			if(username.matches(usernameRegex))
			{
				if((password.length() >= 8) && (password.length() <= 16) && (password.matches(passwordRegex)))
				{
					Map<String, String> formData = new HashMap<String, String>();
					formData.put("username", username);
					formData.put("password", password);
					
					RPCClientContext.set(null);
					//System.out.println("Check value: " + getCheckValue());
					System.out.println("Login page login button: " + getUsername());
					Log.info("Login page login button: " + getUsername());
					rememberMe = getCheckValue();
					UserValidationServiceAsync service = UserValidationService.Util.getInstance();			
					service.validateUserData(getUsername(), getPassword(), getCheckValue(), loginCallback);
				}
				else
				{
					lblWarning.setText("");
					lblWarning.setText("Please enter a valid password.");
				}
			}
			else
			{
				lblWarning.setText("");
				lblWarning.setText("Please enter a valid username.");
			}
		}    	
    }

    public String getPassword() 
    {
        return ((InputElement) Document.get().getElementById(PASSWORD_ID)).getValue().trim();
    }

    public String getUsername() 
    {
        return ((InputElement) Document.get().getElementById(USERNAME_ID)).getValue().trim();
    }
    
    public void setPassword(String password)
    {
        ((InputElement) Document.get().getElementById(PASSWORD_ID)).setValue(password);
    }

    public void setUsername(String username)
    {
        ((InputElement) Document.get().getElementById(USERNAME_ID)).setValue(username);
    }
    
    public Boolean getCheckValue() 
    {
        return ((InputElement) Document.get().getElementById(REMEMBERME_ID)).isChecked();
    }    
    
    public void setCheckValue(boolean checked) 
    {
        ((InputElement) Document.get().getElementById(REMEMBERME_ID)).setChecked(checked);
    } 
	
	public void onClick(ClickEvent event) 
	{
		Widget source = (Widget) event.getSource();
		if(source == requestAnchor)
		{
			//History.newItem("register");
			Register register = new Register();
			RootPanel.get("content").clear();
			RootPanel.get("content").add(register);
		}
		if(source == accessAnchor)
		{
			ForgotPassword fp = new ForgotPassword();
			fp.showFolderPopup();
		}	
	}
	
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
						service.ckLogin(serverSessionID, " ", true, reLoginCallback);
					}					
				}					
			}
			else
			{
				Login login = new Login();
				login.displayLoginBox();
			}
		}
	};
	
	AsyncCallback<User> reLoginCallback = new AsyncCallback<User>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("Login loginCallback error: " + arg0.toString());
			setUsername("");
			setPassword("");
			lblWarning.setText("");
			lblWarning.setText("Error in setting user session.");		
		}		
		public void onSuccess(User user) 
		{
			if(user == null)
			{
				Log.debug("In Login in user is not set.");
			}
			else
			{
				//System.out.println("$$$$$$$$$Relogin user: " + user);
				//System.out.println("$$$$$$$$$$Relogin user: " + user.getUsername()); 
				RootPanel.get("header").clear();
				RootPanel.get("leftnav").clear();
				RootPanel.get("footer").clear();
				RootPanel.get("content").clear();
				RPCClientContext.set(new ClientContext());
				setUser(user);	
			}
		}
	};
	
	//Set the current user context
	AsyncCallback<User> loginCallback = new AsyncCallback<User>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("Login loginCallback error: " + arg0.toString());
			setUsername("");
			setPassword("");
			lblWarning.setText("");
			lblWarning.setText("Error in setting user session.");		
		}		
		public void onSuccess(User user) 
		{
			if(user == null)
			{
				Log.debug("In Login in user is not set.");
			}
			else
			{
				//System.out.println("User: " + user.getUsername());
				Log.info("User: " + user.getUsername());
				if(user.getUsername() == null)
				{
					setUsername("");
					setPassword("");
					lblWarning.setText("");
					lblWarning.setText("Invalid username/password.");
				}
				else
				{
					System.out.println("User: " + user.getUsername() + " logged in at: " + new Date());
					Log.debug("User: " + user.getUsername() + " logged in at: " + new Date());
					RootPanel.get("header").clear();
					RootPanel.get("leftnav").clear();
					RootPanel.get("footer").clear();
					RootPanel.get("content").clear();
					RPCClientContext.set(new ClientContext());
					
					 String sessionID = user.getSessionID();
					 if(sessionID.length() > 0)
					 {
						 if(rememberMe)
						 {
							 // Session valid for DURATION unless user signs off
							 final long DURATION = 1000 * 60 * 60 * 24 * 14; //duration remembering login for 2 weeks
							 Date expires = new Date(System.currentTimeMillis() + DURATION);
							 Cookies.setCookie("sid", sessionID, expires);
							 //Cookies.setCookie("sid", sessionID);
							 //System.out.println("~~~Checking session: " + Cookies.getCookie("sid") + " " + sessionID); 
						 }						 						 
						 else
						 {
							 // Session ends when the browser window is closed
							 //final long DURATION = 1000 * 60 * 10; //duration remembering login for 2 weeks
							 //Date expires = new Date(System.currentTimeMillis() + DURATION);
							 //Cookies.setCookie("sid", sessionID, expires);
							 Cookies.setCookie("sid", sessionID);
							 //System.out.println("~~~If remember me not checked checking session: " + Cookies.getCookie("sid") + " " + sessionID);
						 }
					 }					 
					 setUser(user);								
				}
			}
		}	
	};	
	
	
	public void setUser(User user)
	{
		/*UsersUsageGeneratorServiceAsync usersUsageService = GWT.create(UsersUsageGeneratorService.class);			
		usersUsageService.start(anAsyncCallback);*/
		Log.info("Setting user: " + user.getUsername());
		if(user.getUsertype().equalsIgnoreCase("admin"))
		{						
			ctx = (ClientContext)RPCClientContext.get();
			ctx.setCurrentUser(user);	
			UserTopPanel topPanel = new UserTopPanel();						
			UserBottomPanel bottomPanel = new UserBottomPanel();
			RootPanel.get("header").add(topPanel);					
			RootPanel.get("footer").add(bottomPanel);						
			GetUsersServiceAsync service = GetUsersService.Util.getInstance();			
			service.getUsers(usersCallback);						
		}
		else if(user.getUsertype().equalsIgnoreCase("user"))
		{						
			ctx = (ClientContext)RPCClientContext.get();
			ctx.setCurrentUser(user);	
			UserTopPanel topPanel = new UserTopPanel();						
			UserBottomPanel bottomPanel = new UserBottomPanel();
			RootPanel.get("header").add(topPanel);					
			RootPanel.get("footer").add(bottomPanel);
			UserHistory userHistory = new UserHistory();
			userHistory.history();
			/*UserPage userPage = new UserPage(0);					
			RootPanel.get("content").add(userPage);*/
		}
	}
	
	/*AsyncCallback<Void> anAsyncCallback = new AsyncCallback<Void>()
	{
		public void onFailure(Throwable aThrowable) 
		{
			
		}

	    public void onSuccess(Void aResult) 
	    {
	    	
	    }
	};*/
	
	//If the user is Administrator set the list of users
	AsyncCallback<ArrayList<User>> usersCallback = new AsyncCallback<ArrayList<User>>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("Login usersCallback error: " + arg0.toString());
			setUsername("");
			setPassword("");
			lblWarning.setText("");
			lblWarning.setText("Error in setting user session.");		
		}		
		public void onSuccess(ArrayList<User> users)
		{
			if(ctx != null)
			{
				User currentUser = ctx.getCurrentUser();
				if(users != null)
				{
					UserItems userItems = new UserItems();
					userItems.setUserItems(users);
					currentUser.setUserItems(userItems);
					ctx.setCurrentUser(currentUser);
				}
				
				UserHistory userHistory = new UserHistory();
				userHistory.history();
			}			
		}
	};
}