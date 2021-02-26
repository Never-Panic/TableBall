//
//  Vector2f.swift
//  Table Ball
//
//  Created by 刘坤昊 on 2021/2/13.
//

import Foundation

struct Vector2f {
    var x: Double
    var y: Double
    var center: Vector2f {
        Vector2f(x: x/2, y: y/2)
    }
    
    static func + (lhs: Vector2f, rhs: Vector2f) -> Vector2f {
        Vector2f(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: Vector2f, rhs: Vector2f) -> Vector2f {
        Vector2f(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func DistenceBewteen (_ lhs: Vector2f, _ rhs: Vector2f) -> Double {
        sqrt((lhs.x - rhs.x) * (lhs.x - rhs.x) + (lhs.y - rhs.y) * (lhs.y - rhs.y))
    }
    
    static var zero: Vector2f {
        Vector2f(x: 0, y: 0)
    }
}
