//
//  TargetActionStorage.swift
//  
//
//  Created by An Nguyen on 24/12/2023.
//

import Foundation

fileprivate var associatedKey = "ThemerTargetActionStorage"

public protocol TargetAction {
    func applyTheme(theme: Theme)
}

// The object-associated storage, which is attached to the targets (themable visual
// elements) and stores the relevant target's registered *target-actions*
// (theme handlers).
final class TargetActionStorage {
    private var targetActions: [TargetAction] = []

    static func setup(for target: Any) -> TargetActionStorage {
        let storage = TargetActionStorage()
        objc_setAssociatedObject(
            target,
            &associatedKey,
            storage,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        return storage
    }

    static func get(for target: Any) -> TargetActionStorage? {
        return objc_getAssociatedObject(target, &associatedKey).map { $0 as! TargetActionStorage }
    }

    func register<Target: AnyObject>(target: Target, action: @escaping (Target) -> (Theme) -> (), initialTheme: Theme?) {
        let ta = AnyTargetActionWrapper(target: target, action: action)
        targetActions.append(ta)
        if let initialTheme = initialTheme {
            ta.applyTheme(theme: initialTheme)
        }

    }

    func applyTheme(_ theme: Theme) {
        targetActions.forEach {
            $0.applyTheme(theme: theme)
        }
    }
}

struct AnyTargetActionWrapper<T: AnyObject>: TargetAction {
    weak var target: T?
    let action: (T) -> (Theme) -> ()
    func applyTheme(theme: Theme) {
        if let t = target {
            action(t)(theme)
        }
    }
}
