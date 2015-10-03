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
package com.googlecode.mgwt.examples.showcase.client.header;

import com.google.gwt.event.shared.EventBus;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.googlecode.mgwt.examples.showcase.client.ClientFactory;
import com.googlecode.mgwt.examples.showcase.client.DetailActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonPlace;

/**
 * @author Daniel Kurka
 * 
 */
public class HeaderRightWidgetPanelActivity extends DetailActivity {

	private final ClientFactory clientFactory;

	public HeaderRightWidgetPanelActivity(ClientFactory clientFactory) {
		super(clientFactory.getEnrollImgUploadView(clientFactory), "nav");
		this.clientFactory = clientFactory;

	}

	@Override
	public void start(AcceptsOneWidget panel, EventBus eventBus) {
		super.start(panel, eventBus);
		HeaderRightWidgetPanelView view = clientFactory.getHeaderRightWidgetPanelView(clientFactory);

		/*view.getBackbuttonText().setText("LoginHome");
		view.getMainButtonText().setText("Nav");
		view.getHeader().setText("EnrollImageUpload");*/
		
		/*Location location = new Location();
		String text = location.getHeader(new BCFunctionButtonPlace());		
		view.getBackbuttonText().setText(text);*/

		panel.setWidget(view);

	}

}
