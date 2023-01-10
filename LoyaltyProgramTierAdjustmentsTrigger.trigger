/**
 * @File Name          : LoyaltyProgramTiedAdjustmentsTrigger
 * @Description        : Trigger that calls LPTiedAdjustmentsTriggerHandler
 * @Author             : Harsh Garg
 * @Last Modified By   : Harsh Garg
 * @Last Modified On   : 02-02-2022
 * @Modification Log   :
 * Ver       Date               Author                  Modification
 * 1.0    02/02/2022            Harsh G                 Initial Version
**/
trigger LoyaltyProgramTierAdjustmentsTrigger on Loyalty_Tier_Adjustments__c (before insert, before update) {
        //Call updateLoyaltyTierAdjustments() with the inserted list of Loyalty_Tier_Adjustments__c
        try {
            if(Trigger.isBefore){
                if(Trigger.isInsert){
                    LPTierAdjustmentsTriggerHandler.complimentaryCheck(Trigger.new);
                    LPTierAdjustmentsTriggerHandler.updateLoyaltyTierAdjustments(Trigger.new);
                }
                if(Trigger.isUpdate){
                    List<Loyalty_Tier_Adjustments__c> ltasToCheck = new List<Loyalty_Tier_Adjustments__c>();
                    for(Id ltaId:Trigger.oldMap.keySet()){
                        Loyalty_Tier_Adjustments__c oldLta = Trigger.oldMap.get(ltaId);
                        Loyalty_Tier_Adjustments__c newLta = Trigger.newMap.get(ltaId);
                        String oldValue = oldLta.Change_Reward_Tier_To__c;
                        String newValue = newLta.Change_Reward_Tier_To__c;
                        if(oldValue!=newValue){
                            ltasToCheck.add(newLta);
                        }
                    }
                    if(ltasToCheck.size() > 0){
                        LPTierAdjustmentsTriggerHandler.complimentaryCheck(ltasToCheck);
                    }
                }
            }
        }catch(Exception dmlException){
            ErrorHandler.handleException(new ErrorHandler.ErrorDataContainer(ErrorOriginType.APEX_TRIGGER,'LoyaltyProgramTiedAdjustmentsTrigger','In line number' + dmlException.getLineNumber() + ', in the after insert context',new Map<String,Object>{'Trigger.new'=>Trigger.new,'Trigger.oldMap'=>Trigger.oldMap},dmlException.getTypeName(),dmlException.getMessage(),dmlException.getStackTraceString(),'Loyalty','Loyalty_Tier_Adjustments__c'));
        }
}