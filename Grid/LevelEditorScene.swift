//
//  LevelEditorScene.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/18.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

enum LayerType: String {
  case nodeTypeLayer = "nodeType"
  case rotatableCountLayer = "rotatableCount"
  case clockwiseLayer = "clockwise"
  case rotateCountLayer = "rotateCount"
  
  static var allType: [LayerType] {
    return [.nodeTypeLayer, .rotatableCountLayer, .clockwiseLayer, .rotateCountLayer]
  }
}

let ShowEditSceneInstructionCountKey = "ShowEditSceneInstructionCount"

class LevelEditorScene: SKScene, SceneLayerProtocol {
  
  // MARK: Properties
  
  var typeLayerInfo = [LayerType: String]() {
    didSet {
      if let nodeType = typeLayerInfo[.nodeTypeLayer] {
        if nodeType != "point" {
          typeLayerInfo[.rotateCountLayer] = nil
          typeLayerInfo[.rotatableCountLayer] = nil
          typeLayerInfo[.clockwiseLayer] = nil
          if nodeType == "static" || nodeType == "translation"{
            for button in pointButtons {
              if button.type == nil {
                button.selectedTexture = SKTexture(imageNamed: nodeType)
              }
              button.nextNodeName = nodeType
            }
          }
          showEditLayer()
        }else {
          // select the point node
          showPointDetailComponent()
          hiddenOtherNodeType()
        }
      }
      setUpPointDetail()
    }
  }
  
  func setUpPointDetail() {
    let layerNode = overlayNode.childNode(withName: LayerType.nodeTypeLayer.rawValue)!
    let point = (layerNode.childNode(withName: "point") as! SKButtonNode)
    for node in point.children { node.removeFromParent() }
    if let _ = typeLayerInfo[.nodeTypeLayer] {
      let pointTypeName = pointButtonTypeName()
      let textureImageName = PointNodeType(nodeName: pointTypeName).textureImageName()
      point.texture = SKTexture(imageNamed: textureImageName)
      point.highlightTexture = SKTexture(imageNamed: textureImageName)
      if let rotatableCount = self.typeLayerInfo[.rotatableCountLayer] {
        SceneManager.sharedInstance.addBubbles(point, rotatableRodCount: (Int(rotatableCount)!))
      }
      if let clockwiseStr = self.typeLayerInfo[.clockwiseLayer] {
        var clockwise: Bool = true
        if clockwiseStr == "ac" { clockwise = false }
        SceneManager.sharedInstance.animationBubble(point, isClockwise: clockwise)
      }
      if let rotateCount = self.typeLayerInfo[.rotateCountLayer] {
        SceneManager.sharedInstance.addRotateCountNodes(point, rotateCount: Int(rotateCount)!)
      }
    }
  }
  
  var pointButtons = [PointButton]()
  var rodButtons = [SKButtonNode]()
  
  var transferNodes = Set<SKSpriteNode>() {
    didSet {
      let componentButton = spritesNode.childNode(withName: "componentButton") as! SKButtonNode
      componentButton.isEnabled = transferNodes.count % 2 == 0
      if transferNodes.count % 2 != 0 {
        (spritesNode.childNode(withName: "runButton") as? SKButtonNode)?.isEnabled = false
      }else {
        (spritesNode.childNode(withName: "runButton") as? SKButtonNode)?.isEnabled = isAddBall && isAddDestination
      }
//      for nodeName in transferNodesNames {
//        if GameplayConfiguration.transferTargetNames[nodeName] == nil {
//          componentButton.isEnabled = false
//          return
//        }
//      }
//      componentButton.isEnabled = true
    }
  }
  
  var isAddBall: Bool = false {
    didSet {
      (spritesNode.childNode(withName: "runButton") as? SKButtonNode)?.isEnabled = isAddBall && isAddDestination
    }
  }
  var isAddDestination: Bool = false {
    didSet {
      (spritesNode.childNode(withName: "runButton") as? SKButtonNode)?.isEnabled = isAddBall && isAddDestination
    }
  }
  
