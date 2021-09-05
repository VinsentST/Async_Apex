/*
 * Create Scheduled Job which runs every 30 minutes and call 2 created batches
 */ 
global class StartTwoBatches  implements Schedulable {
    global void execute(SchedulableContext ctx) {
        GetTaskBatch ucaTB = new GetTaskBatch();
		Id batchIdGetTaskBath = Database.executeBatch(ucaTB);
		ContactBatch ucaCB = new ContactBatch();
		Id batchIdContactBatch = Database.executeBatch(ucaCB);
    }
}