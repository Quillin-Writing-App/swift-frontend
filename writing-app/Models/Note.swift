//
//  Note.swift
//  writing-app
//
//  Created by Otto Kunkel on 2/8/25.
//

import Foundation
import PencilKit

struct Note: Identifiable {
    let id = UUID()
    var drawing: PKDrawing
    var title: String
    var createdAt: Date
    var transform: CGAffineTransform = .identity
}

enum EditMode {
    case draw
    case erase
    case panSelect
}
