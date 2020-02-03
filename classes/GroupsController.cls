// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE   : 01/06/2016
// PURPOSE     :  Show /Create/Delete Chatter Groups on Community Dynamically
// TEST CLASS :   GroupControllerTest
// SPECIAL NOTES:
// ===============================
public class GroupsController{
    
    public boolean showForm {get;set;}
    public string groupName {get;set;}
    public string groupDescrition {get;set;}
    public string groupCategory {get;set;}
    public string groupType {get;set;}
    
    public string groupId {get;set;}
    public string message {get;set;}
    public Id tempId{get;set;}
    //Constructor loading... 
    public GroupsController() {
        tempId = UserInfo.getUserId();
        message='';
        Success_Group_Admins__c[] sAdmins = [Select Id From Success_Group_Admins__c Where User_ID_15_Digit__c=:UserInfo.getUserId().Substring(0,15)];
        if(sAdmins!=null && sAdmins.size()>0)
            showForm=true;
        else
            showForm=false;
        
        GetRecords();
    }   
    
     List<CollaborationGroup> cGroupsListAll;
    //Get Started Groups
    public List<GroupWrapper> getgetStartedGroupList(){
        
        List<GroupWrapper> getStartedList = new List<GroupWrapper>();
        
        for(CollaborationGroup cRegional: cGroupsListAll){
            if( cRegional.InformationBody=='Getting Started'){ 
                List<String> groupName = Split_String_MultiLine(cRegional.Name,Integer.ValueOf(Label.GroupNameSize));
                getStartedList.add(new GroupWrapper(cRegional, groupName));
            }
        }
        
        return getStartedList;
    }
    //Tip & Trends Success Groups
    public List<GroupWrapper> gettipTrendGroupList(){
        
        List<GroupWrapper> tipTrendList = new List<GroupWrapper>();
        
        for(CollaborationGroup cRegional: cGroupsListAll){
            if( cRegional.InformationBody=='Tips &amp; Trends'){ 
                List<String> groupName = Split_String_MultiLine(cRegional.Name,Integer.ValueOf(Label.GroupNameSize));
                tipTrendList.add(new GroupWrapper(cRegional, groupName));
            }
        }
        
        return tipTrendList;
    }
    
    
    //Regional Groups
    public List<GroupWrapper> getRegionalGroupList(){
        
        List<GroupWrapper> regionalList = new List<GroupWrapper>();
        
        for(CollaborationGroup cRegional: cGroupsListAll){
            if( cRegional.InformationBody=='In Your Area'){ 
                List<String> groupName = Split_String_MultiLine(cRegional.Name,Integer.ValueOf(Label.GroupNameSize));
                regionalList.add(new GroupWrapper(cRegional, groupName));
            }
        }
        
        return regionalList;
    }
    
    
    //Vertical Groups
    public List<GroupWrapper> getVerticalGroupList(){
        
        List<GroupWrapper> verticalList = new List<GroupWrapper>();
        
        for(CollaborationGroup cVertical: cGroupsListAll){
            if( cVertical.InformationBody=='Vertical'){
                List<String> groupName = Split_String_MultiLine(cVertical.Name,Integer.ValueOf(Label.GroupNameSize));
                verticalList.add(new GroupWrapper(cVertical,groupName));
            }
        }
        
        return verticalList;
        
    }
    
    //Get Group Records
    public List<CollaborationGroup> GetRecords(){
        cGroupsListAll = [ Select Id, Name, NetworkId ,FullPhotoUrl,InformationBody From CollaborationGroup 
          where NetworkId = :Network.getNetworkId() ORDER BY Name asc];
        
        return cGroupsListAll;
    }
    
    //Create a New Chatter Group
    public PageReference CreateGroup(){
                
        CollaborationGroup cbGroup = new CollaborationGroup ();
        cbGroup.Name = groupName ;
        cbGroup.NetworkId = Network.getNetworkId() ;
        cbGroup.CollaborationType = groupType;
        cbGroup.Description = groupDescrition;
        cbGroup.InformationBody =  groupCategory;
       
        //Validations For Blank Fields 
        if(groupCategory=='--None--'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Select Category'));
            return null;
        }
        if(groupType=='--None--'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Select Visibilty'));
            return null;
        }
        
        insert cbGroup;
        return new PageReference  ('/_ui/core/chatter/groups/GroupProfilePage?g='+ cbGroup.Id );
    }
    
    //Delete Existing Chatter Group
    public void DeleteGroup(){
        System.debug('___ ID ' +groupId );
        Delete [Select Id From CollaborationGroup Where Id=:groupId];
        GetRecords();
        //return null;
    }
    
    
    
    //Method is used to split a string into multiple lines by defining the size of charaters for each line.
    public static List<String> Split_String_MultiLine(String line, Integer charSize){
        
        string [] stringArray = new List<String>();
    
        string[] gArray = line.Split(' '); 
        String name = '';
    
    
        //Iterate Each Word from string        
        for(string s : gArray){
            
            name = name!=''? name + ' ' + s : s ;
            
            //Check If Line Exceeds More than Defined charSize per line
            //Append to next element
            if(name.length() > charSize ){
                
                //Remove Last Added Word
                name = name.remove(s);
                stringArray.add(name);    
                
                
                //Set the last word for next iteration merge 
                name = s;
    
             }
             
            //Check if current element is the last in the list
            if(gArray.get(gArray.size()-1)==s)
            stringArray.add(name);   
        }
        
        return stringArray;
        
    }
    
    
    
    
    //wrapper class
    public class GroupWrapper{
    
        public CollaborationGroup groupObj  {get;set;}
        public List<String> groupNameArray {get;set;} 
        
        public GroupWrapper(CollaborationGroup groupObj, List<String> groupNameArray){
                this.groupObj = groupObj ;
                this.groupNameArray = groupNameArray;                
        }
    }
      
}