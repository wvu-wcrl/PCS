package com.googlecode.mgwt.examples.showcase.client.header;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.googlecode.mgwt.examples.showcase.client.ClientFactory;
import com.googlecode.mgwt.examples.showcase.client.DetailViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.RPCClientContext;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.service.UserValidationService;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.service.UserValidationServiceAsync;
import com.googlecode.mgwt.examples.showcase.client.settings.ChangePasswordPlace;

public class HeaderRightWidgetPanelViewGwtImpl extends DetailViewGwtImpl implements HeaderRightWidgetPanelView, ClickHandler {
	
	private VerticalPanel panel;
	private HTML username;
	private Anchor settings;
	private Anchor signout;
	private ClientFactory clientFactory;
	
	public HeaderRightWidgetPanelViewGwtImpl(ClientFactory clientFactory) {
		this.clientFactory = clientFactory;
		
		username = new HTML("eman");
		settings = new Anchor("Settings");
		signout = new Anchor("Sign out");
		
		panel = new VerticalPanel();
		panel.add(username);
		panel.add(settings);
		panel.add(signout);
		
		
		settings.addClickHandler(this);
		signout.addClickHandler(this);
	}


	public VerticalPanel getPanel() {
		return panel;
	}


	public void setPanel(VerticalPanel panel) {
		this.panel = panel;
	}


	@Override
	public void onClick(ClickEvent event) {
		Object widget = event.getSource();
		
		if(widget == settings)
		{
			clientFactory.getPlaceController().goTo(new ChangePasswordPlace());
		}
		if(widget == signout)
		{		
			resetContext();
			UserValidationServiceAsync service = UserValidationService.Util.getInstance();			
			service.clearSession(sessionCallback);
		}		
	}
	
	private void resetContext() 
	{	  
		RPCClientContext.set(null);
	}	
	
	AsyncCallback<Boolean> sessionCallback = new AsyncCallback<Boolean>() {
		public void onFailure(Throwable arg0) {
			Log.info("HeaderRight usersCallback error: " +arg0.toString());
		}
		public void onSuccess(Boolean bool) {
			if(bool)
			{
				Cookies.removeCookie("sid");
				clientFactory.getPlaceController().goTo(new ElementsPlace());			  
			}		  
		}
	};
}
