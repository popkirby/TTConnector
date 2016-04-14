//
//  debugPrint.swift
//  TTConnector
//
//  Created by popkirby on 2016/04/13.
//  Copyright © 2016年 popkirby. All rights reserved.
//

import Foundation

func print(value: Any) {
    #if DEBUG
        Swift.print(value)
    #endif
}