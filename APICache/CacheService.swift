import Foundation
/**
 Protocol  to save data in cache according to cpf, request and amount of hours cache is valid
 - Parameters
 - primary key: primary key associated
 - request: request cache
 - quantidadeDeHoras: Define amount of hours cache is valid
 */
protocol GetCacheService {
    var primaryKey: String { get }
    var request: String { get }
    var quantidadeDeHorasEmMinutos: Int? { get }
    var isError: Bool? { get set }
}

class GetCacheServiceString: GetCacheService {
    var primaryKey: String
    var request: String { "" } // Not necessary
    var quantidadeDeHorasEmMinutos: Int?
    var isError: Bool?
    
    init(pk: String, cacheDuration: Int? = EnumCache.k4H.rawValue) {
        self.primaryKey = pk
        self.quantidadeDeHorasEmMinutos = cacheDuration
    }
}

class GetCacheServiceSaquePIS: GetCacheService {
    var primaryKey: String { """
        \(conta.sistemaOrigem ?? ""):
        \(conta.siglaSureg):
        \(conta.inscricaoEmpregador):
        \(conta.nis ?? ""):
        \(conta.tipoConta?.codigo ?? 0):
        \(conta.empregado?.codigo ?? 0)
        """ }
    var request: String
    var quantidadeDeHorasEmMinutos: Int?
    var conta: Account
    var isError: Bool?
    
    init(conta: Account, request: String, cacheDuration: Int? = nil) {
        self.conta = conta
        self.request = request
        self.quantidadeDeHorasEmMinutos = cacheDuration
    }
}

struct SaveCache<U: GetCacheService, T: CacheObject> {
    var result: T
    var cacheService: U
}

struct CacheResult<T: CacheObject> {
    var result: T
    var isValid: Bool
}

/**
 Alias to save data in cache according to cpf, request, result from api and amount of hours cache is valid
 - Parameters
 - primary key: primary key user associated
 - request: request cache
 - result: Object returned from api
 - quantidadeDeHoras: Define amount of hours cache is valid
 */
typealias SaveCacheService = (primaryKey: Any, request: String, result: Any?, quantidadeDeHorasEmMinutos: Int)

/**
 Alias to get cache even if is outdated
 - Parameters
 - data: Any data returned from cache
 - isValid: mark needed to update from server
 */
typealias CacheResponse = (result: Any, isValid: Bool)

struct RequestObject<T: CacheObject> {
    
    var resource: String
    var isArray: Bool = false
    var params: [String: String]?
    var cacheService: GetCacheService
    var adapter: Adapter
    var clazz = T.self
    
    var name: String { "\(T.className) \(cacheService.primaryKey)" }
}

class BaseService: NSObject {
    
    typealias onGoingRequestFinish = ((CacheObject?, Error?) -> Void)
    
    fileprivate static var onGoingRequests = [String: [onGoingRequestFinish]]()
    
    static func handleGet<T: CacheObject>(requestObject: RequestObject<T>, completion: @escaping (T?, Error?) -> Void ) {
        
        beginRequest(requestObject: requestObject, completion)
        
        // Caso existam requisicoes em paralelo, somente uma sera realizada e outras serao notificadas da resposta
        if (onGoingRequests[requestObject.name] ?? []).count > 1 {
            return
        }
        
        let loadValidObject = T.loadValidObject(cacheService: requestObject.cacheService)
        if loadValidObject.hasCache && DevShortcut.shouldCache() {
            debugPrint("======== GET CACHE \(T.className)")
            finishRequest(requestObject: requestObject,
                          response: loadValidObject.object,
                          error: loadValidObject.error)
        } else {
            Requestor().get(forResource: requestObject.resource, parameters: requestObject.params, adapter: requestObject.adapter, clazz: T.self) { (response, error) in
                
                guard error == nil, let resp = response as? T else {
                    if let err = error as NSError? {
                        debugPrint("======== [!] GET ERROR API \(T.className)",
                            err.userInfo["NSLocalizedDescription"] ?? "",
                            err.userInfo["NSErrorFailingURLKey"] ?? "",
                            err.code,
                            "======", separator: "\n")
                        
                        // Verificacao para logout
                        let lastState = SSOService.getLastSavedAuthState()
                        
                        if ([401, 403].contains(err.code) && err.domain == "WL_AUTH") ||
                            (lastState?.isAuthorized ?? false) == false {
                            SSOService().logout()
                        }
                    } else {
                        debugPrint("======== [!] GET ERROR API \(T.className)")
                    }
                    
                    if DevShortcut.shouldSaveErrorInCache() {
                        T.saveInCache(cacheService: requestObject.cacheService, cacheObject: nil, isError: true)
                    }
                    
                    finishRequest(requestObject: requestObject,
                                  type: T.self,
                                  error: error)
                    return
                }
                
                debugPrint("======== GET API \(T.className)")
                T.saveInCache(cacheService: requestObject.cacheService, cacheObject: resp)
                finishRequest(requestObject: requestObject,
                              response: resp,
                              error: nil)
            }
        }
    }
    
    private static func beginRequest<T: CacheObject>(requestObject: RequestObject<T>, _ completion: @escaping (T?, Error?) -> Void ) {
    
        // Lidando com multiplas requisições quando há requisição em andamento
        if onGoingRequests[requestObject.name] == nil {
            onGoingRequests[requestObject.name] = [onGoingRequestFinish]()
        }
        
        onGoingRequests[requestObject.name]?.append({ cache, err in
            if let resp = cache as? T {
                completion(resp, err)
            } else {
                completion(nil, err)
            }
        })
    }
    
    private static func finishRequest<T: CacheObject>(requestObject: RequestObject<T>, response: T?, error: Error?) {
        
        // Notificando resposta a todos
        while let request = onGoingRequests[requestObject.name]?.popLast() {
            request(response, error)
        }
        
        // Limpando fila de requisicoes
        onGoingRequests[requestObject.name]?.removeAll()
    }
    
    private static func finishRequest<T: CacheObject>(requestObject: RequestObject<T>, type: T.Type, error: Error?) {
        
        // Notificando resposta a todos
        while let request = onGoingRequests[requestObject.name]?.popLast() {
            request(nil, error)
        }
        
        // Limpando fila de requisicoes
        onGoingRequests[requestObject.name]?.removeAll()
    }
}
