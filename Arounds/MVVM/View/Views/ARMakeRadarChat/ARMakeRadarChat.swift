//
//  ARMakeRadarChat.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/17/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import SVProgressHUD
import RangeSeekSlider
import UIKit

class ARMakeRadarChat: UIView, RangeSeekSliderDelegate {
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var distanceSlider: ARDistanceSlider!
    @IBOutlet weak var ageFilterSlider: RangeSeekSlider!
    @IBOutlet weak var foundPersonCountLabel: UILabel!
    var didCloseSadarChat:((ARUserFilter)-> Void)?

    var currentFilter: ARUserFilter!
    var mapViewModel: MapViewModeling?
   
    var users = [ARUser]() {
        didSet {
            updateUI()
        }
    }
    
    class func loadFromNib(filter: ARUserFilter, mapViewModel: MapViewModeling) -> ARMakeRadarChat {
        let sharedView = UINib.init(nibName: "ARMakeRadarChat", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ARMakeRadarChat
        sharedView.currentFilter = filter
        sharedView.update(by: sharedView.currentFilter)
        sharedView.frame = UIScreen.main.bounds
        sharedView.distanceSlider.selectedDistance = CGFloat(filter.distance)
        sharedView.setSelected(button: sharedView.maleButton)
        sharedView.setSelected(button: sharedView.femaleButton)
        sharedView.mapViewModel = mapViewModel
        sharedView.ageFilterSlider.delegate = sharedView
        return sharedView
    }
    
    func update(by filter: ARUserFilter)  {
        ageFilterSlider.selectedMinValue = CGFloat(filter.ageStart)
        ageFilterSlider.selectedMaxValue = CGFloat(filter.ageEnd)
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
            getUsers()
        }
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        didCloseSadarChat?(currentFilter)
        removeFromSuperview()
    }
    
    @IBAction func maleButtonClick(_ sender: UIButton) {
        if sender.isSelected {
            if femaleButton.isSelected == false {return}
            setDeselected(button: sender)
        } else {
            setSelected(button: sender)
        }
        currentFilter.male = sender.isSelected
        getUsers()

    }
    
    @IBAction func femaleButtonClick(_ sender: UIButton) {
        if sender.isSelected {
            if maleButton.isSelected == false {return}
            setDeselected(button: sender)
        } else {
            setSelected(button: sender)
        }
        currentFilter.female = sender.isSelected
        getUsers()
    }
    
    @IBAction func sendChat(_ sender: UIButton) {

    }

    func setSelected(button:UIButton) {
        button.isSelected = true
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    func setDeselected(button:UIButton) {
        button.isSelected = false
        button.backgroundColor = UIColor.clear
    }

    func updateUI() {
        if foundPersonCountLabel != nil {
            foundPersonCountLabel.text = users.count > 99 ? "99+" : "\(users.count)"
        }
    }
    
    func getUsers() {
        SVProgressHUD.show()
        mapViewModel?.getUsers(by: currentFilter, completion: {[weak self] (users) in
            SVProgressHUD.dismiss(completion: {
                self?.users = users
            })
        })
    }
    
    //MARK: - RangeSeekSliderDelegate
    
    func didEndTouches(in slider: RangeSeekSlider) {
        currentFilter.ageStart = Int(slider.selectedMinValue)
        currentFilter.ageEnd = Int(slider.selectedMaxValue)
        getUsers()
    }
    
}
