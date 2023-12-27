import Foundation

class EventNew {
    var eventKey: String
    var creator: String
    var date: Date
    var description: String
    var name: String
    var time: String
    var isDateCell: Bool // Flag to indicate whether it's a date cell

    init(eventKey: String, creator: String, date: Date, description: String, name: String, time: String, isDateCell: Bool = false) {
        self.eventKey = eventKey
        self.creator = creator
        self.date = date
        self.description = description
        self.name = name
        self.time = time
        self.isDateCell = isDateCell
    }
}
