//
//  Bill.swift
//  TipsApp
//
//  Created by Akrm Almsaodi on 7/7/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation

class Bill: NSObject, NSCoding{
    var tipPercentages = [15, 20, 25]
    var tipSelectedIndex = 0
    var includeTax = false
    var taxPercentage = 7.5
    var numPeople = 1
    var maxNumP = 20
    var bill = 0
    var total:Double = 0
    var billIncludeTax:Double{
        return Double(bill) + taxPercentage*Double(bill)/100
    }
    
    override init() {
        
    }
    
    init(tipPercentages:[Int], tipSelectedIndex:Int, includeTax:Bool, taxPercentage:Double, numPeople:Int, maxNumP:Int, bill:Int, total:Double) {
        self.tipPercentages = tipPercentages
        self.tipSelectedIndex = tipSelectedIndex
        self.includeTax = includeTax
        self.taxPercentage = taxPercentage
        self.numPeople = numPeople
        self.maxNumP = maxNumP
        self.bill = bill
        self.total = total
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(tipPercentages, forKey: "tipPercentages")
        aCoder.encode(tipSelectedIndex, forKey: "tipSelectedIndex")
        aCoder.encode(includeTax, forKey: "includeTax")
        aCoder.encode(taxPercentage, forKey: "taxPercentage")
        aCoder.encode(numPeople, forKey: "numPeople")
        aCoder.encode(maxNumP, forKey: "maxNumP")
        aCoder.encode(bill, forKey: "bill")
        aCoder.encode(total, forKey: "total")
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let tipPercentages = aDecoder.decodeObject(forKey: "tipPercentages") as! [Int]
        let tipSelectedIndex = aDecoder.decodeInteger(forKey: "tipSelectedIndex")
        let includeTax = aDecoder.decodeBool(forKey: "includeTax")
        let taxPercentage = aDecoder.decodeDouble(forKey: "taxPercentage")
        let numPeople = aDecoder.decodeInteger(forKey: "numPeople")
        let maxNumP = aDecoder.decodeInteger(forKey: "maxNumP")
        let bill = aDecoder.decodeInteger(forKey: "bill")
        let total = aDecoder.decodeDouble(forKey: "total")
        
        self.init(tipPercentages:tipPercentages, tipSelectedIndex:tipSelectedIndex, includeTax:includeTax, taxPercentage:taxPercentage, numPeople:numPeople, maxNumP:maxNumP, bill:bill, total:total)
    }
    
    
    func calculateTotal() -> Double {
        if includeTax {
            total = billIncludeTax + billIncludeTax*Double(tipPercentages[tipSelectedIndex])/100
            return total
        }
        else {
            total = Double(bill) + Double(bill)*Double(tipPercentages[tipSelectedIndex])/100
            return total
        }
    }
    
    func calculateTip() -> Double {
        if includeTax {
            return Double(tipPercentages[tipSelectedIndex])*billIncludeTax/100
        }
        else
        {
            return Double(tipPercentages[tipSelectedIndex])*Double(bill)/100
        }
    }
    
    func calculateShare() -> Double {
        return total/Double(numPeople)
    }
    
    
}
