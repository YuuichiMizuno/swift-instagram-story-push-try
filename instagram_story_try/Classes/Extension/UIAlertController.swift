import UIKit

extension UIAlertController {

    /// (ex. ok (nothing works. only show message.))
    public static func showAttention(title: String? = nil,
                                     message: String,
                                     target: UIViewController? = nil) {
        let alert = self.getAlertOne(title: title, message: message)
        alert.presentFront(target: target)
    }
    
    /// (ex. ok (feedback works. no choice.))
    public static func showInduction(title: String? = nil,
                                     message: String,
                                     okButtonText: String? = nil,
                                     target: UIViewController? = nil,
                                     handler: (() -> Void)?) {
        let alert = self.getAlertOne(title: title, message: message, handler: handler)
        alert.presentFront(target: target)
    }
    
    public static func showCaution(error: NSError, handler: (() -> Void)? = nil) {
        var title = ""
        var message = ""
        if let reason = error.localizedFailureReason {
            title = error.localizedDescription
            message = reason
        }
        else {
            title = "エラー" // FIXME: now temp
            message = error.localizedDescription
        }
        self.showInduction(title: title, message: message, handler: handler)
    }
    
    /// (ex. yes / no)
    public static func showAlertYesOrNo(title: String? = nil,
                                        message: String,
                                        target: UIViewController? = nil,
                                        handler: (() -> Void)?) {
        let alert = self.getAlertTwo(title: title, message: message, primeHandler: handler)
        alert.presentFront(target: target)
    }
    
    /// (for two options. (ex. yes / not yet))
    public static func showAlertTwo(title: String? = nil, message: String, target: UIViewController? = nil,
                                    yesButtonText: String? = nil, noButtonText: String? = nil,
                                    handler: (() -> Void)?) {
        let alert = self.getAlertTwo(title: title, message: message,
                                     primeButtonText: yesButtonText, primeHandler: handler,
                                     secondButtonText: noButtonText)
        alert.presentFront(target: target)
    }
    
    /// (ex. yes / no (both handler))
    public static func showAlertTwoChoice(title: String? = nil, message: String, target: UIViewController? = nil,
                                          primeButtonText: String? = nil, primeHandler: @escaping (() -> Void),
                                          secondButtonText: String? = nil, secondHandler: (() -> Void)?) {
        let alert = self.getAlertTwo(title: title, message: message,
                                     primeButtonText: primeButtonText, primeHandler: primeHandler,
                                     secondButtonText: secondButtonText, secondHandler: secondHandler)
        alert.presentFront(target: target)
    }
    
    
    
    /// (for three or more options. (ex. "a" / "b" / "c" / "d" / cancel))
    public static func showAlert(title: String? = nil, message: String? = nil, target: UIViewController? = nil, actions: [UIAlertAction]) {
        let alert  = UIAlertController(title: title,  message: message, preferredStyle: .alert)
        actions.enumerated().forEach { (_, action) in
            alert.addAction(action)
        }
        alert.presentFront(target: target)
    }
    
    
    // MARK: - private
    fileprivate static func getAlertOne(title: String? = nil, message: String,
                                        okButtonText: String? = nil,
                                        handler: (() -> Void)? = nil) -> UIAlertController {
        let alert  = UIAlertController(title: title,  message: message, preferredStyle: .alert)
        let textYes = okButtonText ?? "はい" // FIXME: now temp
        let action = UIAlertAction(title: textYes, style: .destructive, handler: { action in
            if let handle = handler {
                handle()
            }
        })
        alert.addAction(action)
        return alert
    }
    
    fileprivate static func getAlertTwo(title: String? = nil, message: String,
                                              primeButtonText: String? = nil, primeHandler: (() -> Void)? = nil,
                                              secondButtonText: String? = nil, secondHandler: (() -> Void)? = nil) -> UIAlertController {
        let alert  = UIAlertController(title: title,  message: message, preferredStyle: .alert)
        // first button
        let textYes = primeButtonText ?? "はい" // FIXME: now temp
        let action = UIAlertAction(title: textYes, style: .destructive, handler: { action in
            if let handle = primeHandler {
                handle()
            }
        })
        alert.addAction(action)
        
        // second button
        let textNo = secondButtonText ?? "いいえ" // FIXME: now temp
        let refusal = UIAlertAction(title: textNo, style: .default, handler: { action in
            if let handle = secondHandler {
                handle()
            }
        })
        alert.addAction(refusal)
        
        return alert
    }
    
    
    
    fileprivate func presentFront(target: UIViewController? = nil) {
        // present
        if let targetViewController = target {
            targetViewController.present(self, animated: true, completion: nil)
        }
        else if let window = UIApplication.shared.keyWindow {
            var topViewController = window.rootViewController
            while (topViewController?.presentedViewController != nil) {
                topViewController = topViewController?.presentedViewController
            }
            if let mostTopViewController = topViewController {
                mostTopViewController.present(self, animated: true, completion: nil)
            }
        }
    }

}
