//
//  ViewController.swift
//  tip_calculator
//
//  Created by user on 7/7/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

var tipPercentages = [15, 20, 25]
var includeTax = false
var taxPercentage = 7.5
var maxNumP = 20
let defaults = UserDefaults.standard
let clearDefaultsAfter = 600.0 //seconds
var notUsedForLongTime = false
var firstRun = true

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
    let formatter = NumberFormatter()
    var theBill = Bill()
    var animate = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the coordinats of "billField"
        billField.layer.sublayerTransform = CATransform3DMakeTranslation(-30, 0, 0)
        
        // Setting up the right color of the navigating bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 102/255, green: 205/255, blue: 255/255, alpha: 1)
        
        preparingFrontView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.preparingFrontView), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        numPeopleSlider.maximumValue = Float(maxNumP)
        
        if (notUsedForLongTime == false){
            preparingFrontView()
            
            if (defaults.double(forKey: "0") != 0) { //Checking if settings defaults were set up already
                loadSavedSettingsDefaultsValues()
            }
        }
        
        calculateBill()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onViewTap(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func billChanged(_ sender: AnyObject) {
        theBill.bill = Double(billField.text!) ?? 0
        defaults.set(Double(billField.text!), forKey: "bill")
       
        calculateBill()

        if (animate){ // Animating and showing "maskView" is needed the first time the app is used
            UIView.animate(withDuration: 1, animations: {self.maskView.alpha = 0}, completion: nil)
            animate = false
        }
    }
    
    @IBAction func tipRateChanged(_ sender: AnyObject) {
        theBill.tipRate = Double(tipPercentages[tipControl.selectedSegmentIndex])
        calculateBill()
    }
    
    @IBAction func sliderPeopleChanged(_ sender: AnyObject) {
        numPeople = Int(numPeopleSlider.value)
        numPeopleLabel.text = "👥 Split between: " + String(numPeople)
        calculateBill()
        
    }
    
    
    func calculateBill() {
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2;
        
        theBill.taxRate = taxPercentage
        theBill.tipRate = Double(tipPercentages[tipControl.selectedSegmentIndex])
        let total = theBill.calculateTotal(includeTax: includeTax)
        totalLabel.text = formatter.string(from: NSNumber(value: total))
        
        theBill.tipRate = Double(tipPercentages[tipControl.selectedSegmentIndex])
        tipLabel.text = formatter.string(from: NSNumber(value: theBill.calculateTip(includeTax: includeTax)))

        let theShare = theBill.calculateShare(numOfPeople: numPeople)
        billPerPerson.text = "Total per person: " + formatter.string(from: NSNumber(value: theShare))!
        
        if (roundingControl.selectedSegmentIndex == 0){
            eachShare.text = formatter.string(from: NSNumber(value: theShare.rounded(.up)))
        } else {
            eachShare.text = formatter.string(from: NSNumber(value: theShare.rounded(.down)))
        }
        
    }
   
    func preparingFrontView(){
        
        if !notUsedForLongTime && defaults.string(forKey: "bill") != nil {
            loadSavedFrontViewDefaultsValues()
            maskView.alpha = 0
        }
        
        if (notUsedForLongTime || firstRun) {
            clearAllSavedUserDefaults()
            
            // Getting the local currency symbol of the device
            let locale = Locale.current
            let currencySymbol = locale.currencySymbol!
            billField.placeholder = currencySymbol
            billField.text = nil
            
            maskView.alpha = 1
            animate = true
            
            notUsedForLongTime = false
            firstRun = false
        }
        
        billField.becomeFirstResponder()
    }
    
    func loadSavedFrontViewDefaultsValues(){
        
        billField.text = String(describing: NSNumber(value: defaults.double(forKey: "bill")))
        theBill.bill = Double(defaults.string(forKey: "bill")!)!
    }
    
    
    func loadSavedSettingsDefaultsValues(){
        
        for i in 0...2 {
            tipPercentages[i] = Int(defaults.string(forKey: String(i))!)!
            tipControl.setTitle(String(tipPercentages[i]) + "%", forSegmentAt: i)
        }
        
        includeTax = defaults.bool(forKey: "taxInc")
        maxNumP = Int(defaults.string(forKey: "numP")!)!
        taxPercentage = Double(defaults.string(forKey: "taxP")!)!

    }
    
    func clearAllSavedUserDefaults(){
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
}

