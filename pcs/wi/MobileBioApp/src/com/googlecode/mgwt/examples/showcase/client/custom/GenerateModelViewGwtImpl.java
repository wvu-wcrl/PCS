package com.googlecode.mgwt.examples.showcase.client.custom;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.FormPanel;
import com.google.gwt.user.client.ui.FormPanel.SubmitCompleteEvent;
import com.google.gwt.user.client.ui.FormPanel.SubmitEvent;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.TextBox;
import com.googlecode.mgwt.dom.client.event.tap.TapEvent;
import com.googlecode.mgwt.dom.client.event.tap.TapHandler;
import com.googlecode.mgwt.examples.showcase.client.ChromeWorkaround;
import com.googlecode.mgwt.examples.showcase.client.ClientFactory;
import com.googlecode.mgwt.examples.showcase.client.DetailViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.ClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.RPCClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.User;
import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.service.MasterKeyService;
import com.googlecode.mgwt.examples.showcase.client.custom.service.MasterKeyServiceAsync;
import com.googlecode.mgwt.ui.client.MGWT;
import com.googlecode.mgwt.ui.client.MGWTStyle;
import com.googlecode.mgwt.ui.client.widget.Button;
import com.googlecode.mgwt.ui.client.widget.MPasswordTextBox;
import com.googlecode.mgwt.ui.client.widget.WidgetList;


/**
 * An example of a MultiUploader panel using a very simple upload progress widget
 * The example also uses PreloadedImage to display uploaded images.
 * 
 * @author Manolo Carrasco Moino
 */
public class GenerateModelViewGwtImpl extends DetailViewGwtImpl implements GenerateModelView{

  private static String GENERATEJOB_ACTION_URL = GWT.getModuleBaseURL() + "gupld";
  private Label lblWarning;
  private FormPanel form;
  private ClientContext ctx;
  private User currentUser;
  private ClientFactory clientFactory;