  // This property is for EditButton, to prevent execute didMoveToView twice
  var isFirstTime: Bool = true
  
  
  // MARK: Scene Life Cycle
  
  override func didMove(to view: SKView) {
    guard isFirstTime else { return }
    isFirstTime = false
    var pointNodes = [RotationPointNode]()
    var rods = [RodNode]()
    enumerateChildNodes(withName: "//*", using: { [unowned self] (node, _) -> () in
      if let node = node as? RodNode {
        rods.append(node)
      }
      if let node = node as? RotationPointNode {
        pointNodes.append(node)
      }
      if let node = node as? SKSpriteNode , node.name == "componentButton" {
        
        let componentButton = copyNode(node, toButtonType: SKButtonNode.self, selectedTextue: nil, disabledTextue: SKTexture(imageNamed: "componentButton_disabled"))
        node.removeFromParent()
        self.spritesNode.addChild(componentButton)
        
        // ComponentButton Action
        
        componentButton.actionTouchUpInside = { [unowned self] in
          SKTAudio.sharedInstance().playSoundEffect("button_click_3.wav")
          self.typeLayerInfo[.rotatableCountLayer] = nil
          self.typeLayerInfo[.rotateCountLayer] = nil
          self.typeLayerInfo[.clockwiseLayer] = nil
          self.typeLayerInfo[.nodeTypeLayer] = nil
          
          self.setAllButtonsNotHighlight()
          self.showComponetLayer()
          
        }
      }
      
      if let node = node as? SKSpriteNode , node.name == "runButton" {
        let runButton = copyNode(node, toButtonType: SKButtonNode.self, selectedTextue: nil, disabledTextue: SKTexture(imageNamed: "runButton_disabled"))
        node.removeFromParent()
        self.spritesNode.addChild(runButton)
        runButton.actionTouchUpInside = {
          SKTAudio.sharedInstance().playSoundEffect("fadeout.mp3")
          self.generateNewScene()
        }
        runButton.isEnabled = false
      }
      
    })
 
    rodButtons = rods.map{ rod in
      let rodButton = copyNode(rod, toButtonType: SKButtonNode.self, selectedTextue: SKTexture(imageNamed: "rod0"), disabledTextue: nil)
      rodButton.name = nil
      rod.removeFromParent()
      rodButton.actionTouchUpInside = {
        
        let normal = rodButton.normalSKTexture
        rodButton.normalSKTexture = rodButton.selectedTexture
        rodButton.selectedTexture = normal
        if rodButton.name == nil {
          SKTAudio.sharedInstance().playSoundEffect("button_click_3.wav")
          rodButton.name = "rod"
        }else {
          SKTAudio.sharedInstance().playSoundEffect("button_click_3.wav")
          rodButton.name = nil
        }
      }
      spritesNode.addChild(rodButton)
      return rodButton
    }
    
    pointButtons = pointNodes.map { pointNode in
      let pointButton = copyNode(pointNode, toButtonType: PointButton.self, selectedTextue: SKTexture(imageNamed: "pointnode0"), disabledTextue: nil) as! PointButton
      pointNode.removeFromParent()
      pointButton.type = nil
      pointButton.nextNodeName = "static"
      pointButton.actionTouchUpInside = {
        
        if pointButton.type == nil { // This will do when touched on the node unchecked
          SKTAudio.sharedInstance().playSoundEffect("button_click_3.wav")
          pointButton.name = pointButton.nextNodeName
          pointButton.type = PointNodeType(nodeName: pointButton.name)
          pointButton.normalSKTexture = SKTexture(imageNamed: pointButton.type!.textureImageName())
          pointButton.selectedTexture = SKTexture(imageNamed: "point_unchecked")
          pointButton.addDetail()
        }else { // This will do when touched on the node unchecked
          SKTAudio.sharedInstance().playSoundEffect("button_click_3.wav")
          pointButton.type = nil
          pointButton.name = nil
          let nextType = PointNodeType(nodeName: pointButton.nextNodeName)
          pointButton.normalSKTexture = SKTexture(imageNamed: "point_unchecked")
          pointButton.selectedTexture = SKTexture(imageNamed: nextType.textureImageName())
          pointButton.removeDetail()
        }
        
      }
      spritesNode.addChild(pointButton)
      return pointButton
    }
    
    configureOverlay()
    addBackground()
    
    addBackButton()
    addDoneButton()
    showComponetLayer()
    
    if let showInstructionCount =  UserDefaults.standard.object(forKey: ShowEditSceneInstructionCountKey) as? Int , showInstructionCount < 3 {
      addInstructionLabel()
      UserDefaults.standard.set(showInstructionCount + 1, forKey: ShowEditSceneInstructionCountKey)
    }
  }
  
