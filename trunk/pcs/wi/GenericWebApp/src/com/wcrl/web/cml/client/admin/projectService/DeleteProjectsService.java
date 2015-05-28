package com.wcrl.web.cml.client.admin.projectService;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("deleteProjectsService")
public interface DeleteProjectsService extends RemoteService {

	public static class Util {

		public static DeleteProjectsServiceAsync getInstance() {

			return GWT.create(DeleteProjectsService.class);
		}
	}
	
	public ArrayList<Integer> deleteProjects(ArrayList<Integer> projectIds);

}
