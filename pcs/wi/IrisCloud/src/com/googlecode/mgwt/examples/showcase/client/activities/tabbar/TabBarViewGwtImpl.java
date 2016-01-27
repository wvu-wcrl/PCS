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
package com.googlecode.mgwt.examples.showcase.client.activities.tabbar;

import com.google.gwt.user.client.ui.Label;

import com.googlecode.mgwt.examples.showcase.client.DetailViewGwtImpl;
import com.googlecode.mgwt.ui.client.widget.tabbar.ContactsTabBarButton;
import com.googlecode.mgwt.ui.client.widget.tabbar.HistoryTabBarButton;
import com.googlecode.mgwt.ui.client.widget.tabbar.MostViewedTabBarButton;
import com.googlecode.mgwt.ui.client.widget.tabbar.SearchTabBarButton;
import com.googlecode.mgwt.ui.client.widget.tabbar.TabPanel;

/**
 * @author Daniel Kurka
 *
 */
public class TabBarViewGwtImpl extends DetailViewGwtImpl implements TabBarView {

	public TabBarViewGwtImpl() {

		TabPanel tabPanel = new TabPanel();

    tabPanel.add(new ContactsTabBarButton(), new Label("Contacts"));
    tabPanel.add(new HistoryTabBarButton(), new Label("History"));
    tabPanel.add(new MostViewedTabBarButton(), new Label("Most Viewed"));
    tabPanel.add(new SearchTabBarButton(), new Label("Search"));

		main.add(tabPanel, 1);
		main.remove(scrollPanel);
	}
}
