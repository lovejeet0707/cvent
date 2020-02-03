public class coachingSessionQuestionClass{
    public List<String> categoryList{get;set;}
    private final Coaching_Session__c coachingSession;
    private final Id coachingSessionId;
    public String redirectUrl {public get; private set;}
    public Boolean shouldRedirect {public get; private set;}
    public List<Coaching_Session_Question__c> coachingSessionQuestionList{get;set;}
    List<Coaching_Session_Question__c> coachingSessionQuestion;
    public Map<String,List<Coaching_Session_Question__c>> coachingSessionQuestionMap{get;set;}
    public ApexPages.StandardController controller;
    public Boolean isEdit{get;set;}
    
    public coachingSessionQuestionClass(ApexPages.StandardController controller) {
        categoryList = new List<String> {'Noncritical','Business Critical','Compliance Critical','End User Critical'};
        isEdit = False;
        this.controller = controller;
        shouldRedirect = false;
        coachingSessionQuestionList = new List<Coaching_Session_Question__c>();
        coachingSessionQuestionMap = new Map<String,List<Coaching_Session_Question__c>>();
        //Fetching Coaching Form Parent Record.........
        coachingSession = (Coaching_Session__c )controller.getRecord();
        //Fetching Coaching Form Parent Id.........
        coachingSessionId = coachingSession.Id;
        
        For(Coaching_Session_Question__c csqRec : [SELECT Id,Coaching_Question__c,Coaching_Session__c,Question_Number__c,Response__c,Response_Scale__c,Response_Set_Code__c,Coaching_Question_Category__c,
                                                       Comment__c,Max_Score__c,Score__c FROM Coaching_Session_Question__c
                                                           WHERE Coaching_Session__c =:coachingSessionId AND Coaching_Question_Category__c!=NULL ORDER BY Coaching_Question_Category__c DESC]){
                                                       if(!coachingSessionQuestionMap.containsKey(csqRec.Coaching_Question_Category__c))
                                                       {
                                                           coachingSessionQuestion = new List<Coaching_Session_Question__c>();
                                                           coachingSessionQuestion.add(csqRec);
                                                           coachingSessionQuestionMap.put(csqRec.Coaching_Question_Category__c,coachingSessionQuestion);
                                                       }
                                                       else{
                                                           coachingSessionQuestionMap.get(csqRec.Coaching_Question_Category__c).add(csqRec);
                                                       }
                                                   }
        System.debug('coachingSessionQuestionMap********'+coachingSessionQuestionMap);
        System.debug('coachingSessionQuestionMapValues********'+coachingSessionQuestionMap.values());
        System.debug('coachingSessionQuestionMapSize********'+coachingSessionQuestionMap.values().size());
    }
    public void editcoachingSessionQuestion(){
        isEdit = TRUE;
    }
    public void savecoachingSessionQuestion(){
        try{
            System.debug('Inside Try');
            List<Coaching_Session_Question__c> ss = new List<Coaching_Session_Question__c>();
            For(List<Coaching_Session_Question__c> aa : coachingSessionQuestionMap.values())
            {
                For(Coaching_Session_Question__c sss : aa){
                    ss.add(sss);}
            }
            update ss;
            shouldRedirect = true;
            redirectUrl = controller.view().getUrl();
        }
        catch(exception ex){
            system.debug('ex***********8'+ex);
            ApexPages.addMessages(ex);
        }
        isEdit = FALSE;
    }
}