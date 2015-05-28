package com.wcrl.web.cml.server;

import java.io.File;
import java.io.IOException;
import java.util.ResourceBundle;

import com.allen_sauer.gwt.log.client.Log;

public class FileIO 
{
	ResourceBundle scriptsPathConstants = ResourceBundle.getBundle("Scripts");
	
	public int callChangeOwnershipScript(String username, String path)
	{
		int exitValue = -1;
		try 
		{
			String scriptPath = scriptsPathConstants.getString("io_scripts_path").trim() + File.separator + scriptsPathConstants.getString("change_ownership").trim();
			ProcessBuilder processBuilder = new ProcessBuilder();
	   	 	processBuilder.command(scriptPath, username);	 
	   	 	Process proc = processBuilder.start();
	   	 	exitValue = proc.waitFor();
	   	 	Log.info("After executing io_ownership script: " + scriptPath + " exitValue: " + exitValue);
	   	 	Log.info("After executing io_ownership script parameters: " + username);
		} 
		catch (IOException e) 
		{
			System.out.println(e.getClass().getName() + ": " + e.getMessage());
			Log.info(e.getClass().getName() + ": " + e.getMessage());
			StackTraceElement[] trace = e.getStackTrace();
			for(int i = 0; i < trace.length; i++)
			{
				System.out.println("\t" + trace[i].toString());
				Log.info("\n\t" + trace[i].toString());
			}
			e.printStackTrace();
		}
		catch (InterruptedException e) 
		{
			System.out.println(e.getClass().getName() + ": " + e.getMessage());
			Log.info(e.getClass().getName() + ": " + e.getMessage());
			StackTraceElement[] trace = e.getStackTrace();
			for(int i = 0; i < trace.length; i++)
			{
				System.out.println("\t" + trace[i].toString());
				Log.info("\n\t" + trace[i].toString());
			}
			e.printStackTrace();
		}
		return exitValue;
	}
	
	public int callMoveFileScript(String originPath, String destinationPath)
	{
		int exitValue = -1;
		try 
		{
			String scriptPath = scriptsPathConstants.getString("io_scripts_path").trim() + File.separator + scriptsPathConstants.getString("move_file").trim();
			ProcessBuilder processBuilder = new ProcessBuilder();
	   	 	processBuilder.command(scriptPath, originPath, destinationPath);	 
	   	 	Process proc = processBuilder.start();
	   	 	exitValue = proc.waitFor();
	   	 	Log.info("After executing io_ownership script: " + scriptPath + " exitValue: " + exitValue);
	   	 	Log.info("After executing io_ownership script parameters: " + originPath + ", " + destinationPath);
		} 
		catch (IOException e) 
		{
			System.out.println(e.getClass().getName() + ": " + e.getMessage());
			Log.info(e.getClass().getName() + ": " + e.getMessage());
			StackTraceElement[] trace = e.getStackTrace();
			for(int i = 0; i < trace.length; i++)
			{
				System.out.println("\t" + trace[i].toString());
				Log.info("\n\t" + trace[i].toString());
			}
			e.printStackTrace();
		}
		catch (InterruptedException e) 
		{
			System.out.println(e.getClass().getName() + ": " + e.getMessage());
			Log.info(e.getClass().getName() + ": " + e.getMessage());
			StackTraceElement[] trace = e.getStackTrace();
			for(int i = 0; i < trace.length; i++)
			{
				System.out.println("\t" + trace[i].toString());
				Log.info("\n\t" + trace[i].toString());
			}
			e.printStackTrace();
		}
		return exitValue;
	}
}
