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
import java.awt.*;
import javax.swing.*;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.swing.ImageIcon;
import javax.swing.JFrame;

import matlabcontrol.MatlabConnectionException;
import matlabcontrol.MatlabInvocationException;
import matlabcontrol.MatlabProxy;
import matlabcontrol.MatlabProxyFactory;
import matlabcontrol.MatlabProxyFactoryOptions;
import matlabcontrol.MatlabProxyFactoryOptions.Builder;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FilenameUtils;
import org.json.JSONException;
import org.json.JSONObject;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.dev.jjs.ast.JLabel;
//import com.google.gwt.json.client.JSONObject;
import com.googlecode.mgwt.examples.showcase.server.db.BCrypt;
import com.googlecode.mgwt.examples.showcase.server.db.DBConnection;
import com.jmatio.io.MatFileReader;
import com.jmatio.io.MatFileWriter;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLChar;
import com.jmatio.types.MLDouble;
import com.jmatio.types.MLStructure;


 public class GenerateJobServlet extends HttpServlet {
      
	 private static final long serialVersionUID = -1660370413961174966L;
	 private Map<String, String> jobDetailsMap; 
	 private ResourceBundle constants = ResourceBundle.getBundle("Paths");
	 private String rootPath = constants.getString("path");
	 private String rhomePath=constants.getString("path2");
	 private String dataFileName; 
	 private String dataFileName1;
	 private String Selection;
	 private String AlgorithmSelected;
	 private String AlgorithmSelected1;
	 int[] dims = {1, 1};
	 MLStructure mlParamStructure = new MLStructure("JobParam", dims);
	 MLStructure mlStateStructure = new MLStructure("JobState", dims);
	 boolean success;
	 
	 private String jobFileName = "";
	 private String jobMsg;
	 private String dataMsg;
	 private SimpleDateFormat sdf = new SimpleDateFormat("ddMMyyyy-hhmmss");
	 	 
	 public GenerateJobServlet()
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
    	 
    	// if (session.getAttribute("Username") != null)
    	 //{
    		// response.setContentType("application/json");
    		 response.setContentType("text/html");
    		 try {
				PreprocessingData(request,response);
			} catch (MatlabConnectionException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (MatlabInvocationException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
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
    	//	 response.getWriter().printf("{ \"jobFileName\": \"Hi\" }");
    		   // 		 response.getWriter().printf("{ \"jobFileName\": \"%s\" }", MatchingScore);
    		    //	 response.getWriter().print(MatchingScore);
    	//	     response.getWriter().flush();
    		 
    		// response.getOutputStream().println(MatchingScore);
    		// response.getOutputStream().flush();
    //	 }
    	 
    	 
    	 // Put image data in place
    	 
    	 // Generate job file
    	 
    	 
    }
    	 
     
     
     
     
     
     
     private void PreprocessingData(HttpServletRequest request, HttpServletResponse response) throws MatlabConnectionException, MatlabInvocationException {
    	 String matching=null;
    	 String IrisCloudCodeRoot="/home/vtalreja/AIP/AIPData";
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
	             
	           //  dataFileName = jobDetailsMap.get("dataFile");
        		// dataFileName1 = jobDetailsMap.get("dataFile1");
        		 Selection = jobDetailsMap.get("SelectionList");
        		 Log.info("Selection: " + Selection);
        		 if (Selection.equals ("Intra-Class"))
        		 {
        			 AlgorithmSelected=jobDetailsMap.get("AlgorithmList");
        			 AlgorithmSelected1="null";
        			 Log.info("AlgorithmSelected: " + AlgorithmSelected);
        			 Log.info("AlgorithmSelected1: " + AlgorithmSelected1);
        		 }
        		 if (Selection.equals ("Inter-Class"))
        		 {
        			 AlgorithmSelected=jobDetailsMap.get("AlgorithmList");
        			 AlgorithmSelected1=jobDetailsMap.get("AlgorithmList1");
        			 Log.info("AlgorithmSelected: " + AlgorithmSelected);
        			 Log.info("AlgorithmSelected1: " + AlgorithmSelected1);
        		 }
        		 
        		 success=generateJobStruct(Selection, AlgorithmSelected, AlgorithmSelected1);
        		if (success)
        		 {
        		// MatlabProxyFactoryOptions options = new MatlabProxyFactoryOptions.Builder().setMatlabLocation("/usr/local/bin/matlab").build();
        			MatlabProxyFactoryOptions options = new MatlabProxyFactoryOptions.Builder().setHidden(true).build();
        		//	MatlabProxyFactoryOptions options = new MatlabProxyFactoryOptions.Builder().setUsePreviouslyControlledSession(true).setHidden(true).build();
        		// MatlabProxyFactoryOptions options = new MatlabProxyFactoryOptions.Builder()
        		  //  .setUsePreviouslyControlledSession(true)
        		//    .setHidden(true)
        		  //  .setMatlabLocation(null).build(); 
        		 // options.setMatlabLocation("/usr/local/MATLAB/R2015a");
        		// MatlabProxyFactoryOptions build=new MatlabProxyFactoryOptions.Builder(options);
        		// build.setMatlabLocation("/usr/local/MATLAB/R2015a");
       // 	 MatlabProxyFactoryOptions options = new MatlabProxyFactoryOptions.Builder();
        //		build.setMatlabLocation("/usr/local/MATLAB/R2015a");
        	//	 MatlabProxyFactoryOptions options = new MatlabProxyFactoryOptions.Builder().setUsePreviouslyControlledSession(true).build();
        		  
        		 MatlabProxyFactory factory1 = new MatlabProxyFactory(options);
        		    MatlabProxy proxy = factory1.getProxy();
        		//    proxy.setVariable("Class", Selection);
        		 //   proxy.setVariable("IrisCloudCodeRoot", IrisCloudCodeRoot);
        		 //   proxy.setVariable("DBOne",AlgorithmSelected);
        		 //   proxy.setVariable("DBTwo", AlgorithmSelected1);
        		    

        		    //Set a variable, add to it, retrieve it, and print the result
        		    proxy.feval("cd", "/home/vtalreja/AIP/osiris/");
        		//    proxy.setVariable("InputParam", mlParamStructure);
        		    proxy.feval("AipOsirisTask","AIP");
        		    Object[] releaseDate = proxy.returningFeval("version", 1, "-date");
        		    System.out.println("MATLAB Release Date: " + releaseDate[0]);
        		  /*  JFrame frame = new JFrame();
        		  //  Icon icon = new ImageIcon("androidBook.jpg");
        		    Icon icon = new ImageIcon("a.png");
        		    JLabel label1 = new JLabel("Full Name :", icon, JLabel.LEFT);
        		    JLabel label = new JLabel("Image with Text", icon, SwingConstants.BOTTOM);
        		    frame.add(label);
        		    frame.setDefaultCloseOperation
        		           (JFrame.EXIT_ON_CLOSE);
        		    frame.pack();
        		    frame.setVisible(true);*/
        		  //  proxy.setVariable("a", 5);
        		   // proxy.eval("a = a + 6");
        		   // double result = ((double[]) proxy.getVariable("a"))[0];
        		   // System.out.println("Result: " + result);

        		    //Disconnect the proxy from MATLAB
        		    proxy.disconnect();
        		}
        		 
        /*		 for (FileItem item : items) 
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
                 }*/
        		 
		/*	}  
	             
			 catch (FileUploadException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}*/
        	 
			
	
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
    	 
    	 
    	 
     private boolean generateJobStruct(String Class, String DBOne,String DBTwo)
     {
    	 System.out.println("In generateJobFile");
    	 boolean fileGenerated = true;
    	 String jobFile="/home/vtalreja/AIP/osiris/AIP.mat";
    	 try 
    	 {
    		 double[] MatchingScore1=new double[] {-9.9900};
    	 
    		 MLChar testDataFileName = new MLChar("DBOneName", DBOne); 
			// MLChar testDataFileName1 = new MLChar("DBTwoName", DBTwo); 
			 MLChar taskClass = new MLChar("Class",Class);
			 MLDouble MatchingScore=new MLDouble("MatchingScore",MatchingScore1,1);
			 if (Class.equals("Inter-Class"))
    		 {
				 MLChar testDataFileName1 = new MLChar("DBTwoName", DBTwo); 
				 mlParamStructure.setField("DBTwoName", testDataFileName1);
    		 }
			 else
			 {
				 MLChar testDataFileName1 = new MLChar("DBTwoName", "Not Required"); 
				 mlParamStructure.setField("DBTwoName", testDataFileName1);
			 }
				 
			 mlParamStructure.setField("DBOneName", testDataFileName);
			// mlParamStructure.setField("DBTwoName", testDataFileName1);
			 mlParamStructure.setField("Class", taskClass);
			 mlStateStructure.setField("MatchingScore",MatchingScore);
			 
			 MatFileWriter fileWriter = new MatFileWriter();
    		 ArrayList<MLArray> list = new ArrayList<MLArray>();
    		 Log.info("Done ArrayList");
    		 list.add(mlParamStructure);
    		 Log.info("Done JobParam");
    		 list.add(mlStateStructure);
    		 Log.info("Done JobState");
 			 System.out.println("Matlab file name: " + jobFile);
 			 Log.info("Matlab file name: " + jobFile);
 			 fileWriter.write(jobFile, list);
 			Log.info("Writing File ");
    	 
    	 }
    	 catch (IOException e) 
    	 {
    		 fileGenerated = false;
    		 Log.info("File Generated :"+fileGenerated);
    		 e.printStackTrace();
    		 Log.info(e.getMessage());
    	 }
    	 return fileGenerated;
    	 
     }
	

     

    

	private Map<String,String> MvFileItems2HashMap(List<FileItem> items ) 
    		 {
    	Map<String,String> jobDetailsMap = new HashMap<String, String>();
    	 
     for (FileItem item : items) 
     {               	           	  
         if (item.isFormField()) 
         {                    	 
        	 System.out.println("Item: " + item.getFieldName() + " Value: " + item.getString());
        	 Log.info("Item: " + item.getFieldName() + " Value: " + item.getString());
        	 jobDetailsMap.put(item.getFieldName(), item.getString());
         } 
     }
     return jobDetailsMap;
    		 }

     
     

          
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
    			 MLChar testSelection = new MLChar("Selection", Selection); 
    		/*	 if (Selection.equals("Manual Selection"))
        		 {
    				 MLChar testAlgorithmSelected = new MLChar("AlgorithmSelected", AlgorithmSelected); 
    				 
        			// AlgorithmSelected=jobDetailsMap.get("AlgorithmList");
        			 //Log.info("AlgorithmSelected: " + AlgorithmSelected);
        		 }*/
    			// MLChar testAlgorithmSelected = new MLChar("AlgorithmSelected", AlgorithmSelected); 
    			 //MLChar key = new MLChar("Key", hashKey);
    			 
    			 mlParamStructure.setField("ImageOnePath", testDataFileName);
    			 mlParamStructure.setField("ImageTwoPath", testDataFileName1);
    			 mlParamStructure.setField("Selection", testSelection);
    			 if (Selection.equals("Manual Selection"))
        		 {
    		     MLChar testAlgorithmSelected = new MLChar("AlgorithmSelected", AlgorithmSelected);
    			 mlParamStructure.setField("AlgorithmSelected", testAlgorithmSelected);
        		 }
    			 
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
    		 Log.info("Done ArrayList");
    		 list.add(mlParamStructure);
    		 Log.info("Done JobParam");
    		 list.add(mlStateStructure);
    		 Log.info("Done JobState");
 			 System.out.println("Matlab file name: " + jobFile.getPath());
 			 Log.info("Matlab file name: " + jobFile.getPath());
 			 fileWriter.write(jobFile.getPath(), list);
 			Log.info("Writing File ");
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
    		 Log.info("File Generated :"+fileGenerated);
    		 e.printStackTrace();
    		 Log.info(e.getMessage());
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
