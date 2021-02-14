//
//  BookmarkedAlbumListViewModel.swift
//  Albums
//
//  Created by sam on 15/2/2021.
//

import Foundation
import Combine

class BookmarkedAlbumListViewModel: AlbumViewModelType {
    
    private let store: AlbumStoreProtocol
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(store: AlbumStoreProtocol = AlbumStore.shared) {
        self.store = store
    }
    
    // inputs
    func start() {
        store.get()
            .sink { [weak self] (albums) in
                self?.albums?(albums)
            }
            .store(in: &cancellables)
    }
    
    var didBookmark: ((Album) -> ())?
    var didRefresh: (() -> ())?
    
    // outputs
    var title: String { "Bookmarked Albums" }
    var albums: (([Album]) -> ())?
    var error: ((String) -> ())?
    var refeshing: ((Bool) -> ())?
    var refreshable: Bool { false }
    func isBookmarked(id: Int) -> Bool { return store.isBookmarked(id: id) }
}
