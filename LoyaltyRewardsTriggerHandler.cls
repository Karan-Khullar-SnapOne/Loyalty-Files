/**
 * @File Name          : LoyaltyRewardsTriggerHandler.cls
 * @Description        : Update Loyalty Tier Adjustment Complementary End date to Date today + 89 Days
 * @Author             : Mozart Labao
 * @Last Modified By   : Mozart Labao
 * @Last Modified On   : 11-22-2021
 * @Modification Log   : 
 * Ver       Date            	Author      		    Modification
 * 1.0    11/11/2021  	 		Mozart			       Initial Version
 * 2.0    11/22/2021            Mozart                 Clean Code,Remove Debug
**/
public class LoyaltyRewardsTriggerHandler {
    
    public static void updateLoyaltyProgramYearEndDate(List<Loyalty_Rewards__c> loyaltyRewards){
        Loyalty_Dates__c loyaltyDates = Loyalty_Dates__c.getOrgDefaults();
        for(Loyalty_Rewards__c lr:loyaltyRewards){
            lr.Program_Year_End_Date__c = loyaltyDates.End_Date__c;
        }
    }
    
    // This method Update Loyalty Tier Adjustment Complementary End date to Date today + 89 days 
    // and will only run if will be triggered by Integration ( IT Data Services User)
    public static void updateLoyaltyTierAdjustment (List<Loyalty_Rewards__c> newList,Map<Id,Loyalty_Rewards__c> oldMap){

        String integUser ='IT Data Services';
        Integer addtlDay = 89;
        set<Id> loyRewardsIds = new set<Id>(); 
        set<Id> usrIds = new set<Id>(); 
        for(Loyalty_Rewards__c lr : newList){
            if ( (oldMap ==null || (oldMap !=null && !(oldmap.get(lr.Id).if_YTD_is_changed__c) ) ) && lr.YTD_Spend__c>0) {
                loyRewardsIds.add(lr.id);
                usrIds.add(lr.LastModifiedById);
            }
        }
        if(!loyRewardsIds.isEmpty()){ 
            User u = [SELECT id,name FROM User WHERE id =:usrIds LIMIT 1];
            if(u !=null && u.Name == integUser){
                
                List<Loyalty_Tier_Adjustments__c> checkloyTierAdjList =  [SELECT id,Loyalty_Rewards__c,Complimentary_Tier_End_Date__c 
                                                                        FROM Loyalty_Tier_Adjustments__c WHERE Loyalty_Rewards__c=:loyRewardsIds AND Change_Reward_Tier_To__c LIKE 'Complimentary%'];
                
                if(!checkloyTierAdjList.isEmpty()){    
                    Map<String,List<Loyalty_Tier_Adjustments__c>> loyTierAdjMap = new Map<String,List<Loyalty_Tier_Adjustments__c>>();
                    
                    for(Loyalty_Rewards__c lr : newList){
                        for(Loyalty_Tier_Adjustments__c lt : checkloyTierAdjList){
                            if(lr.Id == lt.Loyalty_Rewards__c){
                                if(!loyTierAdjMap.containsKey(lr.Id)){
                                    loyTierAdjMap.put(lr.Id, new List<Loyalty_Tier_Adjustments__c>());    
                                }
                                loyTierAdjMap.get(lr.Id).add(lt);
                            }
                        }
                    }
                    
                    if(!loyTierAdjMap.isEmpty()){
                        List<Loyalty_Tier_Adjustments__c> loyaltyTierAdjListtoUpdate = new List<Loyalty_Tier_Adjustments__c>();
                        
                        Loyalty_Tier_Adjustments__c loyTA;
                        for(Id loyReward : loyTierAdjMap.keyset() ){
                            if(!loyTierAdjMap.get(loyReward).isEmpty() ){
                                for(Loyalty_Tier_Adjustments__c lta : loyTierAdjMap.get(loyReward) ){
                                    loyTA = new Loyalty_Tier_Adjustments__c();
                                    loyTA.id = lta.id;
                                    if(lta.Complimentary_Tier_End_Date__c != null){
                                        loyTA.Complimentary_Tier_End_Date__c = Date.Today().addDays(addtlDay); 
                                    }
                                    loyaltyTierAdjListtoUpdate.add(loyTA);
                                }
                            }
                        }
                        
                        if(!loyaltyTierAdjListtoUpdate.isEmpty()){
                            try{
                                update loyaltyTierAdjListtoUpdate;
                                updateLoyaltyRewardsYTDisTrue(loyRewardsIds);
                            }catch(Exception e){
                                ErrorHandler.handleException(new ErrorHandler.ErrorDataContainer(
                                    ErrorOriginType.APEX_CLASS,
                                    'LoyaltyRewardsTriggerHandler',
                                    'In line number' + e.getLineNumber() + ', in the updateLoyaltyTierAdjustment method',
                                    new Map<String,Object>{'loyaltyTierAdjListtoUpdate'=>loyaltyTierAdjListtoUpdate,'loyRewardsIds'=>loyRewardsIds},
                                    e.getTypeName(),
                                    e.getMessage(),
                                    e.getStackTraceString(),
                                    'Loyalty',
                                    'Loyalty_Rewards__c'
                                ));
                            }
                        }       
                    }
                }
            }else{
                if(Test.isRunningTest()){
                    throw new DMLException('Update needs to be done by IT Data Services. (Should only fire when Test is run)');
                }
            }
        }
    }

    public static void updateLoyaltyRewardsYTDisTrue(Set<Id> loyRewardsIds ){
        List<Loyalty_Rewards__c> loyaltyRewardstoUpdate = new List<Loyalty_Rewards__c>();
        for(Loyalty_Rewards__c lr : [SELECT id, if_YTD_is_changed__c FROM Loyalty_Rewards__c WHERE Id=:loyRewardsIds]){
            lr.if_YTD_is_changed__c = true;
            loyaltyRewardstoUpdate.add(lr);
        }
        
        if(!loyaltyRewardstoUpdate.isEmpty()){ 
            update loyaltyRewardstoUpdate;
        } 
    }
}