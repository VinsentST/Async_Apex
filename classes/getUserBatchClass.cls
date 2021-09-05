public class getUserBatchClass implements
    Database.Batchable<sObject>, Database.Stateful {
        public getUserBatchClass(List<Task> taskList,Set<Id> accountOwnerIds,Map<Id,Account> accountMap){
            this.taskList = taskList;
            this.accountOwnerIds = accountOwnerIds;
            this.accountMap = accountMap;
        }
        List<Task> taskList = new List<Task>();
        Set<Id> accountOwnerIds = new Set<Id>();
        Map<Id,Account> accountMap = new Map<Id, Account>();
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('start getUserBatchClass');
        return Database.getQueryLocator( [select Id,Name from User where Id IN :this.accountOwnerIds] );
    }
    public void execute(Database.BatchableContext bc, List<User> scope){
        System.debug('execute getUserBatchClass');
        Map<Id, User> userMap = new Map<Id,User>();
        for(User u : scope){
            userMap.put(u.Id,u);
        }
        List<Task> taskListToUpdate = new List<Task>();
 		if(userMap.size() > 0) {
            for(Task t : this.taskList ){
                 if (t.WhatId != null                                        // Make sure there is an Account linked to the Task
          			&& this.accountMap.ContainsKey(t.WhatId)                       // Make sure our Account query captured  it
          			&& this.accountMap.get(t.WhatId).OwnerId != null               // Make sure that account has an owner
          			&& usermap.ContainsKey(this.accountMap.get(t.WhatId).Ownerid)  // Finally make sure our User query found the owner
                    ){
                        t.Account_Owner__c = userMap.get(this.accountMap.get(t.WhatId).OwnerId).name;
                        taskListToUpdate.add(t);       
                    }         
            }
        }
        update     taskListToUpdate;
        
    }
    public void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. getUserBatchClass ');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
       
    }
}