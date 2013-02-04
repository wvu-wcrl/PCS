package com.wcrl.web.cml.client.admin.projectService;

import java.util.Map;
import com.google.gwt.user.client.rpc.AsyncCallback;

public interface AddProjectServiceAsync {

	public void addProject(Map<String, String> formData, AsyncCallback<Integer> addGroupCallback);

}
