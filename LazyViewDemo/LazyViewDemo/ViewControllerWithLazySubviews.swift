//
//  ViewControllerWithLazySubviews.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-03.
//

import UIKit
import LazyView

// Conform your UIView or UIViewController to LazyViewContainer
final class ViewControllerWithLazySubviews: UIViewController, LazyViewContainer {

    // MARK: - Properties

    var lazyViewContainerConfiguration: LazyViewContainerConfiguration!

    // Define properties for lazy views
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

        // Initialize lazy views by providing an initializer for the underlying views
        // Note that self is intentionally not referenced at this step

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

        // Initialize container configuration using DSL.
        // Stack view contains label, nestedLazyStack and textField;
        // nestedLazyStack contains buttons.
        // The order is important! Read more in the docs for LazyViewContainerConfiguration

        lazyViewContainerConfiguration = LazyViewContainerConfiguration(container: self) {
            stackView.containing {
                label
                nestedLazyStack.containing {
                    button1
                    button2
                    button3
                    button4
                }
                textField
            }
        }

        print("=====")

        // Use postInitHandler to set up things such as delegates

        textField.postInitHandler = { [weak self] textField in
            guard let self else { return }
            textField.delegate = self
            print("TextField is initialized!")
        }

        label.postInitHandler = { label in
            print("Label is initialized!")
        }

        button1.postInitHandler = { button in
            button.configuration = .borderedProminent()
            print("Button1 is initialized!")
        }

        button2.postInitHandler = { button in
            button.configuration = .borderedProminent()
            print("Button2 is initialized!")
        }

        button3.postInitHandler = { button in
            button.configuration = .borderedProminent()
            print("Button3 is initialized!")
        }

        button4.postInitHandler = { button in
            button.configuration = .borderedProminent()
            print("Button4 is initialized!")
        }

        nestedLazyStack.postInitHandler = { stackView in
            stackView.spacing = 16
            print("Lazy nested stack is initialized!")
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with configuration: Configuration) {

        // Magic happens here 🪄
        // The views are initialized and configured only if the condition is met

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

extension ViewControllerWithLazySubviews: UITextFieldDelegate {}
