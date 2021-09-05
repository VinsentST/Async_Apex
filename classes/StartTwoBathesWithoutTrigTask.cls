/**
 * Create Scheduled Job which runs every 30 minutes and call 2 created batches
 * Create similar Batch and use Iterable
 */ 
global class StartTwoBathesWithoutTrigTask  implements Schedulable {
    global void execute(SchedulableContext ctx) {
        GetTaskBatch ucaTB = new GetTaskBatch();
		Id batchIdGetTaskBath = Database.executeBatch(ucaTB);
		ContactBatchWithQuebly ucaCB = new ContactBatchWithQuebly();
		Id batchIdContactBatch = Database.executeBatch(ucaCB);
    }
}