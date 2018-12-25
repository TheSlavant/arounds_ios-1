//
//  ProfilListVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import Firebase
import UIKit

fileprivate let cellIdent = "usersCell"

class ProfilListVC: UIViewController {
    var users = [ARUser]()
    
    @IBOutlet weak var searchBar: ARSearch!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ARClusteredUsersCell", bundle: nil), forCellReuseIdentifier: cellIdent)
        showDefoultUsers()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.textField.placeholder = "Поиск по профилям"
        searchBar.textField.delegate = self
    }
    
        override var prefersStatusBarHidden: Bool {
        return false
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension ProfilListVC: UITextFieldDelegate {
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var fullName = (textField.text ?? "").appending(string)
        if string == "" { fullName.removeLast() }
        var firstName: String!
        var lastName: String? = nil
        if fullName == "" {
            showDefoultUsers()
        }
        var components = fullName.components(separatedBy: " ")
        
        if(components.count > 0 && components.count < 4)
        {
            firstName = components[0]
            lastName = nil
            
            if components.count > 1, components[1].count > 0  {
                lastName = components[1]
            }
            
            Database.Search.find(by: firstName, lastName: lastName) {[weak self] (newUsers) in
                DispatchQueue.main.async {
                    if textField.text == "" {
                        self?.users.removeAll()
                    } else {
                        self?.users = newUsers
                    }
                    self?.tableView.reloadData()
                }
            }
            
        } else {
            
            users = [ARUser]()
            tableView.reloadData()
        }
        //        print(a)
        
        return true
    }

    func showDefoultUsers() {
        users = [ARUser]()
        Database.Users.users(by: 10) { (defoultUsers) in
            DispatchQueue.main.async {
                self.users = defoultUsers
                self.tableView.reloadData()
            }
        }
    }
}

extension ProfilListVC: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdent, for: indexPath) as! ARClusteredUsersCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let vc = ProfileVC.instantiate(from: .Profile)
        vc.viewModel = OtherProfileViewModel.init(with: user)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}







