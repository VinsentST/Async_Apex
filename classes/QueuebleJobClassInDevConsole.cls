public class QueuebleJobClassInDevConsole implements Queueable {
    public void execute(QueueableContext context) {
        List<Account> accList = [SELECT ID, (SELECT Is_Synced__c,Processed_By_Queue__c from Contacts) FROM Account where  BillingStreet!= null AND BillingState!=null AND BillingCity!= null AND BillingPostalCode!=Null LIMIT 150];
        List<Contact> contactToUpdate = new List<Contact>();
         for(Account a:accList){
            for(Contact c : a.Contacts ){
                c.Is_Synced__c = false;
                c.Processed_By_Queue__c = true;
                contactToUpdate.add(c);
            }
        }
        update  contactToUpdate;
    }
}