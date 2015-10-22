//
//  Media.swift
//  StudioController
//
//  Created by 🍕 Ian Bowler 🍕 on 10/22/15.
//  Copyright © 2015 BradzTech. All rights reserved.
//

import Foundation
class Media : NSObject {
    var url: NSURL
    var name: String {
        return url.lastPathComponent!
    }
    
    init(url: NSURL){
        self.url = url
        super.init()
    }
    
}
