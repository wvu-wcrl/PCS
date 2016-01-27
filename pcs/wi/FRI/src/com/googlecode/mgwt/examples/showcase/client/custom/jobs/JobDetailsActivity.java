/*
 * Copyright 2010 Daniel Kurka
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package com.googlecode.mgwt.examples.showcase.client.custom.jobs;

import com.google.gwt.event.shared.EventBus;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.googlecode.mgwt.dom.client.event.tap.TapEvent;
import com.googlecode.mgwt.dom.client.event.tap.TapHandler;
import com.googlecode.mgwt.examples.showcase.client.ClientFactory;
import com.googlecode.mgwt.examples.showcase.client.DetailActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.IdentifyImgUploadPlace;
import com.googlecode.mgwt.examples.showcase.client.event.ActionEvent;
import com.googlecode.mgwt.examples.showcase.client.event.ActionNames;

/**
 * @author Daniel Kurka
 * 
 */
public class JobDetailsActivity extends DetailActivity {

	private final ClientFactory clientFactory;

	public JobDetailsActivity(ClientFactory clientFactory) {
		super(clientFactory.getJobDetailsView(clientFactory), "nav");
		this.clientFactory = clientFactory;
		
	}

	@Override
	public void start(AcceptsOneWidget panel, EventBus eventBus) {
		super.start(panel, eventBus);
		JobDetailsView view = clientFactory.getJobDetailsView(clientFactory);

		/*Location location = new Location();
		String text = location.getHeader(new JobHistoryPlace());*/		
		view.getBackbuttonText().setText("Back");

		addHandlerRegistration(view.getBackbutton().addTapHandler(new TapHandler() {

		      @Override
		      public void onTap(TapEvent event) {
		    	  //System.out.println("In tap event###");
		    	  //clientFactory.getJobHistoryView(clientFactory);
		    	  if(ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync != null)
				  {
		    		  System.out.println("Stopping ServerGeneratedMessageEventService");
		    		  ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync.stop(VoidAsyncCallback);
		    		  ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync = null;
				  }
		    	  clientFactory.getPlaceController().goTo(new JobHistoryPlace());
		      }
		      AsyncCallback<Void> VoidAsyncCallback = new AsyncCallback<Void>() {
		    	  public void onFailure(Throwable aThrowable) {}
		    	  public void onSuccess(Void aResult) {}
		      };
		    }));
		
		panel.setWidget(view);

	}

}
