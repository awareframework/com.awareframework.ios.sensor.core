//
//  DataSyncHelper.swift
//  com.aware.ios.sensor.core
//
//  Created by Yuuki Nishiyama on 2018/10/18.
//

import UIKit
import Foundation
import RealmSwift
import SwiftyJSON

open class RealmDbSyncHelper:NSObject, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {

    // https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_in_the_background?language=objc
    // https://qiita.com/yimajo/items/a591cf1b47d45db2b6ca
    
    var uploadingObjects = Array<AwareObject>()
    var receivedData = Data()
    var urlSession:URLSession?
    
    var endFlag = false
    
    var engine:RealmEngine
    var host:String
    var objectType:Object.Type
    var tableName:String
    var config:DbSyncConfig
    var filterTime:Int64 = Int64(Date().timeIntervalSince1970 * 1000.0)
    var filter = ""
    var completion:DbSyncCompletionHandler? = nil
    
    var progress:Double = 0.0
    var currentNumOfCandidates:Int = 0
    var originalNumOfCandidates:Int = 0
    
    public init(engine:RealmEngine, host:String, tableName:String, objectType:Object.Type, config:DbSyncConfig){
        self.engine     = engine
        self.host       = host
        self.tableName  = tableName
        self.objectType = objectType
        self.config     = config
        self.filter     = "timestamp <= \(self.filterTime)"
    }
    
    open func run(){
        self.run(completion:nil)
    }
    
    open func run(completion:DbSyncCompletionHandler?){
        
        self.completion = completion
        
        self.urlSession = {
            if self.config.backgroundSession{
                let sessionConfig = URLSessionConfiguration.background(withIdentifier: "aware.sync.task.identifier.\(tableName)")
                sessionConfig.allowsCellularAccess = true
                sessionConfig.sharedContainerIdentifier = "aware.sync.task.shared.container.identifier"
                return URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            }else{
                let sessionConfig = URLSessionConfiguration.default
                sessionConfig.allowsCellularAccess = true
                sessionConfig.sharedContainerIdentifier = "aware.sync.task.shared.container.identifier"
                return URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            }
        }()
        
        urlSession?.getAllTasks(completionHandler: { (tasks) in
            if tasks.count == 0 {
                if let unwrappedCandidates = self.engine.fetch(self.objectType, self.filter) as? Results<Object>{

                    if self.originalNumOfCandidates == 0 {
                        self.originalNumOfCandidates = unwrappedCandidates.count
                    }
                    self.currentNumOfCandidates = unwrappedCandidates.count

                    
                    if self.config.debug {
                        print("AWARE::Core", self.tableName,
                              "Data count = \(unwrappedCandidates.count)")
                    }
                    
                    if unwrappedCandidates.count == 0 {
                        if (self.config.debug) {
                            print("AWARE::Core", self.tableName, "A sync process is done: No Data")
                        }
                        if let pCallback = self.config.progressHandler {
                            DispatchQueue.main.async {
                                pCallback(1.0, nil)
                            }
                        }
                        if let callback = self.completion {
                            DispatchQueue.main.async {
                                callback(true, nil)
                            }
                        }
                        return
                    }
                    
                    var dataArray = Array<Dictionary<String, Any>>()
                    self.uploadingObjects.removeAll()
                    let objects = unwrappedCandidates.sorted(byKeyPath: "timestamp",
                                                             ascending: true).prefix(self.config.batchSize)
                    if objects.count < self.config.batchSize {
                        self.endFlag = true
                    }
                    for object in objects {
                        let castResult = object as? AwareObject
                        if let unwrappedCastResult = castResult{
                            self.uploadingObjects.append(unwrappedCastResult)
                            dataArray.append(unwrappedCastResult.toDictionary())
                        }
                    }
                    
                    
                    
                    
                    /// set parameter
                    let deviceId = AwareUtils.getCommonDeviceId()
                    var requestStr = ""
                    do{
                        var data = ""
                        if (self.config.compactDataFormat) {
                            var aggregatedData: [String: [Any]] = [:]
                            for dict in dataArray {
                                for (key, value) in dict {
                                    if (key != "os" && key != "jsonVersion" && key != "deviceId" && key != "timezone") {
                                        aggregatedData[key, default: []].append(value)
                                    }
                                }
                            }
                            let requestObject = try JSONSerialization.data(withJSONObject:aggregatedData)
                            data = String(data: requestObject, encoding: .utf8)!
                        }else{
                            let requestObject = try JSONSerialization.data(withJSONObject:dataArray)
                            data = String(data: requestObject, encoding: .utf8)!
                        }
                        
                        /// 最終的に取得するPOSTのBODY部分
                        requestStr = "device_id=\(deviceId)&data=\(data)"
                    }catch{
                        if self.config.debug {
                            print(error)
                        }
                    }

                    
                    let hostName = AwareUtils.cleanHostName(self.host)
                    
                    let url = URL.init(string: "https://"+hostName+"/"+self.tableName+"/insert")
                    if let unwrappedUrl = url, let session = self.urlSession {
                        var request = URLRequest.init(url: unwrappedUrl)
                        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                        request.httpBody =  requestStr.data(using: .utf8)
                        request.timeoutInterval = 30
                        request.httpMethod = "POST"
                        request.allowsCellularAccess = true
                        let task = session.dataTask(with: request) // dataTask(with: request)
                        
                        task.resume()
                    }
                }
                
            }
        })
    }
    
