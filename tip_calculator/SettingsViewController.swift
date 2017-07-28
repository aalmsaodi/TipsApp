//
//  SettingsViewController.swift
//  TipsApp
//
//  Created by Akrm Almsaodi on 7/7/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

protocol CanReceive {
    func dataReceived(theBillData:Bill, backgroundColor:color)
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tipPercent_1: UITextField!
    @IBOutlet weak var tipPercent_2: UITextField!
    @IBOutlet weak var tipPercent_3: UITextField!
    @IBOutlet weak var taxPercentageField: UITextField!
    @IBOutlet weak var taxSwitch: UISwitch!
    @IBOutlet weak var MaxnumPeople: UITextField!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var darkLightButton: UIBarButtonItem!
    
    var delegate:CanReceive?
    var theBillData = Bill()
    var backgroundColor = color.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SettingsViewController.goBack))
        navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSettingsView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        theBillData.maxNumP = Int(MaxnumPeople.text!)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func changedTip(_ sender: AnyObject) {
        theBillData.tipPercentages[0] = Int(tipPercent_1.text!)!
        theBillData.tipPercentages[1] = Int(tipPercent_2.text!)!
        theBillData.tipPercentages[2] = Int(tipPercent_3.text!)!
    }
    
    @IBAction func onTap(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func changedTax(_ sender: AnyObject) {
        theBillData.taxPercentage = Double(taxPercentageField.text!)!
    }
    
    @IBAction func onExcludeTax(_ sender: AnyObject) {
        theBillData.includeTax = taxSwitch.isOn
    }
    
    @IBAction func tappedLearnMore(_ sender: AnyObject) {
        UIApplication.shared.open(URL(string: "https://en.wikipedia.org/wiki/Gratuity")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func lightDarkTapped(_ sender: UIBarButtonItem) {
        if darkLightButton.title == "Dark" {
            backgroundColor = .black
            backgroundView.backgroundColor = .black
            darkLightButton.title = "Light"
        } else {
            darkLightButton.title = "Dark"
            backgroundColor = .white
            backgroundView.backgroundColor = .white
        }
    }
    
    @objc func goBack(){
        delegate?.dataReceived(theBillData:theBillData, backgroundColor:backgroundColor)
        _ = navigationController?.popViewController(animated: true)
    }
    
    func updateSettingsView(){
        tipPercent_1.text = String(theBillData.tipPercentages[0])
        tipPercent_2.text = String(theBillData.tipPercentages[1])
        tipPercent_3.text = String(theBillData.tipPercentages[2])
        
        taxPercentageField.text = String(theBillData.taxPercentage)
        MaxnumPeople.text = String(theBillData.maxNumP)
        taxSwitch.setOn(theBillData.includeTax, animated: false)
        
        if backgroundColor == color.black {
            backgroundView.backgroundColor = .black
            darkLightButton.title = "Light"
        }
        else {
            backgroundView.backgroundColor = .white
            darkLightButton.title = "Dark"
        }
        
    }
    
}
