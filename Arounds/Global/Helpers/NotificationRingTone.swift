//
//  NotificationRingTone.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/7/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

struct NotificationRingTone: Equatable {
    
    let title: String
    let filename: String
    
    init(title: String, filename: String) {
        self.title = title
        self.filename = filename
    }
    
    init?(filename: String) {
        guard let ringtone = NotificationRingTone.all.first(where: {$0.filename == filename}) else {
            return nil
        }
        
        self.init(title: ringtone.title, filename: ringtone.filename)
    }
    
    static func ==(lhs: NotificationRingTone, rhs: NotificationRingTone) -> Bool {
        return lhs.title == rhs.title && lhs.filename == rhs.filename
    }
}

extension NotificationRingTone {
    
    static var all: [NotificationRingTone] = [
        NotificationRingTone(title: "Appointed", filename: "ring0.mp3"),
        NotificationRingTone(title: "Here I am", filename: "ring1.mp3"),
        NotificationRingTone(title: "End point reached", filename: "ring2.mp3"),
        NotificationRingTone(title: "Cooked", filename: "ring3.mp3"),
        NotificationRingTone(title: "Chime", filename: "ring4.mp3"),
        NotificationRingTone(title: "You've been informed", filename: "ring5.mp3"),
        NotificationRingTone(title: "Rise and Shine1", filename: "ring6.mp3"),
        NotificationRingTone(title: "Confident", filename: "ring7.mp3"),
        NotificationRingTone(title: "Not bad", filename: "ring8.mp3"),
        NotificationRingTone(title: "Rise and Shine2", filename: "ring9.mp3"),
        NotificationRingTone(title: "Case Closed", filename: "ring10.mp3"),
        NotificationRingTone(title: "Capisci", filename: "ring11.mp3"),
        NotificationRingTone(title: "Graceful", filename: "ring12.mp3"),
        NotificationRingTone(title: "Filling your inbox", filename: "ring13.mp3")
    ]
    
    static var `default`: NotificationRingTone {
        return all[1]
    }
}
