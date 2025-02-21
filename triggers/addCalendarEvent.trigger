trigger addCalendarEvent on Training_Event__c (after insert, after update) {
// List<Event> arrNewEvents = new List<Event> ();
// List<Event> arrUpdatedEvents = new List<Event> ();

// if (Trigger.isInsert)
// {
// for (Training_Event__c currentEvent : Trigger.new)
// {
// String[] arrStartTimeElements = currentEvent.Start_Time__c.split(' ',0);
// String strStartAMPM = arrStartTimeElements[1];
// String[] strStartTime = arrStartTimeElements[0].split(':',0);
// Integer startTimeHour = ((strStartAMPM == 'AM' || (strStartTime[0] == '12' && strStartAMPM == 'PM')) ? 0 : 12) + Integer.valueOf(strStartTime[0]);
// Integer startTimeMinutes = Integer.valueOf(strStartTime[1]);
// Integer startTimeSeconds = 0;
// Date startDate = currentEvent.Start_Date__c;
// System.debug('startDate: '+startDate);

// String[] arrEndTimeElements = currentEvent.End_Time__c.split(' ',0);
// String strEndAMPM = arrEndTimeElements[1]; 
// String[] strEndTime = arrEndTimeElements[0].split(':',0);
// Integer endTimeHour = ((strEndAMPM == 'AM' || (strEndTime[0] == '12' && strEndAMPM == 'PM')) ? 0 : 12) + Integer.valueOf(strEndTime[0]);
// Integer endTimeMinutes = Integer.valueOf(strEndTime[1]);
// Integer endTimeSeconds = 0;
// Date endDate = currentEvent.End_Date__c;
// System.debug('endDate: '+endDate);

// Datetime eventStartTime = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day(), startTimeHour,startTimeMinutes,startTimeSeconds);
// Datetime eventEndTime = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), endTimeHour,endTimeMinutes,endTimeSeconds);
// Event newEvent = new Event(OwnerId=currentEvent.OwnerId,RecordTypeId='01230000000RAaM',WhatId=currentEvent.Id,ActivityDateTime=eventStartTime,EndDateTime=eventEndTime, Subject=currentEvent.Name);
// arrNewEvents.add(newEvent);
// }
// }
// else
// {
// List<Event> arrEvents = [Select Id, OwnerId,WhatId from Event where WhatId in :Trigger.newMap.keySet()];
// for (Integer event = 0; event < Trigger.new.size(); event++)
// {
// 	for (Event evt : arrEvents)
// 		{
// 			if (evt.WhatId == Trigger.new[event].Id)
// 				{
// 					String[] arrStartTimeElements = Trigger.new[event].Start_Time__c.split(' ',0);
// 					String strStartAMPM = arrStartTimeElements[1];
// 					String[] strStartTime = arrStartTimeElements[0].split(':',0);
// 					Integer startTimeHour = ((strStartAMPM == 'AM' || (strStartTime[0] == '12' && strStartAMPM == 'PM')) ? 0 : 12) + Integer.valueOf(strStartTime[0]);
// 					Integer startTimeMinutes = Integer.valueOf(strStartTime[1]);
// 					Integer startTimeSeconds = 0;
// 					Date startDate = Trigger.new[event].Start_Date__c;
// 					System.debug('startDate: '+startDate);

// 					String[] arrEndTimeElements = Trigger.new[event].End_Time__c.split(' ',0);
// 					String strEndAMPM = arrEndTimeElements[1];
// 					String[] strEndTime = arrEndTimeElements[0].split(':',0);
// 					Integer endTimeHour = ((strEndAMPM == 'AM' || (strEndTime[0] == '12' && strEndAMPM == 'PM')) ? 0 : 12) + Integer.valueOf(strEndTime[0]);
// 					Integer endTimeMinutes = Integer.valueOf(strEndTime[1]);
// 					Integer endTimeSeconds = 0;
// 					Date endDate = Trigger.new[event].End_Date__c;
// 					System.debug('endDate: '+endDate);

// 					Datetime eventStartTime = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day(), startTimeHour,startTimeMinutes,startTimeSeconds);
// 					Datetime eventEndTime = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), endTimeHour,endTimeMinutes,endTimeSeconds);
					
// 					evt.ActivityDateTime = eventStartTime;
// 					evt.EndDateTime = eventEndTime;
// 					if (Trigger.new[event].OwnerId != Trigger.old[event].OwnerId)
// 					{
// 					evt.OwnerId = Trigger.new[event].OwnerId;
// 					}
// 					arrUpdatedEvents.add(evt); 
// 				}
// 		}
// 	}
// }
// if (arrNewEvents.size() != 0)
//     insert arrNewEvents;
// if (arrUpdatedEvents.size() != 0)
//     update arrUpdatedEvents;
}