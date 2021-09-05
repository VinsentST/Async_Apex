/*
 * Create class with future method. Inside the method do the following:
	Select 150 Accounts from database.
	For accounts in which BillingAddress is not empty select all related Contacts 
	Set to all Contacts Is Synced = false; Processed By Future = true;
	Run created class using DevConsole.
 */ 
public class AccountAndContHandler {
	@future
    public static void updateContactByFuture(){
        List<Account> accList = [SELECT ID, (SELECT Is_Synced__c,Processed_By_Future__c from Contacts) FROM Account where  BillingStreet!= null AND BillingState!=null AND BillingCity!= null AND BillingPostalCode!=Null LIMIT 150];
        List<Contact> contactToUpdate = new List<Contact>();
        for(Account a:accList){
            for(Contact c : a.Contacts ){
                c.Is_Synced__c = false;
                c.Processed_By_Future__c = true;
                contactToUpdate.add(c);
            }
        }
        update  contactToUpdate;
    }
}