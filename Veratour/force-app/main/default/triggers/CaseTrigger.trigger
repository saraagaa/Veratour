trigger CaseTrigger on Case (after insert, before update) {
    if(Trigger.isInsert){
        CaseTriggerHandler.afterCreation(Trigger.new);
        System.debug('Before Insert :'+Trigger.newMap);
    }  
    if(Trigger.isUpdate){
       CaseTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
}