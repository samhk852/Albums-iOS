//
//  AlbumListViewModel.swift
//  Albums
//
//  Created by sam on 15/2/2021.
//

import Foundation

protocol AlbumViewModelType {
    // inputs
    func start()
    var didRefresh: (() -> ())? { get set }
    var didBookmark: ((Album) -> ())? { get set }
    // outputs
    var title: String { get }
    var albums: (([Album]) -> ())? { get set }
    var error: ((String) -> ())? { get set }
    var refeshing: ((Bool) -> ())? { get set }
    var refreshable: Bool { get }
    func isBookmarked(id: Int) -> Bool
}

class AlbumListViewModel: AlbumViewModelType {
    
    private let url: URL = URL(string: "https://itunes.apple.com/search?term=jack+johnson&entity=album")!
    private let store: AlbumStoreProtocol
    
    init(store: AlbumStoreProtocol = AlbumStore.shared) {
        self.store = store
    }
    
    // inputs
    func start() {
        didRefresh = { [weak self] in
            self?.fetchAlbums()
        }
        
        didBookmark = { [weak self] album in
            self?.store.bookmark(album)
        }
        
        fetchAlbums()
    }
    
    var didRefresh: (() -> ())?
    var didBookmark: ((Album) -> ())?
    
    // outputs
    var title: String { "Albums" }
    var albums: (([Album]) -> ())?
    var error: ((String) -> ())?
    var refeshing: ((Bool) -> ())?
    var refreshable: Bool { true }
    func isBookmarked(id: Int) -> Bool { return store.isBookmarked(id: id) }
}

extension AlbumListViewModel {
    func fetchAlbums() {
        refeshing?(true)
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            self?.refeshing?(false)
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let albumResponse = try decoder.decode(AlbumResponse.self, from: data)
                self?.albums?(albumResponse.results)
            } catch let error {
                self?.error?(error.localizedDescription)
            }
        }.resume()
    }
}

extension AlbumListViewModel {
    struct AlbumResponse: Codable {
        let resultCount: Int
        let results: [Album]
    }
}
