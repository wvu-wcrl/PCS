/*
 * File: JobList.java

Purpose: Java class to display a list of Jobs of all the users (Used for user logged in as an Administrator)
**********************************************************/
package com.wcrl.web.cml.client.jobs;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.Map.Entry;

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
import com.wcrl.web.cml.client.jobService.ArchiveJobsService;
import com.wcrl.web.cml.client.jobService.ArchiveJobsServiceAsync;
import com.wcrl.web.cml.client.jobService.DeleteJobsService;
import com.wcrl.web.cml.client.jobService.DeleteJobsServiceAsync;
import com.wcrl.web.cml.client.jobService.GetPageService;
import com.wcrl.web.cml.client.jobService.GetPageServiceAsync;
import com.wcrl.web.cml.client.jobService.GetPreferredProjectService;
import com.wcrl.web.cml.client.jobService.GetPreferredProjectServiceAsync;
import com.wcrl.web.cml.client.jobService.GetSubscribedProjectListService;
import com.wcrl.web.cml.client.jobService.GetSubscribedProjectListServiceAsync;
import com.wcrl.web.cml.client.jobService.ResumeJobsService;
import com.wcrl.web.cml.client.jobService.ResumeJobsServiceAsync;
import com.wcrl.web.cml.client.jobService.SuspendJobsService;
import com.wcrl.web.cml.client.jobService.SuspendJobsServiceAsync;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.projects.ProjectItem;

public class JobList extends Composite implements ClickHandler, ChangeHandler
{
	private CellTable<JobItem> table;
	private CustomSimplePager pager;
	private CustomSimplePager topPager;	
	//Number of jobs to display in a page
	private int VISIBLE_JOB_COUNT = 25;
	private VerticalPanel vPanel;
	private Label lblMsg;	
	private ClientContext ctx;
	private User currentUser;
	
	private HorizontalPanel linksPanel;
	private Anchor hlAll;
	private Anchor hlNone;
	private Button btnDelete;
	private final SelectionModel<JobItem> selectionModel = new MultiSelectionModel<JobItem>();
	private ColumnSortList sortList;
	
	//List of timers for active jobs
	private int tab;
	private ListBox lstStatus;
	private ListBox lstUsers;
	private ListBox lstProjects;	
	private Button btnAddJob;
	private Button btnSuspend;
	private Button btnResume;
	private Button btnArchive;
	
	private int Start;
	private int from;
	private String selectUser;
	private String selectProject;
	private String selectStatus;
	private int counter;
	private MyDataProvider dataProvider1;
	
