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
    public static String cleanTimeFormat(String originalTime) {
        // Trim whitespace
        originalTime = originalTime.trim();

        // Normalize the string by adding a space before AM/PM if missing
        originalTime = normalizeTimeFormat(originalTime);
        
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
        String cleanTime = ''; 
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
    
    //Private method to help normalize the time string. 9:00AM should be 9:00 AM (with space)
    private static String normalizeTimeFormat(String timeString) {
        // Remove any existing spaces around AM/PM
        timeString = timeString.replaceAll('\\s*AM\\s*', ' AM')
                                .replaceAll('\\s*PM\\s*', ' PM');
        
        // Add space before AM/PM if missing
        if (timeString.contains('AM') && !timeString.contains(' AM')) {
            timeString = timeString.replace('AM', ' AM');
        }
        if (timeString.contains('PM') && !timeString.contains(' PM')) {
            timeString = timeString.replace('PM', ' PM');
        }
        
        return timeString;
    }

    //Private method to parse the time string into hours and minutes and adjusting for AM PM. 
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
}