//
//  Album.swift
//  Albums
//
//  Created by sam on 15/2/2021.
//

import Foundation

struct Album: Codable {
    let wrapperType, collectionType: String
    let artistID, collectionID: Int
    let amgArtistID: Int?
    let artistName, collectionName, collectionCensoredName: String
    let artistViewURL, collectionViewURL: String
    let artworkUrl60, artworkUrl100: String
    let collectionPrice: Double
    let collectionExplicitness: String
    let trackCount: Int
    let copyright, country, currency: String
    let releaseDate: Date
    let primaryGenreName: String

    enum CodingKeys: String, CodingKey {
        case wrapperType, collectionType
        case artistID = "artistId"
        case collectionID = "collectionId"
        case amgArtistID = "amgArtistId"
        case artistName, collectionName, collectionCensoredName
        case artistViewURL = "artistViewUrl"
        case collectionViewURL = "collectionViewUrl"
        case artworkUrl60, artworkUrl100, collectionPrice, collectionExplicitness, trackCount, copyright, country, currency, releaseDate, primaryGenreName
    }
    
    func iconUrl(width: Int, height: Int) -> String {
        return artworkUrl100.replacingOccurrences(of: "100x100bb.jpg", with: "\(width)x\(height)bb.jpg")
    }
}
