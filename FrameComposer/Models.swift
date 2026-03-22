import SwiftUI

// MARK: - Aspect Ratio
enum AspectRatio: String, CaseIterable, Identifiable {
    case threeByFour = "3:4"
    case nineBy16 = "9:16"
    
    var id: String { rawValue }
    
    var ratio: CGFloat {
        switch self {
        case .threeByFour: return 3.0 / 4.0
        case .nineBy16: return 9.0 / 16.0
        }
    }
}

// MARK: - Fibonacci Rotation
enum FibonacciRotation: String, CaseIterable, Identifiable {
    case topLeft = "↖"
    case topRight = "↗"
    case bottomRight = "↘"
    case bottomLeft = "↙"
    
    var id: String { rawValue }
    
    var degrees: Double {
        switch self {
        case .topLeft: return 0
        case .topRight: return 90
        case .bottomRight: return 180
        case .bottomLeft: return 270
        }
    }
}

// MARK: - Grid Template
enum GridTemplate: String, CaseIterable, Identifiable {
    case ruleOfThirds = "Rule of Thirds"
    case goldenRatio = "Golden Ratio"
    case diagonals = "Diagonals"
    case center = "Center"
    case fibonacci = "Fibonacci"
    case horizons = "Horizon"
    case portrait = "Portrait"
    case symmetry = "Symmetry"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .ruleOfThirds: return "grid"
        case .goldenRatio: return "perspective"
        case .diagonals: return "line.diagonal"
        case .center: return "plus.circle"
        case .fibonacci: return "arrow.clockwise.circle"
        case .horizons: return "minus"
        case .portrait: return "person.crop.rectangle"
        case .symmetry: return "rectangle.split.2x1"
        }
    }
    
    var description: String {
        switch self {
        case .ruleOfThirds: return "Classic 3x3 grid"
        case .goldenRatio: return "Ratio phi = 1.618"
        case .diagonals: return "Dynamic diagonals"
        case .center: return "Center composition"
        case .fibonacci: return "Fibonacci spiral"
        case .horizons: return "Horizon lines"
        case .portrait: return "Portrait zones"
        case .symmetry: return "Symmetry grid"
        }
    }
}
