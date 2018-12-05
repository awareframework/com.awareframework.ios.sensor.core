//
//  SampleData.swift
//  com.awareframework.ios.sensor.core_Example
//
//  Created by Yuuki Nishiyama on 2018/12/04.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import com_awareframework_ios_sensor_core

public class SampleData:AwareObject {
    public static let TABLE_NAME = "sampleTable"
    @objc dynamic public var x:Double = 0
    @objc dynamic public var y:Double = 0
    @objc dynamic public var z:Double = 0
    
    public override func toDictionary() -> Dictionary<String, Any> {
        var dict = super.toDictionary()
        dict["x"] = x
        dict["y"] = y
        dict["z"] = z
        return dict
    }
}

