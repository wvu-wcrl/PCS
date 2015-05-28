/*
 * File: StaticClass.java

Purpose: To manage to stop the timers for each individual Job
**********************************************************/

package com.wcrl.web.cml.client.account;

import java.util.ArrayList;
import java.util.Map;

import com.google.gwt.user.client.Timer;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;



public class StaticClass 
{
	private static Map<Integer, Timer> timerMap;
	private static Timer jobDetailsTimer;

	public static Map<Integer, Timer> getTimerMap() {
		return timerMap;
	}

	public static void setTimerMap(Map<Integer, Timer> timerMap) {
		StaticClass.timerMap = timerMap;
	}

	public static Timer getJobDetailsTimer() {
		return jobDetailsTimer;
	}

	public static void setJobDetailsTimer(Timer jobDetailsTimer) {
		StaticClass.jobDetailsTimer = jobDetailsTimer;
	}	
	
	//Stop each individual job's timers
	public static void stopJobListTimers() 
	{
		ClientContext ctx;
		User currentUser;
		ctx = (ClientContext) RPCClientContext.get();			
	    if(ctx != null)
	    {
	       	currentUser = (User) ctx.getCurrentUser();
	       	if(currentUser != null)
	       	{
	       		ArrayList<Integer> timersJobId = currentUser.getTimersJobId();
	       		if((timerMap != null) && (timersJobId != null))
	    		{		
	    			//Log.info("List of timerMap: "+ timerMap.size());
   			
	    			for(int i = 0; i < timersJobId.size(); i++)
	    			{
	    				int jobId = timersJobId.get(i);
	    				if(timerMap.containsKey(jobId))
	    				{	
	    					Timer timer = timerMap.get(jobId);
	    					timer.cancel();																	
	    					timerMap.remove(jobId);									
	    				}				
	    			}
	    		}       		
	       	}
	    }	
		
	    //Stop the JobDetails timer
		if(jobDetailsTimer != null)
		{
			jobDetailsTimer.cancel();
			jobDetailsTimer = null;
			StaticClass.setJobDetailsTimer(jobDetailsTimer);
		}
	}
}
