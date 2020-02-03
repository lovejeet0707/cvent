// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE : 16/03/2016
// PURPOSE     :  Account Team Member more than One Product/Role
// TEST CLASS :   AccountTeamMemberExtensionTest
// SPECIAL NOTES:
// ===============================

public Class AccountTeamMemberExtension
{
    //List of TeamMembers Information
    public List<AccountTeamWrapper> accMembersWrapperList{get;set;}
    public String teamMemberIds ='';
    Id accId;
    
    
    public AccountTeamMemberExtension (ApexPages.StandardController stdCtr){
        
        accId = stdCtr.getId();
        
        
        //MemberId with TeamMembers
        Map<Id, AccountTeamMember> teamMemberMap = new Map<Id, AccountTeamMember>();
        
        //MemberId with List of Products by adding seperator ';' in string
        Map<Id, String> productMap = new Map<Id, String>();
        
        accMembersWrapperList = new List<AccountTeamWrapper>();
        
        
        //Account Team Members
        for( AccountTeamMember accMember : [ Select Id, AccountId, TeamMemberRole , User.Name, UserId  From  AccountTeamMember Where AccountId =:accId] ){
                teamMemberMap.Put(accMember.UserId , accMember);
                teamMemberIds+= ',' +accMember.UserId;
                
        }
        
        //Opened Opportunities owned by Account Team Members
        for( Opportunity opp: [ Select OwnerId, Owner.Name , Product__c From Opportunity Where AccountId =:accId and OwnerId IN: teamMemberMap.KeySet() and IsClosed= false]){
            
            //Populating Products per Member and putting into productMap 
            if(opp.Product__c !=null ){
                
                if(productMap.ContainsKey(opp.OwnerId)){

                    productMap.Put(opp.OwnerId, productMap.Get(opp.OwnerId) + ' ; ' + opp.Product__c);
                }
                else{
                    productMap.Put(opp.OwnerId, opp.Product__c);
                }
            }
        }
        
        for( Id memberId : teamMemberMap.KeySet()){
            
            AccountTeamMember accMember =  teamMemberMap.get(memberId) ;

            //Prodcuts will be shown only If TeamMember Role is 'Multi-Product' 
            String Products = accMember.TeamMemberRole != 'Multi-Product' ? '' : productMap.get(memberId); 
            
            accMembersWrapperList.add( new AccountTeamWrapper( accMember.Id , accMember.User.Name , Products , accMember.TeamMemberRole) );
        }
        
    }
    
    public void AddTeam(){
        
        
        System.debug('*****accMembersWrapperList*******' + teamMemberIds);
        
        if(AMAlertsSetting__c.getValues(accId+UserInfo.getUserId())!=null){
            delete AMAlertsSetting__c.getValues(accId+UserInfo.getUserId());
        }
        
        
        AMAlertsSetting__c alertSetting = new AMAlertsSetting__c();
        alertSetting.Name = accId+UserInfo.getUserId();
        alertSetting.TeamMemberIds__c =  teamMemberIds;
        insert alertSetting;
        
    }
    
    
    public pageReference SendAMAlert(){
        
        Id accountId = ApexPages.currentPage().getParameters().get('newid');
        
        
        List<ID> oldMemberIds = new List<ID>();           
        
        if(AMAlertsSetting__c.getValues(accountId+UserInfo.getUserId())!=null){
          if(AMAlertsSetting__c.getValues(accountId+UserInfo.getUserId()).TeamMemberIds__c !=null){
            oldMemberIds = AMAlertsSetting__c.getValues(accountId+UserInfo.getUserId()).TeamMemberIds__c.Split(',');
          }
            delete AMAlertsSetting__c.getValues(accountId+UserInfo.getUserId());
        }
        
  
        
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        
        for( AccountTeamMember accMember : [ Select Account.Name,UserId,User.Email From  AccountTeamMember Where AccountId =:accountId and UserId NOT IN : oldMemberIds]){
            
            
             Messaging.SingleEmailMessage message =  new Messaging.SingleEmailMessage();
             message.setToAddresses(new String[] {accMember.User.Email});
             message.setSubject('AM Alert Notification');
             message.setPlainTextBody('Hello , You are added under Account ' + accMember.Account.Name);
             messages.add(message);
             
            
        }
        
        if(messages.size()>0){
            Messaging.sendEmail(messages);
        }
        
        return new PageReference ('/'+ accountId);
    }
    
    
    /*
    //Method is populating AM-(Product) fields on Account 
    public void UpdateAMFieldsonAccount(){
        
        Account accRecord = new Account(Id = accId);
        
        //Updating AM's based on their Products
        for( AccountTeamWrapper accWrapper : accMembersWrapperList ){
            
            //Update AM's for Mult-Product Role
            if( accWrapper.Products != null && accWrapper.Role == 'Multi-Product' ){
                
                
                
                System.Debug('************* accWrapper.Products **' + accWrapper.Products);
                
                for( String product : accWrapper.Products.Split(';') ){
                    
                     System.Debug('************* accRecord AFTER **' + product);
                     AccountTeamMultiProductSetting__c productSetting = AccountTeamMultiProductSetting__c.getValues(product.trim());
                     
                     System.Debug('************* productSetting **' + productSetting);
                     
                     if( productSetting!= null ) 
                     accRecord.put(productSetting.API_Name_AM__c , accWrapper.MemberName); 
                }   
            }
        }
        
        System.Debug('************* accRecord AFTER **' + accRecord);
        
        if(accRecord!=null)
        update accRecord;
        
        
    
    }
    */
    
    //Wrapper Class 
    public class AccountTeamWrapper{
        
        public string MemberName {get;set;}
        public string Role {get;set;}
        public string Products   {get;set;}
        public string memberId {get;set;}
        
        public AccountTeamWrapper ( string memberId0 , string MemberName0 , string Products0 , string Role0){
            memberId   = memberId0;
            MemberName = MemberName0;
            Products = Products0;
            Role = Role0;
        }
    }




}