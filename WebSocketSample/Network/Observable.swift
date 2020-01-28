//
//  Observable.swift
//  WebSocketSample
//
//  Created by Vladyslav Vcherashnii on 27.01.2020.
//  Copyright © 2020 Vladyslav Vcherashnii. All rights reserved.
//

import Foundation

@objc
protocol ObservableProtocol: class { }

protocol Observable {
    
    associatedtype Observer: ObservableProtocol
    var observers: [Observer] { get set }
    
    mutating func add(observer: Observer)
    mutating func remove(observer: Observer)
    func notifyObservers(_ block: (Observer) -> Void)
}

extension Observable {
    mutating func add(observer: Observer) {
        if !self.observers.contains(where: { observer === $0 }) {
            self.observers.append(observer)
        }
    }
    
    mutating func remove(observer: Observer) {
        for (index, entry) in observers.enumerated() {
            if entry === observer {
                observers.remove(at: index)
                return
            }
        }
    }
    
    func notifyObservers(_ block: (Observer) -> Void) {
        observers.forEach { (observer) in
            block(observer)
        }
    }
}
