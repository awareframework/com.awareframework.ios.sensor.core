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
    
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func testSettingConfig(){
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
            engine.save([event], "")
        }
        
        let results = engine.fetch("table", AwareObject.self, nil)
        
        if let castResults = results as? Results<Object> {
            XCTAssertEqual(castResults.count, number)
            for result in castResults {
                print(result)
            }
        }
    }
}
