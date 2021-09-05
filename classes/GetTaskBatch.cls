/**
 * Crate Batch Job which select all tasks with  Is Synced = false
	Batch should copy from Account.Owner.Name to Task.AccountOwner__c
	Set Task.IsSynced__c = true;
	Update Account field Updated By Task = true;
	Use Query Locator
 */
public class GetTaskBatch  implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT  WhatId,Is_Synced__c,Account_Owner__c FROM Task WHERE Is_Synced__c = false');
    }
    public void execute(Database.BatchableContext bc, List<Task> records){
        Set<Id> accountIds = new Set<Id>();
   		Set<Id> accountOwnerIds = new Set<Id>();      
        for(Task t : records ){
            if(t.WhatId != null ){
                accountIds.add(t.WhatId);
            }
        }
       
        Map<Id,Account> accountMap = new Map<Id, Account>([select Id, OwnerId from Account where Id IN :accountIds]);
        for (Account a : accountMap.values()) {
            if(a.OwnerId != null){
                accountOwnerIds.add(a.OwnerId);
                a.Updated_By_Task__c = true;
            } 
            
        }
        update accountMap.values();
        Map<Id, User> userMap = new Map<Id,User>([select Name from User where Id IN :accountOwnerIds]);
        List<Task> taskListToUpdate = new List<Task>();    
        if(userMap.size() > 0) {
            for(Task t : records ){
                 if (t.WhatId != null                                        // Make sure there is an Account linked to the Task
          			&& accountMap.ContainsKey(t.WhatId)                       // Make sure our Account query captured  it
          			&& accountMap.get(t.WhatId).OwnerId != null               // Make sure that account has an owner
          			&& usermap.ContainsKey(accountMap.get(t.WhatId).Ownerid)  // Finally make sure our User query found the owner
                    ){
                        t.Account_Owner__c = userMap.get(accountMap.get(t.WhatId).OwnerId).name;
                        taskListToUpdate.add(t);       
                    }         
            }
        }
        update     taskListToUpdate;
    }
    
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}