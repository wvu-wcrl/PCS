package com.googlecode.mgwt.examples.showcase.client.settings;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.Label;
import com.googlecode.mgwt.dom.client.event.tap.TapEvent;
import com.googlecode.mgwt.dom.client.event.tap.TapHandler;
import com.googlecode.mgwt.examples.showcase.client.ChromeWorkaround;
import com.googlecode.mgwt.examples.showcase.client.ClientFactory;
import com.googlecode.mgwt.examples.showcase.client.DetailViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.ClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.RPCClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.User;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;
import com.googlecode.mgwt.examples.showcase.client.settings.service.ChangePasswordService;
import com.googlecode.mgwt.examples.showcase.client.settings.service.ChangePasswordServiceAsync;
import com.googlecode.mgwt.ui.client.MGWT;
import com.googlecode.mgwt.ui.client.MGWTStyle;
import com.googlecode.mgwt.ui.client.widget.Button;
import com.googlecode.mgwt.ui.client.widget.MPasswordTextBox;
import com.googlecode.mgwt.ui.client.widget.WidgetList;

public class ChangePasswordViewGwtImpl extends DetailViewGwtImpl implements ChangePasswordView {
		
	private MPasswordTextBox mCurrentPasswordTextBox;
	private MPasswordTextBox mNewPasswordTextBox;
	private MPasswordTextBox mConfirmPasswordTextBox;
	private Label lblWarning;
	private ClientContext ctx;
	private User currentUser;

	public ChangePasswordViewGwtImpl(final ClientFactory clientFactory) {
		
		ctx = (ClientContext) RPCClientContext.get();	
		String sessionID = Cookies.getCookie("sid");
        Log.info("sessionID: " + sessionID + " ctx: " + ctx); 
	    if(sessionID != null)
	    {
	    	if(ctx != null)
		    {
			    //Set the current user context
			    currentUser = ctx.getCurrentUser();
			    changePassword();
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
	
	private void changePassword() {
		headerPanel.setLeftWidget(headerBackButton);
		FlowPanel container = new FlowPanel();
		container.getElement().getStyle().setMarginTop(20, Unit.PX);
		
		scrollPanel.setScrollingEnabledX(false);
		scrollPanel.setWidget(container);
		// workaround for android formfields jumping around when using
		// -webkit-transform
		scrollPanel.setUsePos(MGWT.getOsDetection().isAndroid());
		ChromeWorkaround.maybeUpdateScroller(scrollPanel);
		
		HTML header = new HTML("Change password");
		header.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
		container.add(header);
		
		WidgetList widgetList = new WidgetList();
		widgetList.setRound(true);
		
		container.add(widgetList);
		
		lblWarning = new Label();
		widgetList.add(lblWarning);
		
		mCurrentPasswordTextBox = new MPasswordTextBox();
		mCurrentPasswordTextBox.setPlaceHolder("Current password");
	    widgetList.add(mCurrentPasswordTextBox);
	    
	    mNewPasswordTextBox = new MPasswordTextBox();
	    mNewPasswordTextBox.setPlaceHolder("New password");
	    widgetList.add(mNewPasswordTextBox);
	    
	    mConfirmPasswordTextBox = new MPasswordTextBox();
	    mConfirmPasswordTextBox.setPlaceHolder("Confirm new password");
	    widgetList.add(mConfirmPasswordTextBox);
	    
	    Button updateButton = new Button("Update");
	    widgetList.add(updateButton);
	    updateButton.addTapHandler(new TapHandler(){

			@Override
			public void onTap(TapEvent event) {
				
				String currentPassword = mCurrentPasswordTextBox.getText().trim();
				String newPassword = mNewPasswordTextBox.getText().trim();				
				String confirmPassword = mConfirmPasswordTextBox.getText().trim();
				
					
				if(currentPassword.length() < 1)
				{
					lblWarning.setText("");
					lblWarning.setText("Please enter current password.");
				}
				else if(!newPassword.equals(confirmPassword) || newPassword.length() < 1)
				{
					lblWarning.setText("");
				    lblWarning.setText("New password doesn't match.");
				}
			    else
			    {
			    	lblWarning.setText("");
			    	System.out.println("current password: " + currentUser.getPassword());
			    	ChangePasswordServiceAsync service = ChangePasswordService.Util.getInstance();   		
		    		service.changePassword(currentUser.getUserId(), newPassword, currentPassword, currentUser.getPassword(), changePasswordCallback);
				}
			}
	    });
	}
	
	
	AsyncCallback<String> changePasswordCallback = new AsyncCallback<String>() {
		public void onFailure(Throwable caught) 
		{
			Log.info("ChangePassword changePasswordCallback error: " +  caught.toString());			
		}
		public void onSuccess(String newPasswdHash)
		{	
			if(newPasswdHash.length() > 0)
			{
				currentUser.setPassword(newPasswdHash);
				ctx.setCurrentUser(currentUser);
				RPCClientContext.set(ctx);
				lblWarning.setText("Password changed.");	
			}		
			else
			{								
				lblWarning.setText("Current password doesn't match.");
			}
		}	
	};
}
