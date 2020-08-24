import Foundation
import UIKit

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

public func printValue(_ string: String) {
    let d = Date()
    let df = DateFormatter()
    df.dateFormat = "ss.SSSS"
    
    print("\(string) --- at \(df.string(from: d))")
}


public extension DispatchSource {
  public class func timer(interval: Double, queue: DispatchQueue, handler: @escaping () -> Void) -> DispatchSourceTimer {
    let source = DispatchSource.makeTimerSource(queue: queue)
    source.setEventHandler(handler: handler)
    source.schedule(deadline: .now(), repeating: interval, leeway: .nanoseconds(0))
    source.resume()
    return source
  }
}
