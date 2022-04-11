//
//  Sequence+Sort.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/11.
//

import Foundation

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, _ order: (T, T) -> Bool) -> [Element] {
        sorted { lhs, rhs in
            order(lhs[keyPath: keyPath], rhs[keyPath: keyPath])
        }
    }
}

