/*
 * File: AddUsers.java

Purpose: To add the users - with Admin or User role to access the web application.
**********************************************************/

package com.wcrl.web.cml.client.admin.account;

import java.util.ArrayList;
import java.util.HashMap;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.accountService.AddUsersService;
import com.wcrl.web.cml.client.admin.accountService.AddUsersServiceAsync;
import com.wcrl.web.cml.client.admin.accountService.GetUsersService;
import com.wcrl.web.cml.client.admin.accountService.GetUsersServiceAsync;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.projectService.ProjectListService;
import com.wcrl.web.cml.client.projectService.ProjectListServiceAsync;
import com.wcrl.web.cml.client.projects.ProjectItem;
import com.wcrl.web.cml.client.projects.ProjectItems;


public class AddUsers_Org extends Composite implements ClickHandler
{
	private ClientContext ctx;
	private User currentUser;
	private VerticalPanel vPanel;
	private FlexTable table;
	private Label lblTextArea;
	private Label lblMessage;
	private TextArea txtUsernames;
	private Button btnCreate;
	private ListBox lstUsertype;
	private Label lblProjectsText;
	private ListBox lstProjects;
	private ListBox lstSelectedProjects;
	private Button btnAdd;
	private Button btnRemove;
	private Label lblListBox;
	private Anchor hlBack;

	public AddUsers_Org()
	{
		vPanel = new VerticalPanel();
		initWidget(vPanel);
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{			
			//Get the current user context
			ctx = (ClientContext) RPCClientContext.get();
		    if(ctx != null)
		    {	    	
		       	currentUser = ctx.getCurrentUser();
		       
		       	if(currentUser != null)
		       	{	       		
		    		table = new FlexTable();	    		
		    		vPanel.setHorizontalAlignment(HorizontalPanel.ALIGN_LEFT);
		    	    vPanel.setVerticalAlignment(VerticalPanel.ALIGN_TOP);	    		
		    	    setProjects();
		       	}
		    }
		}
		else
		{
			Login login = new Login();
			login.displayLoginBox();
		}		
	}
	
	public void setProjects()
	{		
		if(currentUser != null)
    	{
			ProjectListServiceAsync service = ProjectListService.Util.getInstance();
    	  	service.getProjectList(projectListCallback);	    		
    	}
	}
    
    AsyncCallback<ArrayList<ProjectItem>> projectListCallback = new AsyncCallback<ArrayList<ProjectItem>>()
	{
		public void onFailure(Throwable caught)
		{
			Log.info("ProjectList projectListCallback error: " + caught.toString());
		}
		
		public void onSuccess(ArrayList<ProjectItem> items)
		{	    	
	      	ProjectItems projectItems = new ProjectItems();	      	
	      	projectItems.setItems(items);	      	
	      	currentUser.setProjectItems(projectItems);
	      	ctx.setCurrentUser(currentUser);	      	
	      	createComponents();
	      }
	  };
	
