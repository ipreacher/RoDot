//
//  PointRotatingState.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/27.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class PointRotatingState: GKState {
  
  // MARK: Properties
  
  unowned var entity: RotationPoint
  
  // Initializers
  
  required init(entity: RotationPoint) {
    self.entity = entity
  }
  
  // MARK: GKState Life Cycle
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass is PointCheckingState.Type || stateClass is PointUnlockedState.Type
  }

}
