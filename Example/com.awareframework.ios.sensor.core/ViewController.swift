//
//  ViewController.swift
//  com.awareframework.ios.sensor.core
//
//  Created by tetujin on 11/19/2018.
//  Copyright (c) 2018 tetujin. All rights reserved.
//

import UIKit
import com_awareframework_ios_sensor_core

class ViewController: UIViewController {

    var sensor:SampleSensor?
    var sensor2:SampleSensor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  Do any additional setup after loading the view, typically from a nib.
//        sensor = SampleSensor.init(SampleSensor.Config().apply{config in
//            // config.debug = true
//            config.dbType = .REALM
//            config.dbPath = "hoge"
//            config.dbHost = "node.awareframework.com:1001"
//        })
//        sensor?.start()
//
//        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
//            self.sensor?.sync(force: true)
//        }
//        
//        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (timer) in
//            print("start sync")
//            self.sensor?.sync(force: true)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
