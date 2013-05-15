/*
 * File: UserList.java

Purpose: Java class to display a list of Users (Used for user logged in as an Administrator)
**********************************************************/
package com.wcrl.web.cml.client.admin.account;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.cell.client.CheckboxCell;
import com.google.gwt.cell.client.TextCell;
import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.event.dom.client.ChangeEvent;
import com.google.gwt.event.dom.client.ChangeHandler;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.safehtml.shared.SafeHtmlUtils;
import com.google.gwt.user.cellview.client.CellTable;
import com.google.gwt.user.cellview.client.Column;
import com.google.gwt.user.cellview.client.SimplePager;
import com.google.gwt.user.cellview.client.ColumnSortEvent.ListHandler;
import com.google.gwt.user.cellview.client.SimplePager.TextLocation;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FormPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.google.gwt.user.client.ui.FormPanel.SubmitCompleteEvent;
import com.google.gwt.user.client.ui.FormPanel.SubmitEvent;
import com.google.gwt.view.client.CellPreviewEvent;
import com.google.gwt.view.client.DefaultSelectionEventManager;
import com.google.gwt.view.client.ListDataProvider;
import com.google.gwt.view.client.MultiSelectionModel;
import com.google.gwt.view.client.SelectionModel;
import com.google.gwt.view.client.CellPreviewEvent.Handler;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.accountService.DeleteUsersService;
import com.wcrl.web.cml.client.admin.accountService.DeleteUsersServiceAsync;
import com.wcrl.web.cml.client.admin.accountService.DisableUsersService;
import com.wcrl.web.cml.client.admin.accountService.DisableUsersServiceAsync;
import com.wcrl.web.cml.client.admin.accountService.GetUsersService;
import com.wcrl.web.cml.client.admin.accountService.GetUsersServiceAsync;
import com.wcrl.web.cml.client.admin.accountService.SaveandDownloadUserListFileService;
import com.wcrl.web.cml.client.admin.accountService.SaveandDownloadUserListFileServiceAsync;
import com.wcrl.web.cml.client.custom.CustomSimplePager;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.user.accountService.ResetPasswordAndSendEmailService;
import com.wcrl.web.cml.client.user.accountService.ResetPasswordAndSendEmailServiceAsync;

public class UserList extends Composite implements ClickHandler, ChangeHandler
{
	private static String DOWNLOAD_ACTION_URL = GWT.getModuleBaseURL() + "downloadUserListFile";
	private ClientContext ctx;
	private User currentUser;
	private VerticalPanel vPanel;
	private CellTable<User> table;
	private CustomSimplePager pager;
	private CustomSimplePager topPager;
	private ListDataProvider<User> dataProvider = new ListDataProvider<User>();
	private final SelectionModel<User> selectionModel = new MultiSelectionModel<User>();
	private List<User> list;
	private HorizontalPanel linksPanel;
	private Anchor hlAll;
	private Anchor hlNone;
	private Label lblMsg;
	private HorizontalPanel buttonPanel;
	private Button btnSendEmail;	
	private Button btnDownloadUserList;
	private Button btnDisable;
	private Button btnDelete;
	private UserItems userItems;
	private final int PAGE_COUNT = 25;
	private int tab;
	private Button btnAddUsers;
	private ListBox lstStatus;
	private int userListStatus;
	
