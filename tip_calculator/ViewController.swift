//
//  ViewController.swift
//  tip_calculator
//
//  Created by user on 7/7/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

let defaults = UserDefaults.standard

class ViewController: UIViewController, CanReceive {
    
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
    var backgroundColor = UIColor.white
    var firstRun = true
    var notUsedForLongTime:Bool = false
    
    var tipPercentages = [15, 20, 25]
    var includeTax = false
    var taxPercentage = 7.5
    var maxNumP = 20
    
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
        
        firstRun = defaults.bool(forKey: "firstRun")
        
        if (!notUsedForLongTime && defaults.double(forKey: "0") != 0){
            loadSavedSettingsDefaultsValues()
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
        
        if darkLightButton.title == "Dark" {
            backgroundColor = UIColor.black
            darkLightButton.title = "Light"
        } else {
            darkLightButton.title = "Dark"
            backgroundColor = UIColor.white
        }
        
        backGroundView.backgroundColor = backgroundColor
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSettings" {
            
            let settingsVC = segue.destination as! SettingsViewController
            settingsVC.settingsBackgroundColor = backgroundColor
            settingsVC.tipPercentages = self.tipPercentages
            settingsVC.includeTax = self.includeTax
            settingsVC.taxPercentage = self.taxPercentage
            settingsVC.maxNumP = self.maxNumP
            
            settingsVC.delegate = self
        }
    }
    
    func dataReceived(tipPercentages: [Int], includeTax: Bool, taxPercentage: Double, maxNumP: Int) {
        self.tipPercentages = tipPercentages
        self.includeTax = includeTax
        self.taxPercentage = taxPercentage
        self.maxNumP = maxNumP
    }
    
    
    func preparingFrontView(){
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        notUsedForLongTime = delegate.notUsedForLongTime
        
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
            defaults.set(false, forKey: "firstRun")
        }
        
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

