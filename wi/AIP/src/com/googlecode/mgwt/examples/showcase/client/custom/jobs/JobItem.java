/*
 * File: JobItem.java

Purpose: Java bean class to store the attributes of a Job.
**********************************************************/

package com.googlecode.mgwt.examples.showcase.client.custom.jobs;

import java.io.Serializable;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;


public class JobItem implements Serializable 
{	
	private static final long serialVersionUID = -3996651421304266493L;
	private int userId;
	private String username;
	private int id;
	private int jobId;
	private String jobName;
	private String jobDescription;	
	private Date jobUploadTime;
	private boolean read;	
    private int progress;
    private String status;
    private int downloadTimes;
    private String jobNotes;       
    private boolean outPutFileExists;
    private long timerTime;
    //In List set to '1', in Details set to '2'
    private int jobListTimerFlag;
    //Stores the last update time of the 'status.txt' file
    private long lastModified;
    private int numberOfInputFiles;
    private int numberOfOutputFiles;
    //Store Input and Output files names and their paths
    private Map<Integer, String[]> inputFiles;
    private Map<Integer, String[]> outputFiles;
    
    private int priority;
    private int projectId;
    private String projectName;
    private long resultsLastModified;
    private LinkedHashMap<String, String> columns;
    private String inputFileName;
    private String startTime;
    private String stopTime;
    
    public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getStartTime() {
		return startTime;
	}

	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}

	public String getStopTime() {
		return stopTime;
	}

	public void setStopTime(String stopTime) {
		this.stopTime = stopTime;
	}

	public String getProcessDuration() {
		return processDuration;
	}

	public void setProcessDuration(String processDuration) {
		this.processDuration = processDuration;
	}

	private String processDuration;
	private String matchingScore;
	private int    serialNumber;
  
	public JobItem()
	{
		
	}

	public JobItem(int jobId, int userId, String username, String jobName, int serialNumber,String matchingScore,String jobDescription, Date jobUploadTime, int progress, String status, String jobNotes, boolean outputFileExists, int numberOfInputFiles, int numberOfOutputFiles, Map<Integer, String[]> inputFiles, Map<Integer, String[]> outputFiles)
	{
		this.jobId = jobId;
		this.userId = userId;
		this.username = username;
		this.jobName = jobName;
		this.jobDescription = jobDescription;
		this.jobUploadTime = jobUploadTime;		
		this.status = status;
		this.progress = progress;
		this.jobNotes = jobNotes;		
		this.outPutFileExists = outputFileExists;		
		this.numberOfInputFiles = numberOfInputFiles;
		this.numberOfOutputFiles = numberOfOutputFiles;
		this.inputFiles = inputFiles;
		this.outputFiles = outputFiles;	
		this.matchingScore=matchingScore;
		this.serialNumber=serialNumber;
	}
		
	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public String getJobNotes() {
		return jobNotes;
	}

	public void setJobNotes(String jobNotes) {
		this.jobNotes = jobNotes;
	}

	public int getDownloadTimes() {
		return downloadTimes;
	}

	public void setDownloadTimes(int downloadTimes) {
		this.downloadTimes = downloadTimes;
	}

	public int getJobId() {
		return jobId;
	}

	public void setJobId(int jobId) {
		this.jobId = jobId;
	}
		
	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public int getProgress() {
		return progress;
	}

	public void setProgress(int progress) {
		this.progress = progress;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getJobName() {
		return jobName;
	}

	public void setJobName(String jobName) {
		this.jobName = jobName;
	}

	public String getJobDescription() {
		return jobDescription;
	}

	public void setJobDescription(String jobDescription) {
		this.jobDescription = jobDescription;
	}

	public Date getJobUploadTime() {
		return jobUploadTime;
	}

	public void setJobUploadTime(Date jobUploadTime) {
		this.jobUploadTime = jobUploadTime;
	}

	public boolean isRead() {
		return read;
	}

	public void setRead(boolean read) {
		this.read = read;
	}

	public boolean isOutPutFileExists() {
		return outPutFileExists;
	}

	public void setOutPutFileExists(boolean outPutFileExists) {
		this.outPutFileExists = outPutFileExists;
	}
		
	public long getTimerTime() {
		return timerTime;
	}

	public void setTimerTime(long timerTime) {
		this.timerTime = timerTime;
	}

	public int getJobListTimerFlag() {
		return jobListTimerFlag;
	}

	public void setJobListTimerFlag(int jobListTimerFlag) {
		this.jobListTimerFlag = jobListTimerFlag;
	}

	public int getNumberOfInputFiles() {
		return numberOfInputFiles;
	}

	public void setNumberOfInputFiles(int numberOfInputFiles) {
		this.numberOfInputFiles = numberOfInputFiles;
	}

	public int getNumberOfOutputFiles() {
		return numberOfOutputFiles;
	}

	public void setNumberOfOutputFiles(int numberOfOutputFiles) {
		this.numberOfOutputFiles = numberOfOutputFiles;
	}

	public Map<Integer, String[]> getInputFiles() {
		return inputFiles;
	}

	public void setInputFiles(Map<Integer, String[]> inputFiles) {
		this.inputFiles = inputFiles;
	}

	public Map<Integer, String[]> getOutputFiles() {
		return outputFiles;
	}

	public void setOutputFiles(Map<Integer, String[]> outputFiles) {
		this.outputFiles = outputFiles;
	}

	public int getPriority() {
		return priority;
	}

	public void setPriority(int priority) {
		this.priority = priority;
	}

	// Map of the String and the corresponding integer status values
	/*public int getJobStatusValue(String statusStr)
	{
		int status = 0;
		if((statusStr.equalsIgnoreCase("Done")) || statusStr.equalsIgnoreCase("Error"))
		{
			status = 3;
		}
		else if(statusStr.equalsIgnoreCase("Queued"))
		{
			status = 6;
		}
		else if(statusStr.equalsIgnoreCase("Suspended"))
		{
			status = 2;
		}
		else
		{
			status = 5;
		}
		return status;
	}*/

	public long getLastModified() {
		return lastModified;
	}

	public void setLastModified(long lastModified) {
		this.lastModified = lastModified;
	}

	public int getProjectId() {
		return projectId;
	}

	public void setProjectId(int projectId) {
		this.projectId = projectId;
	}

	public String getProjectName() {
		return projectName;
	}

	public void setProjectName(String projectName) {
		this.projectName = projectName;
	}

	public long getResultsLastModified() {
		return resultsLastModified;
	}

	public void setResultsLastModified(long resultsLastModified) {
		this.resultsLastModified = resultsLastModified;
	}

	public LinkedHashMap<String, String> getColumns() {
		return columns;
	}

	public void setColumns(LinkedHashMap<String, String> columns) {
		this.columns = columns;
	}

	public String getInputFileName() {
		return inputFileName;
	}

	public void setInputFileName(String inputFileName) {
		this.inputFileName = inputFileName;
	}

	public void setMatchingScore(String matchingScore) {
		this.matchingScore = matchingScore;
		
	}
	public String getMatchingScore() {
		return matchingScore;
	}
	public void setSerialNumber(int serialNumber) {
		this.serialNumber = serialNumber;
		
	}
	public int getSerialNumber() {
		return serialNumber;
	}




}
