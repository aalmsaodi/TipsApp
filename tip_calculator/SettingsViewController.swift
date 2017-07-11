//
//  SettingsViewController.swift
//  tip_calculator
//
//  Created by user on 7/7/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

var tipPercentages = [15, 20, 25]
var excludeTax = true
var taxPercentage = 7.5
var maxNumP = 20

let defaults = UserDefaults.standard

class SettingsViewController: UIViewController {


    @IBOutlet weak var tipPercent_1: UITextField!
    @IBOutlet weak var tipPercent_2: UITextField!
    @IBOutlet weak var tipPercent_3: UITextField!
    
    @IBOutlet weak var taxPercentageField: UITextField!
   
    @IBOutlet weak var taxSwitch: UISwitch!
   
    @IBOutlet weak var MaxnumPeople: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        if (defaults.string(forKey: "firstP") != nil) {
            tipPercent_1.text = defaults.string(forKey: "firstP")
            tipPercentages[0] = Int(defaults.string(forKey: "firstP")!)!
            tipPercent_2.text = defaults.string(forKey: "secondP")
            tipPercentages[1] = Int(defaults.string(forKey: "secondP")!)!
            tipPercent_3.text = defaults.string(forKey: "thirdP")
            tipPercentages[2] = Int(defaults.string(forKey: "thirdP")!)!
            
            taxPercentageField.text = defaults.string(forKey: "taxP")
            taxPercentage = Double(defaults.string(forKey: "taxP")!)!
            
            MaxnumPeople.text = defaults.string(forKey: "numP")
            maxNumP = Int(defaults.string(forKey: "numP")!)!
            
            taxSwitch.setOn(defaults.bool(forKey: "taxEx"), animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        defaults.set(tipPercent_1.text, forKey: "firstP")
        defaults.set(tipPercent_2.text, forKey: "secondP")
        defaults.set(tipPercent_3.text, forKey: "thirdP")
        defaults.set(taxPercentageField.text, forKey: "taxP")
        defaults.set(MaxnumPeople.text, forKey: "numP")
        defaults.set(taxSwitch.isOn, forKey: "taxEx")

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
        excludeTax = taxSwitch.isOn
    }
    
    @IBAction func tappedLearnMore(_ sender: AnyObject) {
        UIApplication.shared.open(URL(string: "https://en.wikipedia.org/wiki/Gratuity")!, options: [:], completionHandler: nil)
    }
    
}
