package com.wcrl.web.cml.client.admin.account;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ChangeEvent;
import com.google.gwt.event.dom.client.ChangeHandler;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.safehtml.shared.SafeHtmlBuilder;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.accountService.ClusterStatusService;
import com.wcrl.web.cml.client.admin.accountService.ClusterStatusServiceAsync;
import com.wcrl.web.cml.client.login.Login;

public class ClusterStatus extends Composite implements ChangeHandler, ClickHandler
{
	private ClientContext ctx;
	private User currentUser;
	private VerticalPanel vPanel;	
	private Label lblMessage;	
	private Label lblStatus;
	private ListBox lstQueue;	
	private HTML lblStatusOutput;
	private Button btnStatus;
		
	public ClusterStatus()
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
		    		vPanel.setHorizontalAlignment(HorizontalPanel.ALIGN_LEFT);
		    	    vPanel.setVerticalAlignment(VerticalPanel.ALIGN_TOP);		    	    
		       	}
		    }
		}
		else
		{
			Login login = new Login();
			login.displayLoginBox();
		}				
	} 
	
	//Create the display components
	public void createComponents()
	{
		lblMessage = new Label();
		lblStatus = new Label("Queue: ");
		lblStatusOutput = new HTML();
		lstQueue = new ListBox();
		lstQueue.addItem("Long", "0");
		lstQueue.addItem("Short", "1");
		lstQueue.setItemSelected(0, true);
		//lstQueue.addChangeHandler(this);
		btnStatus = new Button("Get status");	
		btnStatus.addClickHandler(this);
		
		FlexTable table = new FlexTable();
		table.getCellFormatter().setHorizontalAlignment(0, 0, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(0, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(0, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(0, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(0, 2, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(0, 2, HasVerticalAlignment.ALIGN_MIDDLE);
	    
	    table.setWidget(0, 0, lblStatus);
	    table.setWidget(0, 1, lstQueue);
	    table.setWidget(0, 2, btnStatus);
	    
		/*HorizontalPanel hPanel = new HorizontalPanel();
		hPanel.add(lblStatus);
		hPanel.add(lstQueue);
		hPanel.add(btnStatus);*/
		
		vPanel.add(lblMessage);
		//vPanel.add(hPanel);
		vPanel.add(table);
		vPanel.add(lblStatusOutput);
		
		ClusterStatusServiceAsync service = ClusterStatusService.Util.getInstance();
		service.getClusterStatus(lstQueue.getItemText(lstQueue.getSelectedIndex()).toLowerCase(), clusterStatusCallback);
	}

	public void onChange(ChangeEvent event) 
	{
		Widget source = (Widget) event.getSource();
		
		if(source == lstQueue)
		{
			ClusterStatusServiceAsync service = ClusterStatusService.Util.getInstance();
			service.getClusterStatus(lstQueue.getItemText(lstQueue.getSelectedIndex()).toLowerCase(), clusterStatusCallback);
		}
	}
	
	AsyncCallback<String> clusterStatusCallback = new AsyncCallback<String>()
	{
		public void onFailure(Throwable caught)
		{
			Log.info("Cluster status clusterStatusCallback error: " + caught.toString());
		}
		
		public void onSuccess(String output)
		{
			//Log.info("Cluster status output in callback: " + output);			
			lblStatusOutput.setHTML(new SafeHtmlBuilder().appendEscapedLines(output).toSafeHtml());					
		}
	};

	@Override
	public void onClick(ClickEvent event) 
	{
		Widget source = (Widget) event.getSource();
		
		if(source == btnStatus)
		{
			ClusterStatusServiceAsync service = ClusterStatusService.Util.getInstance();
			service.getClusterStatus(lstQueue.getItemText(lstQueue.getSelectedIndex()).toLowerCase(), clusterStatusCallback);
		}
		
	}
}