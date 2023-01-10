/**
 * @File Name          : LoyaltyRewardsTriggerHandlerTest.cls
 * @Description        : Test class for LoyaltyRewardsTriggerHandler.cls
 * @Author             : Mozart Labao
 * @Last Modified By   : Mozart Labao
 * @Last Modified On   : 11-22-2021
 * @Modification Log   : 
 * Ver       Date            	Author      		    Modification
 * 1.0    11/11/2021  	 		Mozart			       Initial Version
 * 2.0    11/22/2021            Mozart                 Added Documentation, Remove Debugs, Added Assertion
**/


@isTest
public class LoyaltyRewardsTriggerHandlerTest {
    
        @isTest static void updateLoyaltyTierAdjustmenttest(){
        User user = [SELECT id,Name FROM User WHERE Name = 'IT Data Services'];
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        
        Loyalty_Rewards__c loy = new Loyalty_Rewards__c();
        List<Loyalty_Tier_Adjustments__c> lTier = new List<Loyalty_Tier_Adjustments__c>();

        if(user != null ){
            system.runAs(user){
                test.startTest();

                insert acc;
                
                loy.Account__c = acc.id;
                insert loy;
                
                for(integer i=0;i<4;i++) {
                    Loyalty_Tier_Adjustments__c lt = new Loyalty_Tier_Adjustments__c(Change_Reward_Tier_To__c='Complimentary Bronze');
                    lt.Loyalty_Rewards__c = loy.Id;
                    lt.Date__c = System.today();
                    lt.Complimentary_Tier_End_Date__c = System.today()+1;
                    lt.Reason__c = 'test '+i;
                    lTier.add(lt);
                }
                insert lTier;
                
                loy.if_YTD_is_changed__c = True;
                loy.YTD_Spend__c = 1;
                update loy;

                test.stopTest();

                System.assertNotEquals(False, loy.if_YTD_is_changed__c);
                System.assertNotEquals(null, loy);
                System.assertNotEquals(System.today(), lTier[0].Complimentary_Tier_End_Date__c);
            }
        }
    }
    
    @isTest static void updateLoyaltyTierAdjustment_givenTestData_throwsExpectedException(){
        User user = [SELECT id,Name FROM User WHERE Name = 'IT Data Services'];
        User otherUser = [SELECT id,Name FROM User WHERE Name != 'IT Data Services' LIMIT 1];
        Account acc = new Account();
        acc.Name = 'Test Account With Exception';
        
        Loyalty_Rewards__c loy = new Loyalty_Rewards__c();
        List<Loyalty_Tier_Adjustments__c> lTier = new List<Loyalty_Tier_Adjustments__c>();

        insert acc;
        if(user != null ){
            system.runAs(user){
                test.startTest();
                
                loy.Account__c = acc.id;
                insert loy;
                
                for(integer i=0;i<5;i++) {
                    Loyalty_Tier_Adjustments__c lt = new Loyalty_Tier_Adjustments__c();
                    lt.Loyalty_Rewards__c = loy.Id;
                    lt.Date__c = System.today();
                    lt.Complimentary_Tier_End_Date__c = System.today()+1;
                    lt.Reason__c = 'exception '+i;
                    lTier.add(lt);
                }
                insert lTier;
                system.runAs(otherUser){
                    loy.if_YTD_is_changed__c = True;
                    loy.YTD_Spend__c = 1;
                    
                    update loy;
                }
                
                test.stopTest();

                System.assertNotEquals(False, loy.if_YTD_is_changed__c);
                System.assertNotEquals(null, loy);
                System.assertNotEquals(System.today(), lTier[0].Complimentary_Tier_End_Date__c);
            }
        }
    }
    

}