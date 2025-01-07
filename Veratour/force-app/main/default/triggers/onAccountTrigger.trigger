trigger onAccountTrigger on Account (after insert, after delete, after update) {

	if(trigger.isInsert){
		if(trigger.isAfter){
			OnAccountTriggerHandler.CreateSlaveMap(trigger.new);
		}
	}

	if(trigger.isUpdate){
		if(Trigger.isAfter){
			OnAccountTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
		}
	}
   
	if(trigger.isDelete){
		if(trigger.isAfter){
			OnAccountTriggerHandler.CreateSlaveAssociation(trigger.old);
		}
	}
     
}