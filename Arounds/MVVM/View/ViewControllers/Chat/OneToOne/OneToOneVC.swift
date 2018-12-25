//
//  OneToOneVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase
import Foundation

class OneToOneVC: BaseChatViewController {
    
    fileprivate var oneToOneViewModel: OneToOneViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listeners()

    }
    
    deinit {
        DispatchQueue.main.async {[weak self] in
            self?.dismiss(animated: true, completion: nil)
            self?.navigationView.removeFromSuperview()
            self?.acceptedView.removeAllSubviews()
        }
        Database.database().reference().child("chat-accept").removeAllObservers()
    }
    
    override func setViewModel<T>(_ viewModel: T) where T: OneToOneViewModel {
        super.setViewModel(viewModel)
        
        self.oneToOneViewModel = viewModel
    }
    
    func listeners() {
        
        // did click audio
        self.navigationView.didClickAudio = { sender in
            
        }
        
        // did click video
        self.navigationView.didClickVideo = { sender in
            
        }
        
        // did click back
        self.navigationView.didClickBack = { sender in
            DispatchQueue.main.async {[weak self] in
                self?.dismiss(animated: true, completion: nil)
                self?.navigationView.removeFromSuperview()
                self?.acceptedView.removeAllSubviews()
            }
        }
        
        Database.database().reference().child("chat-accept").observe(.value) {[weak self] (snapshot) in
            
            if snapshot.exists(),
                let dict = snapshot.value as? [String: [String : Any]],
                let filtered = dict.filter({($0.value["chatID"] as? String ?? "") == self?.viewModel.chat.id}).first {
                let a = ARChatAccept.init(dict: [filtered.key: filtered.value])
                if a.myAccept?.accept ?? .panding != .panding {
                    self?.acceptedView.close()
                    self?.collectionView.collectionViewLayout.sectionInset.top = self?.navigationView.frame.height ?? 0
                }
            }
        }
    
        
    }
    
}

// MARK: - Initializer
extension OneToOneVC {
    
    class func create(with chat: ARChat) -> OneToOneVC {
        let viewController: OneToOneVC = OneToOneVC.instantiate(from: .Chat)
        let viewModel = OneToOneViewModel(chat: chat)
        viewModel.delegate = viewController
        viewController.setViewModel(viewModel)
        return viewController
    }
}

extension OneToOneVC {
    
    func open() {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
        }
    }
}