    //////////
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        if let httpResponse = response as? HTTPURLResponse{
            if(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300){
                completionHandler(URLSession.ResponseDisposition.allow);
            }else{
                completionHandler(URLSession.ResponseDisposition.cancel);
                if config.debug { print("AWARE::Core","\( tableName )=>\(response)") }
                // print("\( config.table! )=>\(httpResponse.statusCode)")
            }
        }
    }
    
    open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let e = error {
            print(#function)
            print(e)
        }
    }
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // print(#function)
        var responseState = false
        
        if let unwrappedError = error {
            if config.debug { print("AWARE::Core","failed: \(unwrappedError)") }
        }else{
            /**
             * TODO: this is an error handler
             * aware-server-node ( https://github.com/awareframework/aware-server-node/blob/master/handlers/errorHandlers.js )
             * generates 201 even if the query is wrong ...
             * {"status":404,"message":"Not found"} with error code 201
             *
             * The value should be as follows:
             *{"status":false,"message":"Not found"} with error code 404
             */
            do {
                if (!receivedData.isEmpty) {
                    let json = try JSON.init(data: receivedData)
                    if json["status"] == 404 {
                        responseState = false
                    }else{
                        // normal condition
                        responseState = true
                    }
                }
            }catch {
                if ( config.debug ) {
                    print("AWARE::Core","[\(tableName)]: Error: A JSON convert error: \(error)")
                }
                // An upload task is done correctly.
                responseState = true
            }
        }
        
        let response = String.init(data: receivedData, encoding: .utf8)
        if let unwrappedResponse = response{
            if self.config.debug {
                print("AWARE::Core","[Server Response][\(self.tableName)][\(self.host)]", unwrappedResponse)
            }
        }
        
        if (responseState){
            if config.debug {
                print("AWARE::Core","[\(tableName)] Success: A sync task is done correctly.")
            }
            
            session.finishTasksAndInvalidate()
            
            self.engine.fetch(objectType, filter, completion:{ (resultsObject, realmInstance, error) in
                if let results = resultsObject, let realm = realmInstance {
                    let objects = results.sorted(byKeyPath: "timestamp",ascending:true).prefix(self.config.batchSize)
                    self.engine.remove(Array(objects), in: realm)
                }
            })
            
        }else{
            session.invalidateAndCancel()
        }
        
        receivedData = Data()
        
        if responseState {
            // A sync process is succeed
            if endFlag {
                if config.debug { print("AWARE::Core","A sync process (\(tableName)) is done!") }
                
                if let pCallback = self.config.progressHandler {
                    DispatchQueue.main.async {
                        pCallback(1, nil)
                    }
                }
                
                if let callback = self.completion {
                    DispatchQueue.main.async {
                        callback(true, error)
                    }
                }else{
                    print("self.completion is `nil`")
                }
            }else{
                if config.debug { print("AWARE::Core","A sync task(\(tableName)) is done. Execute a next sync task.") }
                DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + 1 ) {
                    if let pCallback = self.config.progressHandler {
                        let p = 1.0 - (Double(self.currentNumOfCandidates)/Double(self.originalNumOfCandidates))
                        DispatchQueue.main.async{
                            pCallback(p, nil)
                        }
                    }
                    
                    if let queue = self.config.dispatchQueue {
                        queue.async {
                            self.run(completion: self.completion)
                        }
                    }else{
                        self.run(completion: self.completion)
                    }
                }
            }
        }else{
            //A sync process is failed
            if config.debug { print("AWARE::Core","A sync task (\(tableName)) is faild.") }
            if let callback = self.completion {
                DispatchQueue.main.async {
                    callback(false, error)
                }
            }
        }
    }
    
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        /// show progress of an upload process
        if config.debug {
            print("AWARE::Core","\(task.taskIdentifier): \( NSString(format: "%.2f",Double(totalBytesSent)/Double(totalBytesExpectedToSend)*100.0))%")
        }
    }
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if config.debug{
            print("AWARE::Core","\(#function):\(dataTask.taskIdentifier)")
        }
        self.receivedData.append(data)
    }
    
    public func stop() {
        if let session = self.urlSession {
            session.getAllTasks { (sessionTasks) in
                for task in sessionTasks{
                    if self.config.debug { print("AWARE::Core","[\(task.taskIdentifier)] session task is canceled.") }
                    task.cancel()
                }
            }
        }
    }
}



//////////////////////////

//// Set a HTTP Body
//                    let timestamp = Int64(Date().timeIntervalSince1970/1000.0)
//                    let deviceId = AwareUtils.getCommonDeviceId()
//                    var requestStr = ""
//                    let requestParams: Dictionary<String, Any>
//                        = ["timestamp":timestamp,
//                           "deviceId":deviceId,
//                           "data":dataArray,
//                           "tableName":self.tableName]
//                    do{
//                        let requestObject = try JSONSerialization.data(withJSONObject:requestParams)
//                        requestStr = String.init(data: requestObject, encoding: .utf8)!
//                        // requestStr = requestStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlUserAllowed)!
//                    }catch{
//                        print(error)
//                    }
//
//                    if self.config.debug {
//                        // print(requestStr)
//                    }
//
//                    let hostName = AwareUtils.cleanHostName(self.host)
//
//                    let url = URL.init(string: "https://"+hostName+"/insert/")
//                    if let unwrappedUrl = url, let session = self.urlSession {
//                        var request = URLRequest.init(url: unwrappedUrl)
//                        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
//                        request.httpBody = requestStr.data(using: .utf8)
//                        request.timeoutInterval = 30
//                        request.httpMethod = "POST"
//                        request.allowsCellularAccess = true
//                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                        request.setValue("application/json", forHTTPHeaderField: "Accept")
//                        let task = session.dataTask(with: request) // dataTask(with: request)
//
//                        task.resume()
//                    }