  public GenerateModelViewGwtImpl(ClientFactory clientFactory) {
	  
	  this.clientFactory = clientFactory;
	  ctx = (ClientContext) RPCClientContext.get();	
	  String sessionID = Cookies.getCookie("sid");
	  Log.info("sessionID: " + sessionID + " ctx: " + ctx); 
	  if(sessionID != null)
	  {
		  if(ctx != null)
		  {
			    //Set the current user context
			    currentUser = ctx.getCurrentUser();
			    generateModel();
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
  
  private void generateModel() {
	  headerPanel.setLeftWidget(headerBackButton);
	  FlowPanel container = new FlowPanel();
	  container.getElement().getStyle().setMarginTop(20, Unit.PX);
	  
	  
	  scrollPanel.setScrollingEnabledX(false);
	  scrollPanel.setWidget(container);
	  // workaround for android formfields jumping around when using
	  // -webkit-transform
	  scrollPanel.setUsePos(MGWT.getOsDetection().isAndroid());
	  ChromeWorkaround.maybeUpdateScroller(scrollPanel);
	  
	  HTML header = new HTML("Generate Templates");
	  header.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
	  container.add(header);
	  	  
	  WidgetList widgetList = new WidgetList();  
	  container.add(widgetList);
	  
	  //WidgetList widgetList1 = new WidgetList();  
	  //container.add(widgetList1);
	  
	  lblWarning = new Label();
	  
	  widgetList.add(lblWarning);
	  
	  final MPasswordTextBox mCurrentKeyTextBox = new MPasswordTextBox();
	  mCurrentKeyTextBox.setPlaceHolder("Current Key");
	  widgetList.add(mCurrentKeyTextBox);
	  
	  final MPasswordTextBox mKeyBox = new MPasswordTextBox();
	  mKeyBox.setPlaceHolder("New Key");
	  widgetList.add(mKeyBox);
	  
	  final MPasswordTextBox mConfirmKeyBox = new MPasswordTextBox();
	  mConfirmKeyBox.setPlaceHolder("Confirm New Key");
	  widgetList.add(mConfirmKeyBox);
	  
	  form = new FormPanel();
	  form.reset();
	  form.setVisible(false);
	  form.setAction(GENERATEJOB_ACTION_URL);
	  form.setEncoding(FormPanel.ENCODING_MULTIPART);
	  form.setMethod(FormPanel.METHOD_POST);
	  
	  HorizontalPanel formContainerPanel = new HorizontalPanel();
	  
	  final TextBox txtProject = new TextBox();
	  txtProject.setVisible(false);
	  txtProject.setName("project");
	  formContainerPanel.add(txtProject);
		
	  final TextBox txtUsername = new TextBox();
	  txtUsername.setVisible(false);
	  txtUsername.setName("user");
	  formContainerPanel.add(txtUsername);
		
	  final TextBox txtTask = new TextBox();
	  txtTask.setVisible(false);
	  txtTask.setName("taskName");
	  formContainerPanel.add(txtTask);
	  
	  final TextBox txtKey = new TextBox();
	  txtKey.setVisible(false);
	  txtKey.setName("key");
	  formContainerPanel.add(txtKey);
	  
	  final TextBox txtModelTaskType = new TextBox();
	  txtModelTaskType.setVisible(false);
	  txtModelTaskType.setName("modelTask");
	  formContainerPanel.add(txtModelTaskType);
	  
	  /*final TextBox txtGalleryPath = new TextBox();
	  txtGalleryPath.setVisible(false);
	  txtGalleryPath.setName("dbPath");
	  formContainerPanel.add(txtGalleryPath);*/
	  
	  form.add(formContainerPanel);
	  //widgetList.add(form);
	  
	  Button confirmButton = new Button("Generate");
	  //widgetList.add(form); 
	  widgetList.add(confirmButton);
	    
	  confirmButton.addTapHandler(new TapHandler() {
		  @Override
		  public void onTap(TapEvent event) {
			  
			    //System.out.println(" Email: " + txtUsername.getText());
			  	String currentKey = mCurrentKeyTextBox.getText().trim();
				String newKey = mKeyBox.getText().trim();
				String confirmKey = mConfirmKeyBox.getText().trim();
				if(currentKey.length() < 1)
				{
					lblWarning.setText("");
					lblWarning.setText("Please enter current key.");
				}
				else if(!newKey.equals(confirmKey) || newKey.length() <= 0)
				{
					lblWarning.setText("");
				    lblWarning.setText("New key doesn't match.");
				}
			    else
			    {
			    	lblWarning.setText("");
				    MasterKeyServiceAsync service = MasterKeyService.Util.getInstance();			
				    service.verifyMasterKey(currentKey, verifyCallback);
				}
		 }
	  });
	    
	  form.addSubmitHandler(new FormPanel.SubmitHandler() 
      {      	
		public void onSubmit(SubmitEvent event) {
			
			/* Change to make it dynamic */  
			String username = currentUser.getUsername();
			txtUsername.setValue(username);
			txtProject.setValue("plbp");
			txtTask.setValue("Model");
			txtModelTaskType.setValue("Identification");
			String newKey = mKeyBox.getText().trim();
			//System.out.println("Submitting");
			if(newKey.length() > 0)
			{
				txtKey.setValue(newKey);
			}
			else
			{
				event.cancel();
			}
		}
      });
	  
	  form.addSubmitCompleteHandler(new FormPanel.SubmitCompleteHandler() 
      {
		public void onSubmitComplete(SubmitCompleteEvent event) {
			System.out.println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
			String result = event.getResults();  
        	System.out.println("Result: " + result);
        	form.reset();
        	clientFactory.getPlaceController().goTo(new BCFunctionButtonPlace());
		}
      });
  }
  
  AsyncCallback<Boolean> verifyCallback = new AsyncCallback<Boolean>()
  {
	  public void onFailure(Throwable arg0) {
		  Log.info("In verifyCallback error: " + arg0.toString());
	  }		
	  public void onSuccess(Boolean match) {
		  System.out.println("In verify");
		  if(match)
		  {
			  lblWarning.setText("");
			  form.submit();
		  }
		  else
		  {
			  lblWarning.setText("");
			  lblWarning.setText("Please enter the correct current key.");
		  }
	  }
  };
}