//
//  Created by Samvel Pahlevanyan on 5/17/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import TTRangeSlider
import NotificationCenter
import Firebase
import IQKeyboardManagerSwift
import SVProgressHUD
import UIKit

class ARMakeRadarChat: UIView {
    
    @IBOutlet weak var maleView: ARBorderedButton!
    @IBOutlet weak var felmaleView: ARBorderedButton!
    @IBOutlet weak var rangeSlider: TTRangeSlider!
    @IBOutlet weak var femaleImage: UIImageView!
    @IBOutlet weak var shadowButton: UIImageView!
    @IBOutlet weak var maleImage: UIImageView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sendButton: ARGradientedButton!
    @IBOutlet weak var textView: ARTextView!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var distanceSlider: ARDistanceSlider!
    @IBOutlet weak var foundPersonCountLabel: UILabel!
    //    var didCloseSadarChat:((ARUserFilter)-> Void)?
    
    var currentFilter: ARUserFilter!
    var mapViewModel: MapViewModeling?
    
    var users = [ARUser]() {
        didSet {
            updateUI()
        }
    }
    
    class func loadFromNib(filter: ARUserFilter, mapViewModel: MapViewModeling = MapViewModel()) -> ARMakeRadarChat {

// ) -> ARMakeRadarChat {
        let sharedView = UINib.init(nibName: "ARMakeRadarChat", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ARMakeRadarChat
        
        sharedView.currentFilter = filter
        sharedView.update(by: sharedView.currentFilter)
        sharedView.frame = UIScreen.main.bounds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sharedView.distanceSlider.selectedDistance = CGFloat(filter.distance)
        }
        sharedView.setSelected(button: sharedView.maleButton)
        sharedView.setSelected(button: sharedView.femaleButton)
        sharedView.mapViewModel = mapViewModel
        sharedView.sendButton.isEnabled = true
        sharedView.setDeselected(button: sharedView.maleButton)
        sharedView.setDeselected(button: sharedView.femaleButton)
        sharedView.rangeSlider.handleImage = #imageLiteral(resourceName: "circle")
        sharedView.rangeSlider.handleDiameter = 10
        sharedView.rangeSlider.delegate = sharedView
        return sharedView
    }
    
    
    func update(by filter: ARUserFilter)  {
        rangeSlider.selectedMaximum = Float(filter.ageEnd)
        rangeSlider.selectedMinimum = Float(filter.ageStart)
    }
    
    func listener() {
        distanceSlider.didEndSlide = { [weak self] value in
            self?.currentFilter.distance = Int(value)
            self?.getUsers()
        }
    }
    
