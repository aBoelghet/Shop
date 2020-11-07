//
//  GSOrderInvoiceDottedLineView.swift
//  Shopor
//
//  Created by Ratheesh on 05/08/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSOrderInvoiceDottedLineView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
        let  path = UIBezierPath()
        
        let  p0 = CGPoint(x: self.frame.size.width/2, y: 0)
        path.move(to: p0)
        
        let  p1 = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height)
        path.addLine(to: p1)
        
        let  dashes: [ CGFloat ] = [ 2.0, 2.0 ]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)
        path.lineWidth = self.frame.size.width
        path.lineCapStyle = .butt
        UIColor.lightGray.set()
        path.stroke()
    }

}
