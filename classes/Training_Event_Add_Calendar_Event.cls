/*
*********************************************************
Apex Class Name    : Training_Event_Add_Calendar_Event
Created Date       : 02/20/2025
@description       : Created Events for Training Events. (Creates Calendar Entries, for Training Events). 
@author            : Troy Center
Modification Log:
Ver     Date        Author                  Case            Modification
1.0     02/20/2025  Troy Center             00390503        Initial Version, Training Event Add Calendar Event, from AddCalendarEventTrigger (old)
*********************************************************
*/
public class Training_Event_Add_Calendar_Event {

    // Trigger handler method
    public Training_Event_Add_Calendar_Event(List<Training_Event__c> trainingEvents){
        Set<Id> trainingEventIds = new Set<Id>();
        for (Training_Event__c trainingEvent : trainingEvents){
            trainingEventIds.add(trainingEvent.Id);
        }
        createCalendarEvents(trainingEventIds);
    }

    @future
    public static void createCalendarEvents(Set<Id> trainingEventIds) {

        // Fetch Training Events with all required fields
        List<Training_Event__c> trainingEvents = [
            SELECT Id, Name, OwnerId, 
                   Start_Date__c, Start_Time__c, 
                   End_Date__c, End_Time__c
            FROM Training_Event__c 
            WHERE Id IN :trainingEventIds
        ];
        
        // Get the Record Type ID for Web Training Event (Standard_Web)
        String strRecordTypeID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Standard_Web').getRecordTypeId();
        
        // List to store new Events
        List<Event> eventsToCreate = new List<Event>();
        
        // Process each Training Event
        for (Training_Event__c trainingEvent : trainingEvents) {

            // Prepare Start DateTime
            String cleanStartTime = cleanTimeFormat(trainingEvent.Start_Time__c);
            DateTime startDateTime = combineDateTime(
                trainingEvent.Start_Date__c, 
                cleanStartTime
            );
            
            // Prepare End DateTime
            String cleanEndTime = cleanTimeFormat(trainingEvent.End_Time__c);
            DateTime endDateTime = combineDateTime(
                trainingEvent.End_Date__c, 
                cleanEndTime
            );
            
            // Create new Event
            Event newEvent = new Event(
                OwnerId = trainingEvent.OwnerId,
                RecordTypeId = strRecordTypeID,
                WhatId = trainingEvent.Id,
                Subject = trainingEvent.Name,
                ActivityDateTime = startDateTime,
                EndDateTime = endDateTime
            );
            
            eventsToCreate.add(newEvent);
        }
        
        // Insert Events
        if (!eventsToCreate.isEmpty()) {
            insert eventsToCreate;
        }
    }
    
    // Clean time format, removing timezone info
    private static String cleanTimeFormat(String originalTime) {
        // Trim whitespace
        originalTime = originalTime.trim();
        String cleanTime = ''; 

        // Find the index of AM or PM
        Integer amPmIndex = originalTime.toUpperCase().lastIndexOf('AM');
        Integer pmPmIndex = originalTime.toUpperCase().lastIndexOf('PM');

        // Determine which index to use
        Integer cutoffIndex = -1;
        if (amPmIndex > -1) {
            cutoffIndex = amPmIndex;
        } else if (pmPmIndex > -1) {
            cutoffIndex = pmPmIndex;
        }

        // If AM/PM found, trim everything after it
        if (cutoffIndex > -1) {
            // Ensure we capture AM or PM and nothing more
            cleanTime = originalTime.substring(0, cutoffIndex + 2).trim();
            
            // Ensure proper formatting with leading zero if needed
            if (cleanTime.length() == 7) {  // 9:00 AM format
                cleanTime = '0' + cleanTime;
            } 
        }
        return cleanTime;
    }
    
    // Combine Date and Time into DateTime
    private static DateTime combineDateTime(Date eventDate, String timeString) {
        if (eventDate == null || String.isBlank(timeString)) return null;
        
        // Parse time using the new method
        Time eventTime = parseTimeString(timeString);
        
        // Combine Date and Time
        return Datetime.newInstance(
            eventDate.year(), 
            eventDate.month(), 
            eventDate.day(), 
            eventTime.hour(), 
            eventTime.minute(), 
            0
        );
    }    

