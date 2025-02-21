/*
*********************************************************
Apex Class Name    : Training_Event_Trigger
Created Date       : 02/20/2025
@description       : Main Trigger for the Training Event Object. 
@author            : Troy Center
Modification Log:
Ver     Date        Author                  Case            Modification
1.0     02/20/2025  Troy Center             00390503        Initial Version, Added Training Event Add Calendar Event, from AddCalendarEventTrigger (old)
*********************************************************
*/
trigger Training_Event_Trigger on Training_Event__c (after insert, after update) {
    Boolean isAfterInsert = (Trigger.isAfter && Trigger.isInsert);
    Boolean isAfterUpdate = (Trigger.isAfter && Trigger.isUpdate); 
    
    if(isAfterInsert || isAfterUpdate){
        Training_Event_Add_Calendar_Event addCalendarEvent = new Training_Event_Add_Calendar_Event(Trigger.new);
    }
}