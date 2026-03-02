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
    var withColor: Bool = false
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                CustomIconRepresentable(isSelected: selectedTab == 0, withColor: withColor)
                    .frame(width: 18, height: 18)
                
                CustomIconRepresentable(isSelected: selectedTab == 0, withColor: withColor)
                    .frame(width: 12, height: 12)
                    .offset(x: -10, y: 10)
            }
        }
    }
}

struct CustomIconRepresentable: UIViewRepresentable {
    var isSelected: Bool
    var withColor: Bool
    
    func makeUIView(context: Context) -> CustomCreationShape {
        CustomCreationShape()
    }
    
    func updateUIView(_ uiView: CustomCreationShape, context: Context) {
        uiView.isSelected = isSelected
        uiView.withColor = withColor
    }
}


class CustomCreationShape: UIView {
    
    var isSelected: Bool = false {
        didSet { setNeedsDisplay() }
    }
    
    var withColor: Bool = false {
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
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
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
        
        if withColor {
            context.saveGState()
            path.addClip()
            
            let colors = [
                UIColor(hex: "#D22FFF").cgColor,
                UIColor(hex: "#FF7904").cgColor
            ] as CFArray
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: colors,
                locations: [0.0, 1.0]
            )!
            
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: rect.minX, y: rect.minY),
                end: CGPoint(x: rect.maxX, y: rect.maxY),
                options: []
            )
        }
               
        
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



extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
