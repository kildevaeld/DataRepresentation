//
//  UINavigationViewController.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 18/10/2015.
//
//

import Foundation





public extension UINavigationController {
    public func pushViewController(viewController: UIViewController, withData: AnyObject, animated: Bool) {
        
        self.visibleViewController?.setDidPush(true)
        viewController.setDidPush(false)
        let vc = viewController as? DataRepresentation
        
        if viewController.viewIsLoaded {
            
            if let v = viewController as? DataReuseRepresentation {
                v.prepare()
            }
            
            vc?.arrangeWithData(withData)
        } else {
            viewController.onViewDidLoadBlock = onTimeout(0.5, handler: {
                vc?.arrangeWithData(withData)
                viewController.onViewDidLoadBlock = nil
            })
        }
        
        
        self.pushViewController(viewController, animated: animated)
        
        
    }
    
    
    
}