	//Create the display components
	private void createComponents()
	{
		hlBack = new Anchor("<<back");
		hlBack.addClickHandler(this);
		lblTextArea = new Label();
		lblProjectsText = new Label();
		lblListBox = new Label();
		lblMessage = new Label();
		txtUsernames = new TextArea();
		btnCreate = new Button("Create");
		lstUsertype = new ListBox();
		lstUsertype.addItem("User");
		lstUsertype.addItem("Admin");
		
		btnAdd = new Button(">>");
		btnAdd.addClickHandler(this);
		btnRemove = new Button("<<");
		btnRemove.addClickHandler(this);
		
		VerticalPanel buttonPanel = new VerticalPanel();
		buttonPanel.add(btnAdd);
		buttonPanel.add(new HTML("<br>"));
		buttonPanel.add(btnRemove);
		
		lstProjects = new ListBox(true);
		lstProjects.setWidth("100px");
		lstProjects.setHeight("180px");
				
		ProjectItems projectItems = currentUser.getProjectItems();
		Log.info("Number of projects: " + projectItems.getProjectItemCount());
		for(int i = 0; i < projectItems.getProjectItemCount(); i++)
		{
			ProjectItem item = projectItems.getProjectItem(i);
			lstProjects.addItem(item.getProjectName(), String.valueOf(item.getProjectId()));						
		}
		
		lstSelectedProjects = new ListBox(true);
		lstSelectedProjects.setWidth("100px");
		lstSelectedProjects.setHeight("180px");
		
		btnCreate.addClickHandler(this);
		txtUsernames.setWidth("200px");
		txtUsernames.setVisibleLines(10);
		lblTextArea.setText("List of Usernames: ");
		lblListBox.setText("Usertype: ");
		lblProjectsText.setText("Projects: ");
		
		lblMessage.setStyleName("warnings");
		
		vPanel.add(lblMessage);
		vPanel.add(hlBack);
		vPanel.add(table);
				
	    table.getCellFormatter().setHorizontalAlignment(1, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(1, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(1, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(1, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(2, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(2, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(2, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(2, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(3, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(3, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    
	    table.getCellFormatter().setHorizontalAlignment(1, 2, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(1, 2, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(1, 3, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(1, 3, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(1, 4, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(1, 4, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(1, 5, HasHorizontalAlignment.ALIGN_CENTER);
	    table.getCellFormatter().setVerticalAlignment(1, 5, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(1, 6, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(1, 6, HasVerticalAlignment.ALIGN_MIDDLE);
				
		table.setWidget(1, 0, lblTextArea);
		table.setWidget(1, 1, txtUsernames);
		table.setWidget(1, 2, new HTML("&nbsp;&nbsp;&nbsp;"));
		table.setWidget(1, 3, lblProjectsText);
		table.setWidget(1, 4, lstProjects);
		table.setWidget(1, 5, buttonPanel);
		table.setWidget(1, 6, lstSelectedProjects);
		table.setWidget(2, 0, lblListBox);
		table.setWidget(2, 1, lstUsertype);
		table.setWidget(3, 1, btnCreate);
	}

	
	public void onClick(ClickEvent event) 
	{
		Widget source = (Widget) event.getSource();
		if(source == btnCreate)
		{
			String usernamesText = txtUsernames.getText();				
			String[] usernames = usernamesText.split("\n");
			
			/* Check validity of usernames */
			//String[] usernamesTemp = usernames.clone();
			int userCount = usernames.length;
			boolean validUsers = true;
			//String usernameRegex = "^[a-z][-a-z0-9_]*$";
			//String usernameRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
			String usernameRegex = "^[a-z][-a-z0-9_.]*+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
			//String usernameRegex = "^[a-z][-a-z0-9_]*+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
			for(int i = 0; i < userCount; i++)
			{
				String username = usernames[i].trim();
				if(username.length() > 0)
				{
					if(!username.matches(usernameRegex))
					{
						validUsers = false;
						System.out.println("User: " + username + " validUsers: " + validUsers);
						break;
					}					
				}				
			}
			System.out.println(" validUsers: " + validUsers);
			/* End - Check validity of usernames */
			
			if(validUsers)
			{
				//Get the list of projects the users are subscribed to.
				HashMap<Integer, String> subscribedProjectsMap = new HashMap<Integer, String>();
				for(int i = 0; i < lstSelectedProjects.getItemCount(); i++)
				{
					String project = lstSelectedProjects.getItemText(i);
					String value = lstSelectedProjects.getValue(i);
					try
					{
						subscribedProjectsMap.put(Integer.parseInt(value), project);
					}
					catch(NumberFormatException e)
					{
						e.printStackTrace();
					}				
				}			
				
				//Send the add request to the server side
				AddUsersServiceAsync service = AddUsersService.Util.getInstance();
				int status = 1;
				service.addUsers(status, usernames, lstUsertype.getItemText(lstUsertype.getSelectedIndex()), subscribedProjectsMap, addUsersCallback);				
			}
			else
			{
				lblMessage.setText("Please enter valid email address for each user.");
			}
		}	
		if(source == btnAdd)
		{
			int count = lstProjects.getItemCount();
			int initCount = count;
			int temp = 0;
			int i = 0;
			//while(count > 0)
			while(initCount > temp)
			{
				Log.info(" Project: " + lstProjects.getItemCount() + " " + lstProjects.getItemText(0) + " i: " + i);
				String project = lstProjects.getItemText(i);
				String value = lstProjects.getValue(i);
				Log.info("i: " + i + " Project: " + project + " Value: " + value + " Selected: " + lstProjects.isItemSelected(i));
				if(lstProjects.isItemSelected(i))
				{
					/*String project = lstProjects.getItemText(i);
					String value = lstProjects.getValue(i);*/
					lstSelectedProjects.addItem(project, value);
					lstProjects.removeItem(i);
					count--;					
				}
				else
				{
					i++;
				}
				temp++;
			}
			/*for(int i = 0; i < count; i++)
			{
				String project = lstProjects.getItemText(i);
				String value = lstProjects.getValue(i);
				Log.info("i: " + i + " Project: " + project + " Value: " + value + " Selected: " + lstProjects.isItemSelected(i));
				if(lstProjects.isItemSelected(i))
				{
					String project = lstProjects.getItemText(i);
					String value = lstProjects.getValue(i);
					lstSelectedProjects.addItem(project, value);
					lstProjects.removeItem(i);
					count--;
				}
			}*/
		}
		if(source == btnRemove)
		{
			int count = lstSelectedProjects.getItemCount();
			int initCount = count;
			int temp = 0;
			int i = 0;
			//while(count > 0)
			while(initCount > temp)
			{
				String project = lstSelectedProjects.getItemText(i);
				String value = lstSelectedProjects.getValue(i);
				Log.info("i: " + i + " Project: " + project + " Value: " + value + " Selected: " + lstSelectedProjects.isItemSelected(i));
				if(lstSelectedProjects.isItemSelected(i))
				{					
					lstProjects.addItem(project, value);
					lstSelectedProjects.removeItem(i);
					count--;
				}
				else
				{
					i++;
				}
			}
			/*for(int i = 0; i < count; i++)
			{
				if(lstSelectedProjects.isItemSelected(i))
				{
					String project = lstSelectedProjects.getItemText(i);
					String value = lstSelectedProjects.getValue(i);
					lstProjects.addItem(project, value);
					lstSelectedProjects.removeItem(i);
					count--;
				}
			}*/
		}
		if(source == hlBack)
		{
			History.newItem("userList");			
			/*RootPanel.get("content").clear();
			AdminPage adminPage = new AdminPage(2);
			RootPanel.get("content").add(adminPage);*/
			/*if(currentUser.getUsertype().equalsIgnoreCase("user"))
			{
				UserPage userPage = new UserPage(tab);
				RootPanel.get("content").add(userPage);
			}
			else
			{
				AdminPage adminPage = new AdminPage(2);
				RootPanel.get("content").add(adminPage);
			}*/
		}
	}	
	
	//Callback from the server - Display's the message whether all the users are created or if there is any trouble in creating users.
	AsyncCallback<ArrayList<String>> addUsersCallback = new AsyncCallback<ArrayList<String>>()
	{		
		public void onFailure(Throwable arg0) {
			Log.info("AddUsers addUsersCallback error: " + arg0.toString());			
			lblMessage.setText("");
			lblMessage.setText("Error in creating users.");		
		}		
		public void onSuccess(ArrayList<String> errorUsers)
		{
			if(errorUsers.size() == 0)
			{
				lblMessage.setText("All the listed usernames are created.");
				txtUsernames.setText("");
			}
			else
			{
				String errorUsernames = "";
				for(int i = 0; i < errorUsers.size(); i++)
				{
					if((i + 1) == errorUsers.size())
					{
						errorUsernames = errorUsernames + errorUsers.get(i);
					}
					else if((i + 1) < errorUsers.size())
					{
						errorUsernames = errorUsernames + errorUsers.get(i) + ", ";
					}					
				}
				lblMessage.setText("Error in creating " + errorUsers.size()  + " users. Usernames not created: " + errorUsernames +".");
			}
			//Request to get list of all users
			GetUsersServiceAsync service = GetUsersService.Util.getInstance();			
			service.getUsers(usersCallback);
		}
	};
	
	//Callback from server - To set the list of users enrolled in the web application
	AsyncCallback<ArrayList<User>> usersCallback = new AsyncCallback<ArrayList<User>>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("AddUsers usersCallback error: " +  arg0.toString());				
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
				}
			}			
		}
	};
}
