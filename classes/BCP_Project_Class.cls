public class BCP_Project_Class {
        public Current_Status__c account {get; private set;}
        //public Account account_name {get; private set;}
        String id = ApexPages.currentPage().getParameters().get('id');
        String id2 = ApexPages.currentPage().getParameters().get('PID');
        private String Parent_account_name, Current_account_name, countries, testname;
        //private String[] countries = new String[]{};
        public string selectedLevel1 {get; set;}
        
        
        private String tab_name;
                public BCP_Project_Class() {
                RecordType instRecTypeThir = [SELECT Id FROM RecordType WHERE SobjectType='Current_Status__c' And IsActive = true And DeveloperName = 'Top_Accounts' ];
                 //id2 = '001S000000H7bkN';
                 //id = '001S000000H7bkN';   
                account = [Select c.Parent_Account__c, c.BCP_Status__c, c.Account_Progress__c From Current_Status__c c where Parent_Account__c = :id2 AND RecordTypeId !=:instRecTypeThir.Id];
                Current_account_name  = [select name from account where id = :id limit 1].name;
                Parent_account_name   = [select name from account where id = :id2 limit 1].name;
                 countries = account.Account_Progress__c;
                }
                
         public string getcurrentaccount() {
        return this.Current_account_name ;
        }    
        
         public string getparentaccount() {
        return this.Parent_account_name ;
        }
           
        public PageReference edit() {
                
        String xx;      
        xx = id + '&PID=' + id2;
        String x1 = '/apex/BCP_Project_Edit?id=' + xx;
        //String x1 = 'https://c.cs1.visual.force.com/apex/BCP_Project_Edit?id=' + xx;
        PageReference opptyPage = new PageReference(x1);
        opptyPage.setRedirect(true);
        return opptyPage;
        }
        
        public PageReference cancel() {
                
        String xx;      
        xx = id + '&PID=' + id2;
         countries =account.Account_Progress__c;
        String x1 = '/apex/BCP_Project?id=' + xx;
        //String x1 = 'https://c.cs1.visual.force.com/apex/BCP_Project?id=' + xx;
        PageReference opptyPage = new PageReference(x1);
        opptyPage.setRedirect(true);
        return opptyPage;
        }
        
        public PageReference save() {
                try {
                account.Account_Progress__c = countries;
        update(account);
        String xx;      
        xx = id + '&PID=' + id2;
        String x1 = '/apex/BCP_Project?id=' + xx;
        //String x1 = 'https://c.cs1.visual.force.com/apex/BCP_Project?id=' + xx;
        PageReference opptyPage = new PageReference(x1);
        opptyPage.setRedirect(true);
        return opptyPage;
        } catch(System.DMLException e) {
        ApexPages.addMessages(e);
        return null;
        }
                return null;
        }
         
        public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('No Contact','No Contact'));
        options.add(new SelectOption('Prospecting','Prospecting'));
        options.add(new SelectOption('Working - SMM','Working - SMM'));
        options.add(new SelectOption('Working - Event','Working - Event'));
        options.add(new SelectOption('Working - Sourcing','Working - Sourcing'));
        options.add(new SelectOption('Working - Mobile','Working - Mobile'));
        options.add(new SelectOption('Working - CT','Working - CT'));
        options.add(new SelectOption('Using Competitor/In-house system','Using Competitor/In-house system'));
        options.add(new SelectOption('Keeping in touch - Interested in SMM','Keeping in touch - Interested in SMM'));
        options.add(new SelectOption('Keeping in touch - Interested in Event','Keeping in touch - Interested in Event'));
        options.add(new SelectOption('Keeping in touch - Interested in CSN','Keeping in touch - Interested in CSN'));
        options.add(new SelectOption('Keeping in touch - Interested in Mobile','Keeping in touch - Interested in Mobile'));
        options.add(new SelectOption('Keeping in touch - CT','Keeping in touch - CT'));
        options.add(new SelectOption('Active Review','Active Review'));
        options.add(new SelectOption('Trial','Trial'));
        options.add(new SelectOption('Price Quote/Proposal','Price Quote/Proposal'));
        options.add(new SelectOption('Negotiation','Negotiation'));
        options.add(new SelectOption('Verbal','Verbal'));
        options.add(new SelectOption('Technology Through TMC/MMC','Technology Through TMC/MMC'));
        options.add(new SelectOption('Closed Won','Closed Won'));
        options.add(new SelectOption('Closed Won - Parent','Closed Won - Parent'));
        options.add(new SelectOption('Closed Won - Parent & Subsidiary','Closed Won - Parent & Subsidiary'));
        options.add(new SelectOption('Closed Won - Subsidiary','Closed Won - Subsidiary'));
        options.add(new SelectOption('Closed Won - Sourcing','Closed Won - Sourcing'));
        options.add(new SelectOption('No Opportunity','No Opportunity'));
        
        return options;
        }
        public String getCountries() {
        return countries;
        }
        public void setCountries(String countries) {
        this.countries = countries;
        }
        
        
        }