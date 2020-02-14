////////////////////////////////////////////////////////////////////////////////
// 20 Feb 2015, Friday
// Author: Vaibhav Jain
// 
// This trigger is created for GOMP or Escalation Process under which the Sales Team will create the case for Client Services Team
// This trigger ensures that the case is assigned to the correct team on basis of product type selected.
// version 2.0 
// description - added the onarrival product type too
////////////////////////////////////////////////////////////////////////////////

trigger salesSupportCases on Case (before insert,before update) {
    
    for(Case c : Trigger.new){
        if(c.RecordTypeId=='012o0000000oWbY'){                             //Check if the case is of Support Sales Cases record type
            if(Trigger.isInsert){

                if(c.Product_Type__c=='SMM MRF/Workflow/HCP' && c.Request_Type__c=='Customer Care')
                    c.Product_Type__c = 'Event Blue';
                
                if(c.Product_Type__c=='CSN - Planner' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G00000006w2R0';                                 // assign the case to Client Services Case Queue - CSN Planner
                    //c.RecordTypeId = '0120000000099RR';
                }
            
                else if(c.Product_Type__c=='Genie Connect' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G1N000002aXXZ';                                 // assign the case to Case Queue - Genie Connect
                    //c.RecordTypeId = '0120000000099RR';   
                }

                else if(c.Product_Type__c=='RegOnline' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G1N000002aXXc';                                 // assign the case to Client Services Case Queue - RegOnline
                    //c.RecordTypeId = '0120000000099RR';   
                }

                else if((c.Product_Type__c=='Meetings'||c.Product_Type__c=='Group') && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G1N000002ziFd';                                    // Updated as per Case# 10389856
                    //c.ownerid = '00G1N000002ziFY';                                 // assign the case to Client Services Case Queue - Meeting
                    //c.RecordTypeId = '0120000000099RR';   
                }

                else if(c.Product_Type__c=='Business Transient' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G1N000002ziG2';                                 // assign the case to Client Services Case Queue - Travel
                    //c.RecordTypeId = '0120000000099RR';   
                }
                
                else if(c.Product_Type__c=='Passkey' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G1N000002aXXb';                                 // assign the case to Client Services Case Queue - Travel
                    //c.RecordTypeId = '0120000000099RR';   
                }

                else if(c.Product_Type__c=='Travel' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G1N000002ziG2';                                 // assign the case to Client Services Case Queue - Travel
                    //c.RecordTypeId = '0120000000099RR';   
                }
                
                else if(c.Product_Type__c=='Social Tables' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G2G000004YKS9';// assign the case to CS Case Queue CC - Social Tables    
					c.RecordTypeId = '0122G000001YZVTQA4';
                }    
                
                else if(c.Product_Type__c=='CSN - Supplier' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G00000006w2Qz';                                // assign the case to Client Services Case Queue - CSNSupplier
                    //c.RecordTypeId = '0120000000099RS';
                }    
                else if(c.Product_Type__c=='eMarketing' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G00000006w2R4';                                // assign the case to Client Services Case Queue - eMarketing
                    //c.RecordTypeId = '0120000000099RX';
                }
                else if(c.Product_Type__c=='QuickMobile' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G1N000002e8Cj';                                // assign the case to Client Services Customer Care Queue QM
                    c.RecordTypeId = '0121N000001hVVG';
                }
                
                // onarrival product type too
                
                //else if(c.Product_Type__c=='Event Blue' && c.Request_Type__c=='Customer Care'){
                else if((c.Product_Type__c=='Event Blue' || c.Product_Type__c=='OnArrival' || c.Product_Type__c=='Abstract Management' || c.Product_Type__c=='Appointments'
                || c.Product_Type__c=='Data Services' || c.Product_Type__c=='Integration' || c.Product_Type__c=='LeadCapture' || c.Product_Type__c=='SMM' || c.Product_Type__c=='SocialWall' ) && c.Request_Type__c=='Customer Care'){
                    // onarrival product type too
                    c.ownerid = '00G00000006w2R1';                                // assign the case to Client Services Case Queue - Event
                    //c.RecordTypeId = '0120000000099RV';
                }
                else if(c.Product_Type__c=='Lead Scoring' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00Go0000001rDYm';                                  // assign the case to Client Services Case Queue- Lead Scoring
                }
                else if(c.Product_Type__c=='Surveys' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G00000006w2R3';                                // assign the case to Client Services Case Queue - Surveys         
                    //c.RecordTypeId = '0120000000099RW';
                }
                else if(c.Product_Type__c=='CrowdCompass' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G00000006vs24';                                // assign the case to Crowd Compass Support
                    //c.RecordTypeId = '0120000000099RV';
                }
                else if(c.Product_Type__c=='CrowdTorch Ticketing' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G00000006wAMC';                                // assign the case to TicketMob Client Support
                    //c.RecordTypeId = '0120000000099RV';
                }
                else if((c.Product_Type__c=='EMI' || c.Product_Type__c=='SpeedRFP') && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00Go0000001bjlx';                                // assign the case to SpeedRFP/EMI queue
                    //c.RecordTypeId = '0120000000099RV';
                } 
                if(c.Request_Type__c=='Strategic Support'){
                    c.ownerid = '00Go0000001cE20';
                    System.debug('In Client success');
                    c.Client_Services_Category__c = 'Consultations/Best Practices';
                    c.RecordTypeId = '012000000009AAr';
                    //c.External_Escalation__c = true;
                }
                if(c.Request_Type__c=='Onsite Training'){
                    system.debug('In Onsite Training');
                    c.ownerid = '00G2G000004YMOF'; //Onsite Training request
                    c.RecordTypeId = '012000000009AAr';
                    //c.External_Escalation__c = true;
                }    
            }
                
                
            if(Trigger.isUpdate){

                if(System.Trigger.oldMap.get(c.id).ownerId == c.ownerId){
                    
                    if(c.Product_Type__c=='SMM MRF/Workflow/HCP' && c.Request_Type__c=='Customer Care')
                        c.Product_Type__c = 'Event Blue';
                
                    if(c.Product_Type__c=='CSN - Planner' && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00G00000006w2R0';                                 // assign the case to Client Services Case Queue - CSN Planner
                        //c.RecordTypeId = '0120000000099RR';
                    }    
                    else if(c.Product_Type__c=='CSN - Supplier' && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00G00000006w2Qz';                                // assign the case to Client Services Case Queue - CSNSupplier
                        //c.RecordTypeId = '0120000000099RS';
                    }    
                    else if(c.Product_Type__c=='eMarketing' && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00G00000006w2R4';                                // assign the case to Client Services Case Queue - eMarketing
                        //c.RecordTypeId = '0120000000099RX';
                    }
                    
                    // onarrival product type too
                    
                    //else if(c.Product_Type__c=='Event Blue' && c.Request_Type__c=='Customer Care'){
                    else if((c.Product_Type__c=='Event Blue' || c.Product_Type__c=='OnArrival' || c.Product_Type__c=='Abstract Management' || c.Product_Type__c=='Appointments'
                    || c.Product_Type__c=='Data Services' || c.Product_Type__c=='Integration' || c.Product_Type__c=='LeadCapture' || c.Product_Type__c=='SMM' || c.Product_Type__c=='SocialWall' ) && c.Request_Type__c=='Customer Care'){
                    
                        // onarrival product type too
                        c.ownerid = '00G00000006w2R1';                                // assign the case to Client Services Case Queue - Event
                        //c.RecordTypeId = '0120000000099RV';
                    }
                    else if(c.Product_Type__c=='Lead Scoring' && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00Go0000001rDYm';                                  // assign the case to Client Services Case Queue- Lead Scoring
                    }
                    else if(c.Product_Type__c=='Surveys' && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00G00000006w2R3';                                // assign the case to Client Services Case Queue - Surveys         
                        //c.RecordTypeId = '0120000000099RW';
                    }
                    else if(c.Product_Type__c=='CrowdCompass' && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00G00000006vs24';                                // assign the case to Crowd Compass Support
                        //c.RecordTypeId = '0120000000099RV';
                    }
                    else if(c.Product_Type__c=='CrowdTorch Ticketing' && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00G00000006wAMC';                                // assign the case to TicketMob Client Support
                        //c.RecordTypeId = '0120000000099RV';
                    }
                    else if((c.Product_Type__c=='EMI' || c.Product_Type__c=='SpeedRFP') && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00Go0000001bjlx';                                // assign the case to SpeedRFP/EMI queue
                        //c.RecordTypeId = '0120000000099RV';
                    } 
                    else if(c.Product_Type__c=='Social Tables' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G2G000004YKS9';// assign the case to CS Case Queue CC - Social Tables    

                }    
                    else if(c.Product_Type__c=='Genie Connect' && c.Request_Type__c=='Customer Care'){
                    c.ownerid = '00G1N000002aXXZ';                                 // assign the case to Client Services Case Queue - Genie Connect
                    //c.RecordTypeId = '0120000000099RR';   
                    }

                    else if(c.Product_Type__c=='RegOnline' && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00G1N000002aXXc';                                 // assign the case to Client Services Case Queue - RegOnline
                        //c.RecordTypeId = '0120000000099RR';   
                    }

                    else if((c.Product_Type__c=='Meetings'||c.Product_Type__c=='Group') && c.Request_Type__c=='Customer Care'){
                       c.ownerid = '00G1N000002ziFd';
                        //c.ownerid = '00G1N000002ziFY';                                 // assign the case to Client Services Case Queue - Meeting
                        //c.RecordTypeId = '0120000000099RR';   
                    }

                    else if(c.Product_Type__c=='Business Transient' && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00G1N000002ziG2';                                 // assign the case to Client Services Case Queue - Travel
                        //c.RecordTypeId = '0120000000099RR';   
                    }
                    
                    else if(c.Product_Type__c=='Passkey' && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00G1N000002aXXb';                                 // assign the case to Client Services Case Queue - Travel
                        //c.RecordTypeId = '0120000000099RR';   
                    }

                    else if(c.Product_Type__c=='Travel' && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00G1N000002ziG2';                                 // assign the case to Client Services Case Queue - Travel
                        //c.RecordTypeId = '0120000000099RR';   
                    }
                    else if(c.Product_Type__c=='QuickMobile' && c.Request_Type__c=='Customer Care'){
                        c.ownerid = '00G1N000002e8Cj';                                // assign the case to Client Services Customer Care Queue QM
                        c.RecordTypeId = '0121N000001hVVG';
                    }
                    
                    if(c.Request_Type__c=='Strategic Support'){
                        c.ownerid = '00Go0000001cE20';
                       // c.Client_Services_Category__c = 'Consultations/Best Practices';
                        c.RecordTypeId = '012000000009AAr';
                        //c.External_Escalation__c = true;
                    }
                    if(c.Request_Type__c=='Onsite Training'){
                    c.ownerid = '00G2G000004YMOF'; //Onsite Training request
                    c.RecordTypeId = '012000000009AAr';
                    //c.External_Escalation__c = true;
                }  
                }
            
                Case beforeUpdateVal = System.Trigger.oldMap.get(c.id);
                if(c.Request_Type__c != beforeUpdateVal.Request_Type__c && c.Request_Type__c=='Strategic Support'){
                   c.ownerid = '00Go0000001cE20';
                //   c.Client_Services_Category__c = 'Consultations/Best Practices';
                   c.RecordTypeId = '012000000009AAr';
                   //c.External_Escalation__c = true;
                } 
                   
            }
        }
    }
}