/* 
@Author :kumud thakur
Desc: To get user language locala key for the footerPage


 */
public class FooterPageController{
    public String hrefVal{get;set;}
    public String getLang(){
        System.debug('Inside Controller');
        String languageVal=[select LanguageLocaleKey from user where id=:UserInfo.getUserId()].LanguageLocaleKey ;
        if(languageVal=='de')
            hrefVal='http://www.cvent.com/de/kontakt/kundenbetreuung.shtml';
        else
            hrefVal='/apex/ContactSupport?lang='+languageVal;
        return languageVal;
    }
}