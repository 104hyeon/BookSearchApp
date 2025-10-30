import CoreData
import UIKit

class CoreDataManager {
    static let shared  = CoreDataManager()
    private init() {}
    // 컨테이너 생성하기
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BookSearchApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    var cartItems: [BookInfo]?
    
    func saveBook(bookData: BookInfo.SaveBookData) {
        guard let entity = NSEntityDescription.entity(forEntityName: "BookData", in: context) else { return }
        let newBook = NSManagedObject(entity: entity, insertInto: context)
        
        newBook.setValue(bookData.title, forKey: "title")
        newBook.setValue(bookData.authors, forKey: "authors")
        newBook.setValue(bookData.price, forKey: "price")
        newBook.setValue(bookData.isbn, forKey: "isbn")
        
        do {
            try context.save()
            print("데이터 저장 성공")
        } catch {
            print("데이터 저장 실패")
        }
    }
    static func convertToBookInfo(from bookData: NSManagedObject) -> BookInfo? {
            guard let title = bookData.value(forKey: "title") as? String,
                  let authorStr = bookData.value(forKey: "authors") as? String,
                  let isbn = bookData.value(forKey: "isbn") as? String else { return nil}
            
            return BookInfo(
                isbn: isbn,
                title: title,
                authors: [authorStr],
                price: bookData.value(forKey: "price") as? Int,
                thumbnail: bookData.value(forKey: "thumbnail") as? String,
                contents: bookData.value(forKey: "contents") as? String
            )
        }
    
    // CoreData에서 가져온 데이터 변환
    func fetchBooks() -> [BookInfo] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BookData")
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { CoreDataManager.convertToBookInfo(from: $0)}
        } catch {
            return []
        }
    }
    
    // 전체 데이터 삭제
    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            context.reset()
            self.cartItems = []
        } catch {
            print("데이터 삭제 실패")
        }
    }
    // 개별 데이터 삭제
    func deleteBook(with isbn: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BookData")
        fetchRequest.predicate = NSPredicate(format: "isbn == %@", isbn)
        
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object as! NSManagedObject)
            }
            try context.save()
            
        } catch {}
    }
    // 변경 사항 저장하기
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Unresolved error")
            }
        }
    }
}
