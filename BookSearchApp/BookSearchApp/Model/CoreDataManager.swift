import CoreData
import UIKit

class CoreDataManager {
    static let shared  = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BookSearchApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error")
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
            fetchBooks()
        } catch {
            print("데이터 저장 실패")
        }
    }
    
    func fetchBooks() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BookData")
        
        do {
            let results = try context.fetch(fetchRequest)
            
            self.cartItems = results.compactMap { BookInfo(bookData: $0) }
            
        } catch {
            print("데이터 불러오기 실패")
        }
    }
    
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
    
    func deleteBook(with isbn: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BookData")
        fetchRequest.predicate = NSPredicate(format: "isbn == %@", isbn)
        
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object as! NSManagedObject)
            }
            try context.save()
            
        } catch {
        }
    }
    
    
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error")
            }
        }
    }
    
    
    
}
