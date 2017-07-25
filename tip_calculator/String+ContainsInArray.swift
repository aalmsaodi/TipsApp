//
//  String+ConsistOfInArray.swift
//  TipsAPP
//
//  Created by user on 7/24/17.
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
