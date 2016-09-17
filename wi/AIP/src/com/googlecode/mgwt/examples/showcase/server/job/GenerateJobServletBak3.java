package com.googlecode.mgwt.examples.showcase.server.job;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
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
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FilenameUtils;
import org.json.JSONException;
import org.json.JSONObject;

import com.allen_sauer.gwt.log.client.Log;
//import com.google.gwt.json.client.JSONObject;
import com.googlecode.mgwt.examples.showcase.server.db.BCrypt;
import com.googlecode.mgwt.examples.showcase.server.db.DBConnection;
import com.jmatio.io.MatFileReader;
import com.jmatio.io.MatFileWriter;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLChar;
import com.jmatio.types.MLDouble;
import com.jmatio.types.MLStructure;


 public class GenerateJobServletBak3 extends HttpServlet {
      
	 private static final long serialVersionUID = -1660370413961174966L;
	 private Map<String, String> jobDetailsMap; 
	 private ResourceBundle constants = ResourceBundle.getBundle("Paths");
	 private String rootPath = constants.getString("path");
	 private String rhomePath=constants.getString("path2");
	 private String dataFileName;
	 private String dataFileName1;
	 private String jobFileName = "";
	 private String jobMsg;
	 private String dataMsg;
	 private SimpleDateFormat sdf = new SimpleDateFormat("ddMMyyyy-hhmmss");
	 	 
	 public GenerateJobServletBak3()
	 {
		 super();
	 }
   
     @SuppressWarnings("unchecked")
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
    
    	 // Receive data file
    	 
    	 
    	 jobDetailsMap = new HashMap<String, String>();
    	 String MatchingScore=null;

    	 HttpSession session = request.getSession();
    	 
    	 if (session.getAttribute("Username") != null)
    	 {
    		// response.setContentType("application/json");
    		 response.setContentType("text/html");
    		 PreprocessingData(request,response);
    	//	 JSONObject json = new JSONObject();
    		// JSONObject jsonData = new JSONObject();
    		/*    try {
					jsonData.put("jobFileName", "Hi");
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}*/
    		    
    		// String output = jsonData.toString();
    		//response.getWriter().print(output);
    		 response.getWriter().printf("{ \"jobFileName\": \"Hi\" }");
    		    		// response.getWriter().printf("{ \"jobFileName\": \"%s\" }", MatchingScore);
    		    //	 response.getWriter().print(MatchingScore);
    		     response.getWriter().flush();
    		 
    		// response.getOutputStream().println(MatchingScore);
    		// response.getOutputStream().flush();
    	 }
    	 
    	 
    	 // Put image data in place
    	 
    	 // Generate job file
    	 
    	 
    }
    	 
     
     
     
     
     
     
     private void PreprocessingData(HttpServletRequest request, HttpServletResponse response) {
    	 String matching=null;
    	 if (ServletFileUpload.isMultipartContent(request)) 
         {   
    		 HashMap<String, FileItem> fileMap = new HashMap<String, FileItem>();
             FileItemFactory factory = new DiskFileItemFactory();
             ServletFileUpload upload = new ServletFileUpload(factory);
             List<FileItem> items;
			try {
				items = upload.parseRequest(request);
				String fileName = "";
			//	HashMap<String, FileItem> fileMap = new HashMap<String, FileItem>();
	        	 jobDetailsMap = new HashMap<String, String>();
	             
	             // variables for checking if the datafile already exists
	             
	             
	             jobDetailsMap = MvFileItems2HashMap(items);
	             // Add the error checking later
	             dataFileName = jobDetailsMap.get("dataFile");
        		 dataFileName1 = jobDetailsMap.get("dataFile1");
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
                    	
                    	 if(item.getFieldName().equalsIgnoreCase("fileselect[]"))
                    	 {
                    		 if(dataFileName.length() > 0)
                    		 {
                    			 if (fileName != null) 
                                 {
                    				 //System.out.println("~~~fileName: " + fileName);
                        			 
                                	 fileName = FilenameUtils.getName(fileName);
                                	 if(fileName.length() > 0)
                                	 {
                                		
                                    	 //System.out.println("~~~validFileExtension: " + validFileExtension);
                                    	
                                		 
                                    		 String[] tokens = item.getName().split("\\.");
                                			 int cnt = tokens.length;
                                			 dataFileName=tokens[0]+ "." + tokens[cnt-1];
                                			// dataFileName = tokens[0] + "_" + String.format(sdf.format( new Date() )) +  "_" + jobDetailsMap.get("taskName") + "_Data" + "." + tokens[cnt-1];
                                			 jobFileName = tokens[0] + "_" + String.format(sdf.format( new Date() )) +  "_" + jobDetailsMap.get("taskName") + ".mat";
                                			 System.out.println("~~~dataFileName: " + dataFileName);
                                			// dataFileFlag = checkForDataFile(rootPath, dataFileName, item, jobDetailsMap.get("user"), jobDetailsMap.get("project"), jobDetailsMap.get("overwrite"), response);                                            		 
                                    		 //dataFileFlag = checkForDataFile(rootPath, item.getName(), item, jobDetailsMap.get("user"), jobDetailsMap.get("projectName"), jobDetailsMap.get("overwrite"), response);
                                		 
                                	
                                	 }                                	                         	
                                 }
                    		 }                        		 
                    	 }          
                    	 if(item.getFieldName().equalsIgnoreCase("fileselect1[]"))
                    	 {
                    		 if(dataFileName1.length() > 0)
                    		 {
                    			 if (fileName != null) 
                                 {
                    				 //System.out.println("~~~fileName: " + fileName);
                        			 
                                	 fileName = FilenameUtils.getName(fileName);
                                	 if(fileName.length() > 0)
                                	 {
                                		
                                    	 //System.out.println("~~~validFileExtension: " + validFileExtension);
                                    	
                                		 
                                    		 String[] tokens = item.getName().split("\\.");
                                			 int cnt = tokens.length;
                                			 dataFileName1=tokens[0]+ "." + tokens[cnt-1];
                                			 //dataFileName1 = tokens[0] + "_" + String.format(sdf.format( new Date() )) +  "_" + jobDetailsMap.get("taskName") + "_Data" + "." + tokens[cnt-1];
                                		//	 jobFileName = tokens[0] + "_" + String.format(sdf.format( new Date() )) +  "_" + jobDetailsMap.get("taskName") + ".mat";
                                			 System.out.println("~~~dataFileName1: " + dataFileName1);
                                			// dataFileFlag = checkForDataFile(rootPath, dataFileName, item, jobDetailsMap.get("user"), jobDetailsMap.get("project"), jobDetailsMap.get("overwrite"), response);                                            		 
                                    		 //dataFileFlag = checkForDataFile(rootPath, item.getName(), item, jobDetailsMap.get("user"), jobDetailsMap.get("projectName"), jobDetailsMap.get("overwrite"), response);
                                		 
                                	
                                	 }                                	                         	
                                 }
                    		 }                        		 
                    	 }          
        		 
        		 
                     }
                 }
        		 
		/*	}  
	             
			 catch (FileUploadException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}*/
        	 
			
			Set<Entry<String, FileItem>> entries = fileMap.entrySet();
			 File uploadedFile = null;
			 File uploadedFile1 = null;
        	 
        	 for(Entry<String, FileItem> entry : entries)
        	 {
        		 String key = entry.getKey();
        		 FileItem item = entry.getValue();
        		 System.out.println("# Key: " + key);
        		 if(key.equals("fileselect[]"))
        		 //if(key.equals("dataUpload"))
        		 {
        			 String dir = rootPath + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("project") + File.separator + constants.getString("Data");
        			 /*String[] tokens = item.getName().split("\\.");
        			 int cnt = tokens.length;
        			 System.out.println(" item.getName(): " + item.getName() + " dataFileName: " + dataFileName + " Tokens length: " + cnt);
        			 System.out.println(" # " + tokens[0] + " " + tokens[1]);
        			 System.out.println("SDF :" + String.format(sdf.format( new Date() )));
        			 dataFileName = tokens[0] + "_" + String.format(sdf.format( new Date() )) +  "_" + jobDetailsMap.get("taskName") + "." + tokens[cnt-1];*/
        			 System.out.println(" # DataFilename: " + dataFileName);
        			 uploadedFile = new File(dir, dataFileName);
        			 createFile(uploadedFile, item, response, 1);
        		 }
        		 if(key.equals("fileselect1[]"))
            		 //if(key.equals("dataUpload"))
            		 {
            			 String dir = rootPath + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("project") + File.separator + constants.getString("Data");
            			 /*String[] tokens = item.getName().split("\\.");
            			 int cnt = tokens.length;
            			 System.out.println(" item.getName(): " + item.getName() + " dataFileName: " + dataFileName + " Tokens length: " + cnt);
            			 System.out.println(" # " + tokens[0] + " " + tokens[1]);
            			 System.out.println("SDF :" + String.format(sdf.format( new Date() )));
            			 dataFileName = tokens[0] + "_" + String.format(sdf.format( new Date() )) +  "_" + jobDetailsMap.get("taskName") + "." + tokens[cnt-1];*/
            			 System.out.println(" # DataFilename1: " + dataFileName1);
            			 uploadedFile1 = new File(dir, dataFileName1);
            			 createFile(uploadedFile1, item, response, 1);
            		 }
        	 }                
        	// String tempDirPath = rootPath + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("project") + File.separator + constants.getString("Temp");
        	 String tempDirPath = rootPath + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("project") + File.separator + constants.getString("JobIn");
        	 File tempDir = new File(tempDirPath);
        	 
        	 if(!tempDir.exists())
        	 {
        		 tempDir.mkdir();
        	 }
        	 File tempJobFile  = new File(tempDir, jobFileName);
        	 boolean fileGenerated = generateJobFile(tempJobFile, dataFileName,dataFileName1);
        	 String jobMsg = "";
             if(fileGenerated)
             {
            	 jobMsg = 1 + "~Job created and queued for execution.";	
             }
             else
             {
            	 jobMsg = 2 + "~Error in adding job file. Please try again later.";
             }
             Log.info("GenerateJobServlet: " + jobMsg);
         }
             catch (FileUploadException e) {
 				// TODO Auto-generated catch block
 				e.printStackTrace();
 			}
			//matching = jobFileName;
			/*String jobOutPath=rhomePath + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("project") + File.separator + constants.getString("JobOut");
			String jobOutFile=jobOutPath+jobFileName;
			File OutPutFile = new File (jobOutFile);
			int count =1;
			while (count==1)
			{
				if(OutPutFile.exists())
				{
					count=2;
					 matching=getJobData(OutPutFile,jobFileName,jobOutFile);
					
					
				}
			}*/
				
				
				
				
				
			}
			
		//	return matching;
			
        	 
         }
    	 
    	 
    	 
    	 
		
	

     

     private String getJobData(File outPutFile, String jobFileName2,String jobOutFile) 
     {
    	 String MatchScore = null;
    	 MatFileReader matfilereader=null;
    	 try {
			matfilereader = new MatFileReader(jobOutFile);
			if(matfilereader.getMLArray("JobState") != null)
			{
				MLStructure mlStructure = (MLStructure) matfilereader.getMLArray("JobState");
				if(mlStructure.getField("MatchingScore") != null)
				{
					MLChar jobScore = (MLChar) mlStructure.getField("MatchingScore");
					String MatchStr = jobScore.contentToString();
					if(MatchStr.length() > 0)
					{
						MatchScore = parseString(MatchStr);
						
					}
				}
			}
			
		//	return MatchScore;
			
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return MatchScore;
    	 
    	 
    	 
		
		
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

	private Map<String,String> MvFileItems2HashMap(List<FileItem> items ) 
    		 {
    	Map<String,String> jobDetailsMap = new HashMap<String, String>();
    	 
     for (FileItem item : items) 
     {               	           	  
         if (item.isFormField()) 
         {                    	 
        	 System.out.println("Item: " + item.getFieldName() + " Value: " + item.getString());
        	 jobDetailsMap.put(item.getFieldName(), item.getString());
         } 
     }
     return jobDetailsMap;
    		 }

     
     
/*	private ArrayList<String> getFileExtensions(String str, String project)
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
     }*/
          
     private boolean generateJobFile(File jobFile, String dataFileName,String dataFileName1)
     {
    	 System.out.println("In generateJobFile");
    	 boolean fileGenerated = false;
    	 try 
    	 {
    		 int[] dims = {1, 1};
			 
			 MLStructure mlParamStructure = new MLStructure("JobParam", dims);
			 MLStructure mlStateStructure = new MLStructure("JobState", dims);
		//	 String hashKey = "";
    	/*	 if(jobDetailsMap.get("taskName").equalsIgnoreCase("Model"))
    		 {
    			 //String modelTask = jobDetailsMap.get("modelTask");
    			 String galleryPath = constants.getString("datapath");
    			 String secretKey = jobDetailsMap.get("key");
    			 String taskName = jobDetailsMap.get("taskName");
    			 
    			 //String identificationModelPath = constants.getString("identificationModelPath");
    			 
    			 hashKey = BCrypt.hashpw(secretKey, BCrypt.gensalt(12));
    			 
    			 //MLChar modelTaskValue = new MLChar("ModelTask", modelTask);
    			 MLChar dataPath = new MLChar("DataPath", galleryPath);
    			 //MLChar key = new MLChar("Key", hashKey);
    			 MLChar taskTypeName = new MLChar("TaskType", taskName);
    			 //MLChar modelPath = new MLChar("TaskType", identificationModelPath);
    			 
    			 //mlParamStructure.setField("ModelTask", modelTaskValue);
    			 mlParamStructure.setField("DataPath", dataPath);
    			 //mlParamStructure.setField("Key", key);  
    			 mlParamStructure.setField("TaskType", taskTypeName);
    			 //mlParamStructure.setField("ModelPath", modelPath);
    			 
    		 }*/
    		//  if(jobDetailsMap.get("taskName").equalsIgnoreCase("Identification"))
    		// {
    			 //String dataName = jobDetailsMap.get("dataFile");
			     String dataName=rhomePath + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("project") + File.separator + constants.getString("Data")+ File.separator +dataFileName;
    			// String dataName = dataFileName;
			     String dataName1=rhomePath + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("project") + File.separator + constants.getString("Data")+ File.separator +dataFileName1;
    		//	 String dataName1=dataFileName1;
    			 String UserType="EndUser";
    			 double[] MatchingScore1=new double[] {-9.9900};
    		//	 String taskName = jobDetailsMap.get("taskName");
    			 //MasterKeyImpl keyImpl = new MasterKeyImpl();
    			// hashKey = keyImpl.getHashKey();
    			 
    			 MLChar testDataFileName = new MLChar("ImageOnePath", dataName); 
    			 MLChar testDataFileName1 = new MLChar("ImageTwoPath", dataName1); 
    			 MLChar taskUserType = new MLChar("UserType", UserType);
    			 MLDouble MatchingScore=new MLDouble("MatchingScore",MatchingScore1,1);
    			 //MLChar key = new MLChar("Key", hashKey);
    			 
    			 mlParamStructure.setField("ImageOnePath", testDataFileName);
    			 mlParamStructure.setField("ImageTwoPath", testDataFileName1);
    			 
    			 mlParamStructure.setField("UserType", taskUserType);
    			 mlStateStructure.setField("MatchingScore",MatchingScore);
    			 //mlParamStructure.setField("Key", key);
    			 
    		// }
    	/*	 else if(jobDetailsMap.get("taskName").equalsIgnoreCase("Verification"))
    		 {
    			 //String dataName = jobDetailsMap.get("dataFile");
    			 String dataName = dataFileName;
    			 String secretKey = jobDetailsMap.get("key");
    			 String classID = jobDetailsMap.get("classID");    			 
    			 String taskName = jobDetailsMap.get("taskName");
    			 
    			 hashKey = BCrypt.hashpw(secretKey, BCrypt.gensalt(12));
    			 
    			 System.out.println("dataName: " + dataName + " secretKey:" + secretKey + " classID: " + classID + " taskName: " + taskName);
    			     			 
    			 MLChar testDataFileName = new MLChar("DataFile", dataName);
    			 //MLChar key = new MLChar("Key", hashKey);
    			 MLChar testClassID = new MLChar("ClassID", classID);
    			 //MLDouble testClassID = new MLDouble("ClassID", classID);
    			 MLChar taskTypeName = new MLChar("TaskType", taskName);
    			 
    			 mlParamStructure.setField("DataFile", testDataFileName);
    			 //mlParamStructure.setField("Key", key);
    			 mlParamStructure.setField("TestClassID", testClassID);
    			 mlParamStructure.setField("TaskType", taskTypeName);
    		 }    		*/ 
    		 
    		 MatFileWriter fileWriter = new MatFileWriter();
    		 ArrayList<MLArray> list = new ArrayList<MLArray>();
    		 list.add(mlParamStructure);
    		 list.add(mlStateStructure);
 			 System.out.println("Matlab file name: " + jobFile.getPath());
 			 fileWriter.write(jobFile.getPath(), list);
 			 
 			 /*
 			  * 1. Store job file to a temporary location, pass JobParam (without key) and JobState, and HashedKey separately
 			  * 2. Run Matlab script to get RandomProjection
 			  * 3. Save to file and move it to user JobIn directory
 			  */
 			 
 			String jobFilePath = rootPath + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("project") + File.separator + constants.getString("JobIn") + File.separator + jobFile.getName(); 
 		//	RandomProjection randomProjection = new RandomProjection();
 		//	fileGenerated = randomProjection.getRandomProjection(jobFile.getPath(), jobFilePath, hashKey);
 			
 			
 			 
 			 //fileGenerated = true;
 			 
 			/*if(jobDetailsMap.get("taskName").equalsIgnoreCase("Model"))
 			{
 				MasterKeyImpl keyImpl = new MasterKeyImpl();
 				keyImpl.addHashKeyToDB(hashKey, jobDetailsMap.get("user"));
 			}*/
 			
    	 } 
    	 catch (IOException e) 
    	 {
    		 fileGenerated = false;
    		 e.printStackTrace();
    	 }
    	 return fileGenerated;		    	 
     }
     
     private boolean checkForJobFile(String dir, String fileName, HttpServletResponse response)
     {
    	 boolean fileExists = false;
    	 dir = dir + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("project") + File.separator + constants.getString("JobIn");
         File checkDir = new File(dir);             
         boolean success = false;
  
         if(checkDir.exists())
         {        	 
        	 success = true;
         }         
         Log.info("***checkDir: " + checkDir + " success: " +  success);
         System.out.println("***checkDir: " + checkDir + " success: " +  success);
         if(success)
         {
        	 System.out.println("______________________________________________________");
        	 //checkDir.setWritable(true, false);
             System.setProperty("user.dir", dir);
         
        	 //File uploadedFile = new File(dir, fileName); 

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
        		 String filePath = rootPath + jobDetailsMap.get("user") + File.separator + constants.getString("projects") + File.separator + jobDetailsMap.get("project") + File.separator + fileDir + File.separator + fileName;
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
                		 fileExists = false;
                		 //createFile(uploadedFile, item, response, dataFileName, 0);  
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
          
     private boolean checkForDataFile(String dir, String fileName, FileItem item, String login, String project, String overwrite, HttpServletResponse response)
     {
    	 boolean fileExists = false;
    	        
    	 dir = dir + login + File.separator + constants.getString("projects") + File.separator + project + File.separator + constants.getString("Data");
         File checkDir = new File(dir);             
         boolean success = false;
  
         if(checkDir.exists())
         {
        	success = true;
         }         
         
         if(success)
         {        	 
             System.setProperty("user.dir", dir);
         
        	 String filePath = dir + File.separator + fileName;
    		 System.out.println("Checking file: " + filePath + " uploaded path: " + dir + " filename: " + fileName + " ");
    		 Log.info("Checking file: " + filePath);
    		 File file = new File(filePath);
    		 if(file.exists())
    		 {
    			 fileExists = true;
    		 }   		 
    		 
        	 System.out.println("Checking fileExists: " + fileExists);
        	 
        	 Log.info("Checking fileExists: " + fileExists);
        	 
        	 try
        	 {
        		 if(fileExists)
            	 {
            		 if(!jobDetailsMap.get("overwrite").equals("1"))
                	 {
            			 dataMsg = 0 + "~A data file with the name already exists in the repository. Do you want to overwrite?";
                	 }
                	 else
                	 {
                		 File removeFile = new File(filePath);
                		 removeFile.delete();        
                		 fileExists = false;
                	 }            		 
            	 }
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
     
     public void createFile(File uploadedFile, FileItem item, HttpServletResponse response, int from)
     {    	 
    	 System.out.println("Upload file: " + uploadedFile.getPath() + " absolute path: " + uploadedFile.getAbsolutePath() + " filename: " + item.getName());
    	 try 
         {    		 
    		 if (uploadedFile.createNewFile()) 
			 {    	
    			 item.write(uploadedFile);
    			 
    			 String msg = "";
		    	 if(from == 0)
		    	 {
		    		 msg = 1 + "~Job created and queued for execution.";					     
		    	 }
		    	 else if(from == 1)
		    	 {
		    		 msg = 1 + "~Data file added.";
		    	 }			    	
			     response.getWriter().print(msg);
			 }
			 else
			 {
				 String msg = "";
				 if(from == 1)
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
