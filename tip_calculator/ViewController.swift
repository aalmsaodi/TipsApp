//
//  ViewController.swift
//  tip_calculator
//
//  Created by user on 7/7/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var billPerPerson: UILabel!
    @IBOutlet weak var numPeopleLabel: UILabel!
    @IBOutlet weak var numPeopleSlider: UISlider!
    @IBOutlet weak var roundingControl: UISegmentedControl!
    @IBOutlet weak var eachShare: UILabel!
    @IBOutlet weak var maskView: UIView!
    

    var numPeople = 1
    var animate = true
    
    let formatter = NumberFormatter()
    
    
    override func viewDidLoad() {
        
        let locale = Locale.current
        let currencySymbol = locale.currencySymbol!
        
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2;

        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(red: 102/255, green: 205/255, blue: 255/255, alpha: 1)
        
        billField.layer.sublayerTransform = CATransform3DMakeTranslation(-30, 0, 0)
        
        if (defaults.double(forKey: "bill") != 0){
            billField.text = String(describing: NSNumber(value: defaults.double(forKey: "bill")))
            animate = false
            maskView.alpha = 0
        } else {
            billField.placeholder = currencySymbol
            billField.becomeFirstResponder()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (defaults.string(forKey: "firstP") != nil) { //confirming that defaults values are not nil
            tipPercentages[0] = Int(defaults.string(forKey: "firstP")!)!
            tipPercentages[1] = Int(defaults.string(forKey: "secondP")!)!
            tipPercentages[2] = Int(defaults.string(forKey: "thirdP")!)!
        }
        tipControl.setTitle(String(tipPercentages[0]) + "%", forSegmentAt: 0)
        tipControl.setTitle(String(tipPercentages[1]) + "%", forSegmentAt: 1)
        tipControl.setTitle(String(tipPercentages[2]) + "%", forSegmentAt: 2)
        
        calculateBill()
        numPeopleSlider.maximumValue = Float(maxNumP)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onViewTap(_ sender: AnyObject) {
        view.endEditing(true)
    }

    @IBAction func billChanged(_ sender: AnyObject) {
        calculateBill()
       
        if (animate){
            UIView.animate(withDuration: 1, animations: {self.maskView.alpha = 0}, completion: nil)
            animate = false
        }
    }
    
    @IBAction func sliderPeopleChanged(_ sender: AnyObject) {
        numPeople = Int(numPeopleSlider.value)
        numPeopleLabel.text = "👥 Split between: " + String(numPeople)
        calculateBill()
        
    }
    
    
    func calculateBill() {
        
        let bill = Double(billField.text!) ?? 0
        var billWithoutTax:Double
        
        if excludeTax {
            billWithoutTax = bill - bill*taxPercentage/100
        } else {
            billWithoutTax = bill
        }
        
        let tip = billWithoutTax * Double(tipPercentages[tipControl.selectedSegmentIndex])/100
        
        let total = bill + tip
        
        eachShare.text = formatter.string(from: NSNumber(value: bill))

        tipLabel.text = formatter.string(from: NSNumber(value: tip))
        
        totalLabel.text = formatter.string(from: NSNumber(value: total))
        
        billPerPerson.text = "Total per person: " + formatter.string(from: NSNumber(value: total/Double(numPeople)))!
        
        if (roundingControl.selectedSegmentIndex == 0){
            eachShare.text = formatter.string(from: NSNumber(value: (total/Double(numPeople)).rounded(.up)))
        } else {
            eachShare.text = formatter.string(from: NSNumber(value: (total/Double(numPeople)).rounded(.down)))
        }
        
        defaults.set(bill, forKey: "bill")
        
    }
    
}

