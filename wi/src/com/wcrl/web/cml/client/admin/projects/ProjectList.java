/*
 * File: ProjectList.java

Purpose: Java class to display a list of Projects (Used for user logged in as an Administrator)
**********************************************************/
package com.wcrl.web.cml.client.admin.projects;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.cell.client.CheckboxCell;
import com.google.gwt.cell.client.FieldUpdater;
import com.google.gwt.cell.client.TextCell;
import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Style.Unit;
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
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.google.gwt.view.client.CellPreviewEvent;
import com.google.gwt.view.client.DefaultSelectionEventManager;
import com.google.gwt.view.client.ListDataProvider;
import com.google.gwt.view.client.MultiSelectionModel;
import com.google.gwt.view.client.SelectionModel;
import com.google.gwt.view.client.CellPreviewEvent.Handler;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.projectService.DeleteProjectsService;
import com.wcrl.web.cml.client.admin.projectService.DeleteProjectsServiceAsync;
import com.wcrl.web.cml.client.admin.projectService.UpdateProjectService;
import com.wcrl.web.cml.client.admin.projectService.UpdateProjectServiceAsync;
import com.wcrl.web.cml.client.custom.CustomSimplePager;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.projectService.ProjectListService;
import com.wcrl.web.cml.client.projectService.ProjectListServiceAsync;
import com.wcrl.web.cml.client.projects.ProjectItem;
import com.wcrl.web.cml.client.projects.ProjectItems;


public class ProjectList extends Composite implements ClickHandler
{
	private ClientContext ctx;
	private User currentUser;
	private VerticalPanel vPanel;
	private CellTable<ProjectItem> table;
	private CustomSimplePager pager;
	private CustomSimplePager topPager;
	private ListDataProvider<ProjectItem> dataProvider = new ListDataProvider<ProjectItem>();
	private final SelectionModel<ProjectItem> selectionModel = new MultiSelectionModel<ProjectItem>();
	private List<ProjectItem> list;
	private HorizontalPanel linksPanel;
	private Anchor hlAll;
	private Anchor hlNone;
	private Label lblMsg;
	private HorizontalPanel buttonPanel;		
	private Button btnDelete;
	private ProjectItems projectItems;
	private final int PAGE_COUNT = 20;
	private String projectName;
	private String projectDescription;
	private ProjectDetails projectDetail;
	private Button btnAddProject;
	private int tabIndex;
	
	
	//Get the current user context and send a request to the server for a list of registered users
	public ProjectList(int tabIndex)
	{
		this.tabIndex = tabIndex;
		vPanel = new VerticalPanel();
		initWidget(vPanel);
	}
	
	public void loadProjects()
	{				
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{
			ctx = (ClientContext) RPCClientContext.get();			
		    if(ctx != null)
		    {
		       	currentUser = ctx.getCurrentUser();
		       	if(currentUser != null)
		       	{	       		
		       		ProjectListServiceAsync service = ProjectListService.Util.getInstance();			
					service.getProjectList(projectsCallback);    		
		       	}
		    }
		}
		else
		{
			Login login = new Login();
			login.displayLoginBox();
		}
	}
	
