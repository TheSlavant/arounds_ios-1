//
//  ChatSoudEffects.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/7/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import AVFoundation

enum ChatSoudEffect: String {
    case sendMessage = "send-message.mp3"
    case receiveMessage = "receive-message.mp3"
}

final class ChatSoudEffectsPlayer {
    
    private var audioPlayer: AVAudioPlayer?
    
    static let shared = ChatSoudEffectsPlayer()
    
    private init(){}
    
    func play(effect: ChatSoudEffect) {
        
        guard let soundURL = Bundle.main.url(forResource: effect.rawValue, withExtension: nil) else {
            return
        }
        
        var mySound: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
        AudioServicesPlaySystemSound(mySound);
    }
}


