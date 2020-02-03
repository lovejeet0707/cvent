public with sharing class Quota_DirectSales_Team_LookupController{

// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 11/02/2016
// PURPOSE     :  Lookup Direct Sales Team Members for Quota Managment 
// SPECIAL NOTES:
// TEST CLASS: QuotaAllocation_Creation_Bulk_Ext_Test
// ===============================
// Change History:
//
//==================================
 
    /*
    *   item in context from the page
    */
    Map<Id,User> mapOfUsers;
    public String contextItem{get;set;}
    public List<WrapperRowItem> selectedItems;
    Public String selectedUsers{get;set;}
    Public string searchText{get;set;}
    Private Id currentProfileId = UserInfo.getProfileId();
    /*
    *   set controller
    */
    private ApexPages.StandardSetController setCon;
 
    /*
    *   the user ids selected by the user
    */
    private Set<Id> selectedUserIds;
 
    /*
    *   constructor
    */
    public Quota_DirectSales_Team_LookupController()
    {
        //init variable
        searchText = '';
        this.selectedUserIds= new Set<Id>();
        mapOfUsers = new Map<Id,User>([SELECT Id, Name,FirstName, LastName, Title, Phone, UserRole.Name, Profile.Name, Email FROM User Where isActive=true and (UserRole.Name like '%Direct Sales%' OR UserRole.Name like 'AM%')]);
                                       //where isActive=true and ProfileId =:UserInfo.getProfileId()]);
        //gather data set
        this.setCon= new ApexPages.StandardSetController(mapOfUsers.values());
        this.setCon.setpageNumber(1);
        this.setCon.setPageSize(10);
        selectedItems = new List<WrapperRowItem>();
        selectedUsers = '';
 
    }
    
    public PageReference search() {
         String qry = '';
         
         users.clear();
         users= new List<WrapperRowItem>(); 
       
        

        // dynamic soql for fun
        If(searchText !=null && searchText !='')
        qry = 'SELECT Id, Name,FirstName, LastName, Title, Phone, UserRole.Name, Profile.Name, Email From User Where Name LIKE \'%' + searchText +  '%\'' + ' And isActive=true And (UserRole.Name like \'%Direct Sales%\' OR UserRole.Name like \'AM%\')' + ' Order By Name';  
            //'%\''+ 'And ProfileId =\'' + currentProfileId + '\' Order By Name';
        else 
        qry = 'SELECT Id, Name,FirstName, LastName, Title, Phone, UserRole.Name, Profile.Name, Email From User Where isActive=true and (UserRole.Name like \'%Direct Sales%\' OR UserRole.Name like \'AM%\')';
            //Where ProfileId =\'' + currentProfileId + '\' Order By Name';
        System.debug('*****  qry ====> ' + qry );
        System.debug('*****  DATA====> ' + Database.query(qry));
        // may need to modify for governor limits??
        for(User u : Database.query(qry)) {
            // create a new wrapper by passing it the category in the constructor
            WrapperRowItem rItem = new WrapperRowItem(u,false);
            // add the wrapper to the results
            users.add(rItem);
        }
        System.debug('*****  Users====> ' + users);
        return null;
    }
    
    public void go(){
     
     List<String> sUsers = new List<String>();
     
     System.debug('**********' + [Select Name,LastName From User Where ID IN: selectedUserIds]);
     For( Id uid : selectedUserIds){
     sUsers.add(mapOfUsers.get(uid).Name); 
     //selectedUsers += u.Name + ' ,'; 
     }
     System.debug('selectedUsers======> '+selectedUsers);
     selectedUsers = String.Join(sUsers,' , ');
     
    }
 
    /*
    *   handle item selected
    */
    public void doSelectItem(){
 
        this.selectedUserIds.add(this.contextItem);
 
    }
 
    /*
    *   handle item deselected
    */
    public void doDeselectItem(){
 
        this.selectedUserIds.remove(this.contextItem);
 
    }
 
    /*
    *   return count of selected items
    */
    public Integer getSelectedCount(){
 
        return this.selectedUserIds.size();
 
    }
 
    /*
    *   advance to next page
    */
    public void doNext(){
   
        if(this.setCon.getHasNext())
            this.setCon.next();
 
    }
 
    /*
    *   advance to previous page
    */
    public void doPrevious(){
 
        if(this.setCon.getHasPrevious())
            this.setCon.previous();
 
    }
 
    /*
    *   return current page of groups
    */
    public List<WrapperRowItem> Users{
    get{
        
        If(Users ==null){
        Users = new List<WrapperRowItem>();
        }
        
        If( searchText=='' )
        {
        Users.clear();
        for(sObject r : this.setCon.getRecords()){
            User c = (User)r;
 
            WrapperRowItem row = new WrapperRowItem(c,false);
            if(this.selectedUserIds.contains(c.Id)){
                //selectedItems.add(row);
                row.IsSelected=true;
            }
            else{
                //selectedItems.remove(row);
                row.IsSelected=false;
            }
            Users.add(row);
        }  
       }           
      
      return Users;
     }
        set;
 
    }
 
    /*
    *   return whether previous page exists
    */
    public Boolean getHasPrevious(){
 
        return this.setCon.getHasPrevious();
 
    }
 
    /*
    *   return whether next page exists
    */
    public Boolean getHasNext(){
 
        return this.setCon.getHasNext();
 
    }
 
    /*
    *   return page number
    */
    public Integer getPageNumber(){
 
        return this.setCon.getPageNumber();
 
    }
 
    /*
    *    return total pages
    */
    Public Integer getTotalPages(){
 
        Decimal totalSize = this.setCon.getResultSize();
        Decimal pageSize = this.setCon.getPageSize();
 
        Decimal pages = totalSize/pageSize;
 
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
 
    /*
    *   helper class that represents a row
    */
    public with sharing class WrapperRowItem{
 
        public User tUser{get;set;}
        public Boolean IsSelected{get;set;}
 
        public WrapperRowItem(User c, Boolean s){
            this.tUser=c;
            this.IsSelected=s;
        }
 
    }
}