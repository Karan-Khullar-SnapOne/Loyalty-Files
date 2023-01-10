/**
 * @File Name          : LPTierAdjustmentsTriggerHandlerTest.cls
 * @Description        : test class to increase the coverage of LPTiedAdjustmentsTriggerHandler
 * @Author             : Harsh Garg
 * @Last Modified By   : Harsh Garg
 * @Last Modified On   : 04-02-2022
 * @Modification Log   :
 * Ver       Date               Author                  Modification
 * 1.0    04/02/2022            Harsh G                Initial Version
**/

@isTest
public class LPTierAdjustmentsTriggerHandlerTest {

    /**
     * Method : testupdateLoyaltyTierAdjustments
     * Description : test updateLoyaltyTierAdjustments method.
     * Created by : Harsh G
     */
    @isTest
    public static void testupdateLoyaltyTierAdjustments() {

        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Loyalty_Rewards__c loyaltyRewards = new Loyalty_Rewards__c();
        loyaltyRewards.Account__c = account.Id;
        loyaltyRewards.Reward_Tier__c = 'Complimentary Bronze';
        loyaltyRewards.Program_Year_End_Date__c = date.today();
        insert loyaltyRewards;

        Loyalty_Tier_Adjustments__c loyaltyTierAdjustments = new Loyalty_Tier_Adjustments__c();
        loyaltyTierAdjustments.Loyalty_Rewards__c = loyaltyRewards.Id;
        loyaltyTierAdjustments.Date__c = date.today();
        loyaltyTierAdjustments.Reason__c = 'test';

        test.startTest();
            insert loyaltyTierAdjustments;
        test.stopTest();

        System.assertNotEquals(date.today(), loyaltyTierAdjustments.Complimentary_Tier_End_Date__c);
    }

    /**
     * Method : testneagtiveScenerio
     * Description : test negative scenerios of updateLoyaltyTierAdjustments method.
     * Created by : Harsh G
     */
    @isTest
    public static void testnegativeScenerio() {

        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Loyalty_Rewards__c loyaltyRewards = new Loyalty_Rewards__c();
        loyaltyRewards.Account__c = account.Id;
        loyaltyRewards.Reward_Tier__c = 'Bronze';
        loyaltyRewards.Program_Year_End_Date__c = date.today();
        insert loyaltyRewards;

        Loyalty_Tier_Adjustments__c loyaltyTierAdjustments = new Loyalty_Tier_Adjustments__c();
        loyaltyTierAdjustments.Loyalty_Rewards__c = loyaltyRewards.Id;
        loyaltyTierAdjustments.Date__c = date.today();
        loyaltyTierAdjustments.Reason__c = 'test';

        test.startTest();
            insert loyaltyTierAdjustments;
        test.stopTest();

        System.assertNotEquals(loyaltyRewards.Program_Year_End_Date__c, loyaltyTierAdjustments.Complimentary_Tier_End_Date__c);
    }
}