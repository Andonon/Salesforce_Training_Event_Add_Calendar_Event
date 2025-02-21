/*
*********************************************************
Apex Class Name    : Training_Event_Add_Calendar_Event_Tests
Created Date       : 02/20/2025
@description       : Tests for Training_Event__c. (Test for creates Calendar Entries, for Training Events). 
@author            : Troy Center
Modification Log:
Ver     Date        Author                  Case            Modification
1.0     02/20/2025  Troy Center             00390503        Initial Version
*********************************************************
*/
@isTest
public class Training_Event_Add_Calendar_Event_Tests {
    
    @istest
    public static void testCreate100Events() {
        List<Training_Event__c> trainingEvents = new List<Training_Event__c>();
        
        //Parcific Time should be ignored. The Code looks for Starttime (11). 
        for (Integer i = 0; i < 100; i++) {
            trainingEvents.add(new Training_Event__c(
                Name = 'Training Event ' + i,
                OwnerId = UserInfo.getUserId(),
                Start_Date__c = Date.today(),
                Start_Time__c = '09:00 AM Parcific Time',
                End_Date__c = Date.today(),
                End_Time__c = '5:00 PM Parcific Time'
            ));
        }
        Test.startTest(); 
        insert trainingEvents;
        Test.stopTest(); 

        // Re-fetch the events to assert they were created
        for (Training_Event__c trainEvent : [SELECT Id, (SELECT Id, ActivityDateTime FROM Events) FROM Training_Event__c WHERE Id IN :trainingEvents]) {
            System.assert(trainEvent.Events.size() == 1, '1 Events should be created and linked.');
            System.assert(trainEvent.Events[0].ActivityDateTime != null, 'ActivityDateTime on Events should be created and linked.');
        }
    }


    @isTest
    public static void testUpdate100Events() {
        List<Training_Event__c> trainingEvents = new List<Training_Event__c>();
        
        //Parcific Time should be ignored. The Code looks for Starttime (11). 
        for (Integer i = 0; i < 100; i++) {
            trainingEvents.add(new Training_Event__c(
                Name = 'Training Event ' + i,
                OwnerId = UserInfo.getUserId(),
                Start_Date__c = Date.today(),
                Start_Time__c = '09:00 AM Parcific Time',
                End_Date__c = Date.today(),
                End_Time__c = '5:00 PM Parcific Time'
            ));
        }
        
        insert trainingEvents;
        
        Test.startTest(); 

        // Update test
        for (Training_Event__c trainEvent : trainingEvents) {
            trainEvent.Name = 'Updated ' + trainEvent.Name;
        }
        
        update trainingEvents;
        
        Test.stopTest(); 
        // Assert that updating training events does not create additional events
        for (Training_Event__c trainEvent : [SELECT Id, (SELECT Id,ActivityDateTime FROM Events) FROM Training_Event__c WHERE Id IN :trainingEvents]) {
            System.assert(trainEvent.Events.size() == 1, 'Updating Training Event should not create new Events.');
            System.assert(trainEvent.Events[0].ActivityDateTime != null, 'ActivityDateTime on Events should be created and linked.');
        }
    }
}
