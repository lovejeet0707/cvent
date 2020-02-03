public class LeadMgmtNEscalationFormChooser_Ctrl 
{
    public string selectedname{get;set;}
    
    public List<SelectOption> getForms()
    {
        List<Selectoption> listOfForms = new List<selectoption>();
        listOfForms.add(new selectOption('', '--None--'));
        listOfForms.add(new selectOption(Label.LeadManagementRequestForm,'Lead Management Request Form'));
        if (Schema.sObjectType.CRM_Escalation__c.isCreateable()) {
            listOfForms.add(new selectOption(Label.Escalation_Form,'Sops Escalation Form'));
        }
        return listOfForms; 
    }
    
    public PageReference redirectDirect()
    {
        PageReference leadMgmtForm = null;
        if (!Schema.sObjectType.CRM_Escalation__c.isCreateable()) 
        {
            leadMgmtForm = new PageReference(Label.LeadManagementRequestForm);
            leadMgmtForm.setRedirect(true);
        }
        return leadMgmtForm;
    }
}