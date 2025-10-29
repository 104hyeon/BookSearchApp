import Foundation
import CoreData

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
    
    init?(bookData: NSManagedObject) {
        guard let title = bookData.value(forKey: "title") as? String,
              let authorStr = bookData.value(forKey: "authors") as? String,
              let isbn = bookData.value(forKey: "isbn") as? String else { return nil}
        self.isbn = isbn
        self.title = title
        self.authors = [authorStr]
        self.price = bookData.value(forKey: "price") as? Int
        self.thumbnail = bookData.value(forKey: "thumbnail") as? String
        self.contents = bookData.value(forKey: "contents") as? String
    }
}

