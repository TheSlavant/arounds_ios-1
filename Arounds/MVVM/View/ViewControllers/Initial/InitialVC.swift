//
//  InitialVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/26/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

enum InitialPage:Int {
    case first
    case secound
    case third
    case fourth
}

fileprivate let initialContent: [InitialPage: [String:String]] = [
    .first: ["title":"Локальные знакомства", "description":"Заводи новые знакомства среди тех кто рядом"],
    .secound: ["title":"Радар", "description":"Обменивайся сообщениями, идеями и лайфхаками с теми, кто тебя окружает"],
    .third: ["title":"События", "description":"Создай эвент, пригласи новых знакомых и оторвитесь вместе!"],
    .fourth: ["title":"Чаты", "description":"Просто и удобно общайся с тем, кто нравится"]]

class InitialVC: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var regButton: ARGradientedButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControlParentView: UIView!
    var pageControl: ARPageControl?
    var currentlyPage:InitialPage = .first

    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl = ARPageControl.loadFromNib(onView: pageControlParentView)
        didSwipe(page: .first)
        // Do any additional setup after loading the view.
    }

    @IBAction func panGesture(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right && currentlyPage != .first {
            self.view.isUserInteractionEnabled = false
            //
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView.contentOffset = CGPoint.init(x: self.scrollView.contentOffset.x - self.scrollView.frame.size.width, y: 0)
//                self.scrollView.setContentOffset()
            }) { (finish) in
                self.view.isUserInteractionEnabled = true
            }
            //
            currentlyPage = InitialPage(rawValue: currentlyPage.rawValue - 1) ?? .first
        } else if sender.direction == .left && currentlyPage != .fourth {
            self.view.isUserInteractionEnabled = false
           //
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView.contentOffset = CGPoint.init(x: self.scrollView.contentOffset.x + self.scrollView.frame.size.width, y: 0)
                //                self.scrollView.setContentOffset()
            }) { (finish) in
                self.view.isUserInteractionEnabled = true
            }
            //
            currentlyPage = InitialPage(rawValue: currentlyPage.rawValue + 1) ?? .fourth
        }
        
        didSwipe(page: currentlyPage)
        
    }
    
    func didSwipe(page: InitialPage) {
        if let dict = initialContent[page] {
            updateScreen(dic: dict)

        }
        pageControl?.selected = page.rawValue
        regButton.isHidden = page != .fourth

    }
    
    func updateScreen(dic: [String:String]) {
        titleLabel.text = dic["title"]
        descriptionLabel.text = dic["description"]
    }


    @IBAction func clickRegButton(_ sender: UIButton) {
    }
    
    
}