    func show() {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(self)
            listener()
            //            getUsers()
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
            textView.didClickText = { text in
                self.sendButtonEnabled(text: text, users: self.users)
            }
            textView.didClickText?(textView.textView.text)
        }
    }
    
    
    func sendButtonEnabled(text: String, users: [ARUser]) {
        self.sendButton.isEnabled = (!text.isEmpty && users.count > 0)
        self.sendButton.startColor = UIColor.withHex((!text.isEmpty && users.count > 0) == true ? "FF3FB4" : "88889C" )
        self.sendButton.endColor = UIColor.withHex((!text.isEmpty && users.count > 0) == true ? "F35119" : "88889C" )
        shadowButton.isHidden = !self.sendButton.isEnabled
        
        
    }
    
    var keyboardIsOpened = false
    @objc func keyboardDidShow(notification: NSNotification) {
        if keyboardIsOpened == true {return}
        keyboardIsOpened = true
        UIView.animate(withDuration: 0.2) {
            self.bottomConstraint.constant = 280
            self.layoutIfNeeded()
            
            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        keyboardIsOpened = false
        UIView.animate(withDuration: 0.2) {
            self.bottomConstraint.constant = -5
            self.layoutIfNeeded()
        }
    }
    
    func close() {
//        didCloseSadarChat?(currentFilter)
        removeFromSuperview()
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        close()
    }
    
    @IBAction func maleButtonClick(_ sender: UIButton) {
        if sender.isSelected {
            if femaleButton.isSelected == false {return}
            setDeselected(button: sender)
            felmaleView.borderColor = UIColor.withHex("EDECEE")
        } else {
            setSelected(button: sender)
            felmaleView.borderColor = .clear
        }
        currentFilter.male = sender.isSelected
        getUsers()
        
    }
    
    @IBAction func femaleButtonClick(_ sender: UIButton) {
        if sender.isSelected {
            if maleButton.isSelected == false {return}
            setDeselected(button: sender)
            maleView.borderColor = UIColor.withHex("EDECEE")
        } else {
            setSelected(button: sender)
            maleView.borderColor = .clear
        }
        currentFilter.female = sender.isSelected
        getUsers()
    }
    
    @IBAction func sendChat(_ sender: UIButton) {
        
        if textView.textView.text.count == 0 {
            return
        }
        SVProgressHUD.show()
        Database.database().reference().child("radar_messages").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(), let dict = snapshot.value as? [String: [String: Any]] {
                let filtered = dict.filter({ (obj) -> Bool in
                    return (obj.value["senderID"] as? String) ?? "" == ARUser.currentUser?.id ?? ""
                })
                let mepped = filtered.map({Date(timeIntervalSince1970: ($0.value["timestamp"] as? Double ?? 0) / 1000)})
                if let date =  mepped.sorted(by: {$0 > $1}).first {
                    if Date().interval(ofComponent: .day, fromDate: date) == 0 {
                        let alert = UIAlertController(title: "Увы, но пока ты можешь отправлять в Радар только одно сообщение в день", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction.init(title: "Ясно-понятно", style: .cancel, handler: nil))
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                        SVProgressHUD.dismiss()
                        self.close()
                        return
                    } else {
//                        self.send()
                    }
                } else {
                    self.send()
                }
            } else {
                self.send()
            }
        }
    }
    
    func send() {
        Database.RadarMessage.send(senderID: ARUser.currentUser?.id ?? "", participents: users.map({$0.id ?? ""}), text: self.textView.textView.text)
      
        users.forEach { (user) in
       
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                if let DCS = user.DCS {
                    PushNotification.sharedInstance.sendNotificationWithBadge(reciverToken: DCS, body: self.textView.textView.text, title: "Радар:" )
                }
            })
            
        }
        
        SVProgressHUD.dismiss()
//        self.textView.clear()
        self.textView.textView.resignFirstResponder()
        showAlert("Отправлено")
        self.close()
    }
    
    func setSelected(button:UIButton) {
        button.isSelected = true
        button.backgroundColor = UIColor.withHex("F94865")
        button.tintColor = .white
        
        //        femaleImage.tintColor = .white
        //        maleImage.tintColor = .white
        
    }
    
    func setDeselected(button:UIButton) {
        button.isSelected = false
        button.backgroundColor = .white
        button.tintColor = .gray
        //        femaleImage.tintColor = .gray
        //        maleImage.tintColor = .gray
    }
    
    func updateUI() {
        if foundPersonCountLabel != nil {
            print(users.map({$0.id}))
            foundPersonCountLabel.text = users.count > 99 ? "99+" : "\(users.count)"
        }
    }
    
    func getUsers() {
        SVProgressHUD.show()
        mapViewModel?.getUsers(by: currentFilter, completion: {[weak self] (users) in
            SVProgressHUD.dismiss(completion: {
              
                //
                let rangeDate = Calendar.current.date(byAdding: .minute, value: -5, to: Date()) ?? Date()
                let onlineUsers = users.filter({ (obj) -> Bool in
                    return obj.lastOnlone ?? Date() > rangeDate
                })
                //

                self?.users = onlineUsers.filter({$0.id != ARUser.currentUser?.id ?? ""})

                self?.sendButtonEnabled(text: self?.textView.textView.text ?? "", users: self?.users ?? [ARUser]())
            })
        })
    }
    
    
}

extension Date {
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
}

extension ARMakeRadarChat: TTRangeSliderDelegate {
    
    func didEndTouches(in sender: TTRangeSlider!) {
        
        currentFilter.ageStart = Int(sender.selectedMinimum)
        currentFilter.ageEnd = Int(sender.selectedMaximum)
        getUsers()
        
    }
}


