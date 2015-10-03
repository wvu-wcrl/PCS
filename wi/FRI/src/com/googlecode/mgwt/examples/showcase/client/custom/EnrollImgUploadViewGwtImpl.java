package com.googlecode.mgwt.examples.showcase.client.custom;

import java.util.HashMap;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Element;
import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.Cookies;
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
import com.googlecode.mgwt.ui.client.MGWT;
import com.googlecode.mgwt.ui.client.MGWTStyle;
import com.googlecode.mgwt.ui.client.dialog.ConfirmDialog.ConfirmCallback;
import com.googlecode.mgwt.ui.client.widget.Button;
import com.googlecode.mgwt.ui.client.widget.MEmailTextBox;
import com.googlecode.mgwt.ui.client.widget.MRadioButton;
import com.googlecode.mgwt.ui.client.widget.MTextBox;
import com.googlecode.mgwt.ui.client.widget.WidgetList;


/**
 * An example of a MultiUploader panel using a very simple upload progress widget
 * The example also uses PreloadedImage to display uploaded images.
 * 
 * @author Manolo Carrasco Moino
 */
public class EnrollImgUploadViewGwtImpl extends DetailViewGwtImpl implements EnrollImgUploadView{

  private static String ENROLL_ACTION_URL = GWT.getModuleBaseURL() + "eupld";
  private HTML multiFileUpload;
  private Label lblWarning;
  private ClientContext ctx;
  private User currentUser;
  private ClientFactory clientFactory;

