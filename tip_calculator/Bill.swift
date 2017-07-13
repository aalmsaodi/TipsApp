//
//  Bill.swift
//  TipsAPP
//
//  Created by user on 7/13/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation

class Bill{
    
    var bill:Double = 0
    var tipRate:Double = 15
    var taxRate:Double = 7.5
    var total:Double = 0
    var billIncludeTax:Double{
        return bill + taxRate*bill/100
    }
        
    func calculateTotal(includeTax:Bool) -> Double {
        if includeTax {
            total = billIncludeTax + billIncludeTax*tipRate/100
            return total
        }
        else {
            total = bill + bill*tipRate/100
            return total
        }
    }
    
    func calculateTip(includeTax:Bool) -> Double {
        if includeTax {
            return tipRate * billIncludeTax/100
        }
        else
        {
            return tipRate * bill/100
        }
    }
    
    func calculateShare(numOfPeople:Int) -> Double {
        return total/Double(numOfPeople)
    }
    
    
}
