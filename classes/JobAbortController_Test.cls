/****************************************************
* Author : Sandeep Kumar
* Date : 13 Dec, 2017
* Description : It tests below class
* -> JobAbortController
****************************************************/
@isTest
public class JobAbortController_Test{
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User'];   
    
    static testMethod void testPageButtons(){
        system.runAs(depUser){           
            // Load Account Planning Page.
            JobAbortController controller = new JobAbortController();
            // Negative test case
            controller.scheduledJobId = '08a000000004EEeAA';
            controller.getJobDetail(); 
            List<Apexpages.Message> errormsgs = ApexPages.getMessages();
            boolean getErrorMessage = false;
            for(Apexpages.Message msg : errormsgs){
                system.debug('msg = '+msg);
                if (msg.getDetail().contains('Please enter a valid Job Id.')) getErrorMessage = true;
            }
            system.assert(getErrorMessage);
            
            // Positive test case
            controller.scheduledJobId = '08a000000004EEeAAM';
            controller.getJobDetail(); 
            List<Apexpages.Message> successmsgs = ApexPages.getMessages();
            boolean getSuccessMessage = false;
            for(Apexpages.Message msg : successmsgs){
                system.debug('msg = '+msg);
                if (msg.getDetail().contains('There is no Job exist with entered Job Id, Please try again.')) getSuccessMessage = true;
            }
            //system.assert(getSuccessMessage);
            controller.abortJob(); 
        }
    }
}