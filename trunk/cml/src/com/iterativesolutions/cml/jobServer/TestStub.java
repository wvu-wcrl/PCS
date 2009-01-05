package com.iterativesolutions.cml.jobServer;

public class TestStub {

	/**
	 * @param args
	 * @throws InterruptedException 
	 */
	public static void main(String[] args) throws InterruptedException {
		// TODO Auto-generated method stub

		ServerState servState = new ServerState();
		clientIface ServPlug = servState;
		double[] EbNo = new double[15];
		for(int i = 0;i < 15; i++)
			EbNo[i] = i;


		JobData jobDesc = new JobData();
		jobDesc.setUsername("Terry");
		jobDesc.setEbNo(EbNo);
		jobDesc.setMaxTrials(100000000);
		jobDesc.setErrorFloor(0.00001);
		jobDesc.setjobNum(1);


		ServPlug.addJob(jobDesc);

		
		EbNo = new double[13];
		for(int i = 0;i < 13; i++)
			EbNo[i] = i;

		jobDesc = new JobData();
		jobDesc.setUsername("Terry");
		jobDesc.setEbNo(EbNo);
		jobDesc.setMaxTrials(100000000);
		jobDesc.setErrorFloor(0.00001);
		jobDesc.setjobNum(1);


		ServPlug.addJob(jobDesc);

		while(true){
		
			JobData[] a = ServPlug.reportJobs();
			if(a == null){
				System.out.println("No results to report.");
			}else{
				System.out.println();
				System.out.println("Job results received:");
				double bers[];
				double ebnos[];			
				
				for(int k = 0; k<a.length; k++){
					bers = a[k].getBER();
					ebnos = a[k].getEbNo();
					System.out.println("Eb/No values and BERs:");
					for(int j = 0; j < ebnos.length; j++){
					System.out.print(ebnos[j] + " ");
					
					}
					System.out.println();
					for(int j = 0; j < ebnos.length; j++){
					System.out.print(bers[j] + " ");
					}
				}
				System.out.println();
			}
			Thread.sleep(5000);
		}	
		
			//JobData jobDesc = new JobData();
//			jobDesc.setUsername("Terry");
//			jobDesc.setEbNo(EbNo);
//			jobDesc.setMaxTrials(100000000);
//			jobDesc.setErrorFloor(0.0001);
//			jobDesc.setjobNum(1);
//			ServPlug.addJob(jobDesc);
//			ServPlug.addJob(jobDesc);
//			ServPlug.addJob(jobDesc);
//			
//			while(true){
//			Thread.sleep(5000);
//			a = ServPlug.reportJobs();
//			if(a == null){
//				System.out.println("Nothing to report!");
//			}else{
//				double bers[];
//				bers = a[0].getBER();
//				System.out.println(bers[0]);
//			}
//		
//		}
		
		
	}

}
