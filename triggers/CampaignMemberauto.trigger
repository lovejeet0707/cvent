trigger CampaignMemberauto on Campaign (after insert) {
    
    List<Campaign> newCamps = [select Id, RecordType.Name from Campaign where Id IN :trigger.new ];
    List<CampaignMemberStatus> cms = new List<CampaignMemberStatus>();
    Set<Id> camps = new Set<Id>();
    List<CampaignMemberStatus> cms2Insert = new List<CampaignMemberStatus>();
    
    for(Campaign camp : newCamps){
       
            camps.add(camp.Id);
    }   
    
    for(CampaignMemberStatus cm : [select Id, Label, CampaignId from CampaignMemberStatus where CampaignId IN :camps]) {
        
            CampaignMemberStatus cms1 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'No/No', SortOrder = 3, isDefault = true);
             cms2Insert.add(cms1);          
            
             CampaignMemberStatus cms2 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'No/Yes', SortOrder = 4);
             cms2Insert.add(cms2);
             
             CampaignMemberStatus cms3 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Email Response', SortOrder = 5);
             cms2Insert.add(cms3); 
             
             CampaignMemberStatus cms4 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Cancelled', SortOrder = 6);
             cms2Insert.add(cms4);             
             
             CampaignMemberStatus cms5 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Attended', SortOrder = 7);
             cms2Insert.add(cms5);
             
             CampaignMemberStatus cms6 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'No Show', SortOrder = 8);
             cms2Insert.add(cms6);
             
             CampaignMemberStatus cms7 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Abandoned', SortOrder = 9);
             cms2Insert.add(cms7);
             
             CampaignMemberStatus cms8 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Visited', SortOrder = 10);
             cms2Insert.add(cms8);
             
             CampaignMemberStatus cms9 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Others', SortOrder = 11);
             cms2Insert.add(cms9);
             
             CampaignMemberStatus cms10 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Invite Pending', SortOrder = 12);
             cms2Insert.add(cms10);
             
             CampaignMemberStatus cms11 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Excluded', SortOrder = 13);
             cms2Insert.add(cms11);
             
             CampaignMemberStatus cms12 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Meeting & Dinner/Reception', SortOrder = 14);
             cms2Insert.add(cms12);
             
             CampaignMemberStatus cms13 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Meeting Only', SortOrder = 15);
             cms2Insert.add(cms13);
             
             CampaignMemberStatus cms14 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Dinner/Reception Only', SortOrder = 16);
             cms2Insert.add(cms14);
             
             CampaignMemberStatus cms15 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Booth Attended', sortOrder = 17);
             cms2Insert.add(cms15);
             
             CampaignMemberStatus cms16 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Reception Attended', SortOrder = 18);
             cms2Insert.add(cms16);
                         
             CampaignMemberStatus cms17 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Invite Sent', SortOrder = 19);
             cms2Insert.add(cms17);
             
             CampaignMemberStatus cms18 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Cold Call', SortOrder = 20);
             cms2Insert.add(cms18);
             
             CampaignMemberStatus cms19 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Form Submission', SortOrder = 21);
             cms2Insert.add(cms19);
             
             CampaignMemberStatus cms20 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Registered', SortOrder = 22);
             cms2Insert.add(cms20);
             
             CampaignMemberStatus cms21 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Click Through', SortOrder = 23);
             cms2Insert.add(cms21);
             
             CampaignMemberStatus cms22 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Decline', SortOrder = 24);
             cms2Insert.add(cms22);

             CampaignMemberStatus cms23 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Referral', SortOrder = 25);
             cms2Insert.add(cms23);
             
             CampaignMemberStatus cms24 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
             Label = 'Booth Attended-Walk-in', SortOrder = 24);
             cms2Insert.add(cms24);
             
             
    }
    //system.debug('*******'+cms2Insert);
    Database.insert(cms2Insert,false);

    //insert cms2Insert;
    
    

   }