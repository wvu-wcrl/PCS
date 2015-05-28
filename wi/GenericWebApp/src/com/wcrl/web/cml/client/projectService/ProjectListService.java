package com.wcrl.web.cml.client.projectService;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.seventhdawn.gwt.rcx.client.annotation.ClientProxySuperclass;
import com.seventhdawn.gwt.rcx.client.annotation.CustomSerializableRoots;
import com.seventhdawn.gwt.rpc.context.client.RPCContextServiceProxy;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.projects.ProjectItem;

@RemoteServiceRelativePath("projectList")
@ClientProxySuperclass(RPCContextServiceProxy.class)
@CustomSerializableRoots({ClientContext.class})
public interface ProjectListService extends RemoteService {

	public static class Util {

		public static ProjectListServiceAsync getInstance() {

			return GWT.create(ProjectListService.class);
		}
	}
	
	public ArrayList<ProjectItem> getProjectList();
}

