//
//  Dispatch.swift
//  SnapKitchen
//
//  Created by Graham Perks on 1/12/16.
//  Copyright © 2016 Snap Kitchen. All rights reserved.
//

import Foundation

private func dispatch_after_delay(_ delay: TimeInterval, queue: DispatchQueue, block: @escaping ()->()) {
    let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    queue.asyncAfter(deadline: time, execute: block)
}


public func onMainAfterDelay(_ seconds: TimeInterval, block: @escaping ()->()) {
    dispatch_after_delay(seconds, queue: DispatchQueue.main, block: block)
}

public func onBackgroundAfterDelay(_ seconds: TimeInterval, block: @escaping ()->()) {
    let queue = DispatchQueue.global(qos: .default)
    dispatch_after_delay(seconds, queue: queue, block: block)
}


public func onBackgroundAsync(_ block: @escaping ()->()) {
    let queue = DispatchQueue.global(qos: .default)
    queue.async(execute: block)
}

fileprivate let snap_serial_dispatch_queue = DispatchQueue(label: "com.snapkitchen.serial", attributes: [])

public func onBackgroundSeriallyAsync(_ block: @escaping ()->()) {
    snap_serial_dispatch_queue.async(execute: block)
}

public func onBackgroundSeriallySync(_ block: @escaping ()->()) {
    snap_serial_dispatch_queue.sync(execute: block)
}

public func onMainAsync(_ block: @escaping ()->()) {
    let queue = DispatchQueue.main
    queue.async(execute: block)
}

public func onMainSync(_ block: ()->()) {
    let queue = DispatchQueue.main
    queue.sync(execute: block)
}


private let SerialQueue = DispatchQueue(label: "SerialQueue", attributes: [])

public func onSerialAsync(_ block: @escaping ()->()) {
    SerialQueue.async(execute: block)
}

// Array methods to perform a mapping using concurrent queues.
// We add each element to a BlockOperation, and we add that to an OperationQueue.
public extension Array {

    /// Note this map can and will re-order elements!
    /// Only use when the element order doesn't matter.
    public func parallelFlatMap<T>(_ transform: @escaping (Element) -> T?) -> [T] {

        var results = [T]()
        results.reserveCapacity(self.count)
        let op = BlockOperation()
        let q = OperationQueue()
        q.qualityOfService = .userInitiated
        forEach {
            element in
            op.addExecutionBlock {
                if let p = transform(element) {
                    onBackgroundSeriallySync {
                        results.append(p)
                    }
                }
            }
        }

        q.addOperation(op)
        q.waitUntilAllOperationsAreFinished()
        return results
    }


    /// Note this map can and will re-order elements!
    /// Only use when the element order doesn't matter.
    public func parallelMap<T>(_ transform: @escaping (Element) -> T) -> [T] {

        var results = [T]()
        results.reserveCapacity(self.count)
        let op = BlockOperation()
        let q = OperationQueue()
        q.qualityOfService = .userInitiated
        forEach {
            element in
            op.addExecutionBlock {
                let p = transform(element)
                onBackgroundSeriallySync {
                    results.append(p)
                }
            }
        }

        q.addOperation(op)
        q.waitUntilAllOperationsAreFinished()
        return results
    }
}


//MARK: Notifications

public func postNotification(_ name: String, userInfo: [AnyHashable: Any]? = nil) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: nil, userInfo: userInfo)
}


public extension NSObject {
    public func observeNotifications(_ notes: [String:Selector]) {
        let center = NotificationCenter.default
        for note in notes {
            center.addObserver(self, selector: note.1, name: NSNotification.Name(rawValue: note.0), object: nil)
        }
    }

    public func unobserveNotifications(_ notes: [String: Selector]) {
        let center = NotificationCenter.default
        for note in notes {
            center.removeObserver(self, name: NSNotification.Name(rawValue: note.0), object: nil)
        }
    }

    //

    public func observeNotifications(_ notes: [NSNotification.Name: Selector]) {
        let center = NotificationCenter.default
        for note in notes {
            center.addObserver(self, selector: note.1, name: note.0, object: nil)
        }
    }

    public func unobserveNotifications(_ notes: [NSNotification.Name: Selector]) {
        let center = NotificationCenter.default
        for note in notes {
            center.removeObserver(self, name: note.0, object: nil)
        }
    }

    //

    public func observeNotifications(_ notes: [String: (Notification) -> Void ]) -> [NSObjectProtocol] {
        let center = NotificationCenter.default
        let rc = notes.map() { note in
            return center.addObserver(forName: NSNotification.Name(rawValue: note.0), object: nil, queue: nil, using: note.1)
        }

        return rc
    }

    public func unobserveNotifications(_ observers: [NSObjectProtocol] ) {
        let center = NotificationCenter.default
        for observer in observers {
            center.removeObserver(observer)
        }
    }
}
