//
//  StoreProvider.swift
//  Albums
//
//  Created by TD on 15/3/2023.
//

import Foundation

private struct AlbumStoreProviderKey: InjectionKey {
    static var currentValue: AlbumStoreProtocol = AlbumStore.shared
}

extension InjectedValues {
    var albumStoreProvider: AlbumStoreProtocol {
        get { Self[AlbumStoreProviderKey.self] }
        set { Self[AlbumStoreProviderKey.self] = newValue }
    }
}
