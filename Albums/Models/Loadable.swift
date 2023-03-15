//
//  Loadable.swift
//  Albums
//
//  Created by TD on 15/3/2023.
//

import Foundation

enum Loadable<T> {
    case initialized
    case loading
    case loaded(T)
    case failed(String)
}

extension Loadable {
    var isLoading: Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
    
    var value: T? {
        switch self {
        case let .loaded(value): return value
        default: return nil
        }
    }
    
    var error: String? {
        switch self {
        case let .failed(msg): return msg
        default: return nil
        }
    }
}
