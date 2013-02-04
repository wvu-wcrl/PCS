package com.wcrl.web.cml.server;

import java.io.File;
import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;

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
import com.wcrl.web.cml.client.account.User;

 public class UploadFileServlet extends HttpServlet {
      
	 private static final long serialVersionUID = -1660370413961174966L;
	 private Map<String, String> jobDetailsMap = new HashMap<String, String>();
	 private ArrayList<String> allowedFormats = new ArrayList<String>();
	 private String login;
	 private String project;
	 private String overwrite;
	 private ResourceBundle constants = ResourceBundle.getBundle("Paths");
	 private String rootPath = constants.getString("path");
	 	 
	 public UploadFileServlet()
	 {
		 super();
	 }
   
     @SuppressWarnings("unchecked")
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {   		 
    	 HttpSession session = request.getSession();
    	 if (session.getAttribute("Username") != null)
    	 {
             // process only multipart requests
        	 DBConnection connection = new DBConnection();
        	 response.setContentType("text/html");
        	 String path = constants.getString("path");
    	
        	ResultSet rs = null;
     		try
     		{
     			connection.openConnection();
     			CallableStatement cs = connection.getConnection().prepareCall("{ call GetJobFileExtensions() }");
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
     		
             if (ServletFileUpload.isMultipartContent(request)) 
             {            
                 FileItemFactory factory = new DiskFileItemFactory();
                 ServletFileUpload upload = new ServletFileUpload(factory);
                 
                 try 
                 {
                	 List<FileItem> items = upload.parseRequest(request);
                                    
                     for (FileItem item : items) 
                     { 
                    	 if (item.isFormField()) 
                         {
                    		 jobDetailsMap.put(item.getFieldName(), item.getString());                   	 
                         }
                     }
                     project = jobDetailsMap.get("projectName");
                     login = jobDetailsMap.get("user");
                     overwrite = jobDetailsMap.get("overwrite");
                     
                     //System.out.println(" Items size:" + items.size() + " Login: " + login + " Project: " + project);
                     boolean fileFlag = true;  
                     String[] files = new String[2];
                     ArrayList<FileItem> fileItems = new ArrayList<FileItem>();
                    
                     int idx = 0;
                     for (FileItem item : items) 
                     {
                         // process only file upload - discard other form item types                	           	  
                         if (item.isFormField()) 
                         {                    	 
                        	 continue;
                         }      	                    
                                             
                         String fileName = item.getName();
                         files[idx] = fileName;
                         idx++;
                         fileItems.add(item);
                         
                         // get only the file name not whole path
                         if (fileName != null) 
                         {
                        	 fileName = FilenameUtils.getName(fileName);

                        	 Iterator<String> itr = allowedFormats.iterator();
                        	 boolean validFileExtension = false;
                        	 while(itr.hasNext())
                        	 {
                        		 String fileExtension = itr.next().toString();
                        		 if(fileName.endsWith(fileExtension))
                        		 {
    								 validFileExtension = true;								 
                        		 }
                        	 }
                        	 if(validFileExtension)
                    		 {
                    			//Creating file path to save the file                             
                                 fileFlag = true && fileFlag;
                    		 }
                    		 else
                    		 {
                    			 fileFlag = false;
                    			 String msg = "2~Not a valid file format. Please upload a \".mat\" file.";
                    			 response.getWriter().print(msg);
                    		 }                        	
                         }                                         
                     }
                     if(fileFlag)
                     {
                    	 User currentUser = getUser(login); 
                    	 double usedRuntime = currentUser.getUsedRuntime();
                    	 double totalRuntime = currentUser.getTotalRuntime();
                    	 if(usedRuntime < totalRuntime)
                    	 {
                    		 createNewFile(path, files[0], fileItems.get(0), response);
                    	 }
                    	 else
                    	 {
                    		 String msg = 2 + "~You have exceeded your usage quota. Please contact administrator.";
            				 response.getWriter().print(msg);
            			     //throw new IOException(msg);
                    	 }
                    	 /*int jobId = saveFileData(login, files[0]);
                    	 if(jobId != 0)
                    	 {
                    		 createNewFile(path, files[0], fileItems.get(0), jobId, response);
                    		 for(int i = 0; i < files.length; i++)
                        	 {
                    			 createNewFile(dir, files[i], fileItems.get(i), jobId, response);                    		 
                        	 }
                    	 }*/                	                 	 
                     }                 
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
     
     private void createNewFile(String dir, String fileName, FileItem item, HttpServletResponse response)
     {
    	 String currentDir = dir;     
    	 File checkDir = new File(currentDir);             
         boolean success1 = false;
     
         if(!checkDir.exists())
         {
        	 success1 = checkDir.mkdirs();
         }
         else
         {
        	 success1 = true;
         }         
         Log.info("~~~Creating directory structure to place file: " + checkDir + " success: " +  success1);
         System.out.println("~~~Creating directory structure to place file: " + checkDir + " success: " +  success1 + " dir: " + dir);
         /*if(success1)
         {
        	 checkDir.setWritable(true, false);
         }*/
    	 dir = dir + login + File.separator + constants.getString("projects") + File.separator + project + File.separator + constants.getString("JobIn");
         checkDir = new File(dir);             
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
        		 String filePath = rootPath + login + File.separator + constants.getString("projects") + File.separator + project + File.separator + fileDir + File.separator + fileName;
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
            		 if(!overwrite.equals("1"))
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
                		 createFile(uploadedFile, item, response);  
                	 }            		 
            	 }
            	 else
            	 {
            		 createFile(uploadedFile, item, response);            		 
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
     
     public void createFile(File uploadedFile, FileItem item, HttpServletResponse response)
     {
    	 try 
         {
    		 if (uploadedFile.createNewFile()) 
			 {
			     item.write(uploadedFile);
			     response.setStatus(HttpServletResponse.SC_CREATED);			     
			     response.flushBuffer();
			     String msg = 1 + "~Job created and queued for execution.";
					 
			     Log.info("Message: " + msg + " Absolute path: " + uploadedFile.getAbsolutePath() + " Path: " + uploadedFile.getPath());
			     /*Log.info("Absolute path: " + uploadedFile.getAbsolutePath() + " Path: " + uploadedFile.getPath());
			     //Associate the  directory and its contents if the Operating system is Linux/Unix
			     if(File.separator.equals("/"))
			     {
			    	 Runtime rt = Runtime.getRuntime();
			    	 
			    	 String path = uploadedFile.getPath();
			    	 String temp = "chown tomcat55:tomcatusers " + path;
			    	 System.out.println("command line cmd: " + temp);
			    	 Log.info("command line cmd: " + temp);
			    	 Process proc = rt.exec(temp);
			    	 Log.info("Process inputStream: " + proc.getInputStream().toString());
			    	 Log.info("Process outputStream: " + proc.getOutputStream());
			    	 Log.info("Process errorStream: " + proc.getErrorStream());
			    	 int exitVal = proc.waitFor();
			    	 Log.info("Ownership process exitValue: " + exitVal);
			    	 temp = "chmod 664 " + path;
			    	 System.out.println("command line cmd: " + temp);
			    	 proc = rt.exec(temp);
			    	 exitVal = proc.waitFor();
			    	 System.out.println("Process exitValue: " + exitVal);        			    	 
    	             Log.info("Permissions process exitValue: " + exitVal);
			     }*/    
			     response.getWriter().print(msg);
			 }
			 else
			 {
				//Code Added
				 String msg = 2 + "~Error in adding job. Please try again later.";
				 response.getWriter().print(msg);
			     //throw new IOException(msg);                        
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