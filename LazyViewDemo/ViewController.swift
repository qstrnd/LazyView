//
//  ViewController.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-02.
//

import UIKit

struct Configuration {
    var showLabel = true
    var showTextField = true
    var buttonsCount = 1
}

class ViewController: UIViewController {

    var configuration = Configuration()

    @IBOutlet var labelSwitch: UISwitch!
    
    @IBOutlet var buttonSwitch: UISwitch!
    
    @IBOutlet var textFieldSwitch: UISwitch!

    @IBOutlet var buttonsCountSegmentedControl: UISegmentedControl!

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender === labelSwitch {
            configuration.showLabel = sender.isOn
        } else if sender === buttonSwitch {
            updateButtonsConfiguration()
        } else if sender === textFieldSwitch {
            configuration.showTextField = sender.isOn
        }
    }

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateButtonsConfiguration()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        let vc = ViewControllerWithLazySubviews()
        present(vc, animated: true)

        vc.configure(with: self.configuration)
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    private func updateButtonsConfiguration() {
        configuration.buttonsCount = buttonSwitch.isOn ?  buttonsCountSegmentedControl.selectedSegmentIndex + 1 : 0
    }

}

