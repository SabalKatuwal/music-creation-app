//
//  CustomCreationShape.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/25/26.
//

import UIKit
import SwiftUI

struct TwoCreationIconView: View {
    @Binding var selectedTab: Int
    var body: some View {
        ZStack {
            CustomIconRepresentable(isSelected: selectedTab == 0)
                .frame(width: 18, height: 18)
            
            CustomIconRepresentable(isSelected: selectedTab == 0)
                .frame(width: 12, height: 12)
                .offset(x: -10, y: 10)
        }
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


class CustomCreationShape: UIView {
    
    var isSelected: Bool = false {
        didSet { setNeedsDisplay() }
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
        
        let top = CGPoint(x: rect.midX, y: rect.minY)
        let right = CGPoint(x: rect.maxX, y: rect.midY)
        let bottom = CGPoint(x: rect.midX, y: rect.maxY)
        let left = CGPoint(x: rect.minX, y: rect.midY)
        
        let insetAmount: CGFloat = rect.width * 0.05
        
        path.move(to: top)
        
        path.addQuadCurve(
            to: right,
            controlPoint: CGPoint(x: rect.midX + insetAmount, y: rect.midY - insetAmount)
        )
        
        path.addQuadCurve(to: bottom, controlPoint: CGPoint(x: rect.midX + insetAmount, y: rect.midY + insetAmount)
        )
        
        path.addQuadCurve(
            to: left,
            controlPoint: CGPoint(x: rect.midX - insetAmount, y: rect.midY + insetAmount)
        )
        
        path.addQuadCurve(
            to: top,
            controlPoint: CGPoint(x: rect.midX - insetAmount, y: rect.midY - insetAmount)
        )
        
        path.close()
        
        let strokeColor = isSelected
            ? UIColor.white
            : UIColor(white: 1, alpha: 0.4)
        
        strokeColor.setStroke()
        
        path.lineWidth = 2.0
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        
        path.stroke()
    }
}



