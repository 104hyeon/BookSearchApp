

import Foundation
import CoreData


extension BookData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookData> {
        return NSFetchRequest<BookData>(entityName: "BookData")
    }

    @NSManaged public var title: String?
    @NSManaged public var authors: String?
    @NSManaged public var price: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var contents: String?
    @NSManaged public var isbn: String?

}

extension BookData : Identifiable {

}
