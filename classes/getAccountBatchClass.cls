public class getAccountBatchClass  implements
    Database.Batchable<sObject>, Database.Stateful {
    public getAccountBatchClass(String jsonStringNew){
        if(jsonStringNew!=''){
            this.taskList = (List<Task>)Json.deserialize(jsonStringNew,List<Task>.class);
        }
        
    }
    public List<Task> taskList = new List<Task>();
    public Set<Id> accountOwnerIds = new Set<Id>();
    public Map<Id,Account> accountMap = new Map<Id, Account>();
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('start getAccountBatchClass');
        Set<Id> accountIds = new Set<Id>();
        return Database.getQueryLocator( [Select  Id, OwnerId from Account where Id IN:accountIds ] );
    }
    public void execute(Database.BatchableContext bc, List<Account> scope){
         System.debug('execute getAccountBatchClass ');
        
         
         for(Account a : scope){
             if(a.OwnerId != null){
                 System.debug(a);
                 this.accountMap.put(a.Id, a);
                 this.accountOwnerIds.add(a.OwnerId);
             }
             recordsProcessed = recordsProcessed + 1;
         }
    }
    public void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. getAccountBatchClass ');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
       	getUserBatchClass uca = new getUserBatchClass(this.taskList,this.accountOwnerIds,this.accountMap);
        Id batchId = Database.executeBatch(uca);
    }
}