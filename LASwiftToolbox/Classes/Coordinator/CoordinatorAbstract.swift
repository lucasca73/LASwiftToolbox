import Foundation
import UIKit

public class CoordinatorAbstract: NSObject {
    
    var children = [CoordinatorAbstract]()
    var parent: CoordinatorAbstract?
    var navigation: UINavigationController
    var root: UIViewController?
    private var fluxo: [UIViewController] {
        return navigation.viewControllers
    }
    
    var transitionManager: CoordinatorTransitionManager?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
        self.root = navigation.viewControllers.last
        super.init()
    }
    
    func start() { }
    
    func didEnd(from child: CoordinatorAbstract) {
        navigation.delegate = self
        removeChild(child)
    }
    
    func removeChild(_ child: CoordinatorAbstract) {
        if children.contains(child) {
            child.parent = nil
            children = children.filter({$0 != child})
        }
    }
    
    func startChild(_ child: CoordinatorAbstract) {
        children.append(child)
        child.parent = self
        child.start()
    }
    
    func popTo(controllerName: String, animated: Bool = true) {
        for controller in fluxo where controller.className == controllerName {
            _ = navigation.popToViewController(controller, animated: animated)
            break
        }
    }
    
    func removeCoordinatorViewsFromNavigation() {
        guard let rootVC = root else { return }
        var viewControllers = navigation.viewControllers
        guard let indexRoot = viewControllers.firstIndex(of: rootVC) else { return }
        let removeCount = viewControllers.count - indexRoot - 1
        if removeCount > 0 {
            viewControllers.removeLast(removeCount)
        }
        navigation.viewControllers = viewControllers
    }
    
    func createTransition() -> CoordinatorTransitionManager {
        return CoordinatorTransitionManager(coordinator: self, screens: controllersAboveRoot())
    }
    
    func controllersAboveRoot() -> [UIViewController] {
        
        var controllers = [UIViewController]()
        
        if let root = root {
            
            let rootIndex = fluxo.firstIndex(of: root) ?? 1
            
            for vc in fluxo {
                if fluxo.firstIndex(of: vc) ?? 0 > rootIndex {
                    controllers.append(vc)
                }
            }
        }
        
        return controllers
    }
    
    func popToRoot() {
        if fluxo.count > 0 {
            if let root = root {
                _ = navigation.popToViewController(root, animated: true)
            } else {
                _ = navigation.popToViewController(fluxo.first!, animated: false)
                _ = navigation.popViewController(animated: true)
            }
        }
    }
    
    func push(_ controller: UIViewController) {
        
        navigation.delegate = self
        navigation.interactivePopGestureRecognizer?.isEnabled = false // Desabilita o gesto de voltar
        
        setup(controller: controller)
        
        // Verificar caso tela ja esteja no fluxo
        if fluxo.map({$0.className}).contains(controller.className) {
            popTo(controllerName: controller.className)
        } else {
            navigation.pushViewController(controller, animated: true)
        }
    }
    
    func removeFromNavigation(_ controller: UIViewController) {
        var viewControllers = navigation.viewControllers
        viewControllers.removeAll(where: {$0 == controller})
        
        navigation.viewControllers = viewControllers
    }
    
    func forceNavigationPushTo(_ controller: UIViewController) {
        
        guard let rootVC = root else { return }
        var viewControllers = navigation.viewControllers
        guard let indexRoot = viewControllers.firstIndex(of: rootVC) else { return }
        let removeCount = viewControllers.count - indexRoot - 1
        if removeCount > 0 {
            viewControllers.removeLast(removeCount)
        }
        navigation.viewControllers = viewControllers
        
        push(controller)
    }
    
    func setup(controller: UIViewController) {
        // override here
    }
    
    func getInitialViewControllerFromStoryboardName(storyboardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: .main)
        return storyboard.instantiateInitialViewController() ?? UIViewController()
    }
}

extension CoordinatorAbstract: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        if root === viewController {
            parent?.didEnd(from: self)
        }
        
        if let transition = transitionManager {
            
            // Clear current transition manager
            transitionManager = nil
            
            // Adjust controllers in navigation
            let controllers = navigationController.viewControllers.filter({!transition.screens.contains($0)})
            navigationController.viewControllers = controllers
            
            if controllers.count >= 2 {
                // Get controller before the last, the last is the current new pushed controller
                root = controllers[controllers.count - 2]
            }
        }
    }
}

struct CoordinatorTransitionManager {
    var coordinator: CoordinatorAbstract?
    var screens: [UIViewController]
}