    private static Time parseTimeString(String timeString) {
        if (String.isBlank(timeString)) return null;
        
        // Clean and normalize the time string
        String cleanTime = cleanTimeFormat(timeString);
        
        // Split the time into components
        String[] timeParts = cleanTime.split('\\s+');
        if (timeParts.size() != 2) return null;
        
        // Parse hours and minutes
        String[] hourMinute = timeParts[0].split(':');
        Integer hours = Integer.valueOf(hourMinute[0]);
        Integer minutes = Integer.valueOf(hourMinute[1]);
        
        // Handle AM/PM
        if (timeParts[1].equalsIgnoreCase('PM') && hours != 12) {
            hours += 12;
        } else if (timeParts[1].equalsIgnoreCase('AM') && hours == 12) {
            hours = 0;
        }
        
        // Create and return Time instance
        return Time.newInstance(hours, minutes, 0, 0);
    }
}

    //     //Create a list for Events that we will insert. (Calendar Events). 
    //     List<Event> eventsToAdd = new List<Event>();

    //     // Collect Training Event Ids only if it's after update
    //     Map<Id, Integer> trainingEventToEventCount = new Map<Id, Integer>();
        
    //     // Query existing Events for provided Training Events
    //     for (AggregateResult ar : [SELECT WhatId, COUNT(Id) eventCount FROM Event WHERE WhatId IN :trainingEventIds GROUP BY WhatId]) {
    //         trainingEventToEventCount.put((Id)ar.get('WhatId'), (Integer)ar.get('eventCount'));
    //     }
        
    //     // Retrieve the RecordTypeId for 'Standard_Web' (Developer Name, Record Type). 
    //     String strRecordTypeID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Standard_Web').getRecordTypeId();

    //     //Get the Training Events from the Id's passed in. 
    //     List<Training_Event__c> lstTrainingEvents = [SELECT Id, Name, OwnerId, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c FROM Training_Event__c WHERE Id IN :trainingEventIds];

    //     //Loop on the training events. 
    //     for (Training_Event__c trainingEvent : lstTrainingEvents) {
    //         //Get Existing Calendar Events for the current Training Event. 
    //         Integer existingEventsCount = trainingEventToEventCount.get(trainingEvent.Id) != null ? trainingEventToEventCount.get(trainingEvent.Id) : 0;
            
    //         //If we did not find any, create one. 
    //         if (existingEventsCount == null || existingEventsCount == 0) {

    //             // Get the user's timezone
    //             TimeZone timeZone = UserInfo.getTimeZone();

    //             // Conversion of Start and End Date/Time by trimming any additional text
    //             Datetime startDateTime = convertToUserTimeZone(
    //                 trainingEvent.Start_Date__c, trimTime(trainingEvent.Start_Time__c), timeZone);

    //             Datetime endDateTime = convertToUserTimeZone(
    //                 trainingEvent.End_Date__c, trimTime(trainingEvent.End_Time__c), timeZone);
                
    //             // Create Event record
    //             Event newEvent = new Event(
    //                 OwnerId = trainingEvent.OwnerId,
    //                 RecordTypeId = strRecordTypeID,
    //                 WhatId = trainingEvent.Id,
    //                 ActivityDateTime = startDateTime,
    //                 EndDateTime = endDateTime,
    //                 Subject = trainingEvent.Name
    //             );
    //             eventsToAdd.add(newEvent);
    //         }
    //     }

    //     if (!eventsToAdd.isEmpty()) {
    //         insert eventsToAdd;
    //     }
    // }

    // //Private method to convert the Time to the users timezone when creating the event, or else they get created in GMT Time. 
    // private static Datetime convertToUserTimeZone(Date eventDate, String eventTime, TimeZone timeZone) {
    //     // Parse the time and convert to Datetime using user's timezone
    //     Datetime eventDateTime = getDateTime(eventDate, eventTime);
    //     return eventDateTime.addSeconds(timeZone.getOffset(eventDateTime));
    // }

    // //Private method to put together a real Datetime for the Event. Parses the Training Event Start Time String. 
    // private static Datetime getDateTime(Date eventDate, String eventTime) {
    //     Datetime eventDateTime = null; 
    //     if(eventTime.substring(0, 2).contains(':')){
    //         // Parse the time and convert to Datetime
    //         eventDateTime = DateTime.newInstanceGmt(eventDate.year(), eventDate.month(), 
    //         eventDate.day(), 
    //         Integer.valueOf(eventTime.substring(0, 1)), 
    //         Integer.valueOf(eventTime.substring(2, 4)), 
    //         0);
    //         // Adjust for AM/PM
    //         if (eventTime.contains('PM') && Integer.valueOf(eventTime.substring(0, 1)) < 12) {
    //             eventDateTime = eventDateTime.addHours(12);
    //         }
    //     }
    //     else{
    //         // Parse the time and convert to Datetime
    //         eventDateTime = DateTime.newInstanceGmt(eventDate.year(), eventDate.month(), 
    //         eventDate.day(), 
    //         Integer.valueOf(eventTime.substring(0, 2)), 
    //         Integer.valueOf(eventTime.substring(3, 5)), 
    //         0);
    //         // Adjust for AM/PM
    //         if (eventTime.contains('PM') && Integer.valueOf(eventTime.substring(0, 2)) < 12) {
    //             eventDateTime = eventDateTime.addHours(12);
    //         } else if (eventTime.contains('AM') && Integer.valueOf(eventTime.substring(0, 2)) == 12) {
    //             eventDateTime = eventDateTime.addHours(-12);
    //         }
    //     }
        
    //     return eventDateTime;
    // }

    // //Private method to trimTime. Uses regex to clean the Start Time and End Time fields, 
    // //returning the time without any timezone or extra text the user may have added. 
    // private static String trimTime(String eventTime) {
    //     // Trim to only obtain time without extra timezone info
    //     String trimmedTime = eventTime.replaceAll('[^0-9:AMPamp ]', '').trim();
    //     // Ensure it excludes any additional text after AM/PM
    //     trimmedTime = trimmedTime.substring(0, trimmedTime.indexOf('M') + 1);
    //     return trimmedTime;
    // }
// }
