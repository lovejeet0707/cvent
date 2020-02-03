// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 28/03/2016
// PURPOSE     :   Add Case Team Member for GOMP Cases created by clicking on a Button On Contact level
// TEST CLASS :   AddCaseTeamMemberExtenisonTest
// SPECIAL NOTES:
// ===============================

public Class AddCaseTeamMemberExtenison
{

        Case caseRec ;
        
        public AddCaseTeamMemberExtenison (ApexPages.StandardController cont ){
            
            
            Id caseId = ApexPages.CurrentPage().GetParameters().Get('newid');
            
            if(caseId!=null)
            caseRec =  [ Select Id, CreatedById From Case Where Id =:caseId ];
            
        }
        
        //Method to add creator of case under Case Team Member on Case
        public PageReference AddCaseTeamMember(){
            
            if(caseRec!=null){
                //Getting Case Team Role for User to add under Case Team
                CaseTeamRole [] teamRole = [ SELECT Id, Name FROM CaseTeamRole Where Name = 'Cvent Case Viewer' ];
                
                if(teamRole!=null && teamRole.size()>0 ){
                
                    CaseTeamMember caseMember = new CaseTeamMember();
                    
                    caseMember.MemberId      = caseRec.CreatedById ;
                    caseMember.ParentId      = caseRec.Id ;
                    caseMember.TeamRoleId    = teamRole[0].Id ;
                    
                    //Insert member under Case Team
                    insert  caseMember ;
                
                }  
                    //Redirect to Knowledge Base
                    //return new PageReference ('/_ui/knowledge/ui/KnowledgeHome?isCaseCreation=1&id=' + caseRec.Id);
                    
                    //Redirect to Standard Detail page 
                    return new PageReference ('/' + caseRec.Id);
            }
            return null;
            
        }

}