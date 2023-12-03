//
//  ViewControllerWithLazySubviews.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-03.
//

import UIKit

class ViewControllerWithLazySubviews: UIViewController, LazyViewContainer {

    // MARK: - Properties

    var lazyViewConfiguration: LazyViewContainerConfiguration {
        .init(
            relations: [
                label.uniqueViewId: .init(superview: .view(stackView), referenceNeighbor: nil),
                textField.uniqueViewId: .init(superview: .view(stackView), referenceNeighbor: .lazyView(label)),
                nestedLazyStack.uniqueViewId: .init(superview: .view(stackView), referenceNeighbor: .lazyView(textField)),
                button1.uniqueViewId: .init(superview: .lazyView(nestedLazyStack), referenceNeighbor: nil),
                button2.uniqueViewId: .init(superview: .lazyView(nestedLazyStack), referenceNeighbor: .lazyView(button1)),
                button3.uniqueViewId: .init(superview: .lazyView(nestedLazyStack), referenceNeighbor: .lazyView(button2)),
                button4.uniqueViewId: .init(superview: .lazyView(nestedLazyStack), referenceNeighbor: .lazyView(button3))
            ]
        )
    }

    private let label: LazyView<UILabel>
    private let textField: LazyView<UITextField>
    private let stackView = UIStackView()
    private let nestedLazyStack: LazyView<UIStackView>
    private let button1: LazyView<UIButton>
    private let button2: LazyView<UIButton>
    private let button3: LazyView<UIButton>
    private let button4: LazyView<UIButton>

    // MARK: - Methods

    init() {

        label = LazyView {
            UILabel()
        }

        textField = LazyView {
            UITextField()
        }

        nestedLazyStack = LazyView {
            UIStackView()
        }

        button1 = LazyView {
            UIButton()
        }

        button2 = LazyView {
            UIButton()
        }

        button3 = LazyView {
            UIButton()
        }

        button4 = LazyView {
            UIButton()
        }

        super.init(nibName: nil, bundle: nil)

        // TODO: Can setting a container can be a part of result builder?

        print("=====")

        label.container = self
        label.postInitHandler = { label in
            print("Label is initialized!")
        }

        textField.container = self
        textField.postInitHandler = { textField in
            print("TextField is initialized!")
        }

        button1.container = self
        button1.postInitHandler = { button in
            button.configuration = .borderedProminent()
            print("Button1 is initialized!")
        }

        button2.container = self
        button2.postInitHandler = { button in
            button.configuration = .borderedProminent()
            print("Button2 is initialized!")
        }

        button3.container = self
        button3.postInitHandler = { button in
            button.configuration = .borderedProminent()
            print("Button3 is initialized!")
        }

        button4.container = self
        button4.postInitHandler = { button in
            button.configuration = .borderedProminent()
            print("Button4 is initialized!")
        }

        nestedLazyStack.container = self
        nestedLazyStack.postInitHandler = { stackView in
            stackView.spacing = 16
            print("Lazy nested stack is initialized!")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with configuration: Configuration) {
        label.configure(on: configuration.showLabel) { label in
            label.text = "Lazy label"
        }

        button1.configure(on: configuration.buttonsCount >= 1) { button in
            button.setTitle("Lazy B1", for: .normal)
        }

        button2.configure(on: configuration.buttonsCount >= 2) { button in
            button.setTitle("Lazy B2", for: .normal)
        }

        button3.configure(on: configuration.buttonsCount >= 3) { button in
            button.setTitle("Lazy B3", for: .normal)
        }

        button4.configure(on: configuration.buttonsCount >= 4) { button in
            button.setTitle("Lazy B4", for: .normal)
        }

        textField.configure(on: configuration.showTextField) { textField in
            textField.placeholder = "Lazy text field"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        stackView.alignment = .center

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

}
