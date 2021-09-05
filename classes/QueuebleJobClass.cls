/**
 * In AccountTriggerHandler call Queueble Job, which perform similar logic:
	For accounts in which BillingAddress changed select all related Contacts
	Set to all Contacts Is Synced = false; Processed By Queue = true;
 */ 
public class QueuebleJobClass implements Queueable {
    String before;
    String after;
    public QueuebleJobClass(String before, String after ){
        this.before = before;
        this.after = after;
    }
    
    
   public void execute(QueueableContext context) {
       System.debug('before |'+this.before+'|');
       System.debug('after |'+this.after+'|');
        List<Account> accountListBefore = (List<Account>)Json.deserialize(this.before,List<Account>.class);
        List<Account> accountListAfter = (List<Account>)Json.deserialize(this.after,List<Account>.class);
        for(Account oldAcc : accountListBefore){
            for(Account newAcc : accountListAfter){
                 if(  (oldAcc.ID == newAcc.ID) ){
                    if( oldAcc.BillingStreet !=  newAcc.BillingStreet 
                        || oldAcc.BillingCity !=  newAcc.BillingCity 
                        || oldAcc.BillingState !=  newAcc.BillingState 
                        || oldAcc.BillingPostalCode !=  newAcc.BillingPostalCode
                        || oldAcc.BillingLatitude !=  newAcc.BillingLatitude
                        || oldAcc.BillingLongitude !=  newAcc.BillingLongitude){
                        System.debug(' Choose related contacts |'+newAcc.Name);
                        List<Contact> listCnt = [SELECT ID from Contact where AccountId = :newAcc.ID];
                        for(Contact c : listCnt ){
                        	c.Is_Synced__c = false;
                            c.Processed_By_Queue__c = true;
                        }
                        update listCnt;
                        System.debug('| cnt '+listCnt.size() );
                        break;
                    }
                }            
            }
        }          
    }
}