//
//  RestrictedRotationPoint.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/2.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class RestrictedRotationPoint: RotationPoint {
  
  // Mark: Initializers
  
  init(renderNode: SKSpriteNode, rotatableRodCount: Int, rotateCount: Int?) {
    super.init(renderNode: renderNode, rotateCount: rotateCount)
    
    let rotatableRodCountComponent = RotatableRodCountComponent(rotatableRodCount: rotatableRodCount)
    addComponent(rotatableRodCountComponent)
//    rotatableRodCountComponent.addBubbles()
  }
}
