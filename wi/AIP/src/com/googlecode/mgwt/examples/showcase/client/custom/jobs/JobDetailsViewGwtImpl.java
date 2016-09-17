/*
 * File: JobDetails.java

Purpose: To display the job attributes and provide links to input and output files.
**********************************************************/

package com.googlecode.mgwt.examples.showcase.client.custom.jobs;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.ui.*;
import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.googlecode.mgwt.examples.showcase.client.ChromeWorkaround;
import com.googlecode.mgwt.examples.showcase.client.ClientFactory;
import com.googlecode.mgwt.examples.showcase.client.DetailViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.ClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.RPCClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.User;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.FormatDate;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.service.GetJobDetailsService;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.service.GetJobDetailsServiceAsync;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.service.ServerMessageGeneratorService;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.service.ServerMessageGeneratorServiceAsync;
import com.googlecode.mgwt.ui.client.MGWT;
import com.googlecode.mgwt.ui.client.MGWTStyle;
import com.googlecode.mgwt.ui.client.widget.WidgetList;

import de.novanic.eventservice.client.event.Event;
import de.novanic.eventservice.client.event.RemoteEventService;
import de.novanic.eventservice.client.event.RemoteEventServiceFactory;
import de.novanic.eventservice.client.event.listener.RemoteEventListener;

public class JobDetailsViewGwtImpl extends DetailViewGwtImpl implements JobDetailsView { 

	private VerticalPanel panel;
	//private VerticalPanel headerPanel;	
	private VerticalPanel detailsPanel;
	private VerticalPanel topPanel;
	private HorizontalPanel jobDetailsPanel;
	private FlexTable table;	
	private HTML txtWarnings;
	private JobItem jobItem;
	private ClientContext ctx;
	private User currentUser;
	private int input;
	private int output;
	private int col;
	//private ServerMessageGeneratorServiceAsync theServerMessageGeneratorServiceAsync;
	//private String statusDirectory;
	//private FlowPanel inputPanelImages;
	//private FlowPanel outputPanelImages;

