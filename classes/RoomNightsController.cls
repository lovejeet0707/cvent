public class RoomNightsController {    
	/*
	Supplier Network - Enterprise Bundle
	Supplier Network - Elite Bundle
	Supplier Network - Starter Bundle
	Supplier Network - Enterprise Bundle ENT
	Supplier Network - Elite Bundle ENT
	Supplier Network - Starter Bundle ENT
	Supplier Network - A la carte Bundle
	*/
	
    public Id objId {get; set;}
    
    public DisplayWrapper getRoomNights() {
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT SBQQ__ProductName__c, Room_Nights_or_RFPs__c, Room_Nights__c
                FROM SBQQ__QuoteLine__c 
                WHERE SBQQ__ProductName__c LIKE 'Supplier Network - %' AND SBQQ__Quote__c = :objId];
        
        for(SBQQ__QuoteLine__c quoteLine: quoteLines) {
            
            DisplayWrapper dWrapper = new DisplayWrapper();
            dWrapper.name = quoteLine.Room_Nights_or_RFPs__c;
            dWrapper.value = quoteLine.Room_Nights__c;
			return dWrapper;
        }
		
		return null;
    }
    
    public class DisplayWrapper {
		public String name {get; set;}
        public Decimal value {get; set;}        
    }
}