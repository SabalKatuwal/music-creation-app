//
//  CustomCreationShape.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/25/26.
//

import Foundation
import UIKit
import SwiftUI

class CustomCreationShape: UIView {
    
    var isSelected: Bool = false {
        didSet { setNeedsDisplay() }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 28, height: 28)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()

        // just for now we will replce, I think we shoudl add curves
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.close()
        
        let color = isSelected ? UIColor.white : UIColor(white: 1, alpha: 0.4)
        color.setFill()
        path.fill()
    }
}


struct CustomIconRepresentable: UIViewRepresentable {
    
    var isSelected: Bool
    
    func makeUIView(context: Context) -> CustomCreationShape {
        CustomCreationShape()
    }
    
    func updateUIView(_ uiView: CustomCreationShape, context: Context) {
        uiView.isSelected = isSelected
    }
}
