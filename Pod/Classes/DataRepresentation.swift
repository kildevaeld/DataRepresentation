

@objc public protocol DataRepresentation {
    func arrange ()
    func arrangeWithData(data:AnyObject?)
}

@objc public protocol DataReuseRepresentation : DataRepresentation {
    func prepare ()
}

@objc public protocol DataNavigation {
    var targetNavigationController: UINavigationController? { get set }
}

public func onTimeout(timeout:NSTimeInterval, handler: () -> Void) -> () -> Void {
    
    var called = false
    let fn = {
        if called == false {
            called = true
            handler()
        }
    }
    
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(timeout * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue(), fn)
    
    return fn
}