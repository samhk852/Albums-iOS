//
//  AlbumDetailViewModel.swift
//  Albums
//
//  Created by sam on 15/2/2021.
//

import Foundation
import UIKit
import Combine

protocol AlbumDetailViewModelType {
    // inputs
    func start(iconSize: CGSize)
    var didBookmark: (() -> ())? { get set }
    // outputs
    var icon: ((URL) -> ())? { get set }
    var name: ((String) -> ())? { get set }
    var infos: (([(String, String)]) -> ())? { get set }
    var bookmarked: ((Bool) -> ())? { get set }
}

class AlbumDetailViewModel: AlbumDetailViewModelType {
    
    private let album: Album
    @Injected(\.albumStoreProvider) private var albumStore: AlbumStoreProtocol
    private var cancellables: Set<AnyCancellable> = Set()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()
    
    init(album: Album) {
        self.album = album
    }
    
    // inputs
    func start(iconSize: CGSize) {
        didBookmark = { [weak self] in
            self?.bookmark()
        }
        
        if let url = URL(string: album.iconUrl(width: Int(iconSize.width), height: Int(iconSize.height))) {
            icon?(url)
        }
        
        name?(album.collectionName)
        
        infos?([("Artist:", album.artistName),
                ("Genre:", album.primaryGenreName),
                ("Release Date:", dateFormatter.string(from: album.releaseDate)),
                ("Copyright:", album.copyright)])
        
        albumStore.isBookmarked(id: album.collectionID)
            .sink { [weak self] (isBookmarked) in
                self?.bookmarked?(isBookmarked)
            }
            .store(in: &cancellables)
    }
    
    var didBookmark: (() -> ())?
    
    // outputs
    var icon: ((URL) -> ())?
    var name: ((String) -> ())?
    var infos: (([(String, String)]) -> ())?
    var bookmarked: ((Bool) -> ())?
}

extension AlbumDetailViewModel {
    func bookmark() {
        albumStore.bookmark(album)
    }
}
