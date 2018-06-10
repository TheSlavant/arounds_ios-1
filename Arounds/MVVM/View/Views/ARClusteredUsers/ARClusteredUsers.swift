//
//  ARClusteredUsers.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/26/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import RangeSeekSlider
import UIKit

fileprivate let cellIdent = "usersCell"
class ARClusteredUsers: UIView {
    var users = [ARUser]() {
        didSet {
            finteredUser = users
        }
    }
    var finteredUser = [ARUser]()
    var vc: UIViewController?
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var countOfUsers: UILabel!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ageFilterSlider: RangeSeekSlider!
    
    class func loadFromNib() -> ARClusteredUsers {
        let sharedView = UINib.init(nibName: "ARClusteredUsers", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ARClusteredUsers
        sharedView.frame = UIScreen.main.bounds
        
        sharedView.tableView.register(UINib(nibName: "ARClusteredUsersCell", bundle: nil), forCellReuseIdentifier: cellIdent)
        sharedView.tableView.delegate = sharedView
        sharedView.tableView.dataSource = sharedView
        sharedView.tableView.rowHeight = UITableViewAutomaticDimension
        sharedView.tableView.estimatedRowHeight = 100
        
        sharedView.setSelected(button: sharedView.maleButton)
        sharedView.setSelected(button: sharedView.femaleButton)
        sharedView.ageFilterSlider.delegate = sharedView
        
        return sharedView
    }
    
    func show(with newUsers: [ARUser], onVC:UIViewController) {
        self.users = newUsers
        onVC.view.addSubview(self)
        self.vc = onVC
        tableView.reloadData()
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @IBAction func didClickFIlter(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.filterViewHeightConstraint.constant = sender.isSelected ? 140 : 0
            self?.layoutIfNeeded()
        }
        if sender.isSelected {
            filterUser()
        } else {
            finteredUser = users
        }
        tableView.reloadData()
    }
    
    @IBAction func maleButtonClick(_ sender: UIButton) {
        if sender.isSelected {
            if femaleButton.isSelected == false {return}
            setDeselected(button: sender)
        } else {
            setSelected(button: sender)
        }
        filterUser()
        tableView.reloadData()
        
    }
    
    @IBAction func femaleButtonClick(_ sender: UIButton) {
        if sender.isSelected {
            if maleButton.isSelected == false {return}
            setDeselected(button: sender)
        } else {
            setSelected(button: sender)
        }
        filterUser()
        tableView.reloadData()
    }
    
    func filterUser() {
        finteredUser = users.filter({ [weak self] (user) -> Bool in
            
            if user.id == ARUser.currentUser?.id ?? "" {
                return false
            }
            
            // filter by gender
            if (femaleButton.isSelected == false && user.gender == .female) ||
                (maleButton.isSelected == false && user.gender == .male)
            {
                return false
            }
            //
            // filter by age
            
            let components = Calendar.current.dateComponents([.year], from: user.birtDay ?? Date(), to: Date())
            if components.year ?? 0 < Int(self?.ageFilterSlider.selectedMinValue ?? 0) ||
                components.year ?? 0 > Int(self?.ageFilterSlider.selectedMaxValue ?? 0) {
                return false
            }
            //
            return true
        })
        //        tableView.reloadData()
    }
    
    
    func setSelected(button:UIButton) {
        button.isSelected = true
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    func setDeselected(button:UIButton) {
        button.isSelected = false
        button.backgroundColor = UIColor.clear
    }
    
}

extension ARClusteredUsers: RangeSeekSliderDelegate {
    
    func didEndTouches(in slider: RangeSeekSlider) {
        filterUser()
        tableView.reloadData()
    }
    
}

extension ARClusteredUsers: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellHeight: CGFloat = 100
        tableView.contentSize.height = cellHeight * CGFloat(finteredUser.count)
        countOfUsers.text = "\(finteredUser.count) человек"
        return finteredUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdent, for: indexPath) as! ARClusteredUsersCell
        cell.user = self.finteredUser[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = finteredUser[indexPath.row]
        let vc = ProfileVC.instantiate(from: .Profile)
        vc.viewModel = OtherProfileViewModel.init(with: user)
        self.vc?.navigationController?.pushViewController(vc, animated: true)
    }
}




