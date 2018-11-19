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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
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
            print(x)
        }
        
        // let results = engine.fetch(AccelerometerEvent.self, "y==100") as! Results<Object>
        let results = engine.fetch("table", AwareObject.self, nil)
        
        if let castResults = results as? Results<Object> {
            print("hello")
            
            XCTAssertEqual(castResults.count, number)
            
            for result in castResults {
                print(result)
            }
        }else{
            print("error")
        }
    }
}
