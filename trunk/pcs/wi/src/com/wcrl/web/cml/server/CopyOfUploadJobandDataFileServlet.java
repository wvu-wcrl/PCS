package com.wcrl.web.cml.server;

import java.io.File;
import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.ResourceBundle;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FilenameUtils;
import com.allen_sauer.gwt.log.client.Log;
import com.jmatio.io.MatFileReader;
import com.jmatio.io.MatFileWriter;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLChar;
import com.jmatio.types.MLStructure;
import com.wcrl.web.cml.client.account.User;

 public class CopyOfUploadJobandDataFileServlet extends HttpServlet {
      
	 private static final long serialVersionUID = -1660370413961174966L;
	 private Map<String, String> jobDetailsMap; 
	 private ResourceBundle constants = ResourceBundle.getBundle("Paths");
	 private String rootPath = constants.getString("path");
	 private String dataFileName;
	 private String jobMsg;
	 private String dataMsg;
	 	 
	 public CopyOfUploadJobandDataFileServlet()
	 {
		 super();
	 }
   
     @SuppressWarnings("unchecked")
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {   		 
    	 dataMsg = "";
    	 jobMsg = "";
    	 jobDetailsMap = new HashMap<String, String>();
    	 HttpSession session = request.getSession();
    	 if (session.getAttribute("Username") != null)
    	 {
             // process only multipart requests
        	 
        	 response.setContentType("text/html");
        	 String path = constants.getString("path");       	
     		
             if (ServletFileUpload.isMultipartContent(request)) 
             {            
                 FileItemFactory factory = new DiskFileItemFactory();
                 ServletFileUpload upload = new ServletFileUpload(factory);
                 
                 boolean jobFileFlag = false;
                 boolean dataFileFlag = false;
                 
                 try 
                 {
                	 List<FileItem> items = upload.parseRequest(request);
                	 HashMap<String, FileItem> fileMap = new HashMap<String, FileItem>();
                     ArrayList<String> allowedFormats = new ArrayList<String>();
                     String fileName = "";
                     String validFileTypes = "";
                     for (FileItem item : items) 
                     {               	           	  
                         if (item.isFormField()) 
                         {                    	 
                        	 jobDetailsMap.put(item.getFieldName(), item.getString());
                         } 
                     }
                     dataFileName = jobDetailsMap.get("dataFile");
                     for (FileItem item : items) 
                     {
                         // process only file upload - discard other form item types                	           	  
                         if (item.isFormField()) 
                         {                    	 
                        	 continue;
                         }  
                         else
                         {
                        	 fileName = item.getName();
                        	 fileMap.put(item.getFieldName(), item);
                        	 if(item.getFieldName().equalsIgnoreCase("jobUpload"))
                             {
                            	 if (fileName != null) 
                                 {
                            		 validFileTypes = "";
                                	 fileName = FilenameUtils.getName(fileName);
                                	 allowedFormats = getFileExtensions("job", jobDetailsMap.get("projectName"));
                                	 
                                	 boolean validFileExtension = false;
                                	 int count = allowedFormats.size();
                                	 for(int i = 0; i < count; i++)
                                	 {
                                		 String fileExtension = allowedFormats.get(i).trim();
                                		 if(i == (count - 1))
                                		 {
                                			 validFileTypes = validFileTypes + fileExtension;
                                		 }
                                		 else
                                		 {
                                			 validFileTypes = validFileTypes + fileExtension + ", ";
                                		 }
                                		 if(fileName.endsWith(fileExtension))
                                		 {
            								 validFileExtension = true;	
            								 break;
                                		 } 
                                	 }
                                	 if(validFileExtension)
                            		 {           
                                		 User currentUser = getUser(jobDetailsMap.get("user")); 
                                    	 double usedRuntime = currentUser.getUsedRuntime();
                                    	 double totalRuntime = currentUser.getTotalRuntime();
                                    	 if(usedRuntime < totalRuntime)
                                    	 {
                                    		 jobFileFlag = checkForJobFile(path, item.getName(), item, response, dataFileName);
                                    	 }
                                    	 else
                                    	 {
                                    		 String msg = 2 + "~You have exceeded your usage quota. Please contact administrator.";
                            				 response.getWriter().print(msg);
                                    	 }
                            		 }
                            		 else
                            		 {
                            			 String msg = "2~Not a valid job file type. Please upload a file of following file types " + validFileTypes + ".";
                            			 response.getWriter().print(msg);
                            		 }                        	
                                 }
                             }
                        	 else if(item.getFieldName().equalsIgnoreCase("dataUpload"))
                        	 {
                        		 if (fileName != null) 
                                 {
                        			 validFileTypes = "";
                                	 fileName = FilenameUtils.getName(fileName);
                                	 allowedFormats = getFileExtensions("data", jobDetailsMap.get("projectName"));
                                	 
                                	 boolean validFileExtension = false;
                                	 int count = allowedFormats.size();
                                	 for(int i = 0; i < count; i++)
                                	 {
                                		 String fileExtension = allowedFormats.get(i).trim();
                                		 if(i == (count - 1))
                                		 {
                                			 validFileTypes = validFileTypes + fileExtension;
                                		 }
                                		 else
                                		 {
                                			 validFileTypes = validFileTypes + fileExtension + ", ";
                                		 }
                                		 if(fileName.endsWith(fileExtension))
                                		 {
            								 validFileExtension = true;	
            								 break;
                                		 } 
                                	 }
                                	 if(validFileExtension)
                            		 {      
                                		 dataFileFlag = checkForDataFile(path, item.getName(), item, jobDetailsMap.get("user"), jobDetailsMap.get("projectName"), jobDetailsMap.get("overwrite"), response);
                            		 }
                            		 else
                            		 {
                            			 String msg = "2~Not a valid data file type. Please upload a file of following file types " + validFileTypes + ".";
                            			 response.getWriter().print(msg);
                            		 }                        	
                                 }
                        	 }                                                     	 
                         }                                                                  
                     }
                     if(!jobFileFlag && !dataFileFlag)
                     {
                    	 Set<Entry<String, FileItem>> entries = fileMap.entrySet();
                    	 File uploadedFile = null;
                    	 for(Entry<String, FileItem> entry : entries)
                    	 {
                    		 String key = entry.getKey();
                    		 FileItem item = entry.getValue();
                    		 
                    		 if(key.equals("jobUpload"))
                    		 {
                    			 String dir = path + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("projectName") + File.separator + constants.getString("JobIn");
                    			 uploadedFile = new File(dir, item.getName());
                    			 createFile(uploadedFile, item, response, dataFileName, 0);
                    		 }
                    		 else if(key.equals("dataUpload"))
                    		 {
                    			 String dir = path + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("projectName") + File.separator + constants.getString("Data");
                    			 uploadedFile = new File(dir, item.getName());
                    			 createFile(uploadedFile, item, response, "", 1);
                    		 }
                    	 }                   	 
                     }
                     else if(jobFileFlag && !dataFileFlag)
                     {
                    	 response.getWriter().print(dataMsg);
                     }
                     else if(!jobFileFlag && dataFileFlag)
                     {
                    	 response.getWriter().print(jobMsg);
                     }
                     else if(jobFileFlag && dataFileFlag)
                     {
                    	 String msg = "Chosen files exist in the repository. Please add files with other file names.";
                    	 response.getWriter().print(msg);                    	 
                     }
                     /*if(jobFileFlag)
                     {
                    	 User currentUser = getUser(jobDetailsMap.get("user")); 
                    	 double usedRuntime = currentUser.getUsedRuntime();
                    	 double totalRuntime = currentUser.getTotalRuntime();
                    	 if(usedRuntime < totalRuntime)
                    	 {
                    		 createNewFile(path, fileItems.get(0).getName(), fileItems.get(0), response);
                    	 }
                    	 else
                    	 {
                    		 String msg = 2 + "~You have exceeded your usage quota. Please contact administrator.";
            				 response.getWriter().print(msg);
                    	 }                	                 	 
                     }*/                 
                 } 
                 catch (Exception e) 
                 {
                     response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while creating the file : " + e.getMessage());
                 }           
             } 
             else 
             {
                 response.sendError(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE, "Request contents type is not supported by the servlet.");
             }  
    	 }       
     }    
     
     private ArrayList<String> getFileExtensions(String str, String project)
     {
    	 ArrayList<String> allowedFormats = new ArrayList<String>();
    	 DBConnection connection = new DBConnection();
    	 ResultSet rs = null;
    	 try
    	 {
    		 connection.openConnection();
    		 CallableStatement cs = null;
    		 if(str.equalsIgnoreCase("job"))
    		 {
    			 cs = connection.getConnection().prepareCall("{ call GetJobFileExtensions(?) }");    			 
    		 }
    		 else if(str.equalsIgnoreCase("data"))
    		 {
    			 cs = connection.getConnection().prepareCall("{ call GetDataFileExtensions(?) }");
    		 }
    		 cs.setString(1, project);
    		 boolean hasResults = cs.execute();
    		 
    		 if(hasResults)
    		 {
    			 rs = cs.getResultSet();
    			 allowedFormats.clear();
    			 while(rs.next())
    			 {
    				 allowedFormats.add(rs.getString("FileExtension"));
    			 }
    		 }
    		 rs.close();
    	 }
    	 catch(SQLException e)
    	 {
    		 e.printStackTrace();
    	 }
    	 finally
    	 {
    		 try
    		 {
    			 if(rs != null && !rs.isClosed())
    			 {
    				 rs.close();
    			 }
    			 if(connection.getConnection() != null)
    			 {
    				 connection.closeConnection();
    			 }
    		 }
    		 catch (SQLException e)
    		 {
    			 e.printStackTrace();
    		 }
    	 }
		return allowedFormats;
     }
     
     
     private boolean addDataFileNameInJobFile(File jobFile, String dataFileName)
     {
    	 System.out.println("In addDataFileNameInJobFile");
    	 boolean editFile = false;
    	 try 
    	 {
			MatFileReader matfilereader = new MatFileReader(jobFile);
			System.out.println("matfilereader: " + matfilereader);
			if(matfilereader.getMLArray("JobParam") != null && matfilereader.getMLArray("JobState") != null)
			{				
				MLStructure mlParamStructure = (MLStructure) matfilereader.getMLArray("JobParam");
				System.out.println("JobParam: " + mlParamStructure);
				if(mlParamStructure.getField("DataFile") != null)
				{
					MLArray dataFileField = mlParamStructure.getField("DataFile");
					dataFileField.dispose();
				}
				MLChar dataFile = new MLChar("DataFile", dataFileName);					
				mlParamStructure.setField("DataFile", dataFile);
				MatFileWriter fileWriter = new MatFileWriter();
				ArrayList<MLArray> list = new ArrayList<MLArray>();
				list.add(mlParamStructure);
				list.add(matfilereader.getMLArray("JobState"));
				fileWriter.write(jobFile.getPath(), list);
				editFile = true;
			}
    	 } 
    	 catch (IOException e) 
    	 {
			e.printStackTrace();
    	 }
		return editFile;    	 
     }
     
     private User getUser(String login) 
 	{
    	User currentUser = new User();
 		try 
     	{    
 			DBConnection connection = new DBConnection();	
 			connection.openConnection();
 			CallableStatement cs = connection.getConnection().prepareCall("{ call ValidateUser(?) }");
		    cs.setString(1, login);		
		    boolean hasResults = cs.execute();
		    //System.out.println("HasResults: " + hasResults + " login: " + login);
		    if(hasResults)
			{
		    	ResultSet rs = cs.getResultSet();
		    	//System.out.println("Resultset: " + rs.getFetchSize());
				while(rs.next())
				{					
					currentUser.setUserId(rs.getInt("userId"));					
					currentUser.setUsername(login);
					UserProcessDurationUsage userUsage = new UserProcessDurationUsage();
					double usedRuntime = userUsage.getUserUsage(currentUser.getUserId()) ;
					currentUser.setUsedRuntime(usedRuntime);
					currentUser.setTotalRuntime(rs.getDouble("TotalUnits"));
				}
			}
 			cs.close();	
 			connection.closeConnection();
 		}
     	catch (SQLException e) 
         {
         	e.printStackTrace();
         }
 		return currentUser;
 	}
     
     private boolean checkForJobFile(String dir, String fileName, FileItem item, HttpServletResponse response, String dataFileName)
     {
    	 boolean fileExists = false;
    	 dir = dir + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("projectName") + File.separator + constants.getString("JobIn");
         File checkDir = new File(dir);             
         boolean success = false;
  
         if(!checkDir.exists())
         {
        	 success = checkDir.mkdirs();
         }
         else
         {
        	 success = true;
         }         
         Log.info("***Creating directory structure to place file: " + checkDir + " success: " +  success);
         System.out.println("***Creating directory structure to place file: " + checkDir + " success: " +  success);
         if(success)
         {
        	 System.out.println("______________________________________________________");
        	 //checkDir.setWritable(true, false);
             System.setProperty("user.dir", dir);
         
        	 File uploadedFile = new File(dir, fileName); 

        	 String[] statusDirectory = new String[6];
        	 statusDirectory[0] = "JobIn";
        	 statusDirectory[1] = "JobRunning";
        	 statusDirectory[2] = "JobOut";
        	 statusDirectory[3] = "archive";
        	 statusDirectory[4] = "Suspend";
        	 statusDirectory[5] = "JobFailed";
        	         	 
        	 int directoryCount = statusDirectory.length;
        	 String filePathToDelete = "";
        	 String fileToDeleteStatus = "";
        	 for(int i = 0; i < directoryCount; i++)
        	 {
        		 String fileDir = constants.getString(statusDirectory[i]);
        		 String filePath = rootPath + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("projectName") + File.separator + fileDir + File.separator + fileName;
        		 System.out.println("Checking file: " + filePath);
        		 Log.info("Checking file: " + filePath);
        		 File file = new File(filePath);
        		 if(file.exists())
        		 {
        			 fileExists = true;       			 
        			 filePathToDelete = filePath;
        			 fileToDeleteStatus = getExistingJobStatus(statusDirectory[i]);
        			 break;
        		 }
        	 }
        	 System.out.println("Checking fileExists: " + fileExists);
        	 Log.info("Checking fileExists: " + fileExists);
        	 
        	 try
        	 {
        		 if(fileExists)
            	 {
            		 if(!jobDetailsMap.get("overwrite").equals("1"))
                	 {
            			 //String msg = "";
            			 if(fileToDeleteStatus.equalsIgnoreCase("Archived"))
            			 {
            				 jobMsg = 0 + "~An \"" + fileToDeleteStatus  + "\" job with the file name already exists in the repository. Do you want to overwrite?";
            			 }
            			 else
            			 {
            				 jobMsg = 0 + "~A \"" + fileToDeleteStatus  + "\" job with the file name already exists in the repository. Do you want to overwrite?";
            			 }            			 
            			 //response.getWriter().print(msg);
                	 }
                	 else
                	 {
                		 File removeFile = new File(filePathToDelete);
                		 removeFile.delete();        
                		 createFile(uploadedFile, item, response, dataFileName, 0);  
                	 }            		 
            	 }
            	 /*else
            	 {
            		 createFile(uploadedFile, item, response, dataFileName, 0);            		 
            	 }*/
        	 }
        	 catch (Exception e) 
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
         }
		return fileExists;         
     }
     
     /*private void createNewJobFile(String dir, String fileName, FileItem item, HttpServletResponse response, String dataFileName)
     {
    	 dir = dir + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("projectName") + File.separator + constants.getString("JobIn");
         File checkDir = new File(dir);             
         boolean success = false;
  
         if(!checkDir.exists())
         {
        	 success = checkDir.mkdirs();
         }
         else
         {
        	 success = true;
         }         
         Log.info("***Creating directory structure to place file: " + checkDir + " success: " +  success);
         System.out.println("***Creating directory structure to place file: " + checkDir + " success: " +  success);
         if(success)
         {
        	 System.out.println("______________________________________________________");
        	 //checkDir.setWritable(true, false);
             System.setProperty("user.dir", dir);
         
        	 File uploadedFile = new File(dir, fileName); 

        	 String[] statusDirectory = new String[6];
        	 statusDirectory[0] = "JobIn";
        	 statusDirectory[1] = "JobRunning";
        	 statusDirectory[2] = "JobOut";
        	 statusDirectory[3] = "archive";
        	 statusDirectory[4] = "Suspend";
        	 statusDirectory[5] = "JobFailed";
        	 
        	 boolean fileExists = false;
        	 int directoryCount = statusDirectory.length;
        	 String filePathToDelete = "";
        	 String fileToDeleteStatus = "";
        	 for(int i = 0; i < directoryCount; i++)
        	 {
        		 String fileDir = constants.getString(statusDirectory[i]);
        		 String filePath = rootPath + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("projectName") + File.separator + fileDir + File.separator + fileName;
        		 System.out.println("Checking file: " + filePath);
        		 Log.info("Checking file: " + filePath);
        		 File file = new File(filePath);
        		 if(file.exists())
        		 {
        			 fileExists = true;       			 
        			 filePathToDelete = filePath;
        			 fileToDeleteStatus = getExistingJobStatus(statusDirectory[i]);
        			 break;
        		 }
        	 }
        	 System.out.println("Checking fileExists: " + fileExists);
        	 Log.info("Checking fileExists: " + fileExists);
        	 
        	 try
        	 {
        		 if(fileExists)
            	 {
            		 if(!jobDetailsMap.get("overwrite").equals("1"))
                	 {
            			 String msg = "";
            			 if(fileToDeleteStatus.equalsIgnoreCase("Archived"))
            			 {
            				 msg = 0 + "~An \"" + fileToDeleteStatus  + "\" job with the file name already exists in the repository. Do you want to overwrite?";
            			 }
            			 else
            			 {
            				 msg = 0 + "~A \"" + fileToDeleteStatus  + "\" job with the file name already exists in the repository. Do you want to overwrite?";
            			 }            			 
            			 response.getWriter().print(msg);
                	 }
                	 else
                	 {
                		 File removeFile = new File(filePathToDelete);
                		 removeFile.delete();        
                		 createFile(uploadedFile, item, response, dataFileName, 0);  
                	 }            		 
            	 }
            	 else
            	 {
            		 createFile(uploadedFile, item, response, dataFileName, 0);            		 
            	 }
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
         }         
     }*/
     
     private boolean checkForDataFile(String dir, String fileName, FileItem item, String login, String project, String overwrite, HttpServletResponse response)
     {
    	 boolean fileExists = false;
    	 /*String currentDir = dir;     
    	 File checkDir = new File(currentDir);             
       
         if(!checkDir.exists())
         {
        	 success1 = checkDir.mkdirs();
         }
         else
         {
        	 success1 = true;
         }*/         
         
    	 dir = dir + login + File.separator + constants.getString("projects") + File.separator + project + File.separator + constants.getString("Data");
         File checkDir = new File(dir);             
         boolean success = false;
  
         if(!checkDir.exists())
         {
        	 success = checkDir.mkdirs();
         }
         else
         {
        	 success = true;
         }         
         
         if(success)
         {
        	 System.out.println("______________________________________________________");
        	 
             System.setProperty("user.dir", dir);
         
        	 File uploadedFile = new File(dir, fileName);
        	 

        	 String filePath = dir + File.separator + fileName;
    		 System.out.println("Checking file: " + filePath + " uploaded path: " + dir + " filename: " + fileName + " " + uploadedFile.getAbsolutePath());
    		 Log.info("Checking file: " + filePath);
    		 File file = new File(filePath);
    		 if(file.exists())
    		 {
    			 fileExists = true;
    		 }   		 
    		 
        	 System.out.println("Checking fileExists: " + fileExists + " " + uploadedFile.getPath() + " " + uploadedFile.getAbsolutePath());
        	 
        	 Log.info("Checking fileExists: " + fileExists);
        	 
        	 try
        	 {
        		 if(fileExists)
            	 {
            		 if(!jobDetailsMap.get("dataOverwrite").equals("1"))
                	 {
            			 dataMsg = 0 + "~A data file with the name already exists in the repository. Do you want to overwrite?";
            			 //response.getWriter().print(msg);
                	 }
                	 else
                	 {
                		 File removeFile = new File(filePath);
                		 removeFile.delete();        
                		 createFile(uploadedFile, item, response, "", 1);  
                	 }            		 
            	 }
            	 /*else
            	 {
            		 createFile(uploadedFile, item, response, "", 1);            		 
            	 }*/
        	 }
        	 catch (Exception e) 
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
         }
		return fileExists;         
     }
     
     public String getExistingJobStatus(String directory)
     {
    	 String status = "";
    	 if(directory.equals("JobIn"))
    	 {
    		 status = "queued";
    	 }
    	 else if(directory.equals("JobRunning"))
    	 {
    		 status = "running";
    	 }
    	 else if(directory.equals("archive"))
    	 {
    		 status = "archived";
    	 }
    	 else if(directory.equals("JobOut"))
    	 {
    		 status = "completed";
    	 }
    	 else if(directory.equals("Suspend"))
    	 {
    		 status = "suspended";
    	 }
    	 else if(directory.equals("JobFailed"))
    	 {
    		 status = "failed";
    	 }    	 
    	 return status;    	 
     }
     
     public void createFile(File uploadedFile, FileItem item, HttpServletResponse response, String dataFileName, int from)
     {
    	 
    	 System.out.println("Upload file: " + uploadedFile.getPath() + " absolute path: " + uploadedFile.getAbsolutePath() + " filename: " + item.getName());
    	 try 
         {
    		 if (uploadedFile.createNewFile()) 
			 {    	
    			 item.write(uploadedFile);
    			 boolean flag = true;
    			 File userLockFile = null;
    			 if(dataFileName != null && dataFileName.length() > 0)
    			 {
    				// Add a lock file for job file
        			 String userLockFilePath = uploadedFile.getPath() + ".lck";
        			 userLockFile = new File(userLockFilePath);
        			 userLockFile.createNewFile();
        			 
    			     
    			     response.setStatus(HttpServletResponse.SC_CREATED);			     
    			     response.flushBuffer();
    			     
    			     flag = addDataFileNameInJobFile(uploadedFile, dataFileName);
    			 }
    			 System.out.println("After call to addDataFileNameInJobFile flag: " + flag);
			     if(flag)
			     {
			    	 String msg = "";
			    	 if(from == 0)
			    	 {
			    		 msg = 1 + "~Job created and queued for execution.";					 
					     Log.info("Message: " + msg + " Absolute path: " + uploadedFile.getAbsolutePath() + " Path: " + uploadedFile.getPath());				     
					     if(userLockFile != null)
					     {
					    	 userLockFile.delete();
					     }
			    	 }
			    	 else if(from == 1)
			    	 {
			    		 msg = 1 + "~Data file added.";
			    	 }			    	
				     response.getWriter().print(msg);
			     }
			     else
			     {
			    	 String msg = 2 + "~Error in adding job. Please try again later.";
					 response.getWriter().print(msg);
			     }
			 }
			 else
			 {
				 String msg = "";
				 if(from == 0)
		    	 {
					 msg = 2 + "~Error in adding job file. Please try again later.";
		    	 }
				 else if(from == 1)
		    	 {
					 msg = 2 + "~Error in adding data file. Please try again later.";
		    	 }
				 response.getWriter().print(msg);                     
			 }    			
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
 		 catch (Exception e) 
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
     }
}