//
//  ViewController.swift
//  tip_calculator
//
//  Created by user on 7/7/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

let defaults = UserDefaults.standard


enum color:Int {
    case black
    case white
}

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
    @IBOutlet weak var topViewConstraintRatio: NSLayoutConstraint!
    
    let formatter = NumberFormatter()
    var theBillData = Bill()
    var animate = true
    var backgroundColor:color = color.white
    var firstRun = true
    var notUsedForLongTime:Bool = false
    let clearDefaultsAfter = 600.0 //seconds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialConfiguration()
        preparingFrontView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.preparingFrontView), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.saveData), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateFrontViewValues()
        calculateBill()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onViewTap(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    
    //*********************************************************************************
    //# MARK: - Bill Calculation
    //*********************************************************************************
    @IBAction func billChanged(_ sender: AnyObject) {
        
        theBillData.bill = Int(billField.text!) ?? 0
        calculateBill()
        
        if (animate){
            animate = false
            lowerViewsAlpha(alpha: 1, animate: true)
            
            UIView.animate(withDuration: 1, animations: {
                self.topViewConstraintRatio.constant = 150
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func tipRateChanged(_ sender: AnyObject) {
        theBillData.tipSelectedIndex = tipControl.selectedSegmentIndex
        calculateBill()
    }
    
    @IBAction func sliderPeopleChanged(_ sender: AnyObject) {
        theBillData.numPeople = Int(numPeopleSlider.value)
        numPeopleLabel.text = "👥 Split between: " + String(theBillData.numPeople)
        calculateBill()
    }
    
    func calculateBill() {
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2;
        
        let total = theBillData.calculateTotal()
        totalLabel.text = formatter.string(from: NSNumber(value: total))
        
        tipLabel.text = formatter.string(from: NSNumber(value: theBillData.calculateTip()))
        
        let theShare = theBillData.calculateShare()
        billPerPerson.text = "Total per person: " + formatter.string(from: NSNumber(value: theShare))!
        
        if (roundingControl.selectedSegmentIndex == 0){ //index 0 for rounding up
            eachShare.text = formatter.string(from: NSNumber(value: theShare.rounded(.up)))
        } else {
            eachShare.text = formatter.string(from: NSNumber(value: theShare.rounded(.down)))
        }
    }
    
    //*********************************************************************************
    //# MARK: - Segue and Protocol Confirmation
    //*********************************************************************************
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSettings" {
            
            let settingsVC = segue.destination as! SettingsViewController
            settingsVC.theBillData = theBillData
            settingsVC.settingsBackgroundColor = backgroundColor
            settingsVC.delegate = self
        }
    }
    
    func dataReceived(theBillData:Bill) {
        self.theBillData = theBillData
    }
    
    //*********************************************************************************
    //# MARK: - Front View and Appearance
    //*********************************************************************************
    @IBAction func onDarkLightButton(_ sender: Any) {
        
        if darkLightButton.title == "Dark" {
            backgroundColor = .black
            backGroundView.backgroundColor = .black
            darkLightButton.title = "Light"
        } else {
            darkLightButton.title = "Dark"
            backgroundColor = .white
            backGroundView.backgroundColor = .white
        }
    }
    
    func preparingFrontView(){
        loadSavedData()
        
        if !notUsedForLongTime && defaults.data(forKey: "theBillData") != nil {
            lowerViewsAlpha(alpha: 1, animate: false)
            self.topViewConstraintRatio.constant = 150
            self.view.layoutIfNeeded()
        }
        
        if (notUsedForLongTime || firstRun || theBillData.bill == 0) {
            clearSavedBillOnly()
            
            billField.text = nil
            
            lowerViewsAlpha(alpha: 0, animate: false)
            self.topViewConstraintRatio.constant = 0
            self.view.layoutIfNeeded()
            animate = true
            notUsedForLongTime = false
            firstRun = false
            defaults.set(false, forKey: "firstRun")
        }
        
        billField.becomeFirstResponder()
        billField.placeholder = Locale.current.currencySymbol!
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
    
    func updateFrontViewValues() {
        for i in 0...2 {
            tipControl.setTitle(String(theBillData.tipPercentages[i]) + "%", forSegmentAt: i)
        }
        
        if theBillData.bill == 0 {
            billField.text = nil
        }
        else {
            billField.text = String(theBillData.bill)
        }

        numPeopleSlider.maximumValue = Float(theBillData.maxNumP)
    }
    
    func initialConfiguration(){
        // Setting up the coordinats of "billField"
        billField.layer.sublayerTransform = CATransform3DMakeTranslation(-30, 0, 0)
        
        // Setting up the right color of the navigating bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 55/255, green: 108/255, blue: 139/255, alpha: 1)
        
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    //*********************************************************************************
    //# MARK: - User Defaults Data
    //*********************************************************************************
    func loadSavedData(){
        if(defaults.object(forKey: "lastTimeUsed") != nil){
            firstRun = defaults.bool(forKey: "firstRun")
            
            let lastTimeUsed = defaults.double(forKey: "lastTimeUsed")
            if CACurrentMediaTime()-lastTimeUsed > clearDefaultsAfter {
                notUsedForLongTime = true
            } else {
                notUsedForLongTime = false
            }
            
            let data = defaults.data(forKey:  "theBillData")
            theBillData = (NSKeyedUnarchiver.unarchiveObject(with: data!) as? Bill)!
            
            backgroundColor = color(rawValue: defaults.integer(forKey: "backgroundColor"))!
            if backgroundColor == color.black { //white is the default color - no need to set
                backGroundView.backgroundColor = .black
                backgroundColor = .black
                darkLightButton.title = "Light"
            }

        }
        else {
            print("No Saved data to restore")
        }
        
    }
    
    func saveData() {
        let encodedData:Data = NSKeyedArchiver.archivedData(withRootObject:theBillData)
        defaults.set(encodedData, forKey: "theBillData")
        defaults.set(CACurrentMediaTime(), forKey: "lastTimeUsed")
        defaults.set(backgroundColor.rawValue, forKey: "backgroundColor")
    }
    
    
    func clearSavedBillOnly(){
        UserDefaults.standard.removeObject(forKey: "bill")
        UserDefaults.standard.synchronize()
    }
    
}

