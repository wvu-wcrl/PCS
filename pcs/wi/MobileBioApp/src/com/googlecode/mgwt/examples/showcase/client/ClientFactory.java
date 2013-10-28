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
package com.googlecode.mgwt.examples.showcase.client;

import com.google.gwt.place.shared.Place;
import com.google.gwt.place.shared.PlaceController;
import com.google.web.bindery.event.shared.EventBus;
import com.googlecode.mgwt.examples.showcase.client.activities.animation.AnimationView;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationDoneView;
import com.googlecode.mgwt.examples.showcase.client.activities.button.ButtonView;
import com.googlecode.mgwt.examples.showcase.client.activities.buttonbar.ButtonBarView;
import com.googlecode.mgwt.examples.showcase.client.activities.carousel.CarouselView;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsView;
import com.googlecode.mgwt.examples.showcase.client.activities.forms.FormsView;
import com.googlecode.mgwt.examples.showcase.client.activities.gcell.GroupedCellListView;
import com.googlecode.mgwt.examples.showcase.client.activities.popup.PopupView;
import com.googlecode.mgwt.examples.showcase.client.activities.progressbar.ProgressBarView;
import com.googlecode.mgwt.examples.showcase.client.activities.progressindicator.ProgressIndicatorView;
import com.googlecode.mgwt.examples.showcase.client.activities.pulltorefresh.PullToRefreshDisplay;
import com.googlecode.mgwt.examples.showcase.client.activities.scrollwidget.ScrollWidgetView;
import com.googlecode.mgwt.examples.showcase.client.activities.searchbox.SearchBoxView;
import com.googlecode.mgwt.examples.showcase.client.activities.slider.SliderView;
import com.googlecode.mgwt.examples.showcase.client.activities.tabbar.TabBarView;
import com.googlecode.mgwt.examples.showcase.client.custom.EnrollImgUploadView;
import com.googlecode.mgwt.examples.showcase.client.custom.GenerateModelView;
import com.googlecode.mgwt.examples.showcase.client.custom.IdentifyImgUploadView;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobDetailsView;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobHistoryView;
import com.googlecode.mgwt.examples.showcase.client.header.HeaderRightWidgetPanelView;
import com.googlecode.mgwt.examples.showcase.client.settings.ChangePasswordView;

/**
 * @author Daniel Kurka
 * 
 */
public interface ClientFactory {
	//public ShowCaseListView getHomeView();

	public EventBus getEventBus();

	public PlaceController getPlaceController();

	/**
	 * @return
	 */
	/*public UIView getUIView();

	public AboutView getAboutView();*/

	public AnimationView getAnimationView();

	public AnimationDoneView getAnimationDoneView();

	public ScrollWidgetView getScrollWidgetView();

	public ElementsView getElementsView(ClientFactory clientFactory);

	public ButtonBarView getButtonBarView();

	public SearchBoxView getSearchBoxView();

	public TabBarView getTabBarView();

	public ButtonView getButtonView();
	
	public ButtonView getBcFunctionbuttonView(ClientFactory clientFactory);
	
	public EnrollImgUploadView getEnrollImgUploadView(ClientFactory clientFactory);
	
	public JobHistoryView getJobHistoryView(ClientFactory clientFactory);
	
	public JobDetailsView getJobDetailsView(ClientFactory clientFactory);
	
	public GenerateModelView getGenerateModelView(ClientFactory clientFactory);
	
	public ChangePasswordView getChangePasswordView(ClientFactory clientFactory);
	
	public HeaderRightWidgetPanelView getHeaderRightWidgetPanelView(ClientFactory clientFactory);
	
	public IdentifyImgUploadView getIdentifyImgUploadView(ClientFactory clientFactory);

	/**
	 * 
	 */
	public PopupView getPopupView();

	public ProgressBarView getProgressBarView();

	public SliderView getSliderView();

	public CarouselView getCarouselHorizontalView();

	public PullToRefreshDisplay getPullToRefreshDisplay();

	public ProgressIndicatorView getProgressIndicatorView();

	public FormsView getFormsView();

	public GroupedCellListView getGroupedCellListView();

}
