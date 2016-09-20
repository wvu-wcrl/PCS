/*
 * Copyright 2010 Daniel Kurka
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.googlecode.mgwt.examples.showcase.client.activities.button;

import java.util.HashMap;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Element;
import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.Image;
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
import com.googlecode.mgwt.examples.showcase.client.activities.elements.service.UserValidationService;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.service.UserValidationServiceAsync;
import com.googlecode.mgwt.examples.showcase.client.custom.EnrollImgUploadPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.GenerateModelPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.IdentifyImgUploadPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobHistoryPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.ServerGeneratedMessageEventService;
import com.googlecode.mgwt.examples.showcase.client.settings.ChangePasswordPlace;
import com.googlecode.mgwt.ui.client.MGWT;
import com.googlecode.mgwt.ui.client.MGWTStyle;
import com.googlecode.mgwt.ui.client.widget.Button;
import com.googlecode.mgwt.ui.client.widget.WidgetList;

/**
 * @author Daniel Kurka
 * 
 */
public class BCFunctionButtonViewGwtImpl extends DetailViewGwtImpl implements ButtonView {
	
	private static String GENERATEJOB_ACTION_URL = GWT.getModuleBaseURL() + "gupld";
	private HTML multiFileUpload;
	private ClientContext ctx;
	private User currentUser;
	private ClientFactory clientFactory;
	private Label lb1;
	private Label lb2;

  public BCFunctionButtonViewGwtImpl(final ClientFactory clientFactory) {
	  this.clientFactory = clientFactory;
	//  ctx = (ClientContext) RPCClientContext.get();	
	 // String sessionID = Cookies.getCookie("sid");
	  //Log.info("sessionID: " + sessionID + " ctx: " + ctx); 
	 // if(sessionID != null)
	  //{
		//  if(ctx != null)
		 // {
			    //Set the current user context
		//	    currentUser = ctx.getCurrentUser();
			    
			    headerBackButton.removeFromParent();
			    FlowPanel content = new FlowPanel();
			    final Image image=new Image("fly_wv.svg");
				final Image image1=new Image("helmet_black_70_81.svg");
				  
				 image.addStyleName("Imagewv");
				 image1.addStyleName("Imagemsu");
			    content.getElement().getStyle().setMargin(20, Unit.PX);
			    lb1= new Label("OCULAR CLOUD-Using Cloud To Match Ocular Images");
			    lb1.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
			    lb1.setHorizontalAlignment(HasHorizontalAlignment.ALIGN_CENTER);
			    HTML header = new HTML("User Functions");
			    header.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
			    

			    scrollPanel.setScrollingEnabledX(false);
			    scrollPanel.setWidget(content);    
			    // workaround for android formfields jumping around when using
			    // -webkit-transform
			    scrollPanel.setUsePos(MGWT.getOsDetection().isAndroid());

			    ChromeWorkaround.maybeUpdateScroller(scrollPanel);
			    content.add(image);
			    content.add(image1);
			    content.add(lb1);
			    content.add(new HTML("<br/><br/>"));
			 // content.add(new HTML("<br/><br/>"));
			    content.add(header);
			    WidgetList widgetList = new WidgetList();
			    content.add(widgetList);

			    Button identifyButton = new Button("Ocular Matching");    
			    widgetList.add(identifyButton);
			    		    
			    identifyButton.addTapHandler(new TapHandler() 
			    {
			        public void onTap(TapEvent event) {
			        	
			        	clientFactory.getPlaceController().goTo(new IdentifyImgUploadPlace());
			        }
			        	             
			    }) ;
			    
			    Button historyButton = new Button("History");    
			   widgetList.add(historyButton);
			    		    
			    historyButton.addTapHandler(new TapHandler() 
			    {
			        public void onTap(TapEvent event) {
			        	
			        	clientFactory.getPlaceController().goTo(new JobHistoryPlace());
			        }
			        	             
			    }) ;
			    
			 /*   Button enrollButton = new Button("Enroll");
			    widgetList.add(enrollButton);
			    enrollButton.addTapHandler(new TapHandler() {
			        @Override
			        public void onTap(TapEvent event) {        	
			        	clientFactory.getPlaceController().goTo(new EnrollImgUploadPlace());      	
			        }                   
			    }) ;
			    
			    Button generateModelButton = new Button("Regenerate templates");
			    widgetList.add(generateModelButton);
			    generateModelButton.addTapHandler(new TapHandler() {
			        @Override
			        public void onTap(TapEvent event) {        	
			        	clientFactory.getPlaceController().goTo(new GenerateModelPlace());      	
			        }                   
			    });*/
			    
			/*    Button changePasswordButton = new Button("Change password");    
			   // widgetList.add(changePasswordButton);
			    		    
			    changePasswordButton.addTapHandler(new TapHandler() 
			    {
			        public void onTap(TapEvent event) {
			        	
			        	clientFactory.getPlaceController().goTo(new ChangePasswordPlace());
			        }
			        	             
			    }) ;*/
			    
			    Button signOutButton = new Button("Sign out");
			    widgetList.add(signOutButton);
			    signOutButton.addTapHandler(new TapHandler() {
			        @Override
			        public void onTap(TapEvent event) {        	
			        	resetContext();
	    				UserValidationServiceAsync service = UserValidationService.Util.getInstance();			
						service.clearSession(sessionCallback);      	
			        }                   
			    }) ;
	//	  }
	//	  else
	//	  {
		//	  clientFactory.getPlaceController().goTo(new ElementsPlace());
		//  }
	//  }
//	  else
	//  {
	//	  clientFactory.getPlaceController().goTo(new ElementsPlace());
	 // }
  }
  
  private void resetContext() 
  {	  
	  RPCClientContext.set(null);
  }
  
  AsyncCallback<Boolean> sessionCallback = new AsyncCallback<Boolean>()
  {
	  public void onFailure(Throwable arg0)
	  {
		  Log.info("BCFunctionButtonViewGwtImpl error: " + arg0.toString());
	  }
	  public void onSuccess(Boolean bool)
	  {
		  if(bool)
		  {
			  if(ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync != null)
			  {
				  System.out.println("Stopping ServerGeneratedMessageEventService");
		  		  ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync.stop(VoidAsyncCallback);
		  		  ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync = null;
			  }
			  else
			  {
				  Cookies.removeCookie("sid");
				  clientFactory.getPlaceController().goTo(new ElementsPlace());
			  }
		  }		  
	  }
  };
  
  AsyncCallback<Void> VoidAsyncCallback = new AsyncCallback<Void>() {
  	  public void onFailure(Throwable aThrowable) {}
  	  public void onSuccess(Void aResult) {
  		Cookies.removeCookie("sid");
		clientFactory.getPlaceController().goTo(new ElementsPlace());
  	  }
    };
  
  protected Element getFileSelectElement(HTML element, String elementName) {
	    HashMap<String, Element> idMap = new HashMap<String, Element>();
	    parseIdsToMap(element.getElement(), idMap);
	    Element input = idMap.get(elementName);
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
