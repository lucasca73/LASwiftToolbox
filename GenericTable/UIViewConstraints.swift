import UIKit

extension UIView {
    func setAllConstraints(on view: UIView, padding: CGFloat = 0) {
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: padding).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: padding).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding).isActive = true
    }
    
    func setConstraints(size: CGFloat) {
        self.heightAnchor.constraint(equalToConstant: size).isActive = true
        self.widthAnchor.constraint(equalToConstant: size).isActive = true
    }
}