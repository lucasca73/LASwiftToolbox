import Foundation
import CoreData

class CacheObjectCoreData: NSManagedObject {
    
    // Cache constraints
    @NSManaged var primaryKey: String?
    @NSManaged var name: String?
    @NSManaged var timestamp: String?
    @NSManaged var dataExpiracao: String?
    @NSManaged var isError: Bool
    
    // Data
    @NSManaged var dataObject: Data?
    
    static func entityDescription() -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName(), in: CoredataContext.managedObjectContext)!
    }
}

typealias CacheObject = CacheProtocol & Codable & ClassNameProtocol

protocol CacheProtocol {}

extension CacheProtocol where Self: CacheObject {
    
    static func saveInCache(cacheService: GetCacheService, cacheObject: Self?, isError: Bool = false) {
        
        if DevShortcut.shouldCache() == false {
            return
        }
        
        let object = CacheObjectCoreData(entity: CacheObjectCoreData.entityDescription(), insertInto: CoredataContext.managedObjectContext)
        
        object.name = className
        object.primaryKey = cacheService.primaryKey
        object.timestamp = String.dateToString(date: Date())
        object.isError = isError
        
        let minutesToWait = isError ? EnumCache.k5M.rawValue : cacheService.quantidadeDeHorasEmMinutos
        object.dataExpiracao = String.dateToStringByAddingMinutes(date: Date(), amountOfMinutes: minutesToWait ?? 0)
        
        do {
            if let result = cacheObject {
                let json = try JSONEncoder().encode(result)
                object.dataObject = json
            } else {
                object.dataObject = nil
            }
            
            CoredataContext.saveContext()
            
        } catch {
            debugPrint("Cannot parse or save \(CacheObjectCoreData.entityName()):\(className) object!")
        }
    }
    
    static func loadValidObject(cacheService: GetCacheService) -> (object: Self?, error: Error?, hasCache: Bool) {

        if let coreDataObject = retrieveFromCache(cacheService: cacheService) {
            
            var result: Self?
            
            if let dataObject = coreDataObject.dataObject {
                result = try? JSONDecoder().decode(self, from: dataObject)
            }
            
            let isValid = isCacheValid(cacheObject: coreDataObject)
            
            if !isValid {
                deleteData(dataToDelete: [coreDataObject])
            }
            
            let error = coreDataObject.isError ? NSError.padrao : nil
            
            return (result, error, isValid)
            
        } else {
            return (nil, nil, false)
        }
    }
    
    static fileprivate func getRequest(cacheService: GetCacheService) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: CacheObjectCoreData.entityName())
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "primaryKey = %@ AND name = %@", cacheService.primaryKey, className)
            
        return request
    }
    
    static func retrieveFromCache(cacheService: GetCacheService) -> CacheObjectCoreData? {
        let context = CoredataContext.managedObjectContext
        let request = getRequest(cacheService: cacheService)
        
        do {
            let results = try context.fetch(request) as? [NSManagedObject]
                return results?.first as? CacheObjectCoreData
        } catch let error as NSError {
            print("Could not retrieve", error, error.userInfo)
            return nil
        }
    }
    
    static func isCacheValid(cacheObject: CacheObjectCoreData?) -> Bool {
        let expDate = Date.stringToDate(dateString: cacheObject?.dataExpiracao ?? "")
        
        if let date = expDate, date > Date() {
            return true
        }
        
        return false
    }
    
    static func deleteData(dataToDelete: [CacheObjectCoreData]) {
        let context = CoredataContext.managedObjectContext
        BaseDAO().deleteExpiredData(results: dataToDelete, context: context)
    }
    
    static func expireCache(cacheService: GetCacheService) {
        let request = getRequest(cacheService: cacheService)
        BaseDAO().expireCache(request: request)
    }
    
    static func getRequestAll() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: CacheObjectCoreData.entityName())
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", className)
        
        return request
    }
    
    static func expireAllCache() {
        
        // ExpireAll para objetos que sao lista
        if !(Self.className.contains("Array")) {
            [Self].expireAllCache()
        }
        
        let request = getRequestAll()
        BaseDAO().expireCache(request: request)
    }
}

extension Array: CacheProtocol & ClassNameProtocol where Element: CacheObject {
    static var className: String { "\(Element.className)Array" }
}
