//
//  Media.swift
//  StudioController
//
//  Created by 🍕 Ian Bowler 🍕 on 10/22/15.
//  Copyright © 2015 BradzTech. All rights reserved.
//

import Foundation
class Media : NSObject {
    var name:String
    var path:String
    
    override init() {
        name = ""
        path = ""
        super.init()
    }
    init(name:String,path:String){
        self.name = name
        self.path = path
        super.init()
    }
    
}
