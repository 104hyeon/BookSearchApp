import Foundation

struct BookResponse: Codable {
    let documents: [BookInfo]
}

struct BookInfo: Codable {
    let isbn: String?
    let title: String?
    let authors: [String]?
    let price: Int?
    let thumbnail: String?
    let contents: String?
    
}

