//
//  SampleSensor.swift
//  com.awareframework.ios.sensor.core_Example
//
//  Created by Yuuki Nishiyama on 2018/12/04.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import com_awareframework_ios_sensor_core

public class SampleSensor:AwareSensor {
    // A configuration of the sensor
    public var CONFIG = SampleSensor.Config()
    
    public var timer:Timer? 
    
    // A configuration generater class
    public class Config:SensorConfig {
        // add some parameters
        public override init() {
            super.init()
        }
        
        public func apply(closure: (_ config: Config ) -> Void) -> Self {
            closure(self)
            return self
        }
    }
    
    public override convenience init() {
        self.init(Config())
    }
    
    public init(_ config:SampleSensor.Config){
        super.init()
        super.initializeDbEngine(config: config)
        self.CONFIG = config
    }
    
    public override func start() {
        print("start")
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
                if let engine = self.dbEngine {
                    engine.save(AwareObject())
                }
            })
        }
    }
    
    public override func stop() {
        print("stop")
        if let uwTimer = timer {
            uwTimer.invalidate()
            self.timer = nil
        }
    }
    
    public override func sync(force: Bool = false) {
        // print("sync")
        if let engine = self.dbEngine {
            engine.startSync(SampleData.TABLE_NAME, SampleData.self, DbSyncConfig().apply{ config in
                config.debug = true
                config.completionHandler = { (status, error) in
                    print(status)
                }
            })
        }
    }
    
    public override func set(label: String) {
        super.set(label: label)
    }
}
