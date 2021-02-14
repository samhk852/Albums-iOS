//
//  Store.swift
//  Albums
//
//  Created by sam on 15/2/2021.
//

import Foundation
import Combine

protocol StoreProtocol {
    associatedtype T
    func add(_ model: T)
    func delete(_ model: T)
    func get() -> AnyPublisher<[T], Never>
}

class Store<T>: StoreProtocol {
    
    let currentValueSubject: CurrentValueSubject<[T], Never> = CurrentValueSubject([])
    
    func add(_ model: T) {
        
    }
    
    func delete(_ model: T) {
        
    }
    
    func get() -> AnyPublisher<[T], Never> {
        return currentValueSubject.eraseToAnyPublisher()
    }
}
