//
//  RodNode.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/10.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit



class RodNode: SKSpriteNode, CustomNodeEvents {

//  MARK: Property
  let MIN_MOVE_DISTANCE: CGFloat = 0
  
  // The direction of the rodNode, vertical, horizontal
//  enum Direction {
//    case vertical
//    case horizontal
//  }
  
  var pointNodes = Set<RotationPointNode>() {
    didSet {
      if pointNodes.count == 0 {
        isUserInteractionEnabled = false
      }else {
        isUserInteractionEnabled = false
      }
    }
  }
  
  var firstTouchPoint: CGPoint?
  var lastTouchPoint: CGPoint?
  var rotatingNode: RotationPointNode?
  
  var direction: HVDirection?
  
  var isRotating = false
  
  fileprivate var upOrLeftNode: RotationPointNode?
  fileprivate var downOrRightNode: RotationPointNode?
  

  
//  MARK:CustomNodeEvents methods
  func didMoveToScene() {
    physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 22, height: size.height-8))
    physicsBody!.affectedByGravity = false
    physicsBody!.isDynamic = false
    isRotating = false
    
    physicsBody!.categoryBitMask = PhysicsCategory.Rod
    physicsBody!.collisionBitMask = PhysicsCategory.Ball

  }
  
  
//MARK:  Touch events (Useless now)
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    setUpRotation(touches, withEvent: event)
  }
  
  // Set up rotation 
  // Return if has set up rotation
  func setUpRotation(_ touches: Set<UITouch>, withEvent event: UIEvent?) -> Bool {
    print("Touched RodNode's pointNodes count \(pointNodes.count)")
    
    guard pointNodes.count != 0 && touches.count == 1 else { return false }
    
    firstTouchPoint = touches.first!.location(in: self.parent!)
    // Judge the direction of pointNode reference to the rodNode
    // The jude the location of pointNode according to the rodNode
    if abs(position.x - pointNodes.first!.position.x) < pointNodes.first!.size.width {
      direction = HVDirection.vertical
      for node in pointNodes {
        if node.position.y > position.y {
          upOrLeftNode = node
        }else {
          downOrRightNode = node
        }
      }
    }else {
      direction = HVDirection.horizontal
      for node in pointNodes {
        if node.position.x < position.x {
          upOrLeftNode = node
        }else {
          downOrRightNode = node
        }
      }
    }
    return true
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
  }
  
  // Touch move event
  // Check which rotating direction of the node
  func checkRotation(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let firstTouchPoint = firstTouchPoint, let direction = direction else { return }
    if !isRotating {
      let vector = touches.first!.location(in: self.parent!) - firstTouchPoint
      if abs(vector.x) > MIN_MOVE_DISTANCE && abs(vector.y) > MIN_MOVE_DISTANCE {
        if direction == .vertical {
          if vector.y > 0 {
            upOrLeftNode?.state.enter(Rotating)
          }else {
            downOrRightNode?.state.enter(Rotating)
          }
        }else {
          if vector.x < 0 {
            upOrLeftNode?.state.enter(Rotating)
          }else {
            downOrRightNode?.state.enter(Rotating)
          }
        }
        isRotating = true
        lastTouchPoint = firstTouchPoint
        if let node = upOrLeftNode {
          if node.state.currentState! is Rotating {
            rotatingNode = node
          }
        }
        // may have to be changed
        if let node = downOrRightNode {
          if node.state.currentState! is Rotating {
            rotatingNode = node
          }
        }
      }
    }
  }
  
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//    resetRotation()
  }
  
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//    resetRotation()
  }
  
  override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
    
  }


  func rest() {
    lastTouchPoint = nil
    firstTouchPoint = nil
    upOrLeftNode = nil
    downOrRightNode = nil
    isRotating = false
  }
  
  
  func angleWith(_ lastVector: CGVector, vector: CGVector) -> CGFloat {
    let oldAngle = atan2(lastVector.dy, lastVector.dx) - π/2
    let newAngle = atan2(vector.dy, vector.dx) - π/2
    return shortestAngleBetween(oldAngle, angle2: newAngle)
  }
  
  // Update the nodes that around the rotated nodes
  func updateRelatedPointNodeState() {
    guard let rotatingNode = rotatingNode else { return }
    let tags = [(1, 0), (0, 1), (0, -1), (-1, 0)]
    let distance = max(self.size.width, self.size.height) + rotatingNode.size.width
    for tag in tags {
      let targetPosition = CGPoint(
        x: rotatingNode.position.x + CGFloat(tag.0)*distance,
        y: rotatingNode.position.y + CGFloat(tag.1)*distance)
      if let pointNode = rotatingNode.parent!.atPoint(targetPosition) as? RotationPointNode {
        pointNode.state.enter(Checking)
      }
    }
    rotatingNode.state.enter(Checking)
    // In the game scene file didSimulatePhysics I set the rotatingNode to nil
    //self.rotatingNode = nil
  }
  
}
