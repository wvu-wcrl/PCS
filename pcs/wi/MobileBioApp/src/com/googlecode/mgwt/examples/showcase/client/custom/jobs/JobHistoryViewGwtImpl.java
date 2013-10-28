/*
 * File: JobDetails.java

Purpose: To display the job attributes and provide links to input and output files.
**********************************************************/

package com.googlecode.mgwt.examples.showcase.client.custom.jobs;

import java.util.Date;
import java.util.List;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.cell.client.TextCell;
import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.user.cellview.client.CellTable;
import com.google.gwt.user.cellview.client.Column;
import com.google.gwt.user.cellview.client.ColumnSortList;
import com.google.gwt.user.cellview.client.SimplePager;
import com.google.gwt.user.cellview.client.ColumnSortEvent.AsyncHandler;
import com.google.gwt.user.cellview.client.SimplePager.TextLocation;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.view.client.AsyncDataProvider;
import com.google.gwt.view.client.CellPreviewEvent;
import com.google.gwt.view.client.DefaultSelectionEventManager;
import com.google.gwt.view.client.HasData;
import com.google.gwt.view.client.MultiSelectionModel;
import com.google.gwt.view.client.SelectionModel;
import com.google.gwt.view.client.CellPreviewEvent.Handler;
import com.googlecode.mgwt.examples.showcase.client.ChromeWorkaround;
import com.googlecode.mgwt.examples.showcase.client.ClientFactory;
import com.googlecode.mgwt.examples.showcase.client.DetailViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.ClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.RPCClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.User;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.FormatDate;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.service.GetPageService;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.service.GetPageServiceAsync;
import com.googlecode.mgwt.ui.client.MGWT;
import com.googlecode.mgwt.ui.client.widget.WidgetList;

public class JobHistoryViewGwtImpl extends DetailViewGwtImpl implements JobHistoryView { 

	private CellTable<JobItem> table;
	private CustomSimplePager pager;
	private CustomSimplePager topPager;	
	//Number of jobs to display in a page
	private int VISIBLE_JOB_COUNT = 25;
	private VerticalPanel vPanel;
	private Label lblMsg;	
	private ClientContext ctx;
	private User currentUser;
	
	private final SelectionModel<JobItem> selectionModel = new MultiSelectionModel<JobItem>();
	private ColumnSortList sortList;
	
	//List of timers for active jobs
	private int tab;
	
	private int Start;
	//private int from;
	private MyDataProvider dataProvider;
	//private int counter;
	private ClientFactory clientFactory;
	
	public JobHistoryViewGwtImpl(final ClientFactory clientFactory) {
		
		if(ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync != null)
		{
			System.out.println("Stopping ServerGeneratedMessageEventService");
  		    ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync.stop(VoidAsyncCallback);
  		    ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync = null;
	    }
		
		this.clientFactory = clientFactory;
		
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{
			//this.start = start;
			//This is required to know if the request to view the Job details came from the User view or Administrator view
			//this.tabNumber = tabNumber;
			//Get and set the current user context
			ctx = (ClientContext) RPCClientContext.get();

			if (ctx != null) 
			{			
				currentUser = ctx.getCurrentUser();	
				
				headerPanel.setLeftWidget(headerBackButton);
				FlowPanel container = new FlowPanel();
			    container.getElement().getStyle().setMarginTop(20, Unit.PX);
				  
				scrollPanel.setScrollingEnabledX(false);
				scrollPanel.setWidget(container);
				// workaround for android formfields jumping around when using
				// -webkit-transform
				scrollPanel.setUsePos(MGWT.getOsDetection().isAndroid());
				ChromeWorkaround.maybeUpdateScroller(scrollPanel);
				
				WidgetList widgetList = new WidgetList();  
				container.add(widgetList);
				
				vPanel = new VerticalPanel();	
				widgetList.add(vPanel);
				
				/*HTML header = new HTML("Job Details");
				header.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
				container.add(header);
				
				WidgetList widgetList = new WidgetList();  
				container.add(widgetList);
				
				Button button = new Button("Get data");
				widgetList.add(button);
				
				button.addTapHandler(new TapHandler(){
					  public void onTap(TapEvent event) {
						  System.out.println("To JobDetails");
						  clientFactory.getPlaceController().goTo(new JobDetailsPlace());
					  }  
				  });*/
				getJobList();
				
			} 
			else
			{
				clientFactory.getPlaceController().goTo(new ElementsPlace());
			}
		}
		else
		{
			clientFactory.getPlaceController().goTo(new ElementsPlace());
		}
	}
	
