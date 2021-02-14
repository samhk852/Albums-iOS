//
//  AlbumStore.swift
//  Albums
//
//  Created by sam on 15/2/2021.
//

import Foundation
import Combine

protocol AlbumStoreProtocol {
    func bookmark(_ album: Album)
    func isBookmarked(id: Int) -> AnyPublisher<Bool, Never>
    func isBookmarked(id: Int) -> Bool
    func get() -> AnyPublisher<[Album], Never>
}

class AlbumStore: Store<Album>, AlbumStoreProtocol {
    
    private let storeKey: String = "bookmarkedAlbumList"
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        super.init()
        if let bookmarkedAlbumList = userDefaults.object(forKey: storeKey) as? Data {
            let decoder = JSONDecoder()
            if let albums = try? decoder.decode([Album].self, from: bookmarkedAlbumList) {
                currentValueSubject.send(albums)
            }
        }
    }
    
    func bookmark(_ album: Album) {
        let saved = currentValueSubject.value.contains { (_album) -> Bool in
            return _album.collectionID == album.collectionID
        }
        
        if !saved {
            add(album)
        } else {
            delete(album)
        }
    }
    
    func isBookmarked(id: Int) -> AnyPublisher<Bool, Never> {
        return currentValueSubject.map { (albums) -> Bool in
            return albums.filter{ $0.collectionID == id }.count > 0
        }.eraseToAnyPublisher()
    }
    
    func isBookmarked(id: Int) -> Bool {
        return currentValueSubject.value.filter{ $0.collectionID == id }.count > 0
    }
    
    func save(_ albums: [Album]) {
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(albums) else { return }
        userDefaults.set(encoded, forKey: storeKey)
        currentValueSubject.send(albums)
    }
    
    override func add(_ model: Album) {
        var albums = currentValueSubject.value
        albums.append(model)
        save(albums)
    }
    
    override func delete(_ model: Album) {
        let albums = currentValueSubject.value.filter{ $0.collectionID != model.collectionID }
        save(albums)
    }
    
    static let shared = AlbumStore()
}
