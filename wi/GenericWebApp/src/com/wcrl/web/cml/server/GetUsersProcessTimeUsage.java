package com.wcrl.web.cml.server;

import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;

import com.jmatio.io.MatFileReader;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLStructure;

public class GetUsersProcessTimeUsage 
{
	public HashMap<String, Long> getUsersUsage(String filePath)
	{				
		HashMap<String, Long> usersProcessDuration = new HashMap<String, Long>();
		MatFileReader matfilereader=null;
		try
		{
			matfilereader = new MatFileReader(filePath);
			MLStructure mlStructure = (MLStructure) matfilereader.getMLArray("UserUsage");				
			Collection<MLArray> jobStateList = mlStructure.getAllFields();
			Iterator<MLArray> itr = null;
			itr = jobStateList.iterator();
			while(itr.hasNext())
			{
				MLArray variable = itr.next();
				System.out.println("Job Param Variable name: " + variable.getName());
				System.out.println("Name: " + variable.name + " GetName: " + variable.getName() + " Type: " + variable.getType() + " Content: " + variable.contentToString());
			}
		}
		catch (Exception e)
		{
			System.out.println("error reading file");
			e.printStackTrace();
		}
		return usersProcessDuration;		
	}
}