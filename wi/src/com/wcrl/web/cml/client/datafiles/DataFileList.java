/*
 * File: JobList.java

Purpose: Java class to display a list of Jobs of all the users (Used for user logged in as an Administrator)
**********************************************************/
package com.wcrl.web.cml.client.datafiles;

import java.util.ArrayList;
import java.util.Date;
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
import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.safehtml.shared.SafeHtmlUtils;
import com.google.gwt.user.cellview.client.CellTable;
import com.google.gwt.user.cellview.client.Column;
import com.google.gwt.user.cellview.client.ColumnSortList;
import com.google.gwt.user.cellview.client.ColumnSortEvent.AsyncHandler;
import com.google.gwt.user.cellview.client.SimplePager;
import com.google.gwt.user.cellview.client.SimplePager.TextLocation;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.google.gwt.view.client.CellPreviewEvent;
import com.google.gwt.view.client.CellPreviewEvent.Handler;
import com.google.gwt.view.client.AsyncDataProvider;
import com.google.gwt.view.client.DefaultSelectionEventManager;
import com.google.gwt.view.client.HasData;
import com.google.gwt.view.client.MultiSelectionModel;
import com.google.gwt.view.client.SelectionModel;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.account.UserItems;
import com.wcrl.web.cml.client.admin.accountService.GetUsersService;
import com.wcrl.web.cml.client.admin.accountService.GetUsersServiceAsync;
import com.wcrl.web.cml.client.custom.CustomSimplePager;
import com.wcrl.web.cml.client.custom.FormatDate;
import com.wcrl.web.cml.client.data.filesService.DeleteDataFilesService;
import com.wcrl.web.cml.client.data.filesService.DeleteDataFilesServiceAsync;
import com.wcrl.web.cml.client.data.filesService.GetDataFilesPageService;
import com.wcrl.web.cml.client.data.filesService.GetDataFilesPageServiceAsync;
import com.wcrl.web.cml.client.data.filesService.GetSubscribedDataProjectListService;
import com.wcrl.web.cml.client.data.filesService.GetSubscribedDataProjectListServiceAsync;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.projects.ProjectItem;

public class DataFileList extends Composite implements ClickHandler, ChangeHandler
{
	private CellTable<DataFileItem> table;
	private CustomSimplePager pager;
	private CustomSimplePager topPager;	
	//Number of files to display in a page
	private int VISIBLE_FILE_COUNT = 2;
	private VerticalPanel vPanel;
	private Label lblMsg;	
	private ClientContext ctx;
	private User currentUser;
	
	private HorizontalPanel linksPanel;
	private Anchor hlAll;
	private Anchor hlNone;
	private Button btnDelete;
	private final SelectionModel<DataFileItem> selectionModel = new MultiSelectionModel<DataFileItem>();
	private ColumnSortList sortList;
	
	private int tab;
	private ListBox lstUsers;
	private ListBox lstProjects;	
	private Button btnAddDataFile;
	
	private int Start;
	private int from;
	private String selectUser;
	private String selectProject;
	private int counter;
	private MyDataProvider dataProvider1;
	
