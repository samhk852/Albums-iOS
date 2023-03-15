//
//  AlbumListViewModel.swift
//  Albums
//
//  Created by sam on 15/2/2021.
//

import Foundation
import Combine

protocol AlbumViewModelType {
    // inputs
    func start()
    var didRefresh: (() -> ())? { get set }
    var didSearch: ((String?) -> ())? { get set }
    var didBookmark: ((Album) -> ())? { get set }
    // outputs
    var title: String { get }
    var albums: CurrentValueSubject<Loadable<[Album]>, Never> { get set }
    var refeshing: ((Bool) -> ())? { get set }
    var refreshable: Bool { get }
    func isBookmarked(id: Int) -> Bool
}

class AlbumListViewModel: AlbumViewModelType {
    
    @Injected(\.albumStoreProvider) private var store: AlbumStoreProtocol
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init() {}
    
    // inputs
    func start() {
        didRefresh = { [weak self] in
            self?.keyword.send(nil)
        }
        
        didSearch = { [weak self] keyword in
            self?.keyword.send(keyword)
        }
        
        keyword
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map{ $0 ?? "" }
            .map { [unowned self] keyword in
                self.albums.send(.loading)
                return self.fetchAlbums(keyword: keyword.isEmpty ? "jack+johnson" : keyword)
                    .catch { error -> AnyPublisher<Loadable<[Album]>, Never> in
                        if error is URLError {
                            return Just(.failed("Server Error")).eraseToAnyPublisher()
                        }
                        return Just(.loaded([])).eraseToAnyPublisher()
                    }
            }
            .switchToLatest()
            .sink { [weak self] albums in
                self?.albums.send(albums)
            }
            .store(in: &cancellables)
        
        didBookmark = { [weak self] album in
            self?.store.bookmark(album)
        }
        
        keyword.send("jack+johnson")
    }
    
    var didRefresh: (() -> ())?
    var didSearch: ((String?) -> ())?
    var didBookmark: ((Album) -> ())?
    
    // outputs
    var title: String { "Albums" }
    let keyword: PassthroughSubject<String?, Never> = PassthroughSubject<String?, Never>()
    var albums: CurrentValueSubject<Loadable<[Album]>, Never> = CurrentValueSubject<Loadable<[Album]>, Never>(.initialized)
    var refeshing: ((Bool) -> ())?
    var refreshable: Bool { true }
    func isBookmarked(id: Int) -> Bool { return store.isBookmarked(id: id) }
}

extension AlbumListViewModel {
    func fetchAlbums(keyword: String) -> AnyPublisher<Loadable<[Album]>, Error> {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "itunes.apple.com"
        components.path = "/search"
        components.queryItems = [
            URLQueryItem(name: "term", value: keyword),
            URLQueryItem(name: "entity", value: "album")
        ]
        
        let url = components.url!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .delay(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                return element.data
            }
            .decode(type: AlbumResponse.self, decoder: decoder)
            .map{ .loaded($0.results) }
            .eraseToAnyPublisher()
    }
}

extension AlbumListViewModel {
    struct AlbumResponse: Codable {
        let resultCount: Int
        let results: [Album]
    }
}
