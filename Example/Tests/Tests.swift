import XCTest
import RealmSwift
import com_awareframework_ios_sensor_core

class TestsRealm: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    
    func testInitializationOnAwareSensor(){
        let sensor = AwareSensor.init()
        XCTAssertEqual(sensor.syncState, false)

        sensor.enable()
        XCTAssertEqual(sensor.syncState, true)

        sensor.disable()
        XCTAssertEqual(sensor.syncState, false)

        let sensor2 = AwareSensor.init()
        sensor2.initializeDbEngine(config: SensorConfig())
        XCTAssertNil(sensor2.dbEngine?.config.encryptionKey)
        XCTAssertNil(sensor2.dbEngine?.config.path)
        XCTAssertNil(sensor2.dbEngine?.config.host)
        XCTAssertEqual(sensor2.dbEngine?.config.type, DatabaseType.NONE)
        
        let config = SensorConfig.init()
        config.dbHost = "sample.server.awareframework.com"
        config.dbPath = "aware_hoge"
        config.dbType = DatabaseType.REALM
        config.dbEncryptionKey = "testtest"
        sensor.initializeDbEngine(config: config)
        XCTAssertEqual(config.dbHost!, sensor.dbEngine?.config.host!)
        XCTAssertEqual(config.dbPath, sensor.dbEngine?.config.path!)
        XCTAssertEqual(config.dbType, sensor.dbEngine?.config.type)
        XCTAssertEqual(config.dbEncryptionKey!, sensor.dbEngine?.config.encryptionKey!)
    }
    
    func testInitializationOnDbSyncConfig(){
        let config1 = DbSyncConfig.init()
        XCTAssertTrue(config1.removeAfterSync)
        XCTAssertEqual(config1.batchSize, 100)
        XCTAssertFalse(config1.markAsSynced)
        XCTAssertFalse(config1.skipSyncedData)
        XCTAssertFalse(config1.keepLastData)
        XCTAssertNil(config1.deviceId)
        XCTAssertFalse(config1.debug)
        
        let dict:Dictionary<String,Any> =  [
                     "removeAfterSync":false,
                     "batchSize":200,
                     "markAsSynced":true,
                     "skipSyncedData":true,
                     "keepLastData":true,
                     "deviceId":"hogehogehoge",
                     "debug":true]
        
        let config2 = DbSyncConfig.init(dict)
        XCTAssertFalse(config2.removeAfterSync)
        XCTAssertEqual(config2.batchSize, 200)
        XCTAssertTrue(config2.markAsSynced)
        XCTAssertTrue(config2.skipSyncedData)
        XCTAssertTrue(config2.keepLastData)
        XCTAssertEqual(config2.deviceId, "hogehogehoge")
        XCTAssertTrue(config2.debug)
        
        // test with wrong values
        let dict3:Dictionary<String,Any> =  [
            "removeAfterSync":1234,
            "batchSize":"123",
            "markAsSynced":444,
            "skipSyncedData":23,
            "keepLastData":444,
            "deviceId":123,
            "debug":"hoge"]
        let config3 = DbSyncConfig.init(dict3)
        XCTAssertTrue(config3.removeAfterSync)
        XCTAssertEqual(config3.batchSize, 100)
        XCTAssertFalse(config3.markAsSynced)
        XCTAssertFalse(config3.skipSyncedData)
        XCTAssertFalse(config3.keepLastData)
        XCTAssertNil(config3.deviceId)
        XCTAssertFalse(config3.debug)
    }
    
    
    func testInitializationOnSetConfig(){
        // DatabaseType based DB Type setting (NONE)
        var config = SensorConfig(["dbType":DatabaseType.NONE]);
        XCTAssertEqual(config.dbType, DatabaseType.NONE)
        
        // DatabaseType based DB Type setting (REALM)
        config = SensorConfig(["dbType":DatabaseType.REALM]);
        XCTAssertEqual(config.dbType, DatabaseType.REALM)
        
        // Int based DB Type setting (NONE)
        config.set(config: ["dbType":0])
        XCTAssertEqual(config.dbType, DatabaseType.NONE)
        
        // Int based DB Type setting (REALM)
        config.set(config: ["dbType":1])
        XCTAssertEqual(config.dbType, DatabaseType.REALM)
    }
    
    func testMethodsOnUtils(){
        ////////////////////////////////
        // URL modification //
        let hostName = "node.awareframework.com"
        
        // test in the ideal condition
        var newUrl = AwareUtils.cleanHostName(hostName)
        XCTAssertEqual(newUrl, hostName)

        // test removing "https://"
        newUrl = AwareUtils.cleanHostName("https://"+hostName)
        XCTAssertEqual(newUrl, hostName)

        // test remove "http://"
        newUrl = AwareUtils.cleanHostName("http://"+hostName)
        XCTAssertEqual(newUrl, hostName)
    }

    func testRealmEngine(){
        // remove old database
        let documentDirFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let url = documentDirFileURL.appendingPathComponent("sample.realm")
        do {
            try FileManager.default.removeItem(at: url)
        }catch{
            print(error)
        }
        
        // init realm engine
        let engine = Engine.Builder().setType(DatabaseType.REALM).setPath("sample").build()
        
        // data save on main thread
        let number = 100
        for _ in 0..<number {
            let event:AwareObject = AwareObject()
            // print("[\(i)]",event.timestamp)
            engine.save(event)
        }
        let results = engine.fetch(AwareObject.self, nil)
        if let castResults = results as? Results<Object> {
            XCTAssertEqual(castResults.count, 100)
        }
        
        // data save on sub-thread
        let realmExpect = XCTestExpectation.init(description: "multi-thread realm engin test")
        let queue = OperationQueue()
        queue.addOperation { () -> Void in
            for _ in 0..<number {
                let event:AwareObject = AwareObject()
                // print("[\(i)]",event.timestamp)
                // The realm engine try to save the data into database on the current thread.
                engine.save(event)
            }
            let results2 = engine.fetch(AwareObject.self, nil)
            if let castResults = results2 as? Results<Object> {
                XCTAssertEqual(castResults.count, 200)
            }
            realmExpect.fulfill()
        }
        wait(for: [realmExpect], timeout: 10)
        
        engine.fetch(AwareObject.self, nil) { (resultsObject, error) in
            if let results = resultsObject as? Results<Object>{
                XCTAssertEqual(results.count, 200)
            }else{
                XCTFail()
            }
        }
        
        engine.removeAll(AwareObject.self){ error in
            XCTAssertNil(error)
        }
        
        engine.save(AwareObject(value:["timestamp":1])) { (error) in
            XCTAssertNil(error)
        }
        
        engine.fetch(AwareObject.self, "timestamp=1") { (resultsObject, error) in
            XCTAssertNil(error)
            if let results = resultsObject as? Results<Object>{
                XCTAssertEqual(results.count, 1)
            }else{
                XCTFail()
            }
        }
        
        engine.remove(AwareObject.self, "timestamp=1") { (error) in
            XCTAssertNil(error)
        }
        
        /**
         * [HOW TO DELTE OBJECTS IN REALM ENGINE]
         * RealmEngine provides 4 data delete method from Realm DB.
         *
         * (A) `-remove(objectType:filter:)`
         * (B) `-fetch(objectType:filter:complition:error)`
         * (C) use Realm instance by `-getRealmInstance()`
         * (D) `-removeAll()`
         */
        
        // Example of (A)
        // engine.remove(AwareObject.self, nil)
    
        // Example of (B)
        // Fetch and remove data using Realm Engine.
        // NOTE: You can not control a Realm instance from other thread
        if let realmEngine = engine as? RealmEngine {
            realmEngine.fetch(AwareObject.self, nil) { (resultsObject, realmInstance, error) in
                if let results = resultsObject, let realm = realmInstance {
                    // success
                    realmEngine.remove(Array(results), in: realm)
                    XCTAssertEqual(results.count,0)
                    /// The following code will be fail with 'Realm accessed from incorrect thread.' ///
                    /*
                     let queue = OperationQueue()
                     queue.addOperation { () -> Void in
                     realmEngine.remove(Array(result), in: realm)
                     XCTAssertEqual(result.count,0)
                     }
                     */
                    realmEngine.save(AwareObject()){ (event) in
                        
                    }
                }
            }
        }
        
        // Example of (C)
        // You can Realm instance directoly
        if let realmEngine = engine as? RealmEngine {
            if let realm = realmEngine.getRealmInstance(){
                do{
                    let object1 = AwareObject()
                    // use write scope
                    try realm.write {
                        realm.add(object1)
                        realm.delete(object1)
                    }
                    
                    // use transaction
                    realm.beginWrite()
                    let object2 = AwareObject()
                    realm.add(object2)
                    realm.delete(object2)
                    try realm.commitWrite()
                }catch{
                    print(error)
                }
            }
        }
        
        // Example of (D)
        // Remove all of objects from the database
        // engine.removeAll(AwareObject.self)
    }
    
    var helper:RealmDbSyncHelper? = nil
    
    func testSyncHelpeer(){
        print(Thread.isMainThread)
        let sensor = AwareSensor()
        let config = SensorConfig()
        config.dbHost = "node.awareframework.com:1001"
        config.dbType = .REALM
        config.debug = true
        sensor.initializeDbEngine(config: config )
        if let engine = sensor.dbEngine {
            for i in 0..<10 {
                engine.save(AwareObject(value:["timestamp":i]))
            }
        }
        
        let expectation = XCTestExpectation.init(description: "sync task")
        helper = RealmDbSyncHelper.init(engine: sensor.dbEngine as! RealmEngine,
                                            host: config.dbHost!,
                                            tableName: "sampleTable",
                                            objectType: AwareObject.self, config: DbSyncConfig().apply{setting in
                                                setting.batchSize = 1
                                                setting.debug = true
                                                setting.dispatchQueue = DispatchQueue(label: "com.awareframework.ios.sensor.core.syncTask")
        })
        helper?.run(completion: { (status, error) in
            // The callback is always on the main thread
            XCTAssertTrue(Thread.isMainThread)
            // status: true(=success), false(=failure)
            XCTAssertTrue(status)
            XCTAssertNil(error)
            expectation.fulfill()
        })
        
        self.wait(for: [expectation], timeout: 180)
    }
    
    func testDbSyncManager(){
        
        let interval:Double = 0.5
        let expectation = self.expectation(description: "DbSyncNotificationExpectation_" + String(interval))
        let syncManager =
            DbSyncManager.Builder()
            .setWifiOnly(false)
            .setWifiOnly(false)
            .setSyncInterval(interval)
            .build()
        
        syncManager.start()
        
        // Observe the sync notification
        NotificationCenter.default.addObserver(forName: Notification.Name.Aware.dbSyncRequest,
                                               object: nil,
                                               queue: .main) { (notification) in
            print(notification)
            expectation.fulfill()
            XCTAssertNoThrow(notification)
        }
        // Wait 60 + 10 second
        wait(for: [expectation], timeout: 60+10)
        
        // test ignoring a wrong interval value
        let syncManager2 = DbSyncManager.Builder().setSyncInterval(-1).build()
        XCTAssertEqual(syncManager2.CONFIG.syncInterval, 1.0)

    }
    
    func testCommonUUID(){
        
        UserDefaults.standard.removeObject(forKey: "com.aware.ios.sensor.core.key.deviceid")
        
        // The key is saved on iCloud
        let uuid = AwareUtils.getCommonDeviceId()
        for i in 0..<10 {
            print("[\(i)]",uuid)
            if(uuid == AwareUtils.getCommonDeviceId()){
                XCTAssertNoThrow(uuid)
            }else{
                XCTAssertThrowsError(uuid)
            }
        }
    }
    
    func testAwareObjectDefaultValues(){
        let awareObject = AwareObject()
        XCTAssertGreaterThanOrEqual(awareObject.timestamp,0)
        XCTAssertEqual(awareObject.deviceId, AwareUtils.getCommonDeviceId())
        XCTAssertEqual(awareObject.label, "")
        XCTAssertEqual(awareObject.timezone, AwareUtils.getTimeZone())
        XCTAssertEqual(awareObject.os, "ios")
        
        let dict = awareObject.toDictionary()
        XCTAssertNotNil(dict)
        
        XCTAssertEqual(dict["timestamp"] as! Int64, awareObject.timestamp)
        XCTAssertEqual(dict["deviceId"] as! String, awareObject.deviceId)
        XCTAssertEqual(dict["label"] as! String, awareObject.label)
        XCTAssertEqual(dict["timezone"] as! Int, awareObject.timezone)
        XCTAssertEqual(dict["os"] as! String, awareObject.os)
        XCTAssertEqual(dict["jsonVersion"] as! Int, awareObject.jsonVersion)
        
        let newTime = Int64(Date().timeIntervalSince1970 * 1000.0)
        let newUUID = UUID.init().uuidString
        awareObject.timestamp = newTime
        awareObject.deviceId = newUUID
        awareObject.label = "sample"
        awareObject.timezone = 5
        awareObject.os = "watchOS"
        awareObject.jsonVersion = 12
        let newDict = awareObject.toDictionary()
        
        XCTAssertEqual( newDict["timestamp"] as! Int64, newTime)
        XCTAssertEqual( newDict["deviceId"] as! String, newUUID)
        XCTAssertEqual( newDict["label"] as! String, "sample")
        XCTAssertEqual( newDict["timezone"] as! Int, 5)
        XCTAssertEqual( newDict["os"] as! String, "watchOS")
        XCTAssertEqual( newDict["jsonVersion"] as! Int, 12)
        
    }
    
    func testSensorManager(){
        let manager = SensorManager.shared
        let sensor = AwareSensor()
        sensor.id = "sample"
        sensor.start()
        sensor.stop()
        sensor.enable()
        sensor.enable()
        sensor.disable()
        sensor.set(label: "label")
        sensor.sync(force: false)
        manager.addSensor(sensor)
        XCTAssertEqual(sensor, manager.getSensor(with: sensor.id)!)
        XCTAssertEqual(sensor, manager.getSensor(with: sensor)!)
        XCTAssertTrue(manager.isExist(with: "sample"))
        XCTAssertTrue(manager.isExist(with: sensor.classForCoder) )
        manager.removeSensor(id: "sample")
        XCTAssertFalse(manager.isExist(with: "sample"))
        XCTAssertFalse(manager.isExist(with: sensor.classForCoder) )
        XCTAssertEqual(manager.sensors.count, 0)
        XCTAssertNil(manager.getSensor(with: "sample"))
        XCTAssertNil(manager.getSensor(with: sensor))
        XCTAssertNil(manager.getSensors(with: sensor.classForCoder))
        
        let sensor2 = AwareSensor()
        manager.addSensors([sensor,sensor2])
        XCTAssertEqual(manager.sensors.count, 2)
        manager.removeSensors(with: AwareSensor.classForCoder())
        XCTAssertEqual(manager.sensors.count, 0)
        
        manager.startAllSensors()
        manager.stopAllSensors()
    }
}
