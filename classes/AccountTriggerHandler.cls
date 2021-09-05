public class AccountTriggerHandler {
    /*
     * For AccountTriggerHandler move task creation logic to future method; set Task.IsSynced = false
     */
    @future
    public static void setTaskIsSyncFalse(String jsonString)
    {   
           List<Task> taskList = (List<Task>)Json.deserialize(jsonString,List<Task>.class);
           List<Task> taskListUpdate = new List<Task>();
           for(Task t: taskList){
               t.Is_Synced__c = false;
               taskListUpdate.add(t);
           }
           update taskListUpdate;
    }
    /**
     * In AccountTriggerHandler create future method:
		For accounts in which BillingAddress changed select all related Contacts 
		Set to all Contacts Is Synced = false; Processed By Future = true;
     * 
     */
    @future
    public static void selectAllRelatedContactsWithChanchedBA(String jsonStringOld,String jsonStringNew){
        List<Account> accountListBefore = (List<Account>)Json.deserialize(jsonStringOld,List<Account>.class);
        List<Account> accountListAfter = (List<Account>)Json.deserialize(jsonStringNew,List<Account>.class);
        
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
                                c.Processed_By_Future__c = true;
                            }
                            update listCnt;
                        System.debug('| cnt '+listCnt.size() );
                        break;
                    }
                }                
            }
        }
    }
    /**
     * In AccountTriggerHandler call Queueble Job, which perform similar logic:
			For accounts in which BillingAddress changed select all related Contacts
			Set to all Contacts Is Synced = false; Processed By Queue = true;
     */ 
      public static void callQueuebleJob(String jsonStringOld,String jsonStringNew){
          ID jobID = System.enqueueJob(new QueuebleJobClass(jsonStringOld,jsonStringNew));
    }
    
	 public static void callBathcJob(String jsonStringNew){
        getAccountBatchClass ubdBtchTsk = new getAccountBatchClass(jsonStringNew);
        Id batchId = Database.executeBatch(ubdBtchTsk);
     }
}