//
//  MessageVoiceView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import SVProgressHUD
import AVFoundation

enum MessageVoicePlayerState {
    case playing
    case paused
    case stopped
}

final class MessageVoiceView: UIView {

    @IBOutlet weak var backgroundImageView: UIImageView!

    @IBOutlet weak var outgoingMessageStatusStackView: UIStackView!
    @IBOutlet weak var outgoingMessageTimeLabel: UILabel!
    @IBOutlet weak var outgoingMessageStatusImageView: UIImageView!

    @IBOutlet weak var proggressIndicatorViewLeadingCostraint: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressIndicatorView: UIView!
    @IBOutlet weak var progressViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var playPauseImageLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var playPauseImage: UIImageView!
    @IBOutlet weak var incommingMessageTimeLabel: UILabel!

    @IBOutlet weak var playedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var data: Data? {
        didSet {
            audioPlayer?.stop()
            if let data = self.data {
                
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
                self.audioPlayer = try? AVAudioPlayer(data: data)
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.delegate = self
                updateProgress()
            }
        }
    }
    
    var dontIterruptUntilEnd = false
    
    var url: URL? {
        didSet {
            guard !dontIterruptUntilEnd else {
                return
            }
            
            guard let url = self.url else {
                self.state = .stopped
                return
            }
            
            if oldValue == nil || oldValue != url {
                self.state = .stopped
            }
        }
    }
    
    func onClickOnCell() {
        switch self.state {
        case .paused, .stopped:
            self.state = .playing
        case .playing:
            self.state = .paused
        }
    }
    
    func stop() {
        self.state = .stopped
    }

    fileprivate(set) var state: MessageVoicePlayerState = .stopped {
        didSet {
            if state != oldValue {
                updateView(with: state)
            }
        }
    }

    private func updateView(with state:MessageVoicePlayerState) {
        switch state {
        case .paused:
            self.playedTimeLabel.isHidden = false
            self.remainingTimeLabel.isHidden = false
            self.playPauseImage.image = #imageLiteral(resourceName: "audio-message-play")
            self.audioPlayer?.pause()
            self.timer?.invalidate()
        case .playing:
            self.playedTimeLabel.isHidden = false
            self.remainingTimeLabel.isHidden = false
            self.playPauseImage.image = #imageLiteral(resourceName: "audio-message-pause")
            if data == nil {
                loadAndPlayAudio()
            } else {
                self.audioPlayer?.play()
                updateProgress()
            }
        case .stopped:
            self.playedTimeLabel.isHidden = true
            self.remainingTimeLabel.isHidden = true
            self.playedTimeLabel.text = nil
            self.remainingTimeLabel.text = nil
            self.playPauseImage.image = #imageLiteral(resourceName: "audio-message-play")
            self.proggressIndicatorViewLeadingCostraint.constant = 0
            self.audioPlayer?.stop()
            self.data = nil
            self.timer?.invalidate()
            self.dontIterruptUntilEnd = false
        }
    }
    
    fileprivate func resetToTheBeginnig() {
        self.state = .paused
        self.proggressIndicatorViewLeadingCostraint.constant = 0
        self.playedTimeLabel.isHidden = true
        self.remainingTimeLabel.isHidden = true
    }
    
    private func updateProgress() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { (timer) in
            let duration = self.audioPlayer?.duration ?? 0.0
            let currentTime = self.audioPlayer?.currentTime ?? 0.0
            let remainingTime = duration - currentTime
            self.proggressIndicatorViewLeadingCostraint.constant = (self.progressView.frame.width * CGFloat(currentTime)) / CGFloat(duration)
            self.playedTimeLabel.text = self.getFormattedTime(time: Int(currentTime))
            self.remainingTimeLabel.text = self.getFormattedTime(time: Int(remainingTime))
        })
    }
    
    private func getFormattedTime(time: Int) -> String {
        let minutes = time/60
        let seconds = time - minutes * 60
        
       return NSString(format: "%02d:%02d", minutes,seconds) as String
    }
    
    fileprivate func loadAndPlayAudio() {
        guard let vc = UIApplication.shared.windows.first,
              let url = self.url else {
            return
        }
        
        SVProgressHUD.show()
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
//            guard let receivedData = data,
//                let decryptedData = RSA.shared.decrypt(data: receivedData) ?? data else {
//                    SVProgressHUD.dismiss()
//                    return
//            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                if self.state == .playing {
//                    self.data = decryptedData
                    self.audioPlayer?.play()
                }

                SVProgressHUD.dismiss()
            })

        }).resume()
    }
    
    deinit {
        stop()
    }
}

extension MessageVoiceView: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        resetToTheBeginnig()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let vc = UIApplication.shared.windows.first {
            SVProgressHUD.dismiss()
        }
    }
    
}
