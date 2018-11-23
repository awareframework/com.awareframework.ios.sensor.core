//
//  SensorManager.swift
//  com.awareframework.ios.sensor.core
//
//  Created by Yuuki Nishiyama on 2018/11/23.
//

import UIKit

public class SensorManager: NSObject {
    
    /**
     * Singleton:
     */
    public static let shared = SensorManager()
    private override init() {
        
    }
    
    public var sensors:Array<AwareSensor> = []
    
    ////////////////////////////////////////
    
    public func addSensors(_ sensors:[AwareSensor]){
        for sensor in sensors {
            self.addSensor(sensor)
        }
    }
    
    public func addSensor(_ sensor:AwareSensor) {
        sensors.append(sensor)
    }
    
    
    public func removeSensors(with type: AnyClass ){
        for (index, sensor) in sensors.enumerated() {
            if sensor.classForCoder == type {
                self.sensors.remove(at: index)
                self.removeSensors(with: type)
            }
        }
    }
    
    public func removeSensor(id:String){
        for (index, sensor) in sensors.enumerated() {
            if sensor.id == id {
                self.sensors.remove(at: index)
                return
            }
        }
    }
    
    public func getSensors(with type: AnyClass ) -> [AwareSensor]?{
        var foundSensors:Array<AwareSensor> = []
        for sensor in sensors {
            if type == sensor.classForCoder {
                foundSensors.append(sensor)
            }
        }
        if foundSensors.count == 0 {
            return nil
        }else{
            return foundSensors
        }
    }
    
    public func isExist(with id:String) -> Bool {
        for sensor in sensors {
            if sensor.id == id {
                return true
            }
        }
        return false
    }
    
    public func isExist(with type:AnyClass) -> Bool {
        for sensor in sensors {
            if type == sensor.classForCoder {
                return true
            }
        }
        return false
    }
    
    
    /////////////////////////////////////////////
    public func getSensor(with id: String) -> AwareSensor? {
        for sensor in sensors{
            if sensor.id == id {
                return sensor;
            }
        }
        return nil
    }
    
    public func syncAllSensors(force:Bool = false){
        for sensor in sensors {
            sensor.sync(force: force)
        }
    }
    
    public func stopAllSensors(){
        for sensor in sensors {
            sensor.stop()
        }
    }
    
    public func startAllSensors(){
        for sensor in sensors {
            sensor.start()
        }
    }
}