	public DataFileList()
	{	
		String sessionID = Cookies.getCookie("sid");
		vPanel = new VerticalPanel();		
		initWidget(vPanel);
		ctx = (ClientContext) RPCClientContext.get();	
		System.out.println("sessionID: " + sessionID + " ctx: " + ctx); 
		if(sessionID != null)
		{
			 if(ctx != null)
			 {
				 //Set the current user context
				 currentUser = ctx.getCurrentUser();
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
	

	public void refresh(int from, int start, int fromTab, String selectUser, String selectProject)
	{		
		this.selectUser = selectUser;
		this.selectProject = selectProject;
		
		if(fromTab == 4)
		{			
			if(currentUser.getUsertype().equalsIgnoreCase("admin"))
			{
				/* User == admin, requesting to view admin's files */
				this.tab = 0;
			}				
		}
		else if(currentUser.getUsertype().equalsIgnoreCase("user"))
		{
			/* User == user, requesting to view user's files */
			this.tab = 1;
		}
		else if(fromTab == 5)
		{
			/* User == admin, requesting to view files of all the users */
			this.tab = 2;
		}
		
		/* To display files listed in current page or from the beginning */
		this.from = from;
		if(from == 0)
		{
			this.Start = start;
		}
		
		getDataFileList();
	}
	
	
	public void getDataFileList() 
	{			
		ctx = (ClientContext) RPCClientContext.get();	    
	    if(ctx != null)
	    {
	    	currentUser = ctx.getCurrentUser();
	    	if(currentUser != null)
	    	{  		
	    		lblMsg = new Label();
	    		lblMsg.addStyleName("warnings");	

	    		//lstStatus = new ListBox();
	    		lstUsers = new ListBox();
	    		lstProjects = new ListBox();  	      	    
	    	    vPanel.setSize("100%", "100%");
	    	    vPanel.setSpacing(0);
	    	    
	    	    linksPanel = new HorizontalPanel();		
				hlAll = new Anchor("All");
				hlNone = new Anchor("None");
				hlAll.addClickHandler(this);
				hlNone.addClickHandler(this);
				
				linksPanel.add(hlAll);
				HTML seperator = new HTML(", &nbsp;");
				linksPanel.add(seperator);
				linksPanel.add(hlNone);
								
				Log.info("tabNumber: " + tab + " user: " + selectUser + " project: " + selectProject);
				lstUsers.clear();
				lstUsers.addItem("--Users--", "0");
				if(tab == 2)
				{							
					lstUsers.setItemSelected(0, true);
					lstUsers.setVisible(true);
				}
				else
				{
					lstUsers.addItem(currentUser.getUsername(), Integer.valueOf(currentUser.getUserId()).toString());
					lstUsers.setItemSelected(1, true);
					lstUsers.setVisible(false);
				}
				
	    		lstProjects.addItem("--Projects--", "0");
	    			    		
	    		lstUsers.addChangeHandler(this);
	    		lstProjects.addChangeHandler(this);
	    			    		
	    		populateUsersAndProjects();    		     	   	    		
	    	}
	    }
	    else
	    {
	    	Log.info("Ctx null FileList");
			Login login = new Login();
			login.displayLoginBox();
	    }	    		
	 }
	
	private void afterLoadingUsersAndProjects()
	{
		System.out.println("Users: " + lstUsers.getItemCount() + " User: " + lstUsers.getItemText(0) + " Selected: " + lstUsers.getSelectedIndex() + " " + lstUsers.getItemText(lstUsers.getSelectedIndex()) + " Project: " + lstProjects.getItemText(lstProjects.getSelectedIndex()) + " selectProject: " + selectProject);
		
		VerticalPanel panel = new VerticalPanel();
		btnDelete = new Button("Delete");
						
		btnDelete.addClickHandler(this);
		
		panel.setSize("100%", "100%");
		panel.setSpacing(10);
		panel.add(lblMsg);
		//Initialize the CellTable
		table = (CellTable<DataFileItem>) onInitialize();
		table.setStyleName("hand");
		HorizontalPanel topPanel = new HorizontalPanel();
		btnAddDataFile = new Button("Add File");
		btnAddDataFile.addClickHandler(this);
		topPanel.add(btnDelete);

		topPanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
		topPanel.add(btnAddDataFile);
		topPanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
		topPanel.add(lstUsers);
		topPanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
		topPanel.add(lstProjects);
		
		topPanel.setCellHorizontalAlignment(lstUsers, HasHorizontalAlignment.ALIGN_CENTER);
		topPanel.setCellVerticalAlignment(lstUsers, HasVerticalAlignment.ALIGN_MIDDLE);
		topPanel.setCellHorizontalAlignment(lstProjects, HasHorizontalAlignment.ALIGN_CENTER);
		topPanel.setCellVerticalAlignment(lstProjects, HasVerticalAlignment.ALIGN_MIDDLE);
		/*topPanel.setCellHorizontalAlignment(lstStatus, HasHorizontalAlignment.ALIGN_CENTER);
		topPanel.setCellVerticalAlignment(lstStatus, HasVerticalAlignment.ALIGN_MIDDLE);*/
		
		//panel.add(btnDelete);
		panel.add(topPanel);
		panel.add(linksPanel);
		//Add the Pagers (top and bottom) and the CellTable to the panel
		panel.add(topPager);
		panel.add(table);
		panel.add(pager);
		panel.setCellHorizontalAlignment(topPager, HasHorizontalAlignment.ALIGN_CENTER);
		panel.setCellHorizontalAlignment(pager, HasHorizontalAlignment.ALIGN_CENTER);
		vPanel.add(panel);
		vPanel.setCellHorizontalAlignment(panel, HasHorizontalAlignment.ALIGN_LEFT);
		vPanel.setCellVerticalAlignment(panel, HasVerticalAlignment.ALIGN_TOP);  
	}
	
	private void populateUsersAndProjects()
	{
		GetUsersServiceAsync service = GetUsersService.Util.getInstance();			
		service.getUsers(usersCallback);				
	}
	
	AsyncCallback<ArrayList<User>> usersCallback = new AsyncCallback<ArrayList<User>>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("Login usersCallback error: " + arg0.toString());	
		}		
		public void onSuccess(ArrayList<User> systemUsers)
		{
			if(ctx != null)
			{
				User currentUser = ctx.getCurrentUser();
				if(systemUsers != null)
				{
					UserItems userItems = new UserItems();
					userItems.setUserItems(systemUsers);
					currentUser.setUserItems(userItems);
					ctx.setCurrentUser(currentUser);
				}
				System.out.println("In testing 2: " + systemUsers.size());
				
				HashMap<Integer, String> userMap = new HashMap<Integer, String>();				
				if(tab == 2)
				{
					System.out.println("In testing 2");
					UserItems users = currentUser.getUserItems();		
					Iterator<User> userItr = users.getUserItems().iterator();
					while(userItr.hasNext())
					{
						User user = userItr.next();
						int userId = user.getUserId();
						String username = user.getUsername();
						if(!userMap.containsKey(userId))
						{
							userMap.put(userId, username);
							lstUsers.addItem(username, Integer.valueOf(userId).toString());
							if(selectUser.equalsIgnoreCase(username))
							{
								int userCountInList = lstUsers.getItemCount();
								lstUsers.setItemSelected(userCountInList-1, true);
							}
						}
					}
				}
				else
				{
					int userId = currentUser.getUserId();
					String username = currentUser.getUsername();
					
					lstUsers.clear();
					lstUsers.addItem("--Users--", "0");
					lstUsers.addItem(username, Integer.valueOf(userId).toString());
					lstUsers.setItemSelected(1, true);					
				}
				userMap.clear();
								
				GetSubscribedDataProjectListServiceAsync service = GetSubscribedDataProjectListService.Util.getInstance();
				if(tab == 2)
				{			
					service.getSubscribedDataProjectList(0, subscribedProjectsCallback);
				}
				else
				{
					service.getSubscribedDataProjectList(currentUser.getUserId(), subscribedProjectsCallback);
				} 
			}			
		}
	};
		
	AsyncCallback<ArrayList<ProjectItem>> subscribedProjectsCallback = new AsyncCallback<ArrayList<ProjectItem>>()
	{
		public void onFailure(Throwable caught)
		{
			Window.alert(caught.getMessage());
		}
		
		public void onSuccess(ArrayList<ProjectItem> projectList)
		{
			HashMap<Integer, String> projectMap = new HashMap<Integer, String>();
			int count = projectList.size();
			for(int index = 0; index < count; index++)
			{
				ProjectItem project = projectList.get(index);
				int projectId = project.getProjectId();
				String projectName = project.getProjectName();
				if(!projectMap.containsKey(projectId))
				{
					projectMap.put(projectId, projectName);					
					lstProjects.addItem(projectName, Integer.valueOf(projectId).toString());
					System.out.println("Project: " + projectName + " Select: " + selectProject);
					if(selectProject.equalsIgnoreCase(projectName))
					{
						int projectCountInList = lstProjects.getItemCount();
						lstProjects.setItemSelected(projectCountInList-1, true);
						System.out.println("Item selected Project: " + projectName);
					}
				}
			}
			if(lstProjects.getSelectedIndex() == -1)
			{
				lstProjects.setItemSelected(0, true);
			}
			System.out.println("Project selected: " + lstProjects.getItemText(lstProjects.getSelectedIndex()));
			projectMap.clear();
			System.out.println("Number of projects: " + projectList.size() + " users: " + lstUsers.getItemCount());
			Log.info("Number of projects: " + projectList.size() + " users: " + lstUsers.getItemCount());
			afterLoadingUsersAndProjects();
		}
	};
		
	//Initialize the CellTable and set the pager
	public CellTable<DataFileItem> onInitialize()
	{
	    table = new CellTable<DataFileItem>();
	    table.setWidth("100%", true);
	    table.setPageSize(VISIBLE_FILE_COUNT);
	    
	    table.addCellPreviewHandler(new Handler<DataFileItem>()
	    {
	    	//Call the FileDetails page when user clicks on any File in the table
			public void onCellPreview(CellPreviewEvent<DataFileItem> event) 
			{				
				
				boolean isClick = "click".equals(event.getNativeEvent().getType());
				DataFileItem item = event.getValue();				
				if(isClick && (event.getColumn() != 0))
				{
					if (item == null) 
				    {
				    	return;
				    }			    
					ArrayList<String> nameValues = getSelectedUserAndProjectName();
					/*System.out.println("Before going to file details status: " + lstStatus.getItemText(lstStatus.getSelectedIndex()) + " user: " + nameValues.get(0) + " project: " + nameValues.get(1));
					Log.info("Before going to file details status: " + lstStatus.getItemText(lstStatus.getSelectedIndex()) + " user: " + nameValues.get(0) + " project: " + nameValues.get(1));*/
					DataFileDetails fileDetail = new DataFileDetails(item, Start, tab, nameValues.get(0), nameValues.get(1));
				    
				    RootPanel.get("content").clear();
					RootPanel.get("content").add(fileDetail);
				}				
			}	    	
	    });
	    
	    // Create a Pager to control the table.
	    SimplePager.Resources pagerResources = GWT.create(SimplePager.Resources.class);
	    pager = new CustomSimplePager(VISIBLE_FILE_COUNT, TextLocation.CENTER, pagerResources, false, 0, true);
	    pager.setDisplay(table);
	    
	    topPager = new CustomSimplePager(VISIBLE_FILE_COUNT, TextLocation.CENTER, pagerResources, false, 0, true);
	    topPager.setDisplay(table);
	    
	    // Add a selection model to select cells.	    
	    table.setSelectionModel(selectionModel, DefaultSelectionEventManager.<DataFileItem> createCheckboxManager());
	    
	    //ListHandler<JobItem> sortHandler = new ListHandler<JobItem>(new ArrayList<JobItem>());
	    // Initialize the columns.
	    AsyncHandler sortHandler = new AsyncHandler(table);
	    table.addColumnSortHandler(sortHandler);	   
	    initTableColumns(selectionModel, sortHandler);	
	    sortList = table.getColumnSortList();
	    ArrayList<String> nameValues = getSelectedUserAndProjectName();
	    System.out.println("Users: " + lstUsers.getItemCount() + " User: " + lstUsers.getItemText(0) + " Username: " + nameValues.get(0) + " Project: " + nameValues.get(1));

	    // Create a data provider.
	    dataProvider1 = new MyDataProvider();
	    // Add the cellList to the dataProvider.
	    dataProvider1.addDataDisplay(table);	 
	    return table;
	}
	
	public ArrayList<String> getSelectedUserAndProjectName()
	{
		int selectedUserIndex = lstUsers.getSelectedIndex();
		int selectedProjectIndex = lstProjects.getSelectedIndex();
		int selectedUserId = currentUser.getUserId();
		int selectedProjectId = 0;
		
		try
		{
			selectedUserId = Integer.parseInt(lstUsers.getValue(selectedUserIndex));
			selectedProjectId = Integer.parseInt(lstProjects.getValue(selectedProjectIndex));
		}
		catch(NumberFormatException e)
		{
			e.printStackTrace();
		}
		
		String userName = "";
		String projectName = "";
		
		if(selectedProjectId == 0)
		{
			if(selectedUserId == 0)
			{
				userName = "";
				projectName = "";
			}
			else
			{
				userName = lstUsers.getItemText(selectedUserIndex);
				projectName = "";
			}
		}
		else if(selectedProjectId != 0)
		{
			if(selectedUserId == 0)
			{
				userName = "";
				projectName = lstProjects.getItemText(selectedProjectIndex);
			}
			else
			{
				userName = lstUsers.getItemText(selectedUserIndex);
				projectName = lstProjects.getItemText(selectedProjectIndex);					
			}
		}
		ArrayList<String> nameValues = new ArrayList<String>();
		nameValues.add(userName);
		nameValues.add(projectName);
		return nameValues;
	}
	
	 private class MyDataProvider extends AsyncDataProvider<DataFileItem> 
	 {
		 protected void onRangeChanged(HasData<DataFileItem> display)
			{	
				final int start = display.getVisibleRange().getStart();
				int length = display.getVisibleRange().getLength();
				final GetDataFilesPageServiceAsync service = GetDataFilesPageService.Util.getInstance();
				
				final AsyncCallback<Integer> fileCountCallback = new AsyncCallback<Integer>()
				{
					public void onFailure(Throwable caught)
					{
						Window.alert(caught.getMessage());
					}
					
					public void onSuccess(Integer fileCount)
					{
						System.out.println("Total file Count: " + fileCount);
						updateRowCount(fileCount, true);
						System.out.println("### End ###");
						counter++;						
					}					
				};
				
				
				AsyncCallback<List<DataFileItem>> callback = new AsyncCallback<List<DataFileItem>>()
				{
					public void onFailure(Throwable caught)
					{
						Window.alert(caught.getMessage());
					}
					
					public void onSuccess(List<DataFileItem> result)
					{
						System.out.println("Items: " + result.size() + " From: " + from + " Start: " + Start + "  start: " + start);
						updateRowData(start, result);									
						System.out.println("End: " + new Date());
						service.getFilesNumber(fileCountCallback);
					}
				};
				
				
				// The remote service that should be implemented
				if(from == 0)
				{					
					from = -1;
					ArrayList<String> nameValues = getSelectedUserAndProjectName();
					System.out.println("Start: " + Start + " End: " + (Start + length) + " Date: " + new Date() /*+ " sortList: " + column.getColumn()*/ + " Compare: " + "Rate3by4n1000".compareTo("Rate3by4n1000_1") + " user: " + nameValues.get(0) + " project: " + nameValues.get(1));
					service.getPage(Start, Start + length, !sortList.get(0).isAscending(), nameValues.get(0), nameValues.get(1), tab, callback);
				}
				else
				{
					Start = start;
					ArrayList<String> nameValues = getSelectedUserAndProjectName();	
					System.out.println("@@@Start: " + start + " End: " + (start + length) + " Date: " + new Date() /*+ " sortList: " + column.getColumn()*/ + " Compare: " + "Rate3by4n1000".compareTo("Rate3by4n1000_1") + " user: " + nameValues.get(0) + " project: " + nameValues.get(1));
					service.getPage(start, start + length, !sortList.get(0).isAscending(), nameValues.get(0), nameValues.get(1), tab, callback);
				}				
		    }
	 }
		
	  /**
	   * Add the columns to the table.
	   */	
	  private void initTableColumns(final SelectionModel<DataFileItem> selectionModel, AsyncHandler sortHandler)	
	  {	    
	    Column<DataFileItem, Boolean> checkColumn = new Column<DataFileItem, Boolean>(new CheckboxCell(true, false)) 
	    {
	      public Boolean getValue(DataFileItem object) 
	      {
	        // Get the value from the selection model.
	        return selectionModel.isSelected(object);
	      }	      
	    };	    
	    table.addColumn(checkColumn, SafeHtmlUtils.fromSafeConstant("<br/>"));
	    table.setColumnWidth(checkColumn, 5, Unit.PCT);
	    
	    // Username.
	    Column<DataFileItem, String> userNameColumn = new Column<DataFileItem, String>(new TextCell()) 
	    {	    
	      public String getValue(DataFileItem object) {
	        return object.getUsername();
	      }
	    };	   
	    table.addColumn(userNameColumn, "Username");	    
	    table.setColumnWidth(userNameColumn, 15, Unit.PCT);
	    
	    //ProjectName
	    Column<DataFileItem, String> projectNameColumn = new Column<DataFileItem, String>(new TextCell()) 
	    {	    
	      public String getValue(DataFileItem object) 
	      {
	        return object.getProjectName();
	      }
	    };	    
	    table.addColumn(projectNameColumn, "Project");
	    table.setColumnWidth(projectNameColumn, 20, Unit.PCT);
	    
	    // FileName.
	    Column<DataFileItem, String> fileNameColumn = new Column<DataFileItem, String>(new TextCell()) 
	    {	    
	      public String getValue(DataFileItem object) 
	      {
	        return object.getFileName();
	      }
	    };	    
	    table.addColumn(fileNameColumn, "Name");
	    table.setColumnWidth(fileNameColumn, 40, Unit.PCT);
	  	  
	    // UploadDate	    
	    Column<DataFileItem, String> dateColumn = new Column<DataFileItem, String>(new TextCell()) 
	    {	    
	      public String getValue(DataFileItem object) 
	      {
	    	  long lastModified = object.getLastModified();
	    	  Date date = new Date(lastModified);
	    	  FormatDate fd = new FormatDate();
	    	  DateTimeFormat fmt = fd.formatDate(date);
	    	  return fmt.format(date).toString();
	      }
	    };	    
	    dateColumn.setSortable(true);
	    table.getColumnSortList().push(dateColumn);	    
	    table.addColumn(dateColumn, "Last Modified");
	    table.setColumnWidth(dateColumn, 20, Unit.PCT);	    	    	    
	  }
	
	public void onClick(ClickEvent event) 
	{
		Widget sender = (Widget) event.getSource();
		
		if(sender == hlAll)
		{
			List<DataFileItem> visibleSet = table.getVisibleItems();
		    for (DataFileItem item : visibleSet) 
		    {
		    	if(!selectionModel.isSelected(item))
		    	{
		    		selectionModel.setSelected(item, true);
		    	}
		    }	
		}		
				
		if(sender == hlNone)
		{
			List<DataFileItem> visibleSet = table.getVisibleItems();
		    for (DataFileItem item : visibleSet) 
		    {
		    	if(selectionModel.isSelected(item))
		    	{
		    		selectionModel.setSelected(item, false);
		    	}
		    }
		}
		
		if(sender == btnAddDataFile)
		{
			System.out.println("File list tab: " + tab);
			if(tab == 1 || tab == 0)
			{
				History.newItem("uploadDataFile");				
			}
			else
			{
				History.newItem("adminUploadDataFile");
			}
		}
		
		if(sender == btnDelete)
		{			
			ArrayList<DataFileItem> files = new ArrayList<DataFileItem>();
			List<DataFileItem> visibleSet = table.getVisibleItems();
		    for (DataFileItem item : visibleSet) 
		    {
		    	if(selectionModel.isSelected(item))
		    	{
		    		files.add(item);
					Log.info("File to delete: " + item.getFileName());		    		
					System.out.println("File to delete: " + item.getFileName());
		    	}
		    }
		    if(files.size() > 0)
		    {
		    	if(Window.confirm("Selected data file(s) may be used by current running job(s). Are you sure to delete files?"))
				{
		    		deleteFiles(files);
				}		    	
		    }
		}			
	}

	@Override
	public void onChange(ChangeEvent event) 
	{
		Widget sender = (Widget) event.getSource();
		
		if(sender == lstUsers)
		{
			dataProvider1.onRangeChanged(table);
		}
		if(sender == lstProjects)
		{
			dataProvider1.onRangeChanged(table);
		}		
	}	
	
	//Callback from the server - File is deleted from the Database and the table is updated.
	AsyncCallback<List<DataFileItem>> deleteFilesCallback = new AsyncCallback<List<DataFileItem>>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info("FileList deleteFilesCallback error: " + caught.toString());			
		}
		public void onSuccess(List<DataFileItem> result) 
		{			
			if(result != null)
			{
				dataProvider1.onRangeChanged(table);
			}		
		}
	};	
	
	//Method to call the Delete service for a File
	private void deleteFiles(ArrayList<DataFileItem> files)
	{		
		DeleteDataFilesServiceAsync service = DeleteDataFilesService.Util.getInstance();
		service.deleteDataFiles(files, Start, VISIBLE_FILE_COUNT, !sortList.get(0).isAscending(), 0, tab, deleteFilesCallback);
	}	
}