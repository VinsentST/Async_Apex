/**
 * Create Batch Job, which select all contacts with Is Synced = false
	Batch should copy from Account.BillingAddress to Contact.MailingAddress
	Set Contact.IsSynced__c = true;
	Update Account field Updated By Contact = true;
	Use Iterable
 */
public class ContactBatch  implements Database.Batchable<sObject> {
    public Iterable<sObject> start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return [SELECT  AccountId,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry ,Is_Synced__c FROM Contact WHERE Is_Synced__c = false];
    }
    public void execute(Database.BatchableContext bc, List<Contact> records){
    
        // process each batch of records
        Set<Id> accountIds = new Set<Id>();
    
        for(Contact c : records ){
            if(c.AccountId != null ){
                accountIds.add(c.AccountId);
            }
        }
   
        Map<Id,Account> accountMap = new Map<Id, Account>([select Id, BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry ,Updated_By_Contact__c from Account where Id IN :accountIds]);
        List<Contact> contactToUpdate = new List<Contact>();
        Set<Account> accountToUpdate = new Set<Account>();
      
   
            for(Contact con : records ){
                
                
               if(accountMap.size()>0){ 
            	  if(con.AccountId != null && accountMap.ContainsKey(con.AccountId) ){
                      Account acc = accountMap.get(con.AccountId);
                      acc.Updated_By_Contact__c = true;
                      con.MailingStreet  = acc.BillingStreet;
                         
                      con.MailingCity =  acc.BillingCity;
             		  con.MailingState = acc.BillingState;
            	 	  con.MailingPostalCode = acc.BillingPostalCode;
             		  con.MailingCountry = acc.BillingCountry;
                
            	 
                      accountToUpdate.add(acc);
            	}
               }
               con.Is_Synced__c = true;
               contactToUpdate.add(con);
           
        	}
            update (new List<Account>(accountToUpdate));
        	update contactToUpdate;
           
    
    
	}
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}