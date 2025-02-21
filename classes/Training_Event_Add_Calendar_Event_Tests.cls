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
    
    @isTest
    static void testCreateCalendarEvents() {
        // Create test user
        User testUser = createTestUser();
        
        // Create 100 Training Events
        List<Training_Event__c> testEvents = new List<Training_Event__c>();
        for (Integer i = 0; i < 100; i++) {
            testEvents.add(new Training_Event__c(
                Name = 'Test Training Event ' + i,
                OwnerId = testUser.Id,
                Start_Date__c = Date.today().addDays(i),
                Start_Time__c = '9:00 AM',
                End_Date__c = Date.today().addDays(i),
                End_Time__c = '10:00 AM'
            ));
        }
        
        Test.startTest();
        insert testEvents;
        Test.stopTest();
        
        // Verify Events were created
        List<Event> createdEvents = [SELECT Id FROM Event WHERE WhatId IN :testEvents];
        System.assertEquals(100, createdEvents.size(), 'Should create 100 events');
    }
    
    @isTest
    static void testTimeFormatCleaning() {
        // Test various time format cleaning scenarios
        List<String> testTimes = new List<String>{
            '9:00 AM PDT',
            '12:00 PM Pacific Time',
            '1:30 PM EST',
            '11:45 AM Central Time',
            '8:15 AM Mountain Standard Time'
        };
        
        List<String> expectedCleanTimes = new List<String>{
            '09:00 AM',
            '12:00 PM',
            '01:30 PM',
            '11:45 AM',
            '08:15 AM'
        };
        
        for (Integer i = 0; i < testTimes.size(); i++) {
            String cleanedTime = Training_Event_Add_Calendar_Event.cleanTimeFormat(testTimes[i]);
            System.assertEquals(
                expectedCleanTimes[i], 
                cleanedTime, 
                'Failed to clean time: ' + testTimes[i]
            );
        }
    }
    
    @isTest
    static void testEdgeCaseTimeFormats() {
        // Test edge cases and unusual formats
        Map<String, String> testTimesMap = new Map<String, String>{
            '12:00 AM' => '12:00 AM',
            '12:00 PM' => '12:00 PM',
            '9:00 AM Eastern' => '09:00 AM',
            '1:15 PM (GMT-5)' => '01:15 PM',
            '10:30 AM UTC' => '10:30 AM'
        };
        
        for (String inputTime : testTimesMap.keySet()) {
            String cleanedTime = Training_Event_Add_Calendar_Event.cleanTimeFormat(inputTime);
            System.assertEquals(
                testTimesMap.get(inputTime), 
                cleanedTime, 
                'Failed to clean edge case time: ' + inputTime
            );
        }
    }
    
    @isTest
    static void testInvalidTimeFormats() {
        // Test invalid or null time formats
        List<String> invalidTimes = new List<String>{
            null,
            '',
            '   ',
            'Invalid Time',
            '25:00 XM'
        };
        
        for (String invalidTime : invalidTimes) {
            String cleanedTime = Training_Event_Add_Calendar_Event.cleanTimeFormat(invalidTime);
            System.assertEquals(
                null, 
                cleanedTime, 
                'Should return null for invalid time: ' + invalidTime
            );
        }
    }
    
    @isTest
    static void testEventCreationWithComplexTimeFormats() {
        // Create test user
        User testUser = createTestUser();
        
        // Create Training Event with complex time format
        Training_Event__c testEvent = new Training_Event__c(
            Name = 'Complex Time Format Event',
            OwnerId = testUser.Id,
            Start_Date__c = Date.today(),
            Start_Time__c = '9:00 AM Pacific Standard Time',
            End_Date__c = Date.today(),
            End_Time__c = '10:30 AM EST'
        );
        
        Test.startTest();
        insert testEvent;
        Test.stopTest();
        
        // Verify Event was created with correct time
        Event createdEvent = [
            SELECT ActivityDateTime, EndDateTime 
            FROM Event 
            WHERE WhatId = :testEvent.Id 
            LIMIT 1
        ];
        
        System.assertNotEquals(null, createdEvent, 'Event should be created');
        System.assertNotEquals(null, createdEvent.ActivityDateTime, 'Start time should be set');
        System.assertNotEquals(null, createdEvent.EndDateTime, 'End time should be set');
    }
    
    @isTest
    static void testTimeFormatNormalization() {
        // Test various time format variations
        Map<String, String> testTimesMap = new Map<String, String>{
            '9:00AM' => '09:00 AM',
            '9:00 AM' => '09:00 AM',
            '12:30PM' => '12:30 PM',
            '1:45 PM' => '01:45 PM',
            '11:15AM' => '11:15 AM',
            '9:00 am' => '09:00 AM',
            '9:00pm' => '09:00 PM'
        };
        
        for (String inputTime : testTimesMap.keySet()) {
            String cleanedTime = Training_Event_Add_Calendar_Event.cleanTimeFormat(inputTime);
            System.assertEquals(
                testTimesMap.get(inputTime), 
                cleanedTime, 
                'Failed to normalize time: ' + inputTime
            );
        }
    }

    // Helper method to create a test user
    private static User createTestUser() {
        User testUser = new User(
            Alias = 'testuser', 
            Email='testuser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey='America/Los_Angeles', 
            Username='testuser' + System.now().getTime() + '@testorg.com'
        );
        insert testUser;
        return testUser;
    }

    // @istest
    // public static void testCreate100Events() {
    //     List<Training_Event__c> trainingEvents = new List<Training_Event__c>();
        
    //     //Parcific Time should be ignored. The Code looks for Starttime (11). 
    //     for (Integer i = 0; i < 100; i++) {
    //         trainingEvents.add(new Training_Event__c(
    //             Name = 'Training Event ' + i,
    //             OwnerId = UserInfo.getUserId(),
    //             Start_Date__c = Date.today(),
    //             Start_Time__c = '09:00 AM Parcific Time',
    //             End_Date__c = Date.today(),
    //             End_Time__c = '5:00 PM Parcific Time'
    //         ));
    //     }
    //     Test.startTest(); 
    //     insert trainingEvents;
    //     Test.stopTest(); 

    //     // Re-fetch the events to assert they were created
    //     for (Training_Event__c trainEvent : [SELECT Id, (SELECT Id, ActivityDateTime FROM Events) FROM Training_Event__c WHERE Id IN :trainingEvents]) {
    //         System.assert(trainEvent.Events.size() == 1, '1 Events should be created and linked. Actual :: '+trainEvent.Events.size());
    //         System.assert(trainEvent.Events[0].ActivityDateTime != null, 'ActivityDateTime on Events should be created and linked. Actual :: '+trainEvent.Events[0].ActivityDateTime);
    //     }
    // }


    // @isTest
    // public static void testUpdate100Events() {
    //     List<Training_Event__c> trainingEvents = new List<Training_Event__c>();
        
    //     //Parcific Time should be ignored. The Code looks for Starttime (11). 
    //     for (Integer i = 0; i < 100; i++) {
    //         trainingEvents.add(new Training_Event__c(
    //             Name = 'Training Event ' + i,
    //             OwnerId = UserInfo.getUserId(),
    //             Start_Date__c = Date.today(),
    //             Start_Time__c = '09:00 AM Parcific Time',
    //             End_Date__c = Date.today(),
    //             End_Time__c = '5:00PM Parcific Time'
    //         ));
    //     }
        
    //     insert trainingEvents;
        
    //     Test.startTest(); 
    //     // Update test
    //     for (Training_Event__c trainEvent : trainingEvents) {
    //         trainEvent.Name = 'Updated ' + trainEvent.Name;
    //     }
    //     update trainingEvents;
    //     Test.stopTest(); 

    //     // Assert that updating training events does not create additional events
    //     for (Training_Event__c trainEvent : [SELECT Id, (SELECT Id,ActivityDateTime FROM Events) FROM Training_Event__c WHERE Id IN :trainingEvents]) {
    //         System.assert(trainEvent.Events.size() == 1, '1 Events should be created and linked. Actual :: '+trainEvent.Events.size());
    //         System.assert(trainEvent.Events[0].ActivityDateTime != null, 'ActivityDateTime on Events should be created and linked. Actual :: '+trainEvent.Events[0].ActivityDateTime);
    //     }
    // }
}
