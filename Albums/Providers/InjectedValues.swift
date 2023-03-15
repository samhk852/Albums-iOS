//
//  InjectedValues.swift
//  Albums
//
//  Created by TD on 15/3/2023.
//

import Foundation

public protocol InjectionKey {
    associatedtype Value
    static var currentValue: Self.Value { get set }
}

struct InjectedValues {
    private static var current = InjectedValues()
    
    static subscript<K>(key: K.Type) -> K.Value where K : InjectionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }
    
    static subscript<T>(_ keyPath: WritableKeyPath<InjectedValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}
