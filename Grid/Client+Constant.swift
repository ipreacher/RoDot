//
//  Client+Constant.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/4.
//  Copyright © 2016年 Nero. All rights reserved.
//

import Foundation

extension Client {
  
  
  struct Constants {
    static let Scheme = "https"
    static let Host = "rodot.me"
//    static let Host = "localhost:8080"
    static let SecretKey = ""
  }
  
  struct Methods {
    static let GetLevelDeail = "/level/detail"
    static let ShareLevel = "/level/new"
    static let LikeLevel = "/level/like"
    static let LevelPage = "/level" // expample /level/2
    static let LikeCount = "/level/likescount"
    static let LevelWin = "/level/win"
    static let GetLevelWinTimes = "/level/wintimes"
    static let LevelLose = "/level/lose"
    static let GetLevelLoseTimes = "/level/losetimes"
    
    static let GetLevelPlayInfo = "/level/levelplayinfo"
  }
  
  struct ParameterKeys {
//    static let SecretKey = "secretKey"
    static let LevelId = "levelid"
  }
  
  struct JSONBodyKeys {
    static let Nodes = "nodes"
    static let NodeName = "name"
    static let Position = "position"
    static let ZRotation = "zRotation"
    static let Type = "type"
    
    static let Level = "level"
    static let LevelId = "levelid"
    static let LevelName = "name"
    static let Likes = "likes"
    static let Date = "date"
    
    static let Result = "Result"
    
    static let LevelLikesCount = "likes"
    static let LevelWinTimes = "win"
    static let LevelLoseTimes = "lose"
  }
  
  struct JSONBodyValues {
    static let Success = "Success"
  }
  
}