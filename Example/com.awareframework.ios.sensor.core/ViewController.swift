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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
//        let manager = SensorManager.shared
//        manager.addSensor(A())
//        manager.addSensor(B())        
        // manager.getSensors(with: B.classForCoder())
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

public class A:AwareSensor {
    
}

public class B:AwareSensor {
    
}

