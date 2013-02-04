/*
 * File: UserDto.java

Purpose: Java Bean class to store the attributes of an user.
**********************************************************/
package com.wcrl.web.cml.client.account;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.IsSerializable;
import com.wcrl.web.cml.client.admin.account.UserItems;
import com.wcrl.web.cml.client.datafiles.DataFileItems;
import com.wcrl.web.cml.client.jobs.JobItems;
import com.wcrl.web.cml.client.projects.ProjectItems;

public class User implements IsSerializable 
{
    
	private int userId;
    private String username;
    private String password; 
    private String usertype;
    private String primaryemail;  
    private String firstName;
    private String lastName;
    
    //A user logged in as an Administrator can assume the identity of a regular user. 
    //This is used to store the identity of the Administrator before assuming the role of the user so as to switch back to Administrator after signing off as the assumed user.
    private User adminUser;
    private UserItems userItems;
    //Used In the case of Administrator login
    private JobItems usersJobItems;
    //Store the list of timers for the Jobs that are active
    private ArrayList<Integer> timersJobId;
    private ProjectItems projectItems;
    private int preferredProjectId;
    private String preferredProject;
   
    private DataFileItems usersFileItems;
    private int status;
    private String organization;
    private String jobTitle;
    private String country;
    private double runtime;
    private double totalRuntime;
    private double usedRuntime;
    private String sessionID;
        
    public String getOrganization() {
		return organization;
	}

	public void setOrganization(String organization) {
		this.organization = organization;
	}

	public String getJobTitle() {
		return jobTitle;
	}

	public void setJobTitle(String jobTitle) {
		this.jobTitle = jobTitle;
	}

	public User()
    {
    	
    }
	
	public int getUserId() 
	{
		return userId;
	}

	public void setUserId(int userId) 
	{
		this.userId = userId;
	}

	public String getUsername() 
	{
		return username;
	}

	public void setUsername(String username) 
	{
		this.username = username;
	}

	public String getPassword() 
	{
		return password;
	}

	public void setPassword(String password) 
	{
		this.password = password;
	}

	public String getPrimaryemail() 
	{
		return primaryemail;
	}

	public void setPrimaryemail(String primaryemail) 
	{
		this.primaryemail = primaryemail;
	}

	public String getFirstName() 
	{
		return firstName;
	}

	public void setFirstName(String firstName) 
	{
		this.firstName = firstName;
	}

	public String getLastName() 
	{
		return lastName;
	}

	public void setLastName(String lastName) 
	{
		this.lastName = lastName;
	}

	public String getUsertype() 
	{
		return usertype;
	}

	public void setUsertype(String usertype) 
	{
		this.usertype = usertype;
	}	
	
	public User getAdminUser() {
		return adminUser;
	}

	public void setAdminUser(User adminUser) {
		this.adminUser = adminUser;
	}

	public UserItems getUserItems() {
		return userItems;
	}

	public void setUserItems(UserItems userItems) {
		this.userItems = userItems;
	}

	public JobItems getUsersJobItems() {
		return usersJobItems;
	}

	public void setUsersJobItems(JobItems usersJobItems) {
		this.usersJobItems = usersJobItems;
	}

	public ArrayList<Integer> getTimersJobId() {
		return timersJobId;
	}

	public void setTimersJobId(ArrayList<Integer> timersJobId) {
		this.timersJobId = timersJobId;
	}

	public ProjectItems getProjectItems() {
		return projectItems;
	}

	public void setProjectItems(ProjectItems projectItems) {
		this.projectItems = projectItems;
	}

	public String getPreferredProject() {
		return preferredProject;
	}

	public void setPreferredProject(String preferredProject) {
		this.preferredProject = preferredProject;
	}

	public int getPreferredProjectId() {
		return preferredProjectId;
	}

	public void setPreferredProjectId(int preferredProjectId) {
		this.preferredProjectId = preferredProjectId;
	}

	public DataFileItems getUsersFileItems() {
		return usersFileItems;
	}

	public void setUsersFileItems(DataFileItems usersFileItems) {
		this.usersFileItems = usersFileItems;
	}

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public String getCountry() {
		return country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public double getRuntime() {
		return runtime;
	}

	public void setRuntime(double runtime) {
		this.runtime = runtime;
	}

	public double getTotalRuntime() {
		return totalRuntime;
	}

	public void setTotalRuntime(double totalRuntime) {
		this.totalRuntime = totalRuntime;
	}

	public String getSessionID() {
		return sessionID;
	}

	public void setSessionID(String sessionID) {
		this.sessionID = sessionID;
	}

	public double getUsedRuntime() {
		return usedRuntime;
	}

	public void setUsedRuntime(double usedRuntime) {
		this.usedRuntime = usedRuntime;
	}

}
