import XCTest
import RealmSwift
import com_awareframework_ios_sensor_core

class TestsRealm: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        // NSUbiquitousKeyValueStore.default.removeObject(forKey: "com.aware.ios.sensor.core.key.deviceid")
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
    
    
    func testSensorInitialization(){
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
    
    func testDbSyncConfigInit(){
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
    
    func testCleanUrl(){
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
    
    func testSetConfig(){
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
    
    
    func testSavingFunction(){
        let engine = Engine.Builder().setType(DatabaseType.REALM).build()
        let number = 10
        for x in 0..<number {
            let event:AwareObject = AwareObject()
            switch x{
            case 0..<5:
                event.timestamp = 100
                break
            default:
                break
            }
            engine.save(event, "table")
        }
        
        let results = engine.fetch("table", AwareObject.self, nil)
        
        if let castResults = results as? Results<Object> {
            XCTAssertEqual(castResults.count, number)
            for result in castResults {
                print(result)
            }
        }
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
        self.waitForExpectations(timeout: Double(interval * 60) + 5.0, handler: nil)
        
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
}