  public EnrollImgUploadViewGwtImpl(ClientFactory clientFactory) {
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
			    enrollSubject();
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
  
  private void enrollSubject() {
	  headerPanel.setLeftWidget(headerBackButton);
	  FlowPanel container = new FlowPanel();
	  container.getElement().getStyle().setMarginTop(20, Unit.PX);
	  
	  
	  scrollPanel.setScrollingEnabledX(false);
	  scrollPanel.setWidget(container);
	  // workaround for android formfields jumping around when using
	  // -webkit-transform
	  scrollPanel.setUsePos(MGWT.getOsDetection().isAndroid());
	  ChromeWorkaround.maybeUpdateScroller(scrollPanel);
	  
	  HTML header = new HTML("Enroll subject");
	  header.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
	  container.add(header);
	  
	  lblWarning = new Label();
	 	  
	  WidgetList widgetList = new WidgetList();  
	  container.add(widgetList);
	  
	  widgetList.add(lblWarning);
	  
	  final MTextBox mUsernameBox = new MTextBox();
	  mUsernameBox.setPlaceHolder("SubjectID");
	  mUsernameBox.setVisible(true);
		
	  final MEmailTextBox mEmailBox = new MEmailTextBox();
	  mEmailBox.setPlaceHolder("Email");
	  mEmailBox.setVisible(false);
	  	  
	  /*<input type="email" name="email">*/
	  final FormPanel form = new FormPanel();
	  form.reset();
	  form.setAction(ENROLL_ACTION_URL);
	  form.setEncoding(FormPanel.ENCODING_MULTIPART);
	  form.setMethod(FormPanel.METHOD_POST);
	  
	  final TextBox txtUsername  = new TextBox();
	  txtUsername.setVisible(false);
	  txtUsername.setName("username");
	  
	  final TextBox txtAdminUsername  = new TextBox();
	  txtAdminUsername.setVisible(false);
	  txtAdminUsername.setName("admin");
	 
	  final TextBox txtEmail = new TextBox();
	  txtEmail.setVisible(false);
	  txtEmail.setName("email");
	  
	  final TextBox txtTaskType = new TextBox();
	  txtTaskType.setVisible(false);
	  txtTaskType.setName("task");
	  
	  final TextBox txtProject = new TextBox(); 
	  txtProject.setVisible(false);
	  txtProject.setName("project");
	 
	  final MRadioButton identificationRadioButton = new MRadioButton("task");
	  identificationRadioButton.setText("Identification");
	  identificationRadioButton.setVisible(false);
	  //widgetList.add(identificationRadioButton);

	  MRadioButton verificationRadioButton = new MRadioButton("task");
	  verificationRadioButton.setText("Verification");
	  verificationRadioButton.setVisible(false);
	  //widgetList.add(verificationRadioButton);
	  
	  identificationRadioButton.setValue(true);
	  
	  identificationRadioButton.addTapHandler(new TapHandler(){

		public void onTap(TapEvent event) {
			
			mUsernameBox.setVisible(true);
			mEmailBox.setVisible(false);
		}
		  
	  });
	  
	  verificationRadioButton.addTapHandler(new TapHandler(){

			public void onTap(TapEvent event) {
				
				mUsernameBox.setVisible(false);
				mEmailBox.setVisible(true);
			}
			  
		  });
	  
	  widgetList.add(mUsernameBox);
	  //widgetList.add(mEmailBox);
	  
	  HTML space = new HTML("&nbsp;&nbsp;&nbsp;");
	  final Label lblFilenames = new Label();
	  lblFilenames.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().formListElement());
	  lblFilenames.setVisible(false);
	  
	  multiFileUpload = new HTML("<input type='file' id='fileselect' name='fileselect[]' multiple />");
	  
	  HorizontalPanel hPanel = new HorizontalPanel();
	  hPanel.add(txtUsername);	  
	  hPanel.add(txtAdminUsername);
	  hPanel.add(txtEmail);
	  hPanel.add(txtTaskType);
	  hPanel.add(txtProject);
	  hPanel.add(multiFileUpload);
	  
	  form.add(hPanel);
	  
	  hPanel.add(space);
	  hPanel.add(lblFilenames);
	  
	  form.addSubmitHandler(new FormPanel.SubmitHandler() 
      {      	
		public void onSubmit(SubmitEvent event) {
			String emailRegex = "^[a-z][-a-z0-9_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
			String usernameRegex = "^[a-zA-Z][-a-zA-Z0-9_]*$"; 
			txtProject.setValue("plbp");
			System.out.println(" Email: " + mEmailBox.getText());
			
			String email = mEmailBox.getText().trim();
			String username = mUsernameBox.getText().trim();
			lblWarning.setText("");
			txtAdminUsername.setText(currentUser.getUsername());
			if(identificationRadioButton.getValue())
			{
				if(username.matches(usernameRegex) && username.length() > 1)
				{
					txtUsername.setText(username);
					txtTaskType.setValue("identification");
				}
				else
				{
					lblWarning.setText("");
					lblWarning.setText("Please enter a valid username (starting with an alphabet and can include numbers).");
					event.cancel();
				}
			}
			else
			{
				if(email.matches(emailRegex) && email.length() > 1)
				{
					txtEmail.setText(email);
					String[] tokens = email.split("@");
					username = tokens[0];
					if(username.matches(usernameRegex) && username.length() > 1)
					{
						txtUsername.setText(username);
						txtTaskType.setValue("verification");
					}
					else
					{
						lblWarning.setText("");
						lblWarning.setText("Please enter a valid username (starting with an alphabet and can include numbers).");
						event.cancel();
					}
				}
				else
				{
					lblWarning.setText("");
					lblWarning.setText("Please enter a valid email address.");
					event.cancel();
				}
			}
			
			Element element = getFileSelectElement();
			String filenames = getFileNames(element);
			System.out.println("Filenames: " + filenames);
			if(filenames == null || filenames.length() <= 0)
			{
				lblWarning.setText("");
    			lblWarning.setText("Please upload images.");
				event.cancel();
			}
		}
      });
	  
	  form.addSubmitCompleteHandler(new FormPanel.SubmitCompleteHandler() 
      {
		public void onSubmitComplete(SubmitCompleteEvent event) {
			String result = event.getResults();  
        	System.out.println("EnrollImgUploadViewGwtImpl Result: " + result);
        	Log.info("*** EnrollImgUploadViewGwtImpl Result: " + result);
        	form.reset();
        	clientFactory.getPlaceController().goTo(new BCFunctionButtonPlace());
		}
      });
    
	  widgetList.add(form); 
    
    
	Button confirmButton = new Button("Enroll");
    
    widgetList.add(confirmButton);
    
    confirmButton.addTapHandler(new TapHandler() {
		@Override
		public void onTap(final TapEvent event) {
			clientFactory.getPopupView().confirmSomeStuff("Confirm", "Are you finished adding pictures?", new ConfirmCallback() {

				@Override
				public void onOk() {
					form.submit();
				}

				@Override
				public void onCancel() {

				}
			});

		}
	});
  }
  
  protected Element getFileSelectElement() {
	    HashMap<String, Element> idMap = new HashMap<String, Element>();
	    parseIdsToMap(multiFileUpload.getElement(), idMap);
	    Element input = idMap.get("fileselect");
	    return input;
	}

	public static void parseIdsToMap(Element element, HashMap<String, Element> idMap) {
	    int nodeCount = element.getChildCount();
	    for (int i = 0; i < nodeCount; i++) {
	        Element e = (Element) element.getChild(i);
	        if (e.getId() != null) {
	            idMap.put(e.getId(), e);
	        }
	    }
	}
  
  public static native String getFileNames(Element input) /*-{
  		var ret = "";
  		//microsoft support
  		if (typeof (input.files) == 'undefined'
          || typeof (input.files.length) == 'undefined') {
      		return input.value;
  		}

  		for ( var i = 0; i < input.files.length; i++) {
      	if (i > 0) {
          ret += ", ";
      	}
      	ret += input.files[i].name;
  		}
  		return ret;
	}-*/;

}