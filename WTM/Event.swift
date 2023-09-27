import Foundation

var eventsList = [Event]()

class Event
{
    var place: String!
    var name: String!
    var time: Int!
    var endTime: Int!
    var date: Date!
    var description: String!
    var location: String!
    var type: String!
    var creator: String!
    
    func eventsForDate(date: Date) -> [Event]
    {
        var daysEvents = [Event]()
        for event in eventsList
        {
            if(Calendar.current.isDate(event.date, inSameDayAs:date))
            {
                daysEvents.append(event)
            }
        }
        return daysEvents
    }
}
