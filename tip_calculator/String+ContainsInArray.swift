//
//  String+ConsistOfInArray.swift
//  TipsApp
//
//  Created by Akrm Almsaodi on 7/7/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
extension String {
    
    func containsInArray(arr: [String]) -> Bool {
        for string in arr {
            if self.contains(string) {
                return true
            }
        }
        return false
    }
}