	//Get the current user context and send a request to the server for a list of registered users
	//public UserList(int tab)
	public UserList(int status)
	{
		this.tab = 1;
		this.userListStatus = status;
		vPanel = new VerticalPanel();
		initWidget(vPanel);
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{
			ctx = (ClientContext) RPCClientContext.get();			
		    if(ctx != null)
		    {
		       	currentUser = ctx.getCurrentUser();
		       	if(currentUser != null)
		       	{	       		
		       		GetUsersServiceAsync service = GetUsersService.Util.getInstance();			
					service.getUsers(usersCallback);    		
		       	}
		    }
			else
		   	{
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
	
	/*//Callback to receive the list of registered users and set the users to the usersList
	AsyncCallback<ArrayList<User>> usersCallback = new AsyncCallback<ArrayList<User>>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("UserList usersCallback error: " + arg0.toString());				
		}		
		public void onSuccess(ArrayList<User> users)
		{
			if(ctx != null)
			{
				User currentUser = ctx.getCurrentUser();
				if(users != null)
				{
					userItems = new UserItems();
					userItems.setUserItems(users);
					currentUser.setUserItems(userItems);		
					ctx.setCurrentUser(currentUser);
					createComponents();
				}				
			}			
		}
	};*/
	
	//Callback to receive the list of registered users and set the users to the usersList
	AsyncCallback<ArrayList<User>> usersCallback = new AsyncCallback<ArrayList<User>>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("UserList usersCallback error: " + arg0.toString());				
		}		
		public void onSuccess(ArrayList<User> users)
		{
			if(ctx != null)
			{
				User currentUser = ctx.getCurrentUser();
				
				if(users != null)
				{
					userItems = new UserItems();
					if(userListStatus == 0)
					{						
						userItems.setUserItems(users);						
					}
					else if(userListStatus == 1)
					{
						ArrayList<User> filteredUsers = new ArrayList<User>();
						for(User user : users)
						{
							if(user.getStatus() != 2)
							{
								filteredUsers.add(user);
							}
						}
						userItems.setUserItems(filteredUsers);
					}
					else if(userListStatus == 2)
					{
						ArrayList<User> filteredUsers = new ArrayList<User>();
						for(User user : users)
						{
							if(user.getStatus() == 2)
							{
								filteredUsers.add(user);
							}
						}
						userItems.setUserItems(filteredUsers);
					}
					currentUser.setUserItems(userItems);		
					ctx.setCurrentUser(currentUser);
					createComponents();
				}				
			}			
		}
	};
	
	//Create components to display
	private void createComponents()
	{	
		vPanel.setHorizontalAlignment(HorizontalPanel.ALIGN_LEFT);
	    vPanel.setVerticalAlignment(VerticalPanel.ALIGN_TOP);
		
		lblMsg = new Label();
		lstStatus = new ListBox();
		btnAddUsers = new Button("Add users");
		btnAddUsers.addClickHandler(this);
		linksPanel = new HorizontalPanel();		
		hlAll = new Anchor("All");
		hlNone = new Anchor("None");
		hlAll.addClickHandler(this);
		hlNone.addClickHandler(this);
		
		lstStatus.addItem("All", "0");
		lstStatus.addItem("Enabled", "1");
		lstStatus.addItem("Disabled", "2");
		if(userListStatus == 0)
		{
			lstStatus.setItemSelected(0, true);
		}
		else
		{
			if(userListStatus == 1)
			{
				lstStatus.setItemSelected(1, true);
			}			
			else
			{
				lstStatus.setItemSelected(2, true);
			}
		}
			
		
		lstStatus.addChangeHandler(this);
		
		linksPanel.add(hlAll);
		HTML seperator = new HTML(", &nbsp;");
   		//seperator.addStyleName("normalText");
		linksPanel.add(seperator);
		linksPanel.add(hlNone);
		
		buttonPanel = new HorizontalPanel();
		btnSendEmail = new Button("Reset password and Email");
		btnDisable = new Button("Disable");
		btnDelete = new Button("Delete");
		btnDownloadUserList = new Button("Export users"); 
		
		buttonPanel.add(btnSendEmail);
		buttonPanel.add(btnDisable);
		buttonPanel.add(btnDelete);
		buttonPanel.add(btnAddUsers);
		buttonPanel.add(btnDownloadUserList);
		
		buttonPanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
		buttonPanel.add(lstStatus);
				
		btnSendEmail.addClickHandler(this);
		btnDisable.addClickHandler(this);
		btnDelete.addClickHandler(this);
		btnDownloadUserList.addClickHandler(this);
				
		lblMsg.addStyleName("warnings");
   		
		vPanel.setSize("100%", "100%");
   		table = (CellTable<User>) onInitialize();
   		table.setStyleName("hand");
   		vPanel.add(lblMsg);
   		vPanel.add(buttonPanel);
   		vPanel.add(new HTML("<br>"));
   		vPanel.add(linksPanel);
   		VerticalPanel panel = new VerticalPanel();
   		panel.setSize("100%", "100%");
   		panel.add(topPager);
		panel.add(table);
		panel.add(pager);
		panel.setCellHorizontalAlignment(topPager, HasHorizontalAlignment.ALIGN_CENTER);
		panel.setCellHorizontalAlignment(pager, HasHorizontalAlignment.ALIGN_CENTER);
		vPanel.add(panel);
		vPanel.setCellHorizontalAlignment(panel, HasHorizontalAlignment.ALIGN_LEFT);
		vPanel.setCellVerticalAlignment(panel, HasVerticalAlignment.ALIGN_TOP);				
	}
	
	public void onChange(ChangeEvent event) 
	{
		Widget sender = (Widget) event.getSource();
		
		if(sender == lstStatus)
		{
			userListStatus = lstStatus.getSelectedIndex();			
			GetUsersServiceAsync service = GetUsersService.Util.getInstance();			
			service.getUsers(updateUserListCallback);					
		}
	}
	
	AsyncCallback<ArrayList<User>> updateUserListCallback = new AsyncCallback<ArrayList<User>>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("UserList updateUserListCallback error: " + arg0.toString());				
		}		
		public void onSuccess(ArrayList<User> users)
		{
			if(ctx != null)
			{
				User currentUser = ctx.getCurrentUser();
				
				if(users != null)
				{
					userItems = new UserItems();
					if(userListStatus == 0)
					{						
						userItems.setUserItems(users);	
						dataProvider.setList(users);
					}
					else if(userListStatus == 1)
					{
						ArrayList<User> filteredUsers = new ArrayList<User>();
						for(User user : users)
						{
							if(user.getStatus() != 2)
							{
								filteredUsers.add(user);
							}
						}
						userItems.setUserItems(filteredUsers);
						dataProvider.setList(filteredUsers);
					}
					else if(userListStatus == 2)
					{
						ArrayList<User> filteredUsers = new ArrayList<User>();
						for(User user : users)
						{
							if(user.getStatus() == 2)
							{
								filteredUsers.add(user);
							}
						}
						userItems.setUserItems(filteredUsers);
						dataProvider.setList(filteredUsers);
					}
					currentUser.setUserItems(userItems);		
					ctx.setCurrentUser(currentUser);					
				}				
			}			
		}
	};
			
	//Handle the button clicks
	public void onClick(ClickEvent event) 
	{		
		Widget sender = (Widget) event.getSource();
		
		if(sender == hlAll)
		{
			List<User> lst = dataProvider.getList();
			for(int i = 0; i < lst.size(); i++)
			{
				User item = lst.get(i);
				selectionModel.setSelected(item, true);
			}		
		}
		
		if(sender == hlNone)
		{
			List<User> lst = dataProvider.getList();
			for(int i = 0; i < lst.size(); i++)
			{
				User item = lst.get(i);
				selectionModel.setSelected(item, false);
			}
		}
		
		if(sender == btnAddUsers)
		{
			History.newItem("addUsers");/*
			AddUsers addUsers = new AddUsers();
			RootPanel.get("content").clear();
			RootPanel.get("content").add(addUsers);*/
		}
			
		//Send a request to the server to send email with a list of users
		if(sender == btnSendEmail)
		{
			ArrayList<Integer> emailUsers = getUsers();
			ResetPasswordAndSendEmailServiceAsync service = ResetPasswordAndSendEmailService.Util.getInstance();
			service.resetAndSendEmail(emailUsers, resetSendEmailCallback);
		}
		
		if(sender == btnDownloadUserList)
		{
			ArrayList<User> users = getUserList();			
			if(users.size() > 0)
			{
				SaveandDownloadUserListFileServiceAsync service = SaveandDownloadUserListFileService.Util.getInstance();
				service.saveandDownloadUserListFile(users, downloadUserListCallback);				
			}			
		}
		
		//Send a request to the server to disable users
		if(sender == btnDisable)
		{
			ArrayList<Integer> disableUsers = getUsers();
			Log.info("Disable button - Item count: " + disableUsers.size());
			if(disableUsers.size() > 0)
			{
				if(Window.confirm("Are you sure you want to disable the selected users?"))
				{
					DisableUsersServiceAsync service = DisableUsersService.Util.getInstance();
					service.disableUsers(disableUsers, disableUsersCallback);
				}
			}			
		}	
		
		//Send a request to the server to delete users
		if(sender == btnDelete)
		{
			HashMap<Integer, String> deleteUsers = getDeleteUserList();
			Log.info("Delete button - Item count: " + deleteUsers.size());
			if(deleteUsers.size() > 0)
			{
				if(Window.confirm("Are you sure you want to delete the selected users?"))
				{
					DeleteUsersServiceAsync service = DeleteUsersService.Util.getInstance();
					service.deleteUsers(deleteUsers, deleteUsersCallback);
				}
			}			
		}
	}
	
	//Get a list of selected users
	 private ArrayList<User> getUserList() 
	 {
		 ArrayList<User> users = new ArrayList<User>();
		 List<User> lst = dataProvider.getList();
		 for(int i = 0; i < lst.size(); i++)
		 {
				User item = lst.get(i);
				boolean selected = selectionModel.isSelected(item);
				//Log.info("User: " + item.getUserId() + " Checked: " + selected);
				if (selected) 
				{				
					users.add(item);					
	            }
		 }			
		return users;
	}
	
	//Get a list of selected users
	 private ArrayList<Integer> getUsers() 
	 {
		 ArrayList<Integer> disableUsers = new ArrayList<Integer>();
		 List<User> lst = dataProvider.getList();
		 for(int i = 0; i < lst.size(); i++)
		 {
				User item = lst.get(i);
				boolean selected = selectionModel.isSelected(item);
				//Log.info("User: " + item.getUserId() + " Checked: " + selected);
				if (selected) 
				{				
					disableUsers.add(item.getUserId());					
	            }
		 }			
		return disableUsers;
	}
	 
	//Get a list of selected users
	 private HashMap<Integer, String> getDeleteUserList() 
	 {
		 HashMap<Integer, String> deleteUsers = new HashMap<Integer, String>();
		 List<User> lst = dataProvider.getList();
		 for(int i = 0; i < lst.size(); i++)
		 {
				User item = lst.get(i);
				boolean selected = selectionModel.isSelected(item);
				//Log.info("User: " + item.getUserId() + " Checked: " + selected);
				if (selected) 
				{			
					deleteUsers.put(item.getUserId(), item.getUsername());
	            }
		 }			
		return deleteUsers;
	}

	 //Initialize the CellTable
	public CellTable<User> onInitialize()
	{
		table = new CellTable<User>();
		table.setWidth("100%", true);
		table.setPageSize(PAGE_COUNT);
		table.addCellPreviewHandler(new Handler<User>()
		{
			public void onCellPreview(CellPreviewEvent<User> event)
			{
				boolean isClick = "click".equals(event.getNativeEvent().getType());
				User user = event.getValue();
				if(isClick && (event.getColumn() != 0))
				{
					//Log.info("OnCellPreview: " + user);
					if (user == null)
					{
						return;
					}
					user.setAdminUser(currentUser);
					System.out.println("UserList: going to user: " + user.getUserId() + " from tab: " + tab + "  and user is of type: " + user.getUsertype());
					UserDetails editUser = new UserDetails(user, tab, userListStatus);
					RootPanel.get("content").clear();
					RootPanel.get("content").add(editUser);
					/*RPCClientContext.set(new ClientContext());
					ctx = (ClientContext)RPCClientContext.get();
					ctx.setCurrentUser(user);
					RootPanel.get("header").clear();
					RootPanel.get("leftnav").clear();
					RootPanel.get("footer").clear();
					RootPanel.get("content").clear();
					UserTopPanel topPanel = new UserTopPanel();
					UserBottomPanel bottomPanel = new UserBottomPanel();					
					RootPanel.get("header").add(topPanel);
					RootPanel.get("footer").add(bottomPanel);
					UserPage userPage = new UserPage();
					RootPanel.get("content").add(userPage);*/
				}
			}
		});
		// Connect the table to the data provider.
	    dataProvider.addDataDisplay(table);
	    
	    list = dataProvider.getList();
	   
	    for(User item : userItems.getUserItems())
	    {	    	
	    	list.add(item);
	    }

	    // Add a ColumnSortEvent.ListHandler to connect sorting to the java.util.List.
	    // Attach a column sort handler to the ListDataProvider to sort the list.
	    ListHandler<User> sortHandler = new ListHandler<User>(list);	   
	    table.addColumnSortHandler(sortHandler);

	    // Create a Pager to control the table.
	    SimplePager.Resources pagerResources = GWT.create(SimplePager.Resources.class);
	    pager = new CustomSimplePager(PAGE_COUNT, TextLocation.CENTER, pagerResources, false, 0, true);
	    pager.setDisplay(table);
	    
	    topPager = new CustomSimplePager(PAGE_COUNT, TextLocation.CENTER, pagerResources, false, 0, true);
	    topPager.setDisplay(table);
	    
	    // Add a selection model so we can select cells.	    
	    table.setSelectionModel(selectionModel, DefaultSelectionEventManager.<User> createCheckboxManager());

	    // Initialize the columns.
	    initTableColumns(selectionModel, sortHandler);
	    
		return table;		    
	}
	
	  /**
	   * Add the columns to the table.
	   */
	  private void initTableColumns(final SelectionModel<User> selectionModel, ListHandler<User> sortHandler)	 
	  {	    
	    Column<User, Boolean> checkColumn = new Column<User, Boolean>(new CheckboxCell(true, false)) 
	    {
	      public Boolean getValue(User object) 
	      {
	        // Get the value from the selection model.
	        return selectionModel.isSelected(object);
	      }	      
	    };
	    
	    table.addColumn(checkColumn, SafeHtmlUtils.fromSafeConstant("<br/>"));
	    //table.addColumn(checkColumn);
	    table.setColumnWidth(checkColumn, 5, Unit.PCT);
	    
	    // UserId
	    Column<User, String> userIdColumn = new Column<User, String>(new TextCell()) 
	    {	    
	      public String getValue(User item) 
	      {
	        return Integer.valueOf(item.getUserId()).toString();
	      }
	    };
	    userIdColumn.setSortable(true);
	    sortHandler.setComparator(userIdColumn, new Comparator<User>() {
	      public int compare(User o1, User o2) 
	      {
	    	  int userId1 = o1.getUserId();
	    	  int userId2 = o2.getUserId();
	    	  
	    	  if(userId1 > userId2)
            	return 1;
            else if(userId1 < userId2)
            	return -1;
            else
            	return 0;
	      }
	    });
	    table.addColumn(userIdColumn, "Userid");	    
	    table.setColumnWidth(userIdColumn, 20, Unit.PCT);

	    // Username.
	    Column<User, String> userNameColumn = new Column<User, String>(new TextCell()) 
	    {	    
	      public String getValue(User object) {
	        return object.getUsername();
	      }
	    };
	    userNameColumn.setSortable(true);
	    sortHandler.setComparator(userNameColumn, new Comparator<User>() 
	    {
	      public int compare(User o1, User o2) 
	      {
	        return o1.getUsername().compareTo(o2.getUsername());
	      }
	    });
	    table.addColumn(userNameColumn, "Username");	    
	    table.setColumnWidth(userNameColumn, 30, Unit.PCT);
	    
	    // Category
	    Column<User, String> usertypeColumn = new Column<User, String>(new TextCell()) 
	    {	    
	      public String getValue(User object) 
	      {
	        return object.getUsertype();
	      }
	    };
	    usertypeColumn.setSortable(true);
	    usertypeColumn.setSortable(true);
	    sortHandler.setComparator(usertypeColumn, new Comparator<User>() 
	    {
	      public int compare(User o1, User o2) 
	      {
	        return o1.getUsertype().compareTo(o2.getUsertype());
	      }
	    });
	    table.addColumn(usertypeColumn, "Usertype");
	    table.setColumnWidth(usertypeColumn, 20, Unit.PCT);
	    
	   // Status
	    Column<User, String> statusColumn = new Column<User, String>(new TextCell()) 
	    {	    
	      public String getValue(User object) 
	      {
	    	  int value = object.getStatus();
	    	  String status = "";
	    	  if(value == 1)
	    	  {
	    		  status = "Enabled";
	    	  }
	    	  else if(value == 0)
	    	  {
	    		  status = "Not approved";
	    	  }
	    	  else if(value == 2)
	    	  {
	    		  status = "Disabled";
	    	  }
	        return status;
	      }
	    };
	    statusColumn.setSortable(true);	   
	    sortHandler.setComparator(statusColumn, new Comparator<User>() 
	    {
	    	public int compare(User o1, User o2) 
		      {
		    	  int status1 = o1.getStatus();
		    	  int status2 = o2.getStatus();
		    	  
		    	  if(status1 > status2)
	            	return 1;
	            else if(status1 < status2)
	            	return -1;
	            else
	            	return 0;
		      }
	    });
	    table.addColumn(statusColumn, "Status");
	    table.setColumnWidth(statusColumn, 25, Unit.PCT);	    
	  }
	
	  //Call back of send email request
	AsyncCallback<Boolean> resetSendEmailCallback = new AsyncCallback<Boolean>()
	{
		public void onFailure(Throwable caught)
		{
			Log.info("UserList resetSendEmailCallback error: "+ caught.toString());
		}
		public void onSuccess(Boolean result)
		{
			if(result == true)
			{
				List<User> lst = dataProvider.getList();
				for(int i = 0; i < lst.size(); i++)
				{
					User item = lst.get(i);
					boolean selected = selectionModel.isSelected(item);
					//Log.info("User: " + item.getUserId() + " Checked: " + selected);
					if (selected)
					{
						selectionModel.setSelected(item, false);
					}
				}	
				lblMsg.setText("Email sent to the selected users.");				
			}			
		}
	};
	
	//Call back of disable users - Updates the list (Table display) with users disabled 
	AsyncCallback<ArrayList<Integer>> disableUsersCallback = new AsyncCallback<ArrayList<Integer>>()
	{
		public void onFailure(Throwable caught)
		{
			Log.info("UserList disableUsersCallback error: " + caught.toString());
		}
		public void onSuccess(ArrayList<Integer> userIds)
		{
			User currentUser = ctx.getCurrentUser();
			UserItems useritems = currentUser.getUserItems();
			
			if(userIds != null)
			{
				if(userIds.size() > 0)
				{
					List<User> userList = dataProvider.getList();
					Iterator<User> itr = userList.iterator();
					int index = 0;
					lblMsg.setText("All the selected users are disabled.");
					for(int cnt  =  0; cnt < userIds.size(); cnt++)
					{
						int userId = userIds.get(cnt);
						// useritems.deleteUser(userId);
						
						userList = dataProvider.getList();
						itr = userList.iterator();
						index = 0;
						
						while(itr.hasNext())
						{
							User user = itr.next();
							if(user.getUserId() == userId)
							{
								user.setStatus(2);
								if(selectionModel.isSelected(user))
								{
									selectionModel.setSelected(user, false);
								}
								dataProvider.getList().set(index, user);
								break;
							}
							index = index + 1;
						}
						//dataProvider.getList().remove(index);					
					}
					dataProvider.refresh();					
					currentUser.setUserItems(useritems);
					ctx.setCurrentUser(currentUser);
				}
				else
				{
					lblMsg.setText("Error in disabling selected users. Please try again later.");
				}				
			}						
		}
	};
	
	//Call back of delete users - Updates the list (Table display) with users deleted 
	AsyncCallback<ArrayList<Integer>> deleteUsersCallback = new AsyncCallback<ArrayList<Integer>>()
	{
		public void onFailure(Throwable caught)
		{
			Log.info("UserList deleteUsersCallback error: " + caught.toString());
		}
		public void onSuccess(ArrayList<Integer> userIds)
		{
			User currentUser = ctx.getCurrentUser();
			UserItems useritems = currentUser.getUserItems();
			
			if(userIds != null)
			{
				if(userIds.size() > 0)
				{
					List<User> userList = dataProvider.getList();
					Iterator<User> itr = userList.iterator();
					int index = 0;
					lblMsg.setText("All the selected users are deleted.");
					for(int cnt  =  0; cnt < userIds.size(); cnt++)
					{
						int userId = userIds.get(cnt);
						useritems.deleteUser(userId);
						
						userList = dataProvider.getList();
						itr = userList.iterator();
						index = 0;
						
						while(itr.hasNext())
						{
							User user = itr.next();
							if(user.getUserId() == userId)
							{								
								dataProvider.getList().remove(index);
								break;
							}
							index = index + 1;
						}
						//dataProvider.getList().remove(index);					
					}
					dataProvider.refresh();					
					currentUser.setUserItems(useritems);
					ctx.setCurrentUser(currentUser);
				}
				else
				{
					lblMsg.setText("Error in deleting selected users. Please try again later.");
				}				
			}						
		}
	};
	
	AsyncCallback<Boolean> downloadUserListCallback = new AsyncCallback<Boolean>()
	{
		public void onFailure(Throwable caught)
		{
			Log.info("UserList downloadUsersCallback error: " + caught.toString());
		}
		public void onSuccess(Boolean value)
		{
			if(value)
			{
				System.out.println("In form");
				FormPanel form = new FormPanel();
				form.setAction(DOWNLOAD_ACTION_URL);
				form.setEncoding(FormPanel.ENCODING_MULTIPART);
				form.setMethod(FormPanel.METHOD_POST);
				vPanel.add(form);
				form.submit();
				form.addSubmitHandler(new FormPanel.SubmitHandler() 
		        {
		        	public void onSubmit(SubmitEvent event) 
		        	{
		        		
		        	}
		        });
				form.addSubmitCompleteHandler(new FormPanel.SubmitCompleteHandler() 
		        {
		            public void onSubmitComplete(SubmitCompleteEvent event) 
		            {
		            	 List<User> lst = dataProvider.getList();
		        		 for(int i = 0; i < lst.size(); i++)
		        		 {
		        			 User item = lst.get(i);
		        			 boolean selected = selectionModel.isSelected(item);
		        			 if (selected)
		        			 {
		        				 selectionModel.setSelected(item, false);
		        			 }
		        		 }	
		            }
		        });
			}
		}
	};
}