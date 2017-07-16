//
//  SettingsViewController.swift
//  tip_calculator
//
//  Created by user on 7/7/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tipPercent_1: UITextField!
    @IBOutlet weak var tipPercent_2: UITextField!
    @IBOutlet weak var tipPercent_3: UITextField!
    @IBOutlet weak var taxPercentageField: UITextField!
    @IBOutlet weak var taxSwitch: UISwitch!
    @IBOutlet weak var MaxnumPeople: UITextField!
    @IBOutlet var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tipPercent_1.text = String(tipPercentages[0])
        tipPercent_2.text = String(tipPercentages[1])
        tipPercent_3.text = String(tipPercentages[2])

        taxPercentageField.text = String(taxPercentage)
        MaxnumPeople.text = String(maxNumP)
        taxSwitch.setOn(includeTax, animated: false)
        darkLightBackground()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        savingSettingsValues()
        maxNumP = Int(MaxnumPeople.text!)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func changedTip(_ sender: AnyObject) {
        tipPercentages[0] = Int(tipPercent_1.text!)!
        tipPercentages[1] = Int(tipPercent_2.text!)!
        tipPercentages[2] = Int(tipPercent_3.text!)!
    }
    
    @IBAction func onTap(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func changedTax(_ sender: AnyObject) {
        taxPercentage = Double(taxPercentageField.text!)!
    }
    
    @IBAction func onExcludeTax(_ sender: AnyObject) {
        includeTax = taxSwitch.isOn
    }
    
    @IBAction func tappedLearnMore(_ sender: AnyObject) {
        UIApplication.shared.open(URL(string: "https://en.wikipedia.org/wiki/Gratuity")!, options: [:], completionHandler: nil)
    }
    
    func savingSettingsValues() {
        defaults.set(tipPercent_1.text, forKey: "0")
        defaults.set(tipPercent_2.text, forKey: "1")
        defaults.set(tipPercent_3.text, forKey: "2")
        defaults.set(taxPercentageField.text, forKey: "taxP")
        defaults.set(MaxnumPeople.text, forKey: "numP")
        defaults.set(taxSwitch.isOn, forKey: "taxInc")
    }
    
    func darkLightBackground() {
        backgroundView.backgroundColor = settingsBackgroundColor
    }
}