  func addBackButton() {
    let backButton = SKButtonNode(imageNameNormal: "back", selected: nil)
    backButton.name = "back"
    backButton.position = CGPoint(x: xMargin + 108, y: 1950)
    backButton.actionTouchUpInside = backButtonAction
    backButton.zPosition = overlayNode.zPosition
    overlayNode.addChild(backButton)
    backButton.alpha = 0
    backButton.run(SKAction.sequence([SKAction.wait(forDuration: 0.33), SKAction.fadeIn(withDuration: 0.66)]))
  }
  
  func addBackground() {
    let background = SKSpriteNode(texture: SKTexture(imageNamed: "background"))
    background.zPosition = bgNode.zPosition
    background.anchorPoint = CGPoint.zero
    background.size = backgroundRect.size
    background.position = backgroundRect.origin
    bgNode.addChild(background)
  }
  
  func addDoneButton() {
    let doneButton = SKButtonNode(imageNameNormal: "done_button", selected: nil)
    doneButton.actionTouchUpInside = {
      for button in self.pointButtons {
        let pointTypeName = self.pointButtonTypeName()
        if button.type == nil {
          let textureImageName = PointNodeType(nodeName: pointTypeName).textureImageName()
          button.selectedTexture = SKTexture(imageNamed: textureImageName)
        }
        button.nextNodeName = pointTypeName
      }
      self.showEditLayer()
    }
    doneButton.position = CGPoint(x: 500, y: -150)
    overlayNode.childNode(withName: LayerType.rotateCountLayer.rawValue)?.addChild(doneButton)
  }
  
  func configureOverlay() {
    let overlayScece = SKScene(fileNamed: "ComponentChoose")!
    addChild(overlayScece.childNode(withName: "Overlay")!.copy() as! SKNode)
    enumerateChildNodes(withName: "/Overlay//*", using: { (node, _) -> () in
      if let node = node as? SKSpriteNode {
        let button = copyNode(node, toButtonType: SKButtonNode.self, selectedTextue: SKTexture(imageNamed: "pointnode0"), disabledTextue: nil)
        for child in node.children {
          child.removeFromParent()
          button.addChild(child)
        }
        node.parent?.addChild(button)
        node.removeFromParent()
      }
    })

    setupAllButtons()
  }
  
  
  func setupAllButtons() {
    for layer in LayerType.allType {
      setUpButtonsInLayer(layer)
    }
  }
  
  
  func setUpButtonsInLayer(_ layer: LayerType) {
    let layerNode = overlayNode.childNode(withName: layer.rawValue)!
    for node in layerNode.children {
      if let node = node as? SKButtonNode {
        
        // set the highlightTextue other way
        node.highlightTexture = SKTexture(imageNamed: "pointnode0")
        node.actionTouchUpInside = { [unowned self] in
          self.typeLayerInfo[layer] = node.name
          node.isHighlight = !node.isHighlight
          
          if !node.isHighlight {
            self.typeLayerInfo[layer] = nil
            SKTAudio.sharedInstance().playSoundEffect("button_click_3.wav")
          }else {
            SKTAudio.sharedInstance().playSoundEffect("button_click_3.wav")
          }
          
          if node.name == "point" {
            if node.isHighlight == false {
              self.hiddenPointDetailComponent()
              self.showOtherNodeType()
            }
          }
          
          for otherNode in self.overlayNode.childNode(withName: layer.rawValue)!.children {
            if otherNode != node {
              (otherNode as? SKButtonNode)?.isHighlight = false
            }
          }
        }
      }
    }
    layerNode.alpha = 0
    layerNode.run(SKAction.fadeIn(withDuration: 0.66))
  }
  
