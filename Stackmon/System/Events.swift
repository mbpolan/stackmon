//
//  Events.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import Combine
import SwiftUI

// MARK: - Protocol

protocol Notifiable {
    static var name: Notification.Name { get }
    func notify()
}

// MARK: - Events

struct RefreshViewNotification: Notifiable {
    static var name = Notification.Name("refreshView")
    
    func notify() {
        NotificationCenter.default.post(name: RefreshViewNotification.name, object: nil)
    }
    
    var publisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: RefreshViewNotification.name, object: nil)
    }
}

// MARK: - View Extension

extension View {
    func onNotification(_ name: Notification.Name, perform: @escaping() -> Void) -> some View {
        return onReceive(NotificationCenter.default.publisher(for: name)) { event in
            perform()
        }
    }
    
    func onRefresh(perform: @escaping() -> Void) -> some View {
        return onNotification(RefreshViewNotification.name, perform: perform)
    }
}
