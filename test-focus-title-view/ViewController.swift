//
//  ViewController.swift
//  test-focus-title-view
//
//  Created by Ryan Zulkoski on 3/1/19.
//  Copyright © 2019 Ryan Zulkoski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
        label.text = "Page \(navigationController?.viewControllers.count ?? 0)"
        label.accessibilityTraits = .header
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
        UIAccessibility.post(notification: .screenChanged, argument: navigationItem.titleView)
    }

    private func setupNavigationItem() {
        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItems = [leftButton]
        }
        navigationItem.rightBarButtonItems = [rightButton]

        switch titleViewStyle {
        case .some(.stackView):
            stackView.addArrangedSubview(label)
            stackView.accessibilityLabel = label.text
            navigationItem.titleView = stackView
        default:
            navigationItem.titleView = label
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
