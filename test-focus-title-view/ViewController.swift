//
//  ViewController.swift
//  test-focus-title-view
//
//  Created by Ryan Zulkoski on 3/1/19.
//  Copyright © 2019 Ryan Zulkoski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var myElt: UIAccessibilityElement?
    
    private lazy var leftButton: UIBarButtonItem = {
        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        return leftButton
    }()
    
    private lazy var rightButton: UIBarButtonItem = {
        let rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        return rightButton
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.isAccessibilityElement = true
        return stackView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        //        label.accessibilityTraits = .header
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var label2: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 10)
        //        label.accessibilityTraits = .header
        label.isAccessibilityElement = false
        return label
    }()
    
    enum TitleViewStyle {
        case label
        case stackView
    }
    
    private var titleViewStyle: TitleViewStyle?
    
    class func fromStoryboard(with titleViewStyle: TitleViewStyle) -> ViewController {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
            fatalError()
        }
        vc.titleViewStyle = titleViewStyle
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set VoiceOver focus to title view when screen appears
        UIAccessibility.post(notification: .screenChanged,
                             argument: navigationItem.titleView)
    }
    
    private func setupNavigationItem() {
        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItems = [leftButton]
        }
        navigationItem.rightBarButtonItems = [rightButton]
        
        let subtitle = "Page \(navigationController?.viewControllers.count ?? 0)"
        
        switch titleViewStyle {
        case .some(.label):
            let title = "UILabel"
            let attrText = NSMutableAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: 15)])
            attrText.append(NSAttributedString(string: "\n"))
            attrText.append(NSAttributedString(string: subtitle, attributes: [.font: UIFont.systemFont(ofSize: 10)]))
            label.attributedText = attrText
            label.isAccessibilityElement = true
            label.accessibilityTraits = .header
            label.accessibilityLabel = title.appending(", \(subtitle)")
            navigationItem.titleView = label
        default:
            label.isAccessibilityElement = false
            label.text = "UIStackView"
            label.sizeToFit()
            label2.text = subtitle
            label2.sizeToFit()
            let maxWidth = (label.frame.width > label2.frame.width) ? label.frame.width : label2.frame.width
            let maxHeight = label.frame.height + label2.frame.height
            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(label2)
            //            stackView.accessibilityLabel = label.text?.appending(", \(label2.text!)")
            navigationItem.titleView = stackView
            
            if let navigationBarView = navigationController?.navigationBar {
                
                let centerPoint = navigationBarView.center
                
                let newViewRect = CGRect.init(x: centerPoint.x - (maxWidth / 2.0),
                                              y: centerPoint.y - (maxHeight / 2.0),
                                              width: maxWidth,
                                              height: maxHeight)
                let newView = UIView.init(frame: newViewRect)
                self.view.addSubview(newView)
                
                myElt = UIAccessibilityElement(accessibilityContainer: newView)
                myElt?.accessibilityFrameInContainerSpace = CGRect.init(x: 0.0,
                                                                        y: 0.0,
                                                                        width: maxWidth,
                                                                        height: maxHeight)
                myElt?.accessibilityTraits = .header
                myElt?.accessibilityLabel = label.text?.appending(", \(label2.text!)")
                
                if let myElt = myElt {
                    navigationItem.titleView!.accessibilityElements = [myElt]
                }
            }
        }
    }
    
    @IBAction private func didTapPushLabelButton() {
        pushViewController(with: .label)
    }
    
    @IBAction private func didTapPushStackViewButton() {
        pushViewController(with: .stackView)
    }
    
    private func pushViewController(with titleViewStyle: TitleViewStyle) {
        let vc = ViewController.fromStoryboard(with: titleViewStyle)
        navigationController?.pushViewController(vc, animated: true)
    }
}