	//Callback to receive the list of registered users and set the users to the usersList
	AsyncCallback<ArrayList<ProjectItem>> projectsCallback = new AsyncCallback<ArrayList<ProjectItem>>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("ProjectList projectsCallback error: " + arg0.toString());				
		}		
		public void onSuccess(ArrayList<ProjectItem> projects)
		{
			if(ctx != null)
			{
				User currentUser = ctx.getCurrentUser();
				if(projects != null)
				{
					projectItems = new ProjectItems();
					projectItems.setItems(projects);
					currentUser.setProjectItems(projectItems);		
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
		btnAddProject = new Button("Add Project");
		btnAddProject.addClickHandler(this);
		
		linksPanel = new HorizontalPanel();		
		hlAll = new Anchor("All");
		hlNone = new Anchor("None");
		hlAll.addClickHandler(this);
		hlNone.addClickHandler(this);
		
		linksPanel.add(hlAll);
		HTML seperator = new HTML(", &nbsp;");
   		//seperator.addStyleName("normalText");
		linksPanel.add(seperator);
		linksPanel.add(hlNone);
		
		buttonPanel = new HorizontalPanel();		
		btnDelete = new Button("Delete");
		
		buttonPanel.add(btnDelete);
		buttonPanel.add(btnAddProject);
				
		btnDelete.addClickHandler(this);
				
		lblMsg.addStyleName("warnings");
   		
		vPanel.setSize("100%", "100%");
   		table = (CellTable<ProjectItem>) onInitialize();
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
	
	//Handle the button clicks
	public void onClick(ClickEvent event) 
	{		
		Widget sender = (Widget) event.getSource();
		
		if(sender == hlAll)
		{
			List<ProjectItem> lst = dataProvider.getList();
			for(int i = 0; i < lst.size(); i++)
			{
				ProjectItem item = lst.get(i);
				selectionModel.setSelected(item, true);
			}		
		}
		
		if(sender == hlNone)
		{
			List<ProjectItem> lst = dataProvider.getList();
			for(int i = 0; i < lst.size(); i++)
			{
				ProjectItem item = lst.get(i);
				selectionModel.setSelected(item, false);
			}
		}
		
		if(sender == btnAddProject)
		{
			History.newItem("addProject");
			AddProject addProject = new AddProject();
			RootPanel.get("content").clear();
			RootPanel.get("content").add(addProject);
		}
				
		//Send a request to the server to delete users
		if(sender == btnDelete)
		{
			ArrayList<Integer> deleteProjects = getProjects();
			Log.info("Delete button - Item count: " + deleteProjects.size());
			if(deleteProjects.size() > 0)
			{
				if(Window.confirm("Are you sure to delete the selected projects?"))
				{
					DeleteProjectsServiceAsync service = DeleteProjectsService.Util.getInstance();
					service.deleteProjects(deleteProjects, deleteProjectsCallback);
				}
			}			
		}		
	}
	
	//Get a list of selected users
	 private ArrayList<Integer> getProjects() 
	 {
		 ArrayList<Integer> deleteProjects = new ArrayList<Integer>();
		 List<ProjectItem> lst = dataProvider.getList();
		 for(int i = 0; i < lst.size(); i++)
		 {
				ProjectItem item = lst.get(i);
				boolean selected = selectionModel.isSelected(item);
				Log.info("Project: " + item.getProjectId() + " Checked: " + selected);
				if (selected) 
				{				
					deleteProjects.add(item.getProjectId());					
	            }
		 }			
		return deleteProjects;
	}

	 //Initialize the CellTable
	public CellTable<ProjectItem> onInitialize()
	{
		table = new CellTable<ProjectItem>();
		table.setWidth("100%", true);
		table.setPageSize(PAGE_COUNT);
		
		table.addCellPreviewHandler(new Handler<ProjectItem>()
		{
			//Call the JobDetails page when user clicks on any Job in the table
			public void onCellPreview(CellPreviewEvent<ProjectItem> event)
			{
				boolean isClick = "click".equals(event.getNativeEvent().getType());
				ProjectItem item = event.getValue();
				if(isClick && (event.getColumn() != 0))
				{
					if (item == null)
					{
						return;
					}
					projectDetail = new ProjectDetails(tabIndex, item.getProjectId());
					RootPanel.get("content").clear();
					RootPanel.get("content").add(projectDetail);
				}
			}
		});
		
		// Connect the table to the data provider.
	    dataProvider.addDataDisplay(table);
	    
	    list = dataProvider.getList();
	   
	    for(ProjectItem item : projectItems.getItems())
	    {	    	
	    	list.add(item);
	    }

	    // Add a ColumnSortEvent.ListHandler to connect sorting to the java.util.List.
	    // Attach a column sort handler to the ListDataProvider to sort the list.
	    ListHandler<ProjectItem> sortHandler = new ListHandler<ProjectItem>(list);	   
	    table.addColumnSortHandler(sortHandler);

	    // Create a Pager to control the table.
	    SimplePager.Resources pagerResources = GWT.create(SimplePager.Resources.class);
	    pager = new CustomSimplePager(PAGE_COUNT, TextLocation.CENTER, pagerResources, false, 0, true);
	    pager.setDisplay(table);
	    
	    topPager = new CustomSimplePager(PAGE_COUNT, TextLocation.CENTER, pagerResources, false, 0, true);
	    topPager.setDisplay(table);
	    
	    // Add a selection model so we can select cells.	    
	    table.setSelectionModel(selectionModel, DefaultSelectionEventManager.<ProjectItem> createCheckboxManager());

	    // Initialize the columns.
	    initTableColumns(selectionModel, sortHandler);
	    
		return table;		    
	}
	
	  /**
	   * Add the columns to the table.
	   */
	  private void initTableColumns(final SelectionModel<ProjectItem> selectionModel, ListHandler<ProjectItem> sortHandler)	 
	  {	    
	    Column<ProjectItem, Boolean> checkColumn = new Column<ProjectItem, Boolean>(new CheckboxCell(true, false)) 
	    {
	      public Boolean getValue(ProjectItem object) 
	      {
	        // Get the value from the selection model.
	        return selectionModel.isSelected(object);
	      }	      
	    };
	    
	    table.addColumn(checkColumn, SafeHtmlUtils.fromSafeConstant("<br/>"));
	    table.setColumnWidth(checkColumn, 5, Unit.PCT);
	    
	    // ProjectId
	    Column<ProjectItem, String> projectIdColumn = new Column<ProjectItem, String>(new TextCell()) 
	    {	    
	      public String getValue(ProjectItem item) 
	      {
	        return Integer.valueOf(item.getProjectId()).toString();
	      }
	    };
	    projectIdColumn.setSortable(true);
	    sortHandler.setComparator(projectIdColumn, new Comparator<ProjectItem>() {
	      public int compare(ProjectItem o1, ProjectItem o2) 
	      {
	    	  int projectId1 = o1.getProjectId();
	    	  int projectId2 = o2.getProjectId();
	    	  
	    	  if(projectId1 > projectId2)
            	return 1;
            else if(projectId1 < projectId2)
            	return -1;
            else
            	return 0;
	      }
	    });
	    table.addColumn(projectIdColumn, "Project Id");	    
	    table.setColumnWidth(projectIdColumn, 15, Unit.PCT);

	    // Project name.
	    //Column<ProjectItem, String> projectNameColumn = new Column<ProjectItem, String>(new EditTextCell()) 
	    Column<ProjectItem, String> projectNameColumn = new Column<ProjectItem, String>(new TextCell())
	    {	    
	      public String getValue(ProjectItem object) {
	        return object.getProjectName();
	      }
	    };
	    projectNameColumn.setSortable(true);
	    sortHandler.setComparator(projectNameColumn, new Comparator<ProjectItem>() 
	    {
	      public int compare(ProjectItem o1, ProjectItem o2) 
	      {
	        return o1.getProjectName().compareTo(o2.getProjectName());
	      }
	    });
	    projectNameColumn.setFieldUpdater(new FieldUpdater<ProjectItem, String>()
	    {
	    	public void update(int index, ProjectItem object, String value)
	    	{
	    		projectName = object.getProjectName();
	    		if(value == null)
	    		{
	    			value = "";
	    		}
	    		else
	    		{
	    			UpdateProjectServiceAsync service = UpdateProjectService.Util.getInstance();
	    			service.updateProjectName(object.getProjectId(), value.trim(), updateProjectNameCallback);
	    		}
	    	}
	    });
	    table.addColumn(projectNameColumn, "Project Name");	    
	    table.setColumnWidth(projectNameColumn, 20, Unit.PCT);
	    
	    // Description
	    //Column<ProjectItem, String> descriptionColumn = new Column<ProjectItem, String>(new EditTextCell()) 
	    Column<ProjectItem, String> descriptionColumn = new Column<ProjectItem, String>(new TextCell())
	    {	    
	      public String getValue(ProjectItem object) 
	      {
	        return object.getDescription();
	      }
	    };	   
	    descriptionColumn.setFieldUpdater(new FieldUpdater<ProjectItem, String>()
	    {
	    	public void update(int index, ProjectItem object, String value)
	    	{
	    		projectDescription = object.getDescription();
	    		if(value == null)
	    		{
	    			value = "";
	    		}
	    		else
	    		{
	    			UpdateProjectServiceAsync service = UpdateProjectService.Util.getInstance();
	    			service.updateProjectDescription(object.getProjectId(), value.trim(), updateProjectDescriptionCallback);
	    		}
	    	}
	    });
	    table.addColumn(descriptionColumn, "Description");
	    table.setColumnWidth(descriptionColumn, 60, Unit.PCT);
	    
	  }
	  
	  AsyncCallback<int[]> updateProjectNameCallback = new AsyncCallback<int[]>()
	  {
		  public void onFailure(Throwable arg0)
		  {
			  System.out.print(arg0.toString());
			  Log.info("ProjectList updateProjectNameCallback: " +  arg0.toString());
		  }
		  public void onSuccess(int[] flag)
		  {
			  if(flag[0] == 0)
			  {
				  lblMsg.setText("Project name is updated.");
			  }
			  else
			  {
				  Iterator<ProjectItem> itr = dataProvider.getList().iterator();
				  int index = 0;
				  while(itr.hasNext())
				  {
					  ProjectItem item = itr.next();
					  int projectId = item.getProjectId();
					  if(projectId == flag[1])
					  {
						  item.setProjectName(projectName);
						  dataProvider.getList().set(index, item);
						  break;
					  }
					  index = index + 1;
				  }
				  dataProvider.refresh();
				  lblMsg.setText("Project name already exists. Please choose another project name.");
			  }
		  }
	  };
	  
	  AsyncCallback<int[]> updateProjectDescriptionCallback = new AsyncCallback<int[]>()
	  {
		  public void onFailure(Throwable arg0)
		  {
			  System.out.print(arg0.toString());
			  Log.info("ProjectList updateProjectDescriptionCallback: " + arg0.toString());
		  }
		  public void onSuccess(int[] flag)
		  {
			  if(flag[0] == 0)
			  {
				  lblMsg.setText("Project description is updated.");
			  }
			  else
			  {
				  Iterator<ProjectItem> itr = dataProvider.getList().iterator();
				  int index = 0;
				  while(itr.hasNext())
				  {
					  ProjectItem item = itr.next();
					  int projectId = item.getProjectId();
					  if(projectId == flag[1])
					  {
						  item.setDescription(projectDescription);
						  dataProvider.getList().set(index, item);
						  break;
					  }
					  index = index + 1;
				  }
				  dataProvider.refresh();
				  lblMsg.setText("Error in the update of project description. Please try again later.");
			  }
		  }
	  };
		
	//Call back of delete users request - Updates the list (Table display) with users deleted 
	AsyncCallback<ArrayList<Integer>> deleteProjectsCallback = new AsyncCallback<ArrayList<Integer>>()
	{
		public void onFailure(Throwable caught)
		{
			Log.info("ProjectList deleteProectsCallback error: " + caught.toString());
		}
		public void onSuccess(ArrayList<Integer> projectIds)
		{
			User currentUser = ctx.getCurrentUser();
			ProjectItems projectItems = currentUser.getProjectItems();
			
			if(projectIds != null)
			{
				if(projectIds.size() > 0)
				{
					List<ProjectItem> projectList = dataProvider.getList();
					Iterator<ProjectItem> itr = projectList.iterator();
					int index = 0;
					lblMsg.setText("All the selected projects are deleted.");
					for(int cnt  =  0; cnt < projectIds.size(); cnt++)
					{
						int projectId = projectIds.get(cnt);
						projectItems.deleteProjectItem(projectId);
						
						projectList = dataProvider.getList();
						itr = projectList.iterator();
						index = 0;
						
						while(itr.hasNext())
						{
							ProjectItem project = itr.next();
							if(project.getProjectId() == projectId)
							{
								break;
							}
							index = index + 1;
						}
						dataProvider.getList().remove(index);					
					}
					dataProvider.refresh();					
					currentUser.setProjectItems(projectItems);
					ctx.setCurrentUser(currentUser);
				}
				else
				{
					lblMsg.setText("Error in deleting selected users. Please try again later.");
				}				
			}						
		}
	};
}
