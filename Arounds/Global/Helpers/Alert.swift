//
//  Alert.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import IQKeyboardManagerSwift
import UIKit

func showAlert(_ message: String, tag: Int = 0, positiveActionTitle: String = "OK", handler:(()->Void)? = nil) {
    if let vc = UIApplication.shared.keyWindow?.topMostController() as? UIAlertController {
        if vc.view.tag == tag {
            return
        }
    }
    
    let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: positiveActionTitle, style: .default) { (action) in
        handler? ()
    }
    
    alert.addAction(okAction)
    alert.view.tag = tag
    
    alert.show()
}

extension UIAlertController {
    
    func show() {
        DispatchQueue.main.async {
            self.present(animated: true, completion: nil)
        }
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController?.topViewController() {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            modalPresentationStyle = .popover
            if let popoverPresentationController = popoverPresentationController {
                popoverPresentationController.sourceView = UIApplication.shared.keyWindow?.rootViewController?.view
            }
            controller.present(self, animated: true, completion: nil)
            return
        }
        
        if  let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else {
            if  let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(controller: selectedVC, animated: animated, completion: completion)
            } else {
                controller.present(self, animated: animated, completion: completion)
            }
        }
    }
}
