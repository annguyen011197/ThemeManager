import UIKit

public final class ThemeManager {
    private var targetActionStorages = NSHashTable<TargetActionStorage>.weakObjects()
    
    /// The current theme.
    public var theme: Theme? {
         didSet {
             guard theme?.name != oldValue?.name else { return }
             apply()
         }
     }
    
    public static var shared: ThemeManager = ThemeManager(defaultTheme: nil)
    
    private init(defaultTheme: Theme?) {
        self.theme = defaultTheme
    }
    
    private func apply() {
        guard let theme = self.theme else { return }
        targetActionStorages.allObjects.forEach {
            $0.applyTheme(theme)
        }
    }
    
    public func register<T: AnyObject>(target: T, action: @escaping (T) -> (Theme) -> ()) {
        var storage: TargetActionStorage
        if let s = TargetActionStorage.get(for: target) {
            storage = s
        } else {
            storage = TargetActionStorage.setup(for: target)
            targetActionStorages.add(storage)
        }

        storage.register(target: target, action: action, initialTheme: theme)
    }
}
