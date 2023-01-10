/**
 * @File Name          : LPTierAdjustmentsTriggerHandler.cls
 * @Description        : Update the fields of Loyalty Tier Adjustments
 * @Author             : Harsh Garg
 * @Last Modified By   : Harsh Garg
 * @Last Modified On   : 02-02-2022
 * @Modification Log   :
 * Ver       Date               Author                  Modification
 * 1.0    02/02/2022            Harsh G                Initial Version
**/
public class LPTierAdjustmentsTriggerHandler {
    
    public static void complimentaryCheck(List<Loyalty_Tier_Adjustments__c> loyaltyTierAdjustmentList){
        Loyalty_Dates__c loyaltyDates = Loyalty_Dates__c.getOrgDefaults();
        Date startDate = loyaltyDates.Start_Date__c;
        Date endDate = loyaltyDates.End_Date__c;
        Map<Id,Loyalty_Tier_Adjustments__c> loyaltyRewardIdsToNewComplimentary = new Map<Id,Loyalty_Tier_Adjustments__c>();
        for(Loyalty_Tier_Adjustments__c lta:loyaltyTierAdjustmentList){
            if(lta.Change_Reward_Tier_To__c != null && lta.Change_Reward_Tier_To__c.contains('Complimentary')){
                loyaltyRewardIdsToNewComplimentary.put(lta.Loyalty_Rewards__c,lta);
            }
        }
        for(Loyalty_Rewards__c lr:[SELECT Id, (SELECT Id FROM Loyalty_Tier_Adjustments__r WHERE Change_Reward_Tier_To__c LIKE '%Complimentary%' AND Date__c >=: startDate AND Date__c <=: endDate) FROM Loyalty_Rewards__c WHERE Id IN: loyaltyRewardIdsToNewComplimentary.keySet()]){
            if(lr.Loyalty_Tier_Adjustments__r.size() > 0){
                Loyalty_Tier_Adjustments__c newLta = loyaltyRewardIdsToNewComplimentary.get(lr.Id);
                newLta.addError('There is already an existing complimentary tier adjustment in the program cycle ending on ' + endDate.format());
            }
        }
        
    }

    /**
     * Method : updateLoyaltyTierAdjustments
     * Description : Main method to call all the methods and then update the list of Loyalty_Tier_Adjustments__c
     * Created by : Harsh G
     */
    public static void updateLoyaltyTierAdjustments (List<Loyalty_Tier_Adjustments__c> loyaltyTierAdjustmentList) {
        Loyalty_Dates__c loyaltyDates = Loyalty_Dates__c.getOrgDefaults();
        for(Loyalty_Tier_Adjustments__c lta:loyaltyTierAdjustmentList){
            lta.Complimentary_Tier_End_Date__c = loyaltyDates.End_Date__c;
        }
    }
}