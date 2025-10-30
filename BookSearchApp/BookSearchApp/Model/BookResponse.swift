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
    
    struct SaveBookData {
        let title: String
        let authors: String
        let price: Int
        let isbn: String
        let thumbnail: String?
        let contents: String?
    }
    func toSaveBookData() -> SaveBookData? {
        guard let title = title, let isbn, !isbn.isEmpty else { return nil }
        
        let authorsStr = authors?.joined(separator: ", ") ?? "알 수 없음"
        let priceVlue = price ?? 0
        
        return SaveBookData(title: title, authors: authorsStr, price: priceVlue, isbn: isbn, thumbnail: thumbnail, contents: contents)
    }

}

