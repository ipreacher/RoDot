//
//  FreezableProtocol.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/9.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol FreezableProtocol {
  var freezableComponent: FreezableComponent { get }
  
  func setNodeIsFreezed(_ isFreezed: Bool)
  
  func componentForClass<ComponentType : GKComponent>(_ componentClass: ComponentType.Type) -> ComponentType?
}

extension FreezableProtocol {
  var freezableComponent: FreezableComponent {
    guard let freezableComponent = componentForClass(FreezableComponent.self) else {
      fatalError("A FreezableProtocol entity must have a FreezableComponent ")
    }
    return freezableComponent
  }
  
  
  func setNodeIsFreezed(_ isFreezed: Bool) {
    freezableComponent.isFreezd = isFreezed
    //If it is the Transfer entity, set the reaslted node to isFreezed.
    if let relateEnityFreezableComponent = componentForClass(TransferComponent.self)?.relatedNode.entity.component(ofType: FreezableComponent.self) {
      relateEnityFreezableComponent.isFreezd = isFreezed
    }
  }
}
