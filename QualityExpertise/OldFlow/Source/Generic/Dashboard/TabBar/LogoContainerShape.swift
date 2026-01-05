//
//  LogoContainerShape.swift
// ALNASR
//
//  Created by developer on 26/01/22.
//

import SwiftUI

extension LogoTabItemView {
    struct LogoContainerShape: Shape {
        //let BOTTOM_SPACE: CGFloat = 0

        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            let height: CGFloat = rect.height
            let width = rect.width
            //let centerHeight = height / 2
            let centerWidth = rect.width / 2
            let xCurvePoint: CGFloat = 37.5
            let bottomDfifference: CGFloat = 21
            let yCurvePoint = height - bottomDfifference
            
            path.move(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addCurve(to: CGPoint(x: xCurvePoint + 10, y: yCurvePoint),
                          control1: CGPoint(x: 0, y: yCurvePoint),
                          control2: CGPoint(x: xCurvePoint + 10, y: yCurvePoint)
            )
            
            path.addLine(to: CGPoint(x: (centerWidth - (height * 1.4)), y: yCurvePoint))
            path.addCurve(to: CGPoint(x: centerWidth, y: 0),
                          control1: CGPoint(x: (centerWidth - yCurvePoint), y: yCurvePoint),
                          control2: CGPoint(x: centerWidth - yCurvePoint, y: 0))
            
            path.addCurve(to: CGPoint(x: (centerWidth + (height * 1.4)), y: yCurvePoint),
                          control1: CGPoint(x: centerWidth + yCurvePoint, y: 0),
                          control2: CGPoint(x: (centerWidth + yCurvePoint), y: yCurvePoint))
            
            path.addLine(to: CGPoint(x: width - xCurvePoint - 10, y: yCurvePoint))

            path.addCurve(to: CGPoint(x: width, y: 0),
                          control1: CGPoint(x: width, y: yCurvePoint),
                          control2: CGPoint(x: width, y: 0)
            )
            
            //path.addLine(to: CGPoint(x: width, y: yCurvePoint))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            
            /*path.move(to: CGPoint(x: 0, y: sideCurveDifference))
            path.addCurve(to: CGPoint(x: height + sideCurveDifference, y: height),
                          control1: CGPoint(x: sideCurveDifference, y: height - sideCurveDifference),
                          control2: CGPoint(x: height + sideCurveDifference, y: height)
            )
            
            path.addLine(to: CGPoint(x: (centerWidth - (height * 1.4) - 10), y: height))
            path.addCurve(to: CGPoint(x: centerWidth, y: 0),
                          control1: CGPoint(x: (centerWidth - height), y: height),
                          control2: CGPoint(x: centerWidth - height + 15, y: 0))
            
            path.addCurve(to: CGPoint(x: (centerWidth + (height * 1.4) + 10), y: height),
                          control1: CGPoint(x: centerWidth + height - 15, y: 0),
                          control2: CGPoint(x: (centerWidth + 50), y: height))
            
            path.addLine(to: CGPoint(x: width - height - sideCurveDifference, y: height))

            path.addCurve(to: CGPoint(x: width, y: sideCurveDifference),
                          control1: CGPoint(x: width - height - sideCurveDifference, y: height),
                          control2: CGPoint(x: width, y: height - sideCurveDifference)
            )
            
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: sideCurveDifference))*/
            return path
        }
    }

}

