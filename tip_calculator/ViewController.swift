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
var settingsBackgroundColor = UIColor.white

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
    @IBOutlet var backGroundView: UIView!
    @IBOutlet weak var topFillerView: UIView!
    @IBOutlet weak var tipRatesView: UIView!
    @IBOutlet weak var tipTotalView: UIView!
    @IBOutlet weak var uperDivider: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var lowerDivider: UIView!
    @IBOutlet weak var roundingView: UIView!
    @IBOutlet weak var darkLightButton: UIBarButtonItem!
    
    var numPeople = 1
    let formatter = NumberFormatter()
    var theBill = Bill()
    var animate = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the coordinats of "billField"
        billField.layer.sublayerTransform = CATransform3DMakeTranslation(-30, 0, 0)
        
        // Setting up the right color of the navigating bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 55/255, green: 108/255, blue: 139/255, alpha: 1)
        
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
        
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

        if (animate){
            lowerViewsAlpha(alpha: 1, animate: true)
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
    
    @IBAction func onDarkLightButton(_ sender: Any) {
        
        var color = UIColor.white

        if darkLightButton.title == "Dark" {
            color = UIColor.black
            darkLightButton.title = "Light"
            settingsBackgroundColor = UIColor.black
        } else {
            darkLightButton.title = "Dark"
            settingsBackgroundColor = UIColor.white
        }
        
        backGroundView.backgroundColor = color
        topFillerView.backgroundColor =  color
        billField.backgroundColor = color
        tipRatesView.backgroundColor = color
        tipTotalView.backgroundColor = color
        shareView.backgroundColor = color
        roundingView.backgroundColor = color
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
            lowerViewsAlpha(alpha: 1, animate: false)

        }
        
        if (notUsedForLongTime || firstRun || defaults.string(forKey: "bill") == nil) {
            clearAllSavedUserDefaults()
            
            // Getting the local currency symbol of the device
            let locale = Locale.current
            let currencySymbol = locale.currencySymbol!
            billField.placeholder = currencySymbol
            billField.text = nil
            
            billField.becomeFirstResponder()
            
            lowerViewsAlpha(alpha: 0, animate: false)
            animate = true
            
            notUsedForLongTime = false
            firstRun = false
        }
        
        
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
    
    
    func lowerViewsAlpha(alpha:CGFloat, animate:Bool) {
        
        if animate {
            UIView.animate(withDuration: 1, animations: {self.tipRatesView.alpha = alpha}, completion: nil)
            UIView.animate(withDuration: 1, animations: {self.tipTotalView.alpha = alpha}, completion: nil)
            UIView.animate(withDuration: 1, animations: {self.uperDivider.alpha = alpha}, completion: nil)
            UIView.animate(withDuration: 1, animations: {self.shareView.alpha = alpha}, completion: nil)
            UIView.animate(withDuration: 1, animations: {self.lowerDivider.alpha = alpha}, completion: nil)
            UIView.animate(withDuration: 1, animations: {self.roundingView.alpha = alpha}, completion: nil)
        } else {
            tipRatesView.alpha = alpha
            tipTotalView.alpha = alpha
            uperDivider.alpha = alpha
            shareView.alpha = alpha
            lowerDivider.alpha = alpha
            roundingView.alpha = alpha
        }
    }
    
    func clearAllSavedUserDefaults(){
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
}