  func setAllButtonsNotHighlight() {
    for layer in LayerType.allType {
      for node in overlayNode.childNode(withName: layer.rawValue)!.children {
        if let node = node as? SKButtonNode {
          node.isHighlight = false
        }
      }
    }
  }
  
  
  func generateNewScene() {
    let scene = LevelEditPlayScene.editScene(self.rodButtons, points: self.pointButtons, ball: self.spritesNode.childNode(withName: "ball")! as! SKSpriteNode, destination: self.spritesNode.childNode(withName: "destination")! as! SKSpriteNode, transfers: [SKSpriteNode](transferNodes))
    scene?.scaleMode = self.scaleMode
    scene?.editScene = self
    self.view?.presentScene(scene)
  }
  
  
  func addInstructionLabel() {
    let label = SKLabelNode(text: "Tap the rod and dot to add or cancel.")
//    Tap the empty space to add node
    label.fontColor = UIColor.black
    label.fontSize = 50
    label.fontName = "ArialRoundedMTBold"
    label.position = CGPoint(x: size.width/2, y: size.height - 80)
    spritesNode.addChild(label)
    let fadeInAction = SKAction.fadeIn(withDuration: 0.8)
    let fadeOutActoin = SKAction.fadeOut(withDuration: 1.3)
    fadeInAction.timingMode = .easeInEaseOut
    fadeOutActoin.timingMode = .easeInEaseOut
    
    let willShowTexts = ["Tap the empty space to add node.", "After adding a ball and a target, you can run it.", "Tap the rod and dot to add or cancel."]
    var index = 0
    let runblock = SKAction.run {
      index = index % willShowTexts.count
      label.text = willShowTexts[index]
      index+=1
    }
    let action = SKAction.sequence([fadeInAction, SKAction.wait(forDuration: 3), fadeOutActoin, SKAction.wait(forDuration: 0.1), runblock])
    label.run(SKAction.repeatForever(action))
    
  }
  
  
  // MARK: Help Methods
  
  func showComponetLayer() {
    self.spritesNode.isHidden = true
    self.overlayNode.isHidden = false
    hiddenPointDetailComponent()
    showOtherNodeType()
  }
  
  func showEditLayer() {
    self.spritesNode.isHidden = false
    self.overlayNode.isHidden = true
  }
  
  func showPointDetailComponent() {
    setHiddenForPointDetailComponent(false)
  }
  
  func hiddenPointDetailComponent() {
    setHiddenForPointDetailComponent(true)
  }
  
  func setHiddenForPointDetailComponent(_ hidden: Bool) {
    for layerType in LayerType.allType where layerType != .nodeTypeLayer {
      let layerNode =  overlayNode.childNode(withName: layerType.rawValue)!
      layerNode.removeAllActions()
      if hidden {
        layerNode.run(SKAction.fadeOut(withDuration: 0.33))
      }else {
        layerNode.run(SKAction.fadeIn(withDuration: 0.33))
      }
    }
  }
  
  func hiddenOtherNodeType() {
    setHiddenForOtherNodeType(true)
  }
  
  func showOtherNodeType() {
    setHiddenForOtherNodeType(false)
  }
  
  func setHiddenForOtherNodeType(_ hidden: Bool) {
    for node in overlayNode.childNode(withName: LayerType.nodeTypeLayer.rawValue)!.children where node.name != "point" && node is SKButtonNode{
      let node = node as! SKButtonNode
      node.removeAllActions()
      if hidden {
        node.isEnabled = false
        node.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.33)]))
      }else {
        node.isEnabled = true
        node.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.33)]))
      }
