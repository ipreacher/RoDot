//
//  RotatableRodCountComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/2.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class RotatableRodCountComponent: GKComponent {
  
  // MARK: Properties
  
  var rotatableRodCount: Int
  
  var renderComponent: RenderComponent {
    guard let renderComponent = entity?.component(ofType: RenderComponent.self) else {
      fatalError("The RotateCountComponent's entity must have a RenderComponent")
    }
    return renderComponent
  }
  
  // MARK: Initializers
  
  init(rotatableRodCount: Int) {
    self.rotatableRodCount = rotatableRodCount
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func addBubbles() {
//    var zRotateion:CGFloat = 90
//    if rotatableRodCount == 3 {
//      zRotateion = 120
//    }
//    for i in 0..<rotatableRodCount {
//      let bubble = SKSpriteNode(texture: SKTexture(imageNamed: "bubble"))
//      let angle = (CGFloat(i) * zRotateion).degreesToRadians()
//      bubble.position = CGPoint(x: sin(angle)*GameplayConfiguration.bubbleOrbitRadius, y: cos(angle)*GameplayConfiguration.bubbleOrbitRadius)
//      bubble.name = "bubble"
//      bubble.zPosition = renderComponent.node.zPosition + 10
//      renderComponent.node.addChild(bubble)
//    }
    SceneManager.sharedInstance.addBubbles(renderComponent.node, rotatableRodCount: rotatableRodCount)
  }
}
