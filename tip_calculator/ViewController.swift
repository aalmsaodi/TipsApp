//
//  ViewController.swift
//  tip_calculator
//
//  Created by user on 7/7/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit
import CoreML
import Vision
import SVProgressHUD

let defaults = UserDefaults.standard

enum color:Int {
    case black
    case white
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CanReceive {
    
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
    @IBOutlet weak var tipRatesView: UIView!
    @IBOutlet weak var tipTotalView: UIView!
    @IBOutlet weak var uperDivider: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var lowerDivider: UIView!
    @IBOutlet weak var roundingView: UIView!
    //    @IBOutlet weak var darkLightButton: UIBarButtonItem!
    @IBOutlet weak var smartCameraButton: UIBarButtonItem!
    @IBOutlet weak var topViewConstraintRatio: NSLayoutConstraint!
    
    let formatter = NumberFormatter()
    var theBillData = Bill()
    var animate = true
    var backgroundColor:color = color.white
    var firstRun = true
    var afterInstallation = true
    var notUsedForLongTime:Bool = false
    let clearDefaultsAfter = 600.0 //seconds
    let imagePicker = UIImagePickerController()
    
    let fastFoodTerms = ["burger", "Ketchup", "fries", "sandwich", "burrito", "carry-out", "soda", "coke", "pepsi", "hotdog", "smoothie", "icecream", "sub", "nuggets", "bacon"]
    let bartendersTerms = ["beer", "wine", "alcoholic", "alcohol", "vodka", "glass", "shot"]
    let resturantTerms = ["food", "spoon", "plate", "bowl", "menu", "meat", "meal", "tea", "coffee", "bagel", "muffin", "bread", "cup", "juice", "beverage"]
    let hotelTerms = ["room", "bed", "hotel", "pool", "receptionist"]
    let beautyTerms = ["Hair", "barber", "nails", "spa", "facial", "nails", "style", "massage"]
    let taxiTerms = ["taxi", "limo", "cab", "driver", "uber", "lyft", "carpool", "car", "bus", "transportation", "parking", "ride", "keys"]
    let laborTerms = ["mechanic", "automotive", "mover", "furniture", "applience"]
    
    let fastFoodTip = "Tip is not expected for fast food resturants unless special service was provided"
    let bartendersTip = "Tip for bartenders should be between 15%-20%"
    let resturantTip = "Tip in resturants tipcally is between 15%-20%"
    let hotelTip = "Tip for Hotel Room service typically is included in the price already. If not, 15-20%. Also no tip is expected for Hotel Housekeeping, $1-$2 per person per night."
    let beautyTip = "Tip for beauty and style is 10%-20%"
    let taxiTip = "Tip for taxi typically is 15%-20%. Shuttle Drivers and Parking Attendant can also be given $1-$3"
    let laborTip = "Not expected, Or $5, $10, $20 each depending on the amount"
    
    var tipRecommendationMessage = ""

    var serviceCategories = [String: [String]]()
    var tipRecommendations = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        serviceCategories = ["Fast Food": fastFoodTerms, "Bartenders": bartendersTerms, "Resturants": resturantTerms, "Hotel Service": hotelTerms, "Beauty & Style": beautyTerms, "Transportation": taxiTerms, "Labor Service": laborTerms]
        
        tipRecommendations = ["Fast Food": fastFoodTip, "Bartenders": bartendersTip, "Resturants": resturantTip, "Hotel Service": hotelTip, "Beauty & Style": beautyTip, "Transportation": taxiTip, "Labor Service": laborTip]
        
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
    
    
    @IBAction func onViewTap(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    //*********************************************************************************
    //# MARK: - Image taking and CoreML detecting using Inception3 Model
    //*********************************************************************************
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let imagePicked = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            SVProgressHUD.show(withStatus: "Detecting the Item")
            
            guard let ciimage = CIImage(image: imagePicked) else {
                fatalError("Could not convert into CIImage")
            }
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        SVProgressHUD.dismiss()
        
        if tipRecommendationMessage == "" {
            tipRecommendationMessage = "Unfortunatly TipsApp was unable to detect the service/product you are purchasing"
        }
        diesplayMessageToUser(title: "Smart Tip Recommendation", message: tipRecommendationMessage)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
             fatalError("Loading CoreML Model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let firstResult = results.first {
                for (nameOfService, serviceKeyWords) in self.serviceCategories {
                    if firstResult.identifier.containsInArray(arr: serviceKeyWords) {
                        self.tipRecommendationMessage = self.tipRecommendations[nameOfService] ?? ""
                    }
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    @IBAction func smartCameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func diesplayMessageToUser(title:String, message:String) {
        let dialog = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: .cancel) {
            UIAlertAction in
            if ("Smart Tip Feature" == title){
                self.billField.becomeFirstResponder()
            }
        }
        
        dialog.addAction(okAction)
        self.present(dialog, animated: false, completion: nil)
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
                self.topViewConstraintRatio.constant = 130
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
    //# MARK: - Segue and Sending and Recieving Data between VCs
    //*********************************************************************************
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSettings" {
            
            let settingsVC = segue.destination as! SettingsViewController
            settingsVC.backgroundColor = backgroundColor
            settingsVC.theBillData = theBillData
            settingsVC.delegate = self
        }
    }
    
    func dataReceived(theBillData:Bill, backgroundColor:color) {
        self.theBillData = theBillData
        self.backgroundColor = backgroundColor
    }
    
    //*********************************************************************************
    //# MARK: - Front View and Appearance
    //*********************************************************************************
    @objc func preparingFrontView(){
        loadSavedData()
        
        if (!notUsedForLongTime && defaults.data(forKey: "theBillData") != nil) {
            lowerViewsAlpha(alpha: 1, animate: false)
            self.topViewConstraintRatio.constant = 130
            self.view.layoutIfNeeded()
            
            billField.becomeFirstResponder()
            billField.placeholder = Locale.current.currencySymbol!
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
            
            billField.becomeFirstResponder()
            billField.placeholder = Locale.current.currencySymbol!
        }
        
        if afterInstallation {
            diesplayMessageToUser(title: "Smart Tip Feature", message: "Use the Camera button on the top left corner of the app to get a recommendation about how much your tip should be for the service/product you are purchasing")
            
            afterInstallation = false
            defaults.set(false, forKey: "afterInstallation")
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
        
        if backgroundColor == .black {
            backGroundView.backgroundColor = .black
        } else {
            backGroundView.backgroundColor = .white
        }
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
            afterInstallation = defaults.bool(forKey: "afterInstallation")
            
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
            }

        }
        else {
            print("No Saved data to restore")
        }
        
    }
    
    @objc func saveData() {
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