	AsyncCallback<Void> VoidAsyncCallback = new AsyncCallback<Void>() {
  	  public void onFailure(Throwable aThrowable) {}
  	  public void onSuccess(Void aResult) {}
    };
  
	
	public void getJobList() 
	{			
		lblMsg = new Label();
		lblMsg.addStyleName("warnings");	
	    
	    VerticalPanel panel = new VerticalPanel();
		
		panel.setSize("100%", "100%");
		panel.setSpacing(10);
		panel.add(lblMsg);
		//Initialize the CellTable
		table = (CellTable<JobItem>) onInitialize();
		table.addStyleName("hand");
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
					clientFactory.getPlaceController().goTo(new JobDetailsPlace(item));
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
	  
	    // Create a data provider.
	    dataProvider = new MyDataProvider();
	    // Add the cellList to the dataProvider.
	    dataProvider.addDataDisplay(table);	 
	    return table;
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
						//counter++;						
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
						//System.out.println("Items: " + result.size() + " From: " + from + " Start: " + Start + "  start: " + start);
						updateRowData(start, result);									
						System.out.println("End: " + new Date());
						service.getJobNumber(jobCountCallback);
					}
				};
				
				
				// The remote service that should be implemented
				/*if(from == 0)
				{					
					from = -1;
					Log.info("Start: " + Start + " End: " + (Start + length) + " Date: " + new Date() + " user: " + currentUser.getUsername());
					service.getPage(Start, Start + length, !sortList.get(0).isAscending(), "All", currentUser.getUsername(), "plbp", tab, callback);
				}
				else
				{
					Start = start;
					Log.info("@@@Start: " + start + " End: " + (start + length) + " Date: " + new Date() + " user: " + currentUser.getUsername());
					service.getPage(start, start + length, !sortList.get(0).isAscending(), "All", currentUser.getUsername(), "plbp", tab, callback);
				}*/	
				Start = start;
				Log.info("@@@Start: " + start + " End: " + (start + length) + " Date: " + new Date() + " user: " + ((ClientContext) RPCClientContext.get()).getCurrentUser().getUsername());
				service.getPage(start, start + length, !sortList.get(0).isAscending(), "All", currentUser.getUsername(), "plbp", tab, callback);
		    }
	 }
	
	  /**
	   * Add the columns to the table.
	   */
	private void initTableColumns(final SelectionModel<JobItem> selectionModel, AsyncHandler sortHandler)	
	  {	  
	    
	    // JobName.
	    Column<JobItem, String> id = new Column<JobItem, String>(new TextCell()) 
	    {	    
	      public String getValue(JobItem object) 
	      {
	        return new Integer(object.getId()).toString();
	      }
	    };	    
	    table.addColumn(id, "Serial #");
	    table.setColumnWidth(id, 30, Unit.PCT);
	  	  
	    // UploadDate	    
	    Column<JobItem, String> dateColumn = new Column<JobItem, String>(new TextCell()) 
	    {	    
	      public String getValue(JobItem object) 
	      {
	    	  long lastModified = object.getLastModified();
	    	  Date date = new Date(lastModified);
	    	  FormatDate fd = new FormatDate();
	    	  DateTimeFormat fmt = fd.shortFormatDate(date);
	    	  return fmt.format(date).toString();
	    	  /*DateTimeFormat fmt = formatDate(date);
	    	  return fmt.format(date).toString();*/
	    	  //return date.toString();
	      }
	    };	    
	    dateColumn.setSortable(true);
	    table.getColumnSortList().push(dateColumn);	    
	    table.addColumn(dateColumn, "Last Modified");
	    table.setColumnWidth(dateColumn, 35, Unit.PCT);	   
	    
	    // Status
	    Column<JobItem, String> statusColumn = new Column<JobItem, String>(new TextCell())
	    {
	    	public String getValue(JobItem object)
	    	{
	    		return object.getStatus();
	    	}
	    };
	    table.addColumn(statusColumn, "Status");
	    table.setColumnWidth(statusColumn, 35, Unit.PCT);    	    
	  }
	
}