//      node.hidden = hidden
    }
  }
  
  
  // MARK: Touch Event
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // In spritesNode action
    var touchPosition = touches.first!.location(in: spritesNode)
    if spritesNode.atPoint(touchPosition) == spritesNode && overlayNode.isHidden == true {
      if let nodeType = typeLayerInfo[.nodeTypeLayer] {
        // Make sure it's not the point node
        if nodeType == "ball" || nodeType == "destination" {
          
          if nodeType == "ball" && isAddBall == true { return }
          if nodeType == "destination" && isAddDestination == true { return }
          
          let button = SKButtonNode(textureNormal: SKTexture(imageNamed: nodeType), selected: nil)
          button.position = touchPosition
          button.name = nodeType
          // Ball or destination action
          button.actionTouchUpInside = { [unowned self] in
            SKTAudio.sharedInstance().playSoundEffect("button_click_3.wav")
            if nodeType == "ball" { self.isAddBall = false }
            if nodeType == "destination" { self.isAddDestination = false }
            button.removeFromParent()
          }
          spritesNode.addChild(button)
          SKTAudio.sharedInstance().playSoundEffect("button_click_3.wav")
          if nodeType == "ball" { isAddBall = true }
          if nodeType == "destination" { isAddDestination = true }
        }
        if nodeType == "transfer" {
          addTransfer(touchPosition)
        }
      }
    }
    // In overlayNode action
    touchPosition = touches.first!.location(in: overlayNode)
    if overlayNode.atPoint(touchPosition) == overlayNode && overlayNode.isHidden == false {
      for button in pointButtons {
        let pointTypeName = pointButtonTypeName()
        if button.type == nil {
          let textureImageName = PointNodeType(nodeName: pointTypeName).textureImageName()
          button.selectedTexture = SKTexture(imageNamed: textureImageName)
        }
        button.nextNodeName = pointTypeName
      }
      showEditLayer()
    }
  }
  
  func pointButtonTypeName() -> String {
    let rotatableCount = self.typeLayerInfo[.rotatableCountLayer] == nil ? "" : self.typeLayerInfo[.rotatableCountLayer]!
    let clockwise = self.typeLayerInfo[.clockwiseLayer] == nil ? "normal" : self.typeLayerInfo[.clockwiseLayer]!
    let rotateCount = self.typeLayerInfo[.rotateCountLayer] == nil ? "" : self.typeLayerInfo[.rotateCountLayer]!
    return rotatableCount + clockwise + rotateCount
  }
  
  func addTransfer(_ touchPosition: CGPoint) {
    let nodeType = "transfer"
    if transferNodes.count == 2 {
      return
    }
    let button = SKButtonNode(textureNormal: SKTexture(imageNamed: nodeType), selected: nil)
    button.position = touchPosition
    if transferNodes.count == 0 {
      button.name = nodeType + String(transferNodes.count)
    }else if transferNodes.count == 1 {
      button.name = GameplayConfiguration.transferTargetNames[transferNodes.first!.name!]
    }
    transferNodes.insert(button)
    button.actionTouchUp = { [unowned self] in
      SKTAudio.sharedInstance().playSoundEffect("button_click_3.wav")
      button.removeFromParent()
      self.typeLayerInfo[.nodeTypeLayer] = nodeType
      self.transferNodes.remove(button)
    }
    SKTAudio.sharedInstance().playSoundEffect("button_click_3.wav")
    spritesNode.addChild(button)
  }
  
  
  func backButtonAction() {
    let alertController = UIAlertController(title: "Are you sure to exit?", message: nil, preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "No", style: .cancel) { _ in }
    let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
      SKTAudio.sharedInstance().playSoundEffect("menu_back.wav")
      SceneManager.sharedInstance.backToStartScene()
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(confirmAction)
    
    SceneManager.sharedInstance.presentingController.present(alertController, animated: true, completion: nil)
  }

}



// MARK: Help function
func copyNode(_ node: SKSpriteNode, toButtonType ButtonType: SKButtonNode.Type, selectedTextue: SKTexture?, disabledTextue: SKTexture?) -> SKButtonNode {
  let button = ButtonType.init(textureNormal: node.texture, selected: selectedTextue, disabled: disabledTextue)
  button.size = node.size
  button.name = node.name
  button.position = node.position
  button.zRotation = node.zRotation
  return button
}