	//public JobDetails(JobItem item, String statusDirectory, int start, int tabNumber, String selectUser, String selectProject) 
	public JobDetailsViewGwtImpl(final ClientFactory clientFactory) {
	
		//this.statusDirectory = "Done";
		//this.jobStatusDirectory = statusDirectory;
		//this.selectUser = selectUser;
		//this.selectProject = selectProject;
		System.out.println("In Job details");
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
								
				jobDetailsPanel = new HorizontalPanel();
				panel = new VerticalPanel();
				jobDetailsPanel.add(panel);				
				//inputPanelImages = new FlowPanel();
				//outputPanelImages = new FlowPanel();
				
				headerPanel.setLeftWidget(headerBackButton);
				FlowPanel container = new FlowPanel();
			    container.getElement().getStyle().setMarginTop(20, Unit.PX);
				  
				scrollPanel.setScrollingEnabledX(false);
				scrollPanel.setWidget(container);
				// workaround for android formfields jumping around when using
				// -webkit-transform
				scrollPanel.setUsePos(MGWT.getOsDetection().isAndroid());
				ChromeWorkaround.maybeUpdateScroller(scrollPanel);
				
				HTML header = new HTML("Job Details");
				header.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
				container.add(header);
				
				WidgetList widgetList = new WidgetList();  
				container.add(widgetList);
				container.add(jobDetailsPanel);
				
				Place place = clientFactory.getPlaceController().getWhere();
				
				if(place.getClass() == JobDetailsPlace.class)
				{
					if(((JobDetailsPlace)place).getItem() != null)
					{
						this.jobItem = ((JobDetailsPlace)place).getItem();
						System.out.println("Job Id: " + jobItem.getJobId() + " User: " + jobItem.getUsername());
						
						GetJobDetailsServiceAsync service = GetJobDetailsService.Util.getInstance();
						service.getJobDetails(this.jobItem, 1, callback);
					}
					else
					{
						clientFactory.getPlaceController().goTo(new JobHistoryPlace());
					}
				}
				else
				{
					clientFactory.getPlaceController().goTo(new JobHistoryPlace());
				}
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
	
	AsyncCallback<JobItem> callback = new AsyncCallback<JobItem>() 
	{
		public void onFailure(Throwable caught) 
		{
			Window.alert(caught.getMessage());
		}
		
		public void onSuccess(JobItem item) 
		{
			String status = item.getStatus();
			System.out.println("In job details: " + item + " " + item.getJobName() + " statusDirectory: " + status);
			 
			
			jobItem = item;
			
			if(!status.equalsIgnoreCase("Done") || !status.equalsIgnoreCase("Failed"))
			//if(statusDirectory.equalsIgnoreCase("Queued") || statusDirectory.equalsIgnoreCase("Running") || statusDirectory.equalsIgnoreCase("Suspended"))
			{
				/*if(ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync != null)
				{
					System.out.println("In job details ServerGeneratedMessageEventService not null");
					ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync.stop(VoidAsyncCallback);
					
					//starting the generation of Hello messages from the server
					ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync = GWT.create(ServerMessageGeneratorService.class);
					ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync.start(item, VoidAsyncCallback);
				}
				else
				{
					System.out.println("In job details ServerGeneratedMessageEventService null");
					//starting the generation of Hello messages from the server
					ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync = GWT.create(ServerMessageGeneratorService.class);
					ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync.start(item, VoidAsyncCallback);
				}*/
				System.out.println("@@@@@@@@@@@@@@@ Job Details theServerMessageGeneratorServiceAsync : " + ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync);
				if(ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync == null)
				{
					ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync = GWT.create(ServerMessageGeneratorService.class);
					ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync.start(item, VoidAsyncCallback);
				}
				
				
				/*//starting the generation of Hello messages from the server
				ServerMessageGeneratorServiceAsync theServerMessageGeneratorServiceAsync = GWT.create(ServerMessageGeneratorService.class);
		        theServerMessageGeneratorServiceAsync.start(item, VoidAsyncCallback);*/
				final RemoteEventService theRemoteEventService = RemoteEventServiceFactory.getInstance().getRemoteEventService();
		        //add a listener to the SERVER_MESSAGE_DOMAIN
				theRemoteEventService.removeListeners();
		    	theRemoteEventService.addListener(ServerGeneratedMessageEvent.SERVER_MESSAGE_DOMAIN, new RemoteEventListener() {
		            public void apply(Event anEvent) {
		                if(anEvent instanceof ServerGeneratedMessageEvent) {
		                    ServerGeneratedMessageEvent theServerGeneratedMessageEvent = (ServerGeneratedMessageEvent)anEvent;
		                    System.out.println("##### After receiving item event for " + theRemoteEventService);
		                    setJobValues(theServerGeneratedMessageEvent.getMyServerGeneratedEvent());
		                }
		            }
		        });
				
			}	
	        init();
			setJobValues(item);
		}
	};
	
	AsyncCallback<Void> VoidAsyncCallback = new AsyncCallback<Void>()
	{
		public void onFailure(Throwable aThrowable) {}

	    public void onSuccess(Void aResult) {
	    	/* Logic for GWTEventService starts here 
	        //get the RemoteEventService for registration of RemoteEventListener instances
	    	if(ServerGeneratedMessageEventService.theRemoteEventService == null)
	    	{
	    		ServerGeneratedMessageEventService.theRemoteEventService = RemoteEventServiceFactory.getInstance().getRemoteEventService();
		        //add a listener to the SERVER_MESSAGE_DOMAIN
		    	ServerGeneratedMessageEventService.theRemoteEventService.addListener(ServerGeneratedMessageEvent.SERVER_MESSAGE_DOMAIN, new RemoteEventListener() {
		            public void apply(Event anEvent) {
		                if(anEvent instanceof ServerGeneratedMessageEvent) {
		                    ServerGeneratedMessageEvent theServerGeneratedMessageEvent = (ServerGeneratedMessageEvent)anEvent;
		                    setJobValues(theServerGeneratedMessageEvent.getMyServerGeneratedEvent());
		                }
		            }
		        });
	    		
	    	}*/
	    }
	};
		

	//Initialize and set the components
	private void init() 
	{
		System.out.println("In job details init");
		if(currentUser != null)
		{			
			//headerPanel = new VerticalPanel();
			detailsPanel = new VerticalPanel();
			topPanel = new VerticalPanel();
			//jobDetailsPanel = new HorizontalPanel();
			table = new FlexTable();	
			
			txtWarnings = new HTML();

			table.setCellSpacing(5);
			
			table.setCellPadding(0);
			table.setWidth("100%");
			//jobDetailsPanel.setSize("100%", "75%");

			txtWarnings.setVisible(false);
						
			//setTableRowWidget(0, 0, new HTML("<b>Job Name:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(1, 0, new HTML("<b>JobId:</b>&nbsp;&nbsp;&nbsp;"));
			//setTableRowWidget(2, 0, new HTML("<b>Project:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(3, 0, new HTML("<b>Start time:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(4, 0, new HTML("<b>Last modified:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(5, 0, new HTML("<b>Stop time:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(6, 0, new HTML("<b>Process duration:</b>&nbsp;&nbsp;&nbsp;"));
		//	HTML notesLabel = new HTML("<b>Notes:</b>&nbsp;&nbsp;&nbsp;");
		//	notesLabel.setVisible(false);
			//setTableRowWidget(7, 0, notesLabel);	
			setTableRowWidget(7, 0, new HTML("<b>Matching Score:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(8, 0, new HTML("<b>Status:</b>&nbsp;&nbsp;&nbsp;"));
			
			
		
			detailsPanel.add(table);
			detailsPanel.add(new HTML("<br><br><br>"));

			DockPanel innerPanel = new DockPanel();
			innerPanel.add(detailsPanel, DockPanel.CENTER);
		
			innerPanel.setCellHeight(detailsPanel, "100%");
			
			panel.add(txtWarnings);
			txtWarnings.setStylePrimaryName("progressbar-text");
			txtWarnings.setStylePrimaryName("message");
			panel.add(topPanel);
			panel.add(innerPanel);
			panel.add(table);
			/*System.out.println("In job details init check: " + table.getText(0, 0));*/
			innerPanel.setSize("100%", "100%");
			detailsPanel.setSize("100%", "100%");
			jobDetailsPanel.setCellHorizontalAlignment(panel, HasHorizontalAlignment.ALIGN_CENTER);	

			//setStyleName("mail-Detail");
			innerPanel.setStyleName("mail-DetailInner");		
		}		
	}
	
	private void setJobValues(JobItem jobItem)
	{
		System.out.println("In setting job values: " + jobItem + " status: " + jobItem.getStatus());
		int cnt = 9;
		col = cnt;
		LinkedHashMap<String, String> itemData = jobItem.getColumns();
		
		if(itemData != null)
		{
			Set<Entry<String, String>> entrySet = itemData.entrySet();
			for(Entry<String, String> entry : entrySet)
			{
				String key = entry.getKey();
				setTableRowWidget(cnt, 0, new HTML("<b>" + key + ":</b>&nbsp;&nbsp;&nbsp;"));
				cnt++;
			}
		}
		
		input = cnt;
		output = cnt+1;
		//setTableRowWidget(cnt, 0, new HTML("<b>File(s):</b>&nbsp;&nbsp;&nbsp;"));
		
		//setTableRowText(0, 1, jobItem.getJobName());
		setTableRowText(1, 1, Integer.valueOf(jobItem.getJobId()).toString());		
		
		//setTableRowText(2, 1, jobItem.getProjectName());
		Date lastModifiedDate = new Date(jobItem.getLastModified());
		setTableRowText(3, 1, jobItem.getStartTime());
		FormatDate dt = new FormatDate();
		DateTimeFormat fmt = dt.formatDate(lastModifiedDate);
  	  	fmt.format(lastModifiedDate).toString();
		//System.out.println("########################### last modified: " +  fmt.format(lastModifiedDate).toString());
		setTableRowText(4, 1, fmt.format(lastModifiedDate).toString());
		setTableRowText(5, 1, jobItem.getStopTime());
		String duration = "";
		if(jobItem.getProcessDuration() != null)
		{
			try
			{
				double pd = Double.parseDouble(jobItem.getProcessDuration());
				if(pd > 0)
				{
					duration = jobItem.getProcessDuration() + " seconds";
				}
			}
			catch(NumberFormatException e)
			{
				System.out.println("Process duration value not a number.");
				Log.info("Process duration value not a number.");
			}
			//duration = jobItem.getProcessDuration() + " seconds";
		}
		setTableRowText(6, 1, duration);
		
		String MatchingScore=jobItem.getMatchingScore();
		setTableRowText(7, 1, MatchingScore);
		
		String statusStr = jobItem.getStatus();
		
		setTableRowText(8, 1, statusStr);
		
		if(itemData != null)
		{
			int temp = col;
			Set<Entry<String, String>> entrySet = itemData.entrySet();
			for(Entry<String, String> entry : entrySet)
			{
				String key = entry.getKey();
				HTML value = new HTML();
				value.setText(entry.getValue());
				//System.out.println("Getting data: " + key + " " + value);
				if(key.equalsIgnoreCase("Usage"))
				{
					value.setText(entry.getValue() + " seconds");
					setTableRowText(temp, 1, value);
				}
				else
				{
					setTableRowText(temp, 1, value);
				}
				temp++;
			}
		}
		
		if(this.jobItem.getInputFiles().size() > 0)
		{
			System.out.println("!!!!!!!!!!!!!!!!!!!! Getting the Images");
			setTableRowWidget(input, 0, new HTML("<b>Input image:</b>&nbsp;&nbsp;&nbsp;"));
			displayInputFiles(jobItem);
		}
		
		if(jobItem.getOutputFiles().size() > 1)
		{
			//System.out.println("!!!!!!!!!!!!!!!!!!!!");
			setTableRowWidget(output, 0, new HTML("<b>Output image(s):</b>&nbsp;&nbsp;&nbsp;"));
			displayOutputFiles(jobItem);
		}
	}	
	
	private void displayInputFiles(JobItem jobItem) 
	{
		table.setWidget(input, 1, displayFiles(jobItem.getJobName(), jobItem.getInputFiles()));			
		table.getCellFormatter().setHorizontalAlignment(input, 1, HasHorizontalAlignment.ALIGN_LEFT);
		table.getCellFormatter().setVerticalAlignment(input, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	}
	
	private void displayOutputFiles(JobItem jobItem) 
	{
		table.setWidget(output, 1, displayFiles(jobItem.getJobName(), jobItem.getOutputFiles()));			
		table.getCellFormatter().setHorizontalAlignment(output, 1, HasHorizontalAlignment.ALIGN_LEFT);
		table.getCellFormatter().setVerticalAlignment(output, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	}
	
	private Widget displayFiles(final String fileName, final Map<Integer, String[]> files) 
	{
		final FlexTable filesTable = new FlexTable();
		filesTable.setCellSpacing(0);
		filesTable.setCellPadding(0);
				
		System.out.println("Display files");
		List<Map.Entry<Integer, String[]>> list = new LinkedList<Map.Entry<Integer, String[]>>(files.entrySet());
    	
    	//Sort files by Filename
    	Collections.sort(list, new Comparator<Map.Entry<Integer, String[]>>() 
	    {
    		public int compare(Map.Entry<Integer, String[]> o1, Map.Entry<Integer, String[]> o2)
    		{
    			String[] a = (String[]) ((Map.Entry<Integer, String[]>) (o1)).getValue();
    			String[] b = (String[]) ((Map.Entry<Integer, String[]>) (o2)).getValue();
    			return a[0].compareTo(b[0]);
    		}
    	});
    	
    	/*
    	 * Add files to a table for display
    	 */
    	int i = 0;
    	for (Iterator<Entry<Integer, String[]>> it = list.iterator(); it.hasNext();)
		{
			Map.Entry<Integer, String[]> entry = (Map.Entry<Integer, String[]>)it.next();
			String[] fileData = entry.getValue();
			if(!fileData[0].endsWith(".mat"))
			{
				System.out.println("########### fileData[1]: " + fileData[1] + " and: fileData[0] " + fileData[0] + " ##########");
				Log.info("########### fileData[1]: " + fileData[1] + " and: fileData[0] " + fileData[0] + " ##########");
				//HTML file = new HTML("<a href = '" + fileData[1] + "' target='_blank'>" + fileData[0] + "</a>");
				HTML file;
				ArrayList<String> imageType = new ArrayList<String>();
				imageType.add(".jpg");
				imageType.add(".JPG");
				imageType.add(".jpeg");
				imageType.add(".JPEG");
				imageType.add(".gif");
				imageType.add(".GIF");
				imageType.add(".bmp");
				imageType.add(".BMP");
				imageType.add(".png");
				imageType.add(".PNG");
			//	imageType.add(".tiff");
			//	imageType.add(".TIFF");
				int c = imageType.size();
				boolean imageBool = false;
				for(int j = 0; j < c; j++)
				{
					String type = imageType.get(j);
					if(fileData[0].endsWith(type))
					{
						imageBool = true;
						break;
					}
				}
				if(imageBool)
				{
					
					file = new HTML("<img src = '" + fileData[1] + "' target='_blank' height='100' width='100' alt='" + fileData[0] + "'</img>");
					if(i == 0)
					{
						filesTable.setWidget(0, i, file);
						i++;
					}
					else
					{
						HTML space = new HTML("&nbsp;&nbsp;&nbsp;");
						filesTable.setWidget(0, i, space);
						i++;
						filesTable.setWidget(0, i, file);
						i++;
						System.out.println("Path: " + fileData[1]);
						filesTable.getCellFormatter().setHorizontalAlignment(i, 0, HasHorizontalAlignment.ALIGN_LEFT);
						filesTable.getCellFormatter().setVerticalAlignment(i, 0, HasVerticalAlignment.ALIGN_TOP);
					}
				}
				else
				{
					Log.info("Image Type :" + imageBool);
					file = new HTML("<a href = '" + fileData[1] + "' target='_blank'>" + fileData[0] + "</a>");
					filesTable.setWidget(i, 0, file);
					System.out.println("Path: " + fileData[1]);
					Log.info("Path: " + fileData[1]);
					filesTable.getCellFormatter().setHorizontalAlignment(i, 0, HasHorizontalAlignment.ALIGN_LEFT);
					filesTable.getCellFormatter().setVerticalAlignment(i, 0, HasVerticalAlignment.ALIGN_TOP);
					i++;
				}
			}				    			
		}			
		return filesTable;
	}	

	private void setTableRowText(int row, int column, String text)
	{
		table.setText(row, column, text);
		table.getCellFormatter().setHorizontalAlignment(row, column, HasHorizontalAlignment.ALIGN_LEFT);
		table.getCellFormatter().setVerticalAlignment(row, column, HasVerticalAlignment.ALIGN_TOP);
	}
	private void setTableRowText(int row, int column, HTML widget)
	{
		table.setWidget(row, column, widget);
		table.getCellFormatter().setHorizontalAlignment(row, column, HasHorizontalAlignment.ALIGN_LEFT);
		table.getCellFormatter().setVerticalAlignment(row, column, HasVerticalAlignment.ALIGN_TOP);
	}
	private void setTableRowWidget(int row, int column, Widget widget)
	{
		table.setWidget(row, column, widget);
		table.getCellFormatter().setHorizontalAlignment(row, column, HasHorizontalAlignment.ALIGN_RIGHT);
		table.getCellFormatter().setVerticalAlignment(row, column, HasVerticalAlignment.ALIGN_TOP);		
	}
}