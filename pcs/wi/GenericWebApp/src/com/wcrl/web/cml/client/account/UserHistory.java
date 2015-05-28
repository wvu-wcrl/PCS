package com.wcrl.web.cml.client.account;

import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.ui.DockPanel;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.admin.account.AddUsers;
import com.wcrl.web.cml.client.admin.account.AdminPage;
import com.wcrl.web.cml.client.admin.projects.AddProject;
import com.wcrl.web.cml.client.datafiles.UploadDataFile;
import com.wcrl.web.cml.client.jobs.UploadJob;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.login.Register;
import com.wcrl.web.cml.client.user.account.AccountSettings;
import com.wcrl.web.cml.client.user.account.EditEmail;
import com.wcrl.web.cml.client.user.account.EditPassword;
import com.wcrl.web.cml.client.user.account.EditUserProfile;
import com.wcrl.web.cml.client.user.account.UserPage;

@SuppressWarnings("deprecation")
public class UserHistory 
{
	public void history()
    {	     	    	
	    History.addValueChangeHandler(new ValueChangeHandler<String>() 
	    {
	        public void onValueChange(ValueChangeEvent<String> event) 
	        {        	
	        	ClientContext ctx = (ClientContext) RPCClientContext.get();
	        	String historyToken = event.getValue();
	        	//System.out.println("User: " + ctx.getCurrentUser().getUsertype() + " History: " + historyToken);
	        	//System.out.println(" History: " + historyToken);
	        	if(historyToken.equals("register"))
	        	{
	        		//System.out.println("In register");
	    			Register register = new Register();
	    			RootPanel.get("content").clear();
	    			RootPanel.get("content").add(register);
	        	}	        	
	        	if (historyToken.equals("home")) 
	        	{
	        		if(ctx.getCurrentUser().getUsertype().equalsIgnoreCase("user"))
					{
						History.newItem("userJobList");
					}
					else
					{
						History.newItem("jobList");
					}
	        	}
	        	/* Adding settings */
	        	if (historyToken.equals("settings")) 
	        	{
	        		AccountSettings accountSettings = new AccountSettings(0);
	        		DockPanel outer = new DockPanel();
			    	outer.add(accountSettings, DockPanel.WEST);
			    	outer.setWidth("100%");
			    	outer.setCellWidth(accountSettings, "100%");			    	
			    	RootPanel.get("content").clear();
			    	RootPanel.get("content").add(outer);           		
		        } 
	        	if (historyToken.equals("projectSettings")) 
	        	{
	        		AccountSettings accountSettings = new AccountSettings(1);
	        		DockPanel outer = new DockPanel();
			    	outer.add(accountSettings, DockPanel.WEST);
			    	outer.setWidth("100%");
			    	outer.setCellWidth(accountSettings, "100%");			    	
			    	RootPanel.get("content").clear();
			    	RootPanel.get("content").add(outer);           		
		        }
	        	if (historyToken.equals("editPassword")) 
	        	{
	        		EditPassword editPassword = new EditPassword();
	        		DockPanel outer = new DockPanel();
	        		outer.setWidth("100%");
	    			outer.add(editPassword, DockPanel.WEST);	      	
	    	      	outer.setCellWidth(editPassword, "100%");
	    	      	RootPanel.get("content").clear();
	    			RootPanel.get("content").add(outer);
	        	}
	        	if (historyToken.equals("editMailAddress")) 
	        	{
	        		EditEmail editEmail = new EditEmail();		
	        		DockPanel outer = new DockPanel();
	    	      	outer.add(editEmail, DockPanel.WEST);	      	
	    	      	outer.setCellWidth(editEmail, "100%");
	    	      	RootPanel.get("content").clear();
	    			RootPanel.get("content").add(outer);
	        	}
	        	if (historyToken.equals("editProfile")) 
	        	{
	        		EditUserProfile editProfile = new EditUserProfile();		
	        		DockPanel outer = new DockPanel();
	    	      	outer.add(editProfile, DockPanel.WEST);	      	
	    	      	outer.setCellWidth(editProfile, "100%");
	    	      	RootPanel.get("content").clear();
	    			RootPanel.get("content").add(outer);
	        	}
	        	/* End of adding settings */
	        	if(historyToken.equals("uploadJob"))
	        	{
	        		UploadJob uploadJob = new UploadJob(0);
        			RootPanel.get("content").clear();
        			RootPanel.get("content").add(uploadJob);	        		        			
	        	}
	        	if(historyToken.equals("uploadDataFile"))
	        	{
	        		UploadDataFile addDataFile = new UploadDataFile(4);
        			RootPanel.get("content").clear();
        			RootPanel.get("content").add(addDataFile);	        		
	        	}
	        	if(historyToken.equals("adminUploadJob"))
	        	{
	        		//System.out.println("In history");
	        		UploadJob uploadJob = new UploadJob(2);
        			RootPanel.get("content").clear();
        			RootPanel.get("content").add(uploadJob);	        		        			
	        	}
	        	if(historyToken.equals("adminUploadDataFile"))
	        	{
	        		UploadDataFile addDataFile = new UploadDataFile(5);
        			RootPanel.get("content").clear();
        			RootPanel.get("content").add(addDataFile);	        		
	        	}
	        	if(historyToken.equals("addProject"))
	        	{
	        		AddProject addProject = new AddProject();
        			RootPanel.get("content").clear();
        			RootPanel.get("content").add(addProject);
	        		
	        	}
	        	if(historyToken.equals("adminJobList"))
	        	{
	        		if(ctx.getCurrentUser().getUsertype().equalsIgnoreCase("Admin"))
	    	    	{
	        			AdminPage adminPage = new AdminPage(0, "", "", "", 0);
		        		VerticalPanel contentPanel = new VerticalPanel();
						DockPanel outer = new DockPanel();		        	
						outer.add(adminPage, DockPanel.CENTER);
			        	outer.setWidth("100%");
			        	outer.setCellWidth(adminPage, "100%");
			        	contentPanel.add(outer);
			        	RootPanel.get("content").clear();
						RootPanel.get("content").add(adminPage);
	    	    	}	        		
	        	}
	        	if(historyToken.equals("adminFileList"))
	        	{
	        		if(ctx.getCurrentUser().getUsertype().equalsIgnoreCase("Admin"))
	    	    	{
	        			AdminPage adminPage = new AdminPage(5, "", "", "", 0);
		        		VerticalPanel contentPanel = new VerticalPanel();
						DockPanel outer = new DockPanel();		        	
						outer.add(adminPage, DockPanel.CENTER);
			        	outer.setWidth("100%");
			        	outer.setCellWidth(adminPage, "100%");
			        	contentPanel.add(outer);
			        	RootPanel.get("content").clear();
						RootPanel.get("content").add(adminPage);
	    	    	}	        		
	        	}
	        	if(historyToken.equals("addUsers"))
	        	{
	        		if(ctx.getCurrentUser().getUsertype().equalsIgnoreCase("Admin"))
	    	    	{
		        		/*AdminPage adminPage = new AdminPage(2);
		        		VerticalPanel contentPanel = new VerticalPanel();
						DockPanel outer = new DockPanel();		        	
						outer.add(adminPage, DockPanel.CENTER);
			        	outer.setWidth("100%");
			        	outer.setCellWidth(adminPage, "100%");
			        	contentPanel.add(outer);*/
	        			AddUsers addUsers = new AddUsers();
			        	RootPanel.get("content").clear();
						RootPanel.get("content").add(addUsers);
	    	    	}
	        	}
	        	if(historyToken.equals("userList"))
	        	{
	        		if(ctx.getCurrentUser().getUsertype().equalsIgnoreCase("Admin"))
	    	    	{
		        		AdminPage adminPage = new AdminPage(1, "", "", "", 0);
		        		VerticalPanel contentPanel = new VerticalPanel();
						DockPanel outer = new DockPanel();		        	
						outer.add(adminPage, DockPanel.CENTER);
			        	outer.setWidth("100%");
			        	outer.setCellWidth(adminPage, "100%");
			        	contentPanel.add(outer);
			        	RootPanel.get("content").clear();
						RootPanel.get("content").add(adminPage);
	    	    	}
	        	}
	        	if(historyToken.equals("jobList"))
	        	{
	        		if(ctx.getCurrentUser().getUsertype().equalsIgnoreCase("Admin"))
	    	    	{
		        		AdminPage adminPage = new AdminPage(2, "", "", "", 0);
		        		VerticalPanel contentPanel = new VerticalPanel();
						DockPanel outer = new DockPanel();		        	
						outer.add(adminPage, DockPanel.CENTER);
			        	outer.setWidth("100%");
			        	outer.setCellWidth(adminPage, "100%");
			        	contentPanel.add(outer);
			        	RootPanel.get("content").clear();
						RootPanel.get("content").add(adminPage);
	    	    	}
	        	}
	        	if(historyToken.equals("fileList"))
	        	{
	        		if(ctx.getCurrentUser().getUsertype().equalsIgnoreCase("Admin"))
	    	    	{
	        			AdminPage adminPage = new AdminPage(4, "", "", "", 0);
		        		VerticalPanel contentPanel = new VerticalPanel();
						DockPanel outer = new DockPanel();		        	
						outer.add(adminPage, DockPanel.CENTER);
			        	outer.setWidth("100%");
			        	outer.setCellWidth(adminPage, "100%");
			        	contentPanel.add(outer);
			        	RootPanel.get("content").clear();
						RootPanel.get("content").add(adminPage);
	    	    	}        		
	        	}
	        	if(historyToken.equals("projectList"))
	        	{
	        		if(ctx.getCurrentUser().getUsertype().equalsIgnoreCase("Admin"))
	    	    	{
		        		AdminPage adminPage = new AdminPage(3, "", "", "", 0);
		        		VerticalPanel contentPanel = new VerticalPanel();
						DockPanel outer = new DockPanel();		        	
						outer.add(adminPage, DockPanel.CENTER);
			        	outer.setWidth("100%");
			        	outer.setCellWidth(adminPage, "100%");
			        	contentPanel.add(outer);
			        	RootPanel.get("content").clear();
						RootPanel.get("content").add(adminPage);
	    	    	}
	        	}
	        	if(historyToken.equals("userJobList"))
	        	{
	        		ClientContext ctx1 = (ClientContext) RPCClientContext.get();
	        		System.out.println("Usertype in history: " + ctx1.getCurrentUser().getUsertype() + " ");
	        		System.out.println("Usertype in history: " + ctx.getCurrentUser().getUsertype() + " ");	        		
	        		if(ctx.getCurrentUser().getUsertype().equalsIgnoreCase("User"))
	    	    	{
	        			UserPage userPage = new UserPage(0, "", "", "");
		        		VerticalPanel contentPanel = new VerticalPanel();
						DockPanel outer = new DockPanel();		        	
						outer.add(userPage, DockPanel.CENTER);
			        	outer.setWidth("100%");
			        	outer.setCellWidth(userPage, "100%");
			        	contentPanel.add(outer);
			        	RootPanel.get("content").clear();
						RootPanel.get("content").add(userPage);
	    	    	}	        		
	        	}
	        	if(historyToken.equals("userFileList"))
	        	{
	        		if(ctx.getCurrentUser().getUsertype().equalsIgnoreCase("User"))
	    	    	{
	        			UserPage userPage = new UserPage(1, "", "", "");
		        		VerticalPanel contentPanel = new VerticalPanel();
						DockPanel outer = new DockPanel();		        	
						outer.add(userPage, DockPanel.CENTER);
			        	outer.setWidth("100%");
			        	outer.setCellWidth(userPage, "100%");
			        	contentPanel.add(outer);
			        	RootPanel.get("content").clear();
						RootPanel.get("content").add(userPage);
	    	    	}	        		
	        	}
	        	if(historyToken.equals("clusterStatus"))
	        	{
	        		if(ctx.getCurrentUser().getUsertype().equalsIgnoreCase("Admin"))
	    	    	{
	        			AdminPage adminPage = new AdminPage(6, "", "", "", 0);
		        		VerticalPanel contentPanel = new VerticalPanel();
						DockPanel outer = new DockPanel();		        	
						outer.add(adminPage, DockPanel.CENTER);
			        	outer.setWidth("100%");
			        	outer.setCellWidth(adminPage, "100%");
			        	contentPanel.add(outer);
			        	RootPanel.get("content").clear();
						RootPanel.get("content").add(adminPage);
	    	    	}	        		
	        	}
	        	else if ("".equals(History.getToken()) || History.getToken().equalsIgnoreCase("Signout"))
	      		{
	        		//System.out.println("@@@In login");
	        		if((ClientContext)RPCClientContext.get() == null)	      		
	      	    	{
	      	    		Login login = new Login();
	      	    		login.displayLoginBox();
	      	    	}
	      		}
	        }
	    });
	    if ("".equals(History.getToken()) || History.getToken().equalsIgnoreCase("Signout"))
		{
	    	if((ClientContext)RPCClientContext.get() == null)
	    	{
	    		Login login = new Login();
	    		login.displayLoginBox();
	    	}
	    	else
	    	{
	    		if(((ClientContext) RPCClientContext.get()).getCurrentUser().getUsertype().equalsIgnoreCase("Admin"))
		    	{
		    		History.newItem("jobList");		    		
		    	}
		    	else
		    	{
		    		History.newItem("userJobList");
		    	}
	    		//System.out.println("get token: " + History.getToken());
	    	}	    		    			
		}
	    else
	    {
	    	History.fireCurrentHistoryState();
	    	System.out.println("get token: " + History.getToken());
	    }
    }  
}