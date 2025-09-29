//
//  CoordinatorProtocol.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 02.09.2025.
//

import UIKit

protocol CoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

class BaseCoordinator: NSObject, CoordinatorProtocol {
    private(set) var childCoordinators: [CoordinatorProtocol] = []
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    func start() {
        fatalError("start() must be implemented by subclass")
    }
    
    func store(_ coordinator: CoordinatorProtocol) {
        guard !childCoordinators.contains(where: { $0 === coordinator }) else { return }
        childCoordinators.append(coordinator)
    }
    
    func free(_ coordinator: CoordinatorProtocol) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    func freeAllChildren() {
        childCoordinators.removeAll()
    }
}
