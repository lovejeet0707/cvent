public with sharing class ro_DocumentationController {
	
	public list<Community_Content__c> Videos{get;set;} 
	public wrapper wp{get;set;}
	public list<wrapper> WP_List{get;set;}
	public string str;
	
	public ro_DocumentationController(){
		
		Videos = new list<Community_Content__c>();
		WP_List = new list<wrapper>();
		String sPortalName = ro_ConfigHelper.self.sitePrefix ;
		 
		Videos = [Select Id,Name,Caption__c,Order__c,Tab__c,Type__c,Value__c,Portal_Name__c  from Community_Content__c 
					Where Type__c = 'User Guide' and Portal_Name__c = :sPortalName Order By Order__c];
		if(Videos != Null && Videos.size() > 0){
			for(Community_Content__c video : Videos){
				wp = new wrapper();
				wp.Title = video.Name;
			 	wp.URL = video.Value__c;
			 	wp.PortalName = video.Portal_Name__c;
			 	wp.Name = video.Name;
			 	wp.id = video.Id;
			 	wp.Type = video.Type__c;
			 	wp.sequenceNumber = video.Order__c;
			 	if(video.name.toLowerCase() == 'footer_link'){
			 		wp.isFooter = true;
			 	}
			 	else{
			 	 str = '<iframe frameborder="0" allowfullscreen="" height="315" src=';
			 	 str += '"' + video.Value__c + '"';
			 	 str += ' width="420"></iframe>';
			 	 system.debug('The string is'+str);
		 		 wp.IFrameCode =  str;
			 	}
				WP_List.add(wp);
			}
		}			
	}
	
	public class wrapper{
		public string Title{get;set;}
		public string URL{get;set;}
		public string PortalName{get;set;}
		public string Name{get;set;}
		public string id{get;set;}
		public string Type{get;set;}
		public decimal sequenceNumber{get;set;}
		public string IFrameCode{get;set;}
		public Boolean isFooter {get;set;}
		public wrapper(){
			Title = '';
		 	URL = '';
		 	PortalName = '';
		 	Name = '';
		 	id = '';
		 	Type = '';
		 	IFrameCode = '';
		 	isFooter = false;
		}
	}
}