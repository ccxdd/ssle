//
//  GCDTimer.swift
//  ProtocolDemo
//
//  Created by ccxdd on 2016/11/22.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

import UIKit

public class GCDTimer {
    public enum TimerType {
        case forward(Int), reverse(Int), repeats
    }
    
    private var timer: DispatchSourceTimer?
    public private(set) var isRunning = false
    
    public init(interval: DispatchTimeInterval = .seconds(1), delay: DispatchTimeInterval = .seconds(0), type: TimerType, queue: DispatchQueue = .main, handle: @escaping (Int) -> Void) {
        var max: Int = 0
        var count = 0
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now() + delay, repeating: interval, leeway: interval)
        switch type {
        case .repeats:
            timer?.setEventHandler {
                count += 1
                handle(count)
            }
        case .forward(let i):
            max = i
            timer?.setEventHandler {
                count += 1
                handle(count)
                if count >= max {
                    self.stop()
                    count = 0
                }
            }
        case .reverse(let i):
            max = i
            timer?.setEventHandler {
                max -= 1
                handle(max)
                if max <= 0 {
                    self.stop()
                    count = 0
                }
            }
        }
    }
    
    
    public func cancel() {
        timer?.setEventHandler {}
        timer?.cancel()
        start()
    }
    
    public func start() {
        if !isRunning {
            timer?.resume()
            isRunning = true
            //print("time start")
        }
    }
    
    public func stop() {
        if isRunning {
            timer?.suspend()
            isRunning = false
            //print("time stop")
        }
    }
}
