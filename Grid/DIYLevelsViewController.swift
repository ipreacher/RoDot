//
//  DIYLevelsViewController.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/31.
//  Copyright © 2016年 Nero. All rights reserved.
//

import UIKit

class DIYLevelsViewController: UITableViewController {
  
  
  let CellIdentifier = "Cell"
  
  var levels = [Level]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    self.navigationController?.navigationBar.statusBarHidden = true
//    tableView.registerClass(DIYLevelTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    self.tableView.tableFooterView = UIView()
    self.levels = SceneManager.sharedInstance.fetchAllLevels()
    tableView.reloadData()
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return levels.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! DIYLevelTableViewCell
    let level = levels[indexPath.row]
    cell.levelName.text = level.name
    if indexPath.row % 2 == 1 {
      cell.backgroundColor = UIColor(red: 90/255.0, green: 164/255.0, blue: 253/255.0, alpha: 1)
      cell.levelName.textColor = UIColor.whiteColor()
    }else {
      cell.backgroundColor = UIColor.whiteColor()
      cell.levelName.textColor = UIColor.blackColor()

    }
    cell.contentView.backgroundColor = UIColor.clearColor()
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let level = levels[indexPath.row]
    let nodes: [Dictionary<String, String>] = level.nodes!.map{ node in
//      $0 as! Node
      let node = node as! Node
      return ["name": node.name!, "position": node.position!,
        "zRotation": String(node.zRotation!), "type": node.type!]
    }
    let scene = LevelEditPlayScene.editSceneFromNodesData(nodes, sceneType: .selfPlay(level.name))
    scene!.scaleMode = .AspectFill
    SceneManager.sharedInstance.presentingView.presentScene(scene)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete {
      let levelToMove = levels[indexPath.row]
      levels = levels.filter{ $0 != levelToMove }
      SceneManager.sharedInstance.managedContext.deleteObject(levelToMove)
      do {
        try SceneManager.sharedInstance.managedContext.save()
      }catch let error as NSError {
        print("Could not save: \(error)")
      }
    }
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  @IBAction func doneButton(sender: UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