	public JobList()
	{	
		String sessionID = Cookies.getCookie("sid");
		vPanel = new VerticalPanel();		
		initWidget(vPanel);
		ctx = (ClientContext) RPCClientContext.get();	
		Log.info("sessionID: " + sessionID + " ctx: " + ctx); 
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
	

	public void refresh(int from, int start, int fromTab, String selectUser, String selectProject, String selectStatus)
	{		
		this.selectUser = selectUser;
		this.selectProject = selectProject;
		this.selectStatus = selectStatus;
		
		Log.info("########### JobList selectProject: " + selectProject);
		
		if(fromTab == 0)
		{			
			if(currentUser.getUsertype().equalsIgnoreCase("admin"))
			{
				/* User == admin, requesting to view admin's jobs */
				this.tab = 0;
			}			
			else
			{
				/* User == user, requesting to view user's jobs */
				this.tab = 1;
			}
		}
		else
		{
			/* User == admin, requesting to view jobs of all the users */
			this.tab = 2;
		}
		
		/* To display jobs listed in current page or from the beginning */
		this.from = from;
		if(from == 0)
		{
			this.Start = start;
		}
		
		GetPreferredProjectServiceAsync service = GetPreferredProjectService.Util.getInstance();
      	service.getPreferredProject(currentUser.getUserId(), preferredProjectCallback);		
	}
	
	AsyncCallback<HashMap<Integer, String>> preferredProjectCallback = new AsyncCallback<HashMap<Integer, String>>()
	  {
		  public void onFailure(Throwable caught)
		  {
			  Log.info("UploadJob preferredProjectCallback error: " + caught.toString());
		  }
		  public void onSuccess(HashMap<Integer, String> project)
		  {
			  if(project != null)
			  {
				  Set<Entry<Integer, String>> entrySet = project.entrySet();
				  for(Entry<Integer, String> entry : entrySet)
				  {
					  currentUser.setPreferredProjectId(entry.getKey());
					  currentUser.setPreferredProject(entry.getValue());
					  Log.info("JobList: " + entry.getKey() + " " + entry.getValue());
				  }
				  ctx.setCurrentUser(currentUser);				  
			  }
			  if(selectProject != null)
			  {
				  if(selectProject.length() == 0)
				  {
					  selectProject = currentUser.getPreferredProject();
				  }
			  }
			  //selectProject = currentUser.getPreferredProject();
			  getJobList(selectStatus);
		  }
	  };
	
	
	public void getJobList(String selectStatus) 
	{			
		ctx = (ClientContext) RPCClientContext.get();	    
	    if(ctx != null)
	    {
	    	currentUser = ctx.getCurrentUser();
	    	if(currentUser != null)
	    	{  		
	    		lblMsg = new Label();
	    		lblMsg.addStyleName("warnings");	

	    		lstStatus = new ListBox();
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
				btnSuspend = new Button("Suspend");
				btnResume = new Button("Resume");
				btnArchive = new Button("Archive");
				
				lstStatus.addItem("All", "0");
				lstStatus.addItem("Queued", "1");
				lstStatus.addItem("Running", "2");				
				lstStatus.addItem("Done", "3");
				lstStatus.addItem("Archive", "4");
				lstStatus.addItem("Suspended", "5");
				lstStatus.addItem("Failed", "6");
				//lstStatus.setItemSelected(2, true);
				lstStatus.setItemSelected(0, true);
				//lstStatus.setItemSelected(2, true);
				
				
				if(selectStatus.length() > 0)
				{
					int statusCount = lstStatus.getItemCount();
					for(int i = 0; i < statusCount; i++)
					{
						String selectedStatus = lstStatus.getItemText(i);
						if(selectedStatus.equalsIgnoreCase(selectStatus))
						{
							lstStatus.setItemSelected(i, true);
						}
					}
				}
				
				String selectedJobsStatus = lstStatus.getItemText(lstStatus.getSelectedIndex());
				setButtonStatus(selectedJobsStatus);
				
				lstStatus.addChangeHandler(this);
					
				lstUsers.clear();
				//lstUsers.addItem("--Users--", "0");
				lstUsers.addItem("All", "0");
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
				
	    		//lstProjects.addItem("--Projects--", "0");
				lstProjects.addItem("All", "0");
	    			    		
	    		lstUsers.addChangeHandler(this);
	    		lstProjects.addChangeHandler(this);
	    			    		
	    		populateUsersAndProjects();	    		      	   	    		
	    	}
	    }
	    else
	    {
	    	Log.info("Ctx null JobList");
			Login login = new Login();
			login.displayLoginBox();
	    }	    		
	 }
	
	private void afterLoadingUsersAndProjects()
	{
		Log.info("Users: " + lstUsers.getItemCount() + " User: " + lstUsers.getItemText(0) + " Selected: " + lstUsers.getSelectedIndex() + " " + lstUsers.getItemText(lstUsers.getSelectedIndex()) + " Project: " + lstProjects.getItemText(lstProjects.getSelectedIndex()) + " selectProject: " + selectProject);
		
		VerticalPanel panel = new VerticalPanel();
		btnDelete = new Button("Delete");
						
		btnDelete.addClickHandler(this);
		btnSuspend.addClickHandler(this);
		btnResume.addClickHandler(this);
		btnArchive.addClickHandler(this);
		
		panel.setSize("100%", "100%");
		panel.setSpacing(10);
		panel.add(lblMsg);
		//Initialize the CellTable
		table = (CellTable<JobItem>) onInitialize();
		table.setStyleName("hand");
		HorizontalPanel topPanel = new HorizontalPanel();
		btnAddJob = new Button("Add Job");
		btnAddJob.addClickHandler(this);
		topPanel.add(btnDelete);
		topPanel.add(btnSuspend);
		topPanel.add(btnResume);
		topPanel.add(btnArchive);

		topPanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
		topPanel.add(btnAddJob);
		topPanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
		topPanel.add(lstUsers);
		topPanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
		topPanel.add(lstProjects);
		topPanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
		topPanel.add(lstStatus);
		
		topPanel.setCellHorizontalAlignment(lstUsers, HasHorizontalAlignment.ALIGN_CENTER);
		topPanel.setCellVerticalAlignment(lstUsers, HasVerticalAlignment.ALIGN_MIDDLE);
		topPanel.setCellHorizontalAlignment(lstProjects, HasHorizontalAlignment.ALIGN_CENTER);
		topPanel.setCellVerticalAlignment(lstProjects, HasVerticalAlignment.ALIGN_MIDDLE);
		topPanel.setCellHorizontalAlignment(lstStatus, HasHorizontalAlignment.ALIGN_CENTER);
		topPanel.setCellVerticalAlignment(lstStatus, HasVerticalAlignment.ALIGN_MIDDLE);
		
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
				Log.info("In testing 2: " + systemUsers.size());
				
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
					//lstUsers.addItem("--Users--", "0");
					lstUsers.addItem("All", "0");
					lstUsers.addItem(username, Integer.valueOf(userId).toString());
					lstUsers.setItemSelected(1, true);
					
					/*lstUsers.clear();
					lstUsers.addItem(username, Integer.valueOf(userId).toString());
					lstUsers.setItemSelected(0, true);*/
				}
				userMap.clear();
								
				GetSubscribedProjectListServiceAsync service = GetSubscribedProjectListService.Util.getInstance();
				if(tab == 2)
				{			
					service.getSubscribedProjectList(0, subscribedProjectsCallback);
				}
				else
				{
					service.getSubscribedProjectList(currentUser.getUserId(), subscribedProjectsCallback);
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
			Log.info("JobList subscribedProjectsCallback projectList: " + projectList + " cnt: " + projectList.size());
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
					Log.info("JobList Project: " + projectName + " Select: " + selectProject);
					if(selectProject != null)
					{
						if(selectProject.equalsIgnoreCase(projectName))
						{
							int projectCountInList = lstProjects.getItemCount();
							lstProjects.setItemSelected(projectCountInList-1, true);
							System.out.println("Item selected Project: " + projectName);
						}						
					}					
				}
			}
			if(lstProjects.getSelectedIndex() == -1)
			{
				lstProjects.setItemSelected(0, true);
			}
			System.out.println("Project selected: " + lstProjects.getItemText(lstProjects.getSelectedIndex()));
			Log.info("Project selected: " + lstProjects.getItemText(lstProjects.getSelectedIndex()));
			projectMap.clear();
			System.out.println("Number of projects: " + projectList.size() + " users: " + lstUsers.getItemCount());
			Log.info("JobList Number of projects: " + projectList.size() + " users: " + lstUsers.getItemCount());
			afterLoadingUsersAndProjects();
		}
	};
		
	//Initialize the CellTable and set the pager
	public CellTable<JobItem> onInitialize()
	{
	    table = new CellTable<JobItem>();
	    table.setWidth("100%", true);
	    table.setPageSize(VISIBLE_JOB_COUNT);
	    
	    table.addCellPreviewHandler(new Handler<JobItem>()
	    {
	    	//Call the JobDetails page when user clicks on any Job in the table
			public void onCellPreview(CellPreviewEvent<JobItem> event) 
			{				
				
				boolean isClick = "click".equals(event.getNativeEvent().getType());
				JobItem item = event.getValue();				
				if(isClick && (event.getColumn() != 0))
				{
					if (item == null) 
				    {
				    	return;
				    }			    
					ArrayList<String> nameValues = getSelectedUserAndProjectName();
					System.out.println("Before going to job details status: " + lstStatus.getItemText(lstStatus.getSelectedIndex()) + " user: " + nameValues.get(0) + " project: " + nameValues.get(1));
					Log.info("Before going to job details status: " + lstStatus.getItemText(lstStatus.getSelectedIndex()) + " user: " + nameValues.get(0) + " project: " + nameValues.get(1));
					JobDetails jobDetail = new JobDetails(item, lstStatus.getItemText(lstStatus.getSelectedIndex()), Start, tab, nameValues.get(0), nameValues.get(1));
				    
				    RootPanel.get("content").clear();
					RootPanel.get("content").add(jobDetail);
				}				
			}	    	
	    });
	    
	    // Create a Pager to control the table.
	    SimplePager.Resources pagerResources = GWT.create(SimplePager.Resources.class);
	    pager = new CustomSimplePager(VISIBLE_JOB_COUNT, TextLocation.CENTER, pagerResources, false, 0, true);
	    pager.setDisplay(table);
	    
	    topPager = new CustomSimplePager(VISIBLE_JOB_COUNT, TextLocation.CENTER, pagerResources, false, 0, true);
	    topPager.setDisplay(table);
	    
	    // Add a selection model to select cells.	    
	    table.setSelectionModel(selectionModel, DefaultSelectionEventManager.<JobItem> createCheckboxManager());
	    
	    //ListHandler<JobItem> sortHandler = new ListHandler<JobItem>(new ArrayList<JobItem>());
	    // Initialize the columns.
	    AsyncHandler sortHandler = new AsyncHandler(table);
	    table.addColumnSortHandler(sortHandler);	   
	    initTableColumns(selectionModel, sortHandler);	
	    sortList = table.getColumnSortList();
	    ArrayList<String> nameValues = getSelectedUserAndProjectName();
	    Log.info("onInitialize Users: " + lstUsers.getItemCount() + " User: " + lstUsers.getItemText(0) + " Username: " + nameValues.get(0) + " Project: " + nameValues.get(1));

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
	
	 private class MyDataProvider extends AsyncDataProvider<JobItem> 
	 {
		 protected void onRangeChanged(HasData<JobItem> display)
			{	
				final int start = display.getVisibleRange().getStart();
				int length = display.getVisibleRange().getLength();
				final GetPageServiceAsync service = GetPageService.Util.getInstance();
				
				final AsyncCallback<Integer> jobCountCallback = new AsyncCallback<Integer>()
				{
					public void onFailure(Throwable caught)
					{
						Window.alert(caught.getMessage());
					}
					
					public void onSuccess(Integer jobCount)
					{
						System.out.println("Total Job Count: " + jobCount);
						updateRowCount(jobCount, true);
						System.out.println("### End ###");
						counter++;						
					}					
				};
				
				
				AsyncCallback<List<JobItem>> callback = new AsyncCallback<List<JobItem>>()
				{
					public void onFailure(Throwable caught)
					{
						Window.alert(caught.getMessage());
					}
					
					public void onSuccess(List<JobItem> result)
					{
						System.out.println("Items: " + result.size() + " From: " + from + " Start: " + Start + "  start: " + start);
						updateRowData(start, result);									
						System.out.println("End: " + new Date());
						service.getJobNumber(jobCountCallback);
					}
				};
				
				
				// The remote service that should be implemented
				if(from == 0)
				{					
					from = -1;
					ArrayList<String> nameValues = getSelectedUserAndProjectName();
					Log.info("Start: " + Start + " End: " + (Start + length) + " Date: " + new Date() /*+ " sortList: " + column.getColumn()*/ + " Compare: " + "Rate3by4n1000".compareTo("Rate3by4n1000_1") + " user: " + nameValues.get(0) + " project: " + nameValues.get(1));
					service.getPage(Start, Start + length, !sortList.get(0).isAscending(), lstStatus.getItemText(lstStatus.getSelectedIndex()), nameValues.get(0), nameValues.get(1), tab, callback);
				}
				else
				{
					Start = start;
					ArrayList<String> nameValues = getSelectedUserAndProjectName();	
					Log.info("@@@Start: " + start + " End: " + (start + length) + " Date: " + new Date() /*+ " sortList: " + column.getColumn()*/ + " Compare: " + "Rate3by4n1000".compareTo("Rate3by4n1000_1") + " user: " + nameValues.get(0) + " project: " + nameValues.get(1));
					service.getPage(start, start + length, !sortList.get(0).isAscending(), lstStatus.getItemText(lstStatus.getSelectedIndex()), nameValues.get(0), nameValues.get(1), tab, callback);
				}				
		    }
	 }
		
	  /**
	   * Add the columns to the table.
	   */	
	  private void initTableColumns(final SelectionModel<JobItem> selectionModel, AsyncHandler sortHandler)	
	  {	    
	    Column<JobItem, Boolean> checkColumn = new Column<JobItem, Boolean>(new CheckboxCell(true, false)) 
	    {
	      public Boolean getValue(JobItem object) 
	      {
	        // Get the value from the selection model.
	        return selectionModel.isSelected(object);
	      }	      
	    };	    
	    table.addColumn(checkColumn, SafeHtmlUtils.fromSafeConstant("<br/>"));
	    table.setColumnWidth(checkColumn, 5, Unit.PCT);
	    
	    // Username.
	    Column<JobItem, String> userNameColumn = new Column<JobItem, String>(new TextCell()) 
	    {	    
	      public String getValue(JobItem object) {
	        return object.getUsername();
	      }
	    };	   
	    table.addColumn(userNameColumn, "Username");	    
	    table.setColumnWidth(userNameColumn, 15, Unit.PCT);
	    
	    //ProjectName
	    Column<JobItem, String> projectNameColumn = new Column<JobItem, String>(new TextCell()) 
	    {	    
	      public String getValue(JobItem object) 
	      {
	        return object.getProjectName();
	      }
	    };	    
	    table.addColumn(projectNameColumn, "Project");
	    table.setColumnWidth(projectNameColumn, 15, Unit.PCT);
	    
	    // JobName.
	    Column<JobItem, String> jobNameColumn = new Column<JobItem, String>(new TextCell()) 
	    {	    
	      public String getValue(JobItem object) 
	      {
	        return object.getJobName();
	      }
	    };	    
	    table.addColumn(jobNameColumn, "Name");
	    table.setColumnWidth(jobNameColumn, 35, Unit.PCT);
	  	  
	    // UploadDate	    
	    Column<JobItem, String> dateColumn = new Column<JobItem, String>(new TextCell()) 
	    {	    
	      public String getValue(JobItem object) 
	      {
	    	  long lastModified = object.getLastModified();
	    	  Date date = new Date(lastModified);
	    	  FormatDate fd = new FormatDate();
	    	  DateTimeFormat fmt = fd.formatDate(date);
	    	  return fmt.format(date).toString();
	    	  /*DateTimeFormat fmt = formatDate(date);
	    	  return fmt.format(date).toString();*/
	    	  //return date.toString();
	      }
	    };	    
	    dateColumn.setSortable(true);
	    table.getColumnSortList().push(dateColumn);	    
	    table.addColumn(dateColumn, "Last Modified");
	    table.setColumnWidth(dateColumn, 20, Unit.PCT);	   
	    
	    // Status
	    Column<JobItem, String> statusColumn = new Column<JobItem, String>(new TextCell())
	    {
	    	public String getValue(JobItem object)
	    	{
	    		return object.getStatus();
	    	}
	    };
	    table.addColumn(statusColumn, "Status");
	    table.setColumnWidth(statusColumn, 10, Unit.PCT);
	    /*if(tab != 2)
	    {
	    	table.addColumn(statusColumn, "Status");
		    table.setColumnWidth(statusColumn, 10, Unit.PCT);
	    }*/	    	    
	  }
	
	public void onClick(ClickEvent event) 
	{
		Widget sender = (Widget) event.getSource();
		
		if(sender == hlAll)
		{
			List<JobItem> visibleSet = table.getVisibleItems();
		    for (JobItem item : visibleSet) 
		    {
		    	if(!selectionModel.isSelected(item))
		    	{
		    		selectionModel.setSelected(item, true);
		    	}
		    }	
		}
		if(sender == btnSuspend)
		{
			List<JobItem> visibleSet = table.getVisibleItems();
			ArrayList<JobItem> jobs = new ArrayList<JobItem>();
		    for (JobItem item : visibleSet) 
		    {
		    	if(selectionModel.isSelected(item))
		    	{
		    		String status = lstStatus.getItemText(lstStatus.getSelectedIndex());
					if(status.equalsIgnoreCase("Running") || status.equalsIgnoreCase("Queued"))
					{
						jobs.add(item);
						Log.info("Job suspended: " + item.getJobId() + " status: " + status);
						selectionModel.setSelected(item, false);						
					}
		    	}
		    }
		    if(jobs.size() > 0)
		    {
		    	if(Window.confirm("Are you sure to suspend jobs?"))
				{
		    		suspendJobs(jobs);
				}		    	
		    }
		}
		if(sender == btnResume)
		{
			ArrayList<JobItem> jobs = new ArrayList<JobItem>();
			List<JobItem> visibleSet = table.getVisibleItems();
		    for (JobItem item : visibleSet) 
		    {
		    	if(selectionModel.isSelected(item))
		    	{
		    		jobs.add(item);
					Log.info("Job to resume: " + item.getJobName());		    		
		    	}
		    }
		    if(jobs.size() > 0)
		    {
		    	resumeJobs(jobs);
		    }		
		}
		if(sender == btnArchive)
		{
			List<JobItem> visibleSet = table.getVisibleItems();
			ArrayList<JobItem> jobs = new ArrayList<JobItem>();
		    for (JobItem item : visibleSet) 
		    {
		    	if(selectionModel.isSelected(item))
		    	{
		    		String status = lstStatus.getItemText(lstStatus.getSelectedIndex());
					if(status.equalsIgnoreCase("Done"))
					{
						jobs.add(item);
						Log.info("Job archived: " + item.getJobId() + " status: " + status);
						selectionModel.setSelected(item, false);						
					}
		    	}
		    }
		    if(jobs.size() > 0)
		    {
		    	if(Window.confirm("Are you sure to archive jobs?"))
				{
		    		archiveJobs(jobs);
				}		    	
		    }
		}
				
		if(sender == hlNone)
		{
			List<JobItem> visibleSet = table.getVisibleItems();
		    for (JobItem item : visibleSet) 
		    {
		    	if(selectionModel.isSelected(item))
		    	{
		    		selectionModel.setSelected(item, false);
		    	}
		    }
		}
		
		if(sender == btnAddJob)
		{
			System.out.println("Job list tab: " + tab);
			if(tab == 1 || tab == 0)
			{
				History.newItem("uploadJob");				
			}
			else
			{
				History.newItem("adminUploadJob");
			}
		}
		
		if(sender == btnDelete)
		{			
			ArrayList<JobItem> jobs = new ArrayList<JobItem>();
			List<JobItem> visibleSet = table.getVisibleItems();
		    for (JobItem item : visibleSet) 
		    {
		    	if(selectionModel.isSelected(item))
		    	{
		    		jobs.add(item);
					Log.info("Job to delete: " + item.getJobName());		    		
		    	}
		    }
		    if(jobs.size() > 0)
		    {
		    	if(Window.confirm("Are you sure to delete jobs?"))
				{
		    		deleteJobs(jobs);
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
		if(sender == lstStatus)
		{
			String selectedStatus = lstStatus.getItemText(lstStatus.getSelectedIndex());
			setButtonStatus(selectedStatus);
			
			System.out.println("suspend: " + btnSuspend.isEnabled() + " resume: " + btnResume.isEnabled() + " archive: " + btnArchive.isEnabled());			
			dataProvider1.onRangeChanged(table);			
		}
	}
	
	private void setButtonStatus(String selectedStatus)
	{
		System.out.println("selectedStatus: " + selectedStatus);
		if(selectedStatus.equalsIgnoreCase("Suspended"))
		{
			btnSuspend.setEnabled(false);
			btnResume.setEnabled(true);		
			btnArchive.setEnabled(false);
		}
			
		if(selectedStatus.equalsIgnoreCase("Done"))
		{
			btnSuspend.setEnabled(false);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(true);
		}
			
		if(selectedStatus.equalsIgnoreCase("Failed") || selectedStatus.equalsIgnoreCase("Archive"))
		{
			btnSuspend.setEnabled(false);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(false);
		}
		
		if(selectedStatus.equalsIgnoreCase("Queued") || selectedStatus.equalsIgnoreCase("Running"))
		{
			btnSuspend.setEnabled(true);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(false);
		}
		
		/*if(!selectedStatus.equalsIgnoreCase("Queued") || !selectedStatus.equalsIgnoreCase("Running") || !selectedStatus.equalsIgnoreCase("Failed") || !selectedStatus.equalsIgnoreCase("Archive") || !selectedStatus.equalsIgnoreCase("Done") || !selectedStatus.equalsIgnoreCase("Suspended"))
		{
			btnSuspend.setEnabled(true);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(false);
		}*/		
	}
	
	AsyncCallback<List<JobItem>> suspendJobsCallback = new AsyncCallback<List<JobItem>>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info(" JobList suspendJobCallback error: " + caught.toString());			
		}
		public void onSuccess(List<JobItem> result) 
		{			
			if(result != null)
			{
				dataProvider1.onRangeChanged(table);
			}			
		}
	};	
	
	AsyncCallback<List<JobItem>> resumeJobCallback = new AsyncCallback<List<JobItem>>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info(" JobList resumeJobCallback error: " + caught.toString());			
		}
		public void onSuccess(List<JobItem> result) 
		{			
			if(result != null)
			{
				dataProvider1.onRangeChanged(table);
			}			
		}
	};
	
	AsyncCallback<List<JobItem>> archiveJobsCallback = new AsyncCallback<List<JobItem>>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info(" JobList archiveJobCallback error: " + caught.toString());			
		}
		public void onSuccess(List<JobItem> result) 
		{			
			if(result != null)
			{
				dataProvider1.onRangeChanged(table);
			}			
		}
	};	
	
	//Callback from the server - Job is deleted from the Database and the table is updated.
	AsyncCallback<List<JobItem>> deleteJobsCallback = new AsyncCallback<List<JobItem>>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info(" JobList deleteJobCallback error: " + caught.toString());			
		}
		public void onSuccess(List<JobItem> result) 
		{			
			if(result != null)
			{
				dataProvider1.onRangeChanged(table);
			}		
		}
	};	
	
	//Method to call the Delete service for a Job
	//private void deleteJob(int jobId)
	private void deleteJobs(ArrayList<JobItem> jobs)
	{		
		DeleteJobsServiceAsync service = DeleteJobsService.Util.getInstance();
		service.deleteJobs(jobs, Start, VISIBLE_JOB_COUNT, !sortList.get(0).isAscending(), lstStatus.getItemText(lstStatus.getSelectedIndex()), 0, tab, deleteJobsCallback);
	}
	
	private void suspendJobs(ArrayList<JobItem> jobs)
	{		
		SuspendJobsServiceAsync service = SuspendJobsService.Util.getInstance();		
		service.suspendJobs(jobs, Start, VISIBLE_JOB_COUNT, !sortList.get(0).isAscending(), lstStatus.getItemText(lstStatus.getSelectedIndex()), 0, tab, suspendJobsCallback);		
	}
	
	private void resumeJobs(ArrayList<JobItem> jobs)
	{		
		ResumeJobsServiceAsync service = ResumeJobsService.Util.getInstance();
		service.resumeJobs(jobs, Start, VISIBLE_JOB_COUNT, !sortList.get(0).isAscending(), lstStatus.getItemText(lstStatus.getSelectedIndex()), 0, tab, resumeJobCallback);
	}
	
	private void archiveJobs(ArrayList<JobItem> jobs)
	{		
		System.out.println("Number of jobs: " + jobs.size());
		ArchiveJobsServiceAsync service = ArchiveJobsService.Util.getInstance();		
		service.archiveJobs(jobs, Start, VISIBLE_JOB_COUNT, !sortList.get(0).isAscending(), lstStatus.getItemText(lstStatus.getSelectedIndex()), 0, tab, archiveJobsCallback);		
	}
}