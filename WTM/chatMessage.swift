import Foundation

class chatMessage {
    var chatID: String
    var message: String
    var tag: String
    var likes: [String]
    var dislikes: [String]
    var time: Int

    init(chatID: String, message: String, tag: String, likes: [String], dislikes: [String], time: Int) {
        self.chatID = chatID
        self.message = message
        self.tag = tag
        self.likes = likes
        self.dislikes = dislikes
        self.time = time
    }
}
