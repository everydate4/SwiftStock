//
//  NSLayoutConstraint.swift
//  SwiftStockExample
//
//  Created by Troy Shu on 3/5/17.
//  Copyright © 2017 Michael Ackley. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    public convenience init(item view1: AnyObject, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation, toItem view2: AnyObject?, attribute attr2: NSLayoutAttribute, multiplier: CGFloat, constant c: CGFloat) {
        self.init(item: view1 as Any, attribute: attr1, relatedBy: relation, toItem: view2 as Any?, attribute: attr2, multiplier: multiplier, constant: c)
    }
}
