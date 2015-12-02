//
//  UIViewController.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 18/10/2015.
//
//

import Foundation
import JRSwizzle

var kDidPushKey = "kDidPushKey"
var kViewDidLoadBlockKey = "kViewDidLoadBlockKey"
var kViewIsLoadedKey = "kViewIsLoadedKey"
var kTargetNavigationController = "kTargetNavigationController"

class ViewDidBlockHandler {
    let handler: () -> Void
    init (handler: () -> Void) {
        self.handler = handler
    }
}

public extension UIViewController {
    public var didPush: Bool {
        let p: AnyObject! = objc_getAssociatedObject(self, &kDidPushKey);
        
        if p == nil {
            return false
        }
        let i = p as! Int
        
        return i == 1 ? true : false
    }
    
    func setDidPush (push:Bool) {
        let i = Int(push)
        objc_setAssociatedObject(self, &kDidPushKey, i, .OBJC_ASSOCIATION_ASSIGN)
    }
    
    public var viewIsLoaded: Bool {
        let p: AnyObject! = objc_getAssociatedObject(self, &kViewIsLoadedKey);
        
        if p == nil {
            return false
        }
        let i = p as! Int
        
        return i == 1 ? true : false
    }
    
    public var onViewDidLoadBlock: (() -> Void)? {
        set {
            if newValue == nil {
                objc_setAssociatedObject(self, &kViewDidLoadBlockKey, nil, .OBJC_ASSOCIATION_ASSIGN)
                return
            }
            let handler = ViewDidBlockHandler(handler: newValue!)
            objc_setAssociatedObject(self, &kViewDidLoadBlockKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
        get {
            let o = objc_getAssociatedObject(self, &kViewDidLoadBlockKey)
            
            if o == nil {
                return nil
            }
            
            let handler = o as? ViewDidBlockHandler
            
            return handler?.handler
        }
    }
    
    public func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() ->Void)?, withData:AnyObject? ) {
        
        
        if viewControllerToPresent.viewIsLoaded {
            if let vc = viewControllerToPresent as? DataReuseRepresentation {
                vc.prepare()
                vc.arrangeWithData(withData)
            } else if let vc = viewControllerToPresent as? DataRepresentation {
                vc.arrangeWithData(withData)
            }
        } else {
            viewControllerToPresent.onViewDidLoadBlock = onTimeout(0.5, handler: { () -> Void in
                if let vc = viewControllerToPresent as? DataRepresentation {
                    vc.arrangeWithData(withData)
                }
            })
        }
        self.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        
        /*self.presentViewController(viewControllerToPresent, animated: flag) { () -> Void in
            
            if let vc = viewControllerToPresent as? DataRepresentation {
                vc.arrangeWithData(withData)
            }
            completion?()
        }*/
    }


    func swizzled_viewDidLoad() {
        self.swizzled_viewDidLoad()
        self.onViewDidLoadBlock?()
        self.onViewDidLoadBlock = nil
        objc_setAssociatedObject(self, &kViewIsLoadedKey, Int(true), .OBJC_ASSOCIATION_ASSIGN)
    }
    
    func swizzled_presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        
        self.setDidPush(true)
        
        self.swizzled_presentViewController(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    public override class func initialize () {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        // make sure this isn't a subclass
        if self !== UIViewController.self {
            return
        }
        
        dispatch_once(&Static.token) { () -> Void in
            
            do {
               try self.jr_swizzleMethod("presentViewController:animated:completion:", withMethod: "swizzled_presentViewController:animated:completion:")
                try self.jr_swizzleMethod("viewDidLoad", withMethod: "swizzled_viewDidLoad")
                
            } catch {
                print("ERROR \(error)")
            }
            
        }
    }
    
}