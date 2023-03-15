//
//  BookmarkedAlbumListViewModel.swift
//  Albums
//
//  Created by sam on 15/2/2021.
//

import Foundation
import Combine

class BookmarkedAlbumListViewModel: AlbumViewModelType {
    
    @Injected(\.albumStoreProvider) private var store: AlbumStoreProtocol
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init() {}
    
    // inputs
    func start() {
        getAlbums()
        
        didSearch = { [weak self] keyword in
            self?.keyword.send(keyword)
        }
    }
    
    var didBookmark: ((Album) -> ())?
    var didRefresh: (() -> ())?
    var didSearch: ((String?) -> ())?
    
    // outputs
    var title: String { "Bookmarked Albums" }
    let keyword: PassthroughSubject<String?, Never> = PassthroughSubject<String?, Never>()
//    var albums: (([Album]) -> ())?
    var albums: CurrentValueSubject<Loadable<[Album]>, Never> = CurrentValueSubject<Loadable<[Album]>, Never>(.initialized)
    var error: ((String) -> ())?
    var refeshing: ((Bool) -> ())?
    var refreshable: Bool { false }
    func isBookmarked(id: Int) -> Bool { return store.isBookmarked(id: id) }
}

extension BookmarkedAlbumListViewModel {
    func getAlbums() {
        store.get().combineLatest(keyword.prepend(nil))
            .map{ albums, keyword -> Loadable<[Album]> in
                guard let keyword = keyword, !keyword.isEmpty else { return .loaded(albums) }
                let filterAlbums = albums.filter{ $0.collectionName.contains(keyword) || $0.artistName.contains(keyword)}
                return .loaded(filterAlbums)
            }
            .assign(to: \.value, on: albums)
            .store(in: &cancellables)
    }
}
