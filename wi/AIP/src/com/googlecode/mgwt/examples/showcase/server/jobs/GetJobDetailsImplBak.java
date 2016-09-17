package com.googlecode.mgwt.examples.showcase.server.jobs;

import java.io.File;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.ResourceBundle;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobItem;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.service.GetJobDetailsService;
import com.jmatio.io.MatFileReader;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLChar;
import com.jmatio.types.MLDouble;
import com.jmatio.types.MLStructure;

public class GetJobDetailsImplBak extends RemoteServiceServlet implements GetJobDetailsService
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("Paths");

	public JobItem getDetails(JobItem item, int from, String pathx)
	{
		item = getJobDetails(item, from);
		return item;
		
	}

	//public JobItem getJobDetails(String fileName, String userName, String projectName)
	public JobItem getJobDetails(JobItem item, int from)
	{	
		String projectConstant = constants.getString("projects");
		String rootPath = constants.getString("path");
		String path1 = constants.getString("path1");
		String rHomePath = constants.getString("path2");
		String fileName = item.getJobName();
		String userName = item.getUsername();
		String projectName = item.getProjectName();
		
		String userProjectPath = userName + File.separator + projectConstant + File.separator + projectName + File.separator;
		rootPath = rootPath + userProjectPath;
		String dir = constants.getString("JobIn"); 
		String filePath = rootPath + dir + File.separator + fileName;
		System.out.println("File path: " + filePath);
		File aFile = new File(filePath);
		Map<Integer, String[]> outputFiles = new HashMap<Integer, String[]>();
		Map<Integer, String[]> dataFiles = new HashMap<Integer, String[]>();
		
		if(aFile.exists())
		{
			item.setStatus("Queued");
			item = getJobData(aFile, fileName, filePath, item);
			       
		}
		else
		{
			dir = constants.getString("JobRunning");
			filePath = rootPath + dir + File.separator + fileName;
			aFile = new File(filePath);			
			if(aFile.exists())
			{													
				if(from == 2)
				{
					if(isFileUpdated(item, aFile))
					{
						item = getJobData(aFile, fileName, filePath, item);
					}
					else
					{
						String jobStatus = item.getStatus();
						int index = jobStatus.indexOf("%");
						if(index == -1)
						{
							item.setStatus("Running");
						}
					}
				}
				else
				{
					item.setStatus("Running");
					item = getJobData(aFile, fileName, filePath, item);
				}
			}
			else
			{
				dir = constants.getString("JobOut");
				filePath = rootPath + dir + File.separator + fileName;
				aFile = new File(filePath);
				if(aFile.exists())
				{
					item.setStatus("Done");				
					item = getJobData(aFile, fileName, filePath, item);
				}
				else
				{
					dir = constants.getString("archive");
					filePath = rootPath + dir + File.separator + fileName;
					aFile = new File(filePath);
					if(aFile.exists())
					{
						item.setStatus("Done");					
						item = getJobData(aFile, fileName, filePath, item);
					}
					else
					{
						dir = constants.getString("Suspend");
						filePath = rootPath + dir + File.separator + fileName;
						aFile = new File(filePath);
						if(aFile.exists())
						{
							item.setStatus("Suspended");
							item = getJobData(aFile, fileName, filePath, item);
							item.setStatus("Suspended");
						}
						else
						{
							dir = constants.getString("JobFailed");
							filePath = rootPath + dir + File.separator + fileName;
							aFile = new File(filePath);
							if(aFile.exists())
							{
								item.setStatus("Failed");
								item = getJobData(aFile, fileName, filePath, item);
							}
						}
					}
				}				
			}			
		}
		String outputFilesDir = rootPath + constants.getString("Figures") + File.separator;	
		//System.out.println("!!!!!!Output files directory: " + outputFilesDir + " Filename: " + fileName);
		//outputFiles = getOutputFiles(outputFilesDir, fileName, outputFiles, rootPathForDownload + path1 + File.separator + userProjectPath);
		outputFiles = getOutputFiles(outputFilesDir, fileName, outputFiles, path1 + File.separator + userProjectPath, "output");
		
		String[] fileData = new String[3];
		fileData[0] = fileName;
		//fileData[1] = rootPathForDownload + path1 + File.separator + userProjectPath + dir + File.separator + fileName;
		fileData[1] = path1 + File.separator + userProjectPath + dir + File.separator + fileName;
		fileData[2] = rootPath + dir + File.separator + fileName;
		//System.out.println("Link File path: " + fileData[1]);
		//Log.info("Link File path: " + fileData[1]);
		outputFiles.put(1, fileData);
		//System.out.println("Output file size: " + outputFiles.size());
		
		String dataFilesDir = rootPath + constants.getString("Data") + File.separator;	
		//System.out.println("~~~~~Data files directory: " + dataFilesDir + " Filename: " + fileName);
		dataFiles = getOutputFiles(dataFilesDir, fileName, dataFiles, path1 + File.separator + userProjectPath, "data");
		
		item.setInputFiles(dataFiles);
		item.setOutputFiles(outputFiles);
		item.setUsername(userName);
		item.setProjectName(projectName);
		return item;
	}
	
	private boolean isFileUpdated(JobItem item, File file)
	{
		boolean modified = false;
		if(file.lastModified() > item.getLastModified())
		{
			modified = true;
		}
		return modified;
	}
	
	public Map<Integer, String[]> getOutputFiles(String outputFilesDir, String jobOriginalFileName, Map<Integer, String[]> outputFiles, String rootPathForDownload, String from)
	{		
		File dirPath = new File(outputFilesDir);
		int periodindex = jobOriginalFileName.lastIndexOf(".");
		String jobFileName = jobOriginalFileName.substring(0, periodindex);
		System.out.println("~~~~~~~~~~~Dirpath: " + dirPath.getPath() + " jobFileName: " + jobFileName);
		Log.info("~~~~~~~~~~~Dirpath: " + dirPath.getPath() + " jobFileName: " + jobFileName);
		if(dirPath != null && dirPath.isDirectory())
		{
			int count = dirPath.list().length;
			//System.out.println("File count: " + count);
			if(count > 0)
			{					
				String[] files = dirPath.list();	
				int key = 2;
				for(int i = 0; i < count; i++)
				{
					String fileName = files[i];
					File file  = new File(dirPath, files[i]);
					System.out.println("$$$$$$$$$$$$$$$$$$ output file: " + file.getPath());
					Log.info("$$$$$$$$$$$$$$$$$$ output file: " + file.getPath());
					//If an output file exists add it to the list of output files
					if(file.exists())
					{	
						if(!fileName.endsWith(".txt") && file.isFile())
						{
							int index = fileName.lastIndexOf("_");
							System.out.println("Job out file: " + jobFileName + " File: " + fileName + "Length: " + fileName.length() + " index: " + index);
							Log.info("Job out file: " + jobFileName + " File: " + fileName + "Length: " + fileName.length() + " index: " + index);
							if(index > -1)
							{
								String[] tokens = new String[2];
								tokens[0] = fileName.substring(0, index);
								tokens[1] = fileName.substring(index+1, fileName.length());
								
								System.out.println("Job: " + jobFileName + " File: " + fileName + " Token 1: " + tokens[0] + " Token 2: " + tokens[1]);
								Log.info("&&&&& Job: " + jobFileName + " File: " + fileName + " Token 1: " + tokens[0] + " Token 2: " + tokens[1]);
								if(jobFileName.equals(tokens[0]))
								{	
						        	String filePath = outputFilesDir + fileName;
									String[] fileData = new String[3];
									fileData[0] = fileName;
									if(from.equalsIgnoreCase("output"))
									{
										fileData[1] = rootPathForDownload + constants.getString("Figures") + File.separator + fileName;
									}
									else
									{
										fileData[1] = rootPathForDownload + constants.getString("Data") + File.separator + fileName;
									}
									
									fileData[2] = filePath;
									System.out.println("Job figure file: " + fileName + " path: " + fileData[1] + " path2: " + fileData[2]);
									Log.info("Job figure file: " + fileName + " path: " + fileData[1] + " path2: " + fileData[2]);
									outputFiles.put(key, fileData);
									key++;
								}
							}
						}						
					}										
				}
			}
		}
		return outputFiles;
			
	}
	
	public JobItem getJobData(File file, String fileName, String filePath, JobItem item)
	{
		item.setJobName(fileName);
		long lastModified = file.lastModified();
		item.setLastModified(lastModified);
		item.setJobNotes("");			
		MatFileReader matfilereader=null;
		String status = "Running";
		System.out.println("JobData filepath: " + filePath);
		try
		{
			//System.out.println("matfilereader: " + matfilereader + " filePath: " + filePath);			
			//System.out.println(" filePath: " + filePath + " mlStructure1: " + new MatFileReader(filePath));
			matfilereader = new MatFileReader(filePath);			
			//System.out.println("matfilereader: " + matfilereader + " filePath: " + filePath);
			if(matfilereader.getMLArray("JobInfo") != null)
			{
				MLStructure mlStructure = (MLStructure) matfilereader.getMLArray("JobInfo");	
				
				//Results
				LinkedHashMap<String, String> resultsMap = new LinkedHashMap<String, String>();
							
				if(mlStructure.getField("Results") != null && mlStructure.getField("Results").getType() == 2)
				{
					MLStructure mlResultsStructure = (MLStructure) mlStructure.getField("Results");
					String content = mlResultsStructure.contentToString();
					String contentTokens[] = content.split("\n");
					int count = contentTokens.length;
					//System.out.println("Count :" + count);
					
					for(int i = 0; i < count; i++)
					{
						String text = contentTokens[i].trim();
						System.out.println("Token[" + i + "] :" + contentTokens[i].trim());
						Log.info("Token[" + i + "] :" + contentTokens[i].trim());
						if(text.contains(":"))
						{
							String tokens[] = text.split(":");
							String key = tokens[0].trim();
							MLArray keyValue = mlResultsStructure.getField(key);
							String valueTokens[] = keyValue.contentToString().trim().split("=");
							String value = "";
							if(valueTokens.length > 1)
							{
								if(valueTokens[1].trim().length() > 0)
								{
									value = valueTokens[1].trim();
									value = parseString(value);
								}
							}
							
							resultsMap.put(key, value);							
						}
					}
				}
				item.setColumns(resultsMap);
							
				//JobTiming
				
				if(mlStructure.getField("JobTiming") != null && mlStructure.getField("JobTiming").getType() == 2)
				{
					MLStructure mlDurationStructure = (MLStructure) mlStructure.getField("JobTiming");
					String content = mlDurationStructure.contentToString();
					String contentTokens[] = content.split("\n");
					int count = contentTokens.length;
					//System.out.println("Count :" + count);
					
					for(int i = 0; i < count; i++)
					{
						String text = contentTokens[i].trim();
						System.out.println("Token[" + i + "] :" + contentTokens[i].trim());
						if(text.contains(":"))
						{
							String tokens[] = text.split(":");
							String key = tokens[0].trim();
							MLArray keyValue = mlDurationStructure.getField(key);
							String valueTokens[] = keyValue.contentToString().trim().split("=");
							String value = "";
							if(valueTokens.length > 1)
							{
								value = valueTokens[1].trim();							
							}
							
							if(key.equalsIgnoreCase("StartTime"))
							{
								if(value.length() > 0)
								{
									value = parseString(value);
								}								
								item.setStartTime(value);
							}
							else if(key.equalsIgnoreCase("StopTime"))
							{
								if(value.length() > 0)
								{
									value = parseString(value);
								}
								item.setStopTime(value);
							}
							else if(key.equalsIgnoreCase("ProcessDuration"))
							{
								if(value.length() > 0)
								{
									int ind = value.indexOf(".");
									if(ind != -1)
									{
										int length = value.length();
										if((ind + 5) < length)
										{
											item.setProcessDuration(value.substring(0, (ind + 5)));									
										}
										else
										{
											item.setProcessDuration(value);
										}
									}
									else
									{
										item.setProcessDuration(value);
									}
								}															
							}
							//System.out.println("Key :" + key + " Value: " + value);
						}
					}
				}						
				
				if(item.getStatus().equalsIgnoreCase("Failed"))
				{
					//Errors
					LinkedHashMap<String, String> errorMap = new LinkedHashMap<String, String>();
					
					if(mlStructure.getField("JobError") != null && mlStructure.getField("JobError").getType() == 2)
					{
						MLStructure mlErrorStructure = (MLStructure) mlStructure.getField("JobError");
						String content = mlErrorStructure.contentToString();
						String contentTokens[] = content.split("\n");
						int count = contentTokens.length;
						//System.out.println("Count :" + count);
						
						for(int i = 0; i < count; i++)
						{
							String text = contentTokens[i].trim();
							//System.out.println("Token[" + i + "] :" + contentTokens[i].trim());
							if(text.contains(":"))
							{
								String tokens[] = text.split(":");
								String key = tokens[0].trim();
								MLArray keyValue = mlErrorStructure.getField(key);
								String valueTokens[] = keyValue.contentToString().trim().split("=");
								String value = "";
								if(valueTokens.length > 1)
								{
									if(valueTokens[1].trim().length() > 0)
									{
										value = valueTokens[1].trim();
										//errorMap.put(key, value);									
									}
								}
								
								errorMap.put(key, parseString(value));
								//System.out.println("Key :" + key + " Value: " + value);
							}
						}
					}
					
					//Warnings
					
					if(mlStructure.getField("JobWarning") != null && mlStructure.getField("JobWarning").getType() == 2)
					{
						MLStructure mlWarningStructure = (MLStructure) mlStructure.getField("JobWarning");
						String content = mlWarningStructure.contentToString();
						String contentTokens[] = content.split("\n");
						int count = contentTokens.length;
						//System.out.println("Count :" + count);
						
						for(int i = 0; i < count; i++)
						{
							String text = contentTokens[i].trim();
							//System.out.println("Token[" + i + "] :" + contentTokens[i].trim());
							if(text.contains(":"))
							{
								String tokens[] = text.split(":");
								String key = tokens[0].trim();
								MLArray keyValue = mlWarningStructure.getField(key);
								String valueTokens[] = keyValue.contentToString().trim().split("=");
								String value = "";
								if(valueTokens.length > 1)
								{
									if(valueTokens[1].trim().length() > 0)
									{
										value = valueTokens[1].trim();
									}
								}
								
								errorMap.put(key, parseString(value));
								//errorMap.put(key, value);
								//System.out.println("Key :" + key + " Value: " + value);
							}
						}
					}				
					item.setColumns(errorMap);
				}			
				
				//JobID
				
				int jobId = 0;
				if(mlStructure.getField("JobID") != null)
				{
					MLDouble jobIDStr = (MLDouble) mlStructure.getField("JobID");
					System.out.println("Job ID: " + jobIDStr.contentToString());
					Log.info("Job ID: " + jobIDStr.contentToString());
					String tokens[] = jobIDStr.contentToString().split("\n");
					if(tokens.length > 1)
					{
						if(tokens[1].trim().length() > 0)
						{
							try
							{
								jobId = (int) Double.parseDouble(tokens[1].trim());
							}
							catch(NumberFormatException e)
							{
								e.printStackTrace();
							}
						}
					}										
				}
				item.setJobId(jobId);
				
				
				// Status
				
				if(mlStructure.getField("Status") != null)
				{
					MLChar jobStatus = (MLChar) mlStructure.getField("Status");
					String statusStr = jobStatus.contentToString();
					if(statusStr.length() > 0)
					{
						status = parseString(statusStr);
						double statusValue = 0;
						try
						{
							statusValue = Double.parseDouble(status);
						}
						catch(NumberFormatException e)
						{
							System.out.println("Job " + item.getJobId() + " status not a double value.");
							Log.info("Job " + item.getJobId() + " status not a double value.");
							//e.printStackTrace();
						}
						if(statusValue > 0)
						{
							status = status + "% Complete";
						}
					}
					item.setStatus(status);
					System.out.println("Status: " + status);
				}
			}						
		}
		catch (Exception e)
		{
			Log.info("Error reading file " + filePath);
			e.printStackTrace();
		}	
		System.out.println("***** JobName in getting JobDetails: " + item.getJobName());
		return item;
	}
	
	private String parseString(String value)
	{
		if(value.length() > 0)
		{
			if(value.indexOf("'") != -1)
			{
				String[] tokens = value.split("'");
				return tokens[1].trim();
			}			
		}
		return value;
				
	}
}