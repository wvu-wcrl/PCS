package com.wcrl.web.cml.server;

import java.util.Timer;
import java.util.TimerTask;

import com.wcrl.web.cml.client.jobService.ServerMessageGeneratorService;
import com.wcrl.web.cml.client.jobs.JobItem;
import com.wcrl.web.cml.client.jobs.ServerGeneratedMessageEvent;

import de.novanic.eventservice.client.event.Event;
import de.novanic.eventservice.service.RemoteEventServiceServlet;

public class ServerMessageGeneratorImpl_bkp extends RemoteEventServiceServlet implements ServerMessageGeneratorService
{
	private static final long serialVersionUID = 1L;
	private Timer myEventGeneratorTimer;
    
    //public synchronized void start(String fileName, String userName, String projectName) 
	public synchronized void start(JobItem item)
    {
        if(myEventGeneratorTimer == null) 
        {
            myEventGeneratorTimer = new Timer();
            //myEventGeneratorTimer.schedule(new ServerMessageGeneratorTimerTask(fileName, userName, projectName), 0, 1000 * 30);            
            myEventGeneratorTimer.schedule(new ServerMessageGeneratorTimerTask(item), 0, 1000 * 30);
        }
    }
    
    public synchronized void stop() 
    {
        if(myEventGeneratorTimer != null) 
        {
            myEventGeneratorTimer.cancel();     
            myEventGeneratorTimer = null;
        }
    }

    private class ServerMessageGeneratorTimerTask extends TimerTask
    {   
    	JobItem jobItem;
    	
    	/*public ServerMessageGeneratorTimerTask(String fileName, String userName, String projectName)
    	{
    		this.fileName = fileName;
    		this.userName = userName;
    		this.projectName = projectName;
		}*/
    	
    	public ServerMessageGeneratorTimerTask(JobItem item)
    	{
    		this.jobItem = item;
		}

		public void run() 
		{			
    		GetJobDetails jobDetails = new GetJobDetails();
    		//JobItem item = jobDetails.getJobDetails(fileName, userName, projectName);
    		JobItem item = jobDetails.getJobDetails(jobItem, 2);
    		String status = item.getStatus();
    		if(status.equalsIgnoreCase("Done"))
    		{
    			myEventGeneratorTimer.cancel();
    		}
    		Event theEvent = new ServerGeneratedMessageEvent(item);
            //add the event, so clients can receive it
            addEvent(ServerGeneratedMessageEvent.SERVER_MESSAGE_DOMAIN, theEvent);
        }
    }
}