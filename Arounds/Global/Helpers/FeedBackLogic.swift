//
//  FeedBackLogic.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 8/7/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

fileprivate let feedBack_like = "k_feedBack_like"
fileprivate let feedBack_message = "k_feedBack_message"
fileprivate let feedBack_radar_message = "k_feedBack_radar_message"
fileprivate let feedBack_login_count = "k_feedBack_login_count"
fileprivate let feedBack_last_login_date = "k_feedBack_last_login_date"



class FeedBackLogic {
    static var shared = FeedBackLogic()
    
    func likeIsTrue() {
        UserDefaults.standard.set(true, forKey: feedBack_like)
        UserDefaults.standard.synchronize()
        
        if isShowFeedBack() {
            showFeedBack()
        }
    }
    
    func messageIsTrue() {
        UserDefaults.standard.set(true, forKey: feedBack_message)
        UserDefaults.standard.synchronize()
        
        if isShowFeedBack() {
            showFeedBack()
        }
    }
    
    func radarMessageIsTrue() {
        UserDefaults.standard.set(true, forKey: feedBack_radar_message)
        UserDefaults.standard.synchronize()
        
        if isShowFeedBack() {
            showFeedBack()
        }
    }
    
    func lastLogin() {
        var count = UserDefaults.standard.integer(forKey: feedBack_login_count)
        if let lastLoginDateInterval = UserDefaults.standard.value(forKey: feedBack_last_login_date) as? Double {
            let lastDate = Date.init(timeIntervalSince1970: lastLoginDateInterval)
            let inteval = Calendar.current.dateComponents([.day], from: lastDate, to: Date())
            if let day = inteval.day {
                if day > 0 && day <= 3 {
                    count += 1
                } else if day > 3 {
                    count = 0
                }
                
                UserDefaults.standard.set(count, forKey: feedBack_login_count)
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: feedBack_last_login_date)
                UserDefaults.standard.synchronize()
            }
        } else {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: feedBack_last_login_date)
            UserDefaults.standard.synchronize()
            return
        }
        
        if isShowFeedBack() {
            showFeedBack()
        }
    }
    
    private func isShowFeedBack() -> Bool {
        let like = UserDefaults.standard.bool(forKey: feedBack_like)
        let message = UserDefaults.standard.bool(forKey: feedBack_message)
        let radarMessage = UserDefaults.standard.bool(forKey: feedBack_radar_message)
        let count = UserDefaults.standard.integer(forKey: feedBack_login_count)
        return (like == true && message == true && radarMessage == true && count == 3)
    }
    
    func showFeedBack() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            FirstPopup.loadFromNib().show()
            self.reset()
        }
    }
    
    func reset() {
        UserDefaults.standard.set(false, forKey: feedBack_like)
        UserDefaults.standard.set(false, forKey: feedBack_message)
        UserDefaults.standard.set(false, forKey: feedBack_radar_message)
        UserDefaults.standard.set(0, forKey: feedBack_login_count)
        UserDefaults.standard.removeObject(forKey: feedBack_last_login_date)
        UserDefaults.standard.synchronize()
    }
    
}




