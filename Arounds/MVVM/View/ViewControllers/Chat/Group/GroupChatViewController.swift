//
//  GroupChatViewController.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

class GroupChatViewController: BaseChatViewController {
  
    fileprivate var groupViewModel: GroupChatViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setViewModel<T>(_ viewModel: T) where T: GroupChatViewModel {
        super.setViewModel(viewModel)
        
        self.groupViewModel = viewModel
    }


}


// MARK: - Initializer
extension GroupChatViewController {
    
    class func create(with chat: ARChat) -> GroupChatViewController {
        let viewController: GroupChatViewController = GroupChatViewController.instantiate(from: .Chat)
        let viewModel = GroupChatViewModel(chat: chat)
        viewModel.delegate = viewController
        viewController.setViewModel(viewModel)
        return viewController
    